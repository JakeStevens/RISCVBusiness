/*
*   Copyright 2019 Purdue University
*   
*   Licensed under the Apache License, Version 2.0 (the "License");
*   you may not use this file except in compliance with the License.
*   You may obtain a copy of the License at
*   
*       http://www.apache.org/licenses/LICENSE-2.0
*   
*   Unless required by applicable law or agreed to in writing, software
*   distributed under the License is distributed on an "AS IS" BASIS,
*   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*   See the License for the specific language governing permissions and
*   limitations under the License.
*
*
*   Filename:     sparce_sasa_table.sv
*
*   Created by:   Vadim V. Nikiforov 
*   Email:        vnikifor@purdue.edu
*   Date Created: 04/6/2019
*   Description:  The file containing the SASA table
*/

`include "sparce_internal_if.vh"

parameter SASA_ENTRIES = 16;
parameter SASA_SETS = 4;
parameter SASA_ADDR = 'h1000;

//  modport sasa_table (
//    output sasa_rs1, sasa_rs2, insts_to_skip, preceding_pc, condition, valid,
//    input  pc, sasa_addr, sasa_data, sasa_wen
//  );

// struct for each entry in the SASA table
typedef struct packed {
  logic [1:0]  usage;
  logic        valid;
  logic [13:0] tag;
  logic [4:0]  rs1;
  logic [4:0]  rs2;
  sasa_cond_t  sasa_cond;
  logic [4:0]  insts_to_skip;
} sasa_entry_t;

// struct for the data read from memory
typedef struct packed {
  logic [15:0] prev_pc;
  logic [4:0]  rs1;
  logic [4:0]  rs2;
  sasa_cond_t  sasa_cond;
  logic [4:0]  insts_to_skip;
} sasa_input_t;


module sparce_sasa_table(input logic CLK, nRST, sparce_internal_if.sasa_table sasa_if);

  sasa_entry_t [SASA_SETS-1:0][(SASA_ENTRIES/SASA_SETS)-1:0] sasa_entries;
  sasa_input_t input_data;

  logic [1:0] input_idx;
  logic [1:0] pc_idx;
  logic [13:0] pc_tag;
  logic sasa_match;

  logic [SASA_SETS-1:0] sasa_hits;

  // wiring for indexing of the cache arrays
  assign input_idx = input_data.prev_pc[1:0];
  assign pc_idx = sasa_if.pc[3:2]; // ignore byte addressed aspect
  assign pc_tag = sasa_if.pc[17:4];
  assign sasa_match = sasa_if.sasa_enable && sasa_if.sasa_wen && (sasa_if.sasa_addr == SASA_ADDR);

  
  always_comb begin : sasa_input_conversion
    input_data.prev_pc       = sasa_if.sasa_data[31:16];
    input_data.rs1           = sasa_if.sasa_data[15:11];
    input_data.rs2           = sasa_if.sasa_data[10:6];
    input_data.sasa_cond     = sasa_cond_t'(sasa_if.sasa_data[5]);
    input_data.insts_to_skip = sasa_if.sasa_data[4:0];
  end

  always_ff @(posedge CLK, negedge nRST) begin : sasa_table_entries
    if (!nRST) begin
      // for loops just to set different usage values per entry
      for(int i = 0; i < SASA_SETS; i++) begin
        for(int j = 0; j < SASA_ENTRIES/SASA_SETS; j++) begin
          // set default usage values to 0, 1, 2, 3 for LRU
          sasa_entries[i][j].usage <= 3-i;
          sasa_entries[i][j].valid <= 0;
          sasa_entries[i][j].tag <= '0;
          sasa_entries[i][j].rs1 <= '0;
          sasa_entries[i][j].rs2 <= '0;
          sasa_entries[i][j].sasa_cond <= SASA_COND_OR;
          sasa_entries[i][j].insts_to_skip <= '0;
        end
      end
    end else begin
      sasa_entries <= sasa_entries;
      // If the software is attempting to write to the SASA table, write in
      // the data and then update the LRU usage
      if(sasa_match) begin
        for (int i = 0; i < SASA_SETS; i++) begin
          if (sasa_entries[i][input_idx].usage == '1) begin
            sasa_entries[i][input_idx].valid <= 1;
            sasa_entries[i][input_idx].tag <= input_data.prev_pc[15:2];
            sasa_entries[i][input_idx].rs1 <= input_data.rs1;
            sasa_entries[i][input_idx].rs2 <= input_data.rs2;
            sasa_entries[i][input_idx].sasa_cond <= input_data.sasa_cond;
            sasa_entries[i][input_idx].insts_to_skip <= input_data.insts_to_skip;
          end
          sasa_entries[i][input_idx].usage <= sasa_entries[i][input_idx].usage + 1;
        end
      // If the PC matches in the SASA table, update the LRU usage
      end else if (sasa_hits != 0) begin
        for (int i = 0; i < SASA_SETS; i++) begin
          if(sasa_entries[i][pc_idx].usage < sasa_entries[sasa_hits][pc_idx].usage) 
            sasa_entries[i][pc_idx].usage <= sasa_entries[i][pc_idx].usage + 1;
          else if (i == sasa_hits)
            sasa_entries[i][pc_idx].usage <= '0;
        end
      end
    end
  end

  always_comb begin : sasa_outputs
    sasa_if.sasa_rs1 = '0;
    sasa_if.sasa_rs2 = '0;
    sasa_if.insts_to_skip = '0;
    sasa_if.preceding_pc = sasa_if.pc;
    sasa_if.condition = SASA_COND_OR;
    sasa_if.valid = 1'b0;
    sasa_hits = '0;
    for (int i = 0; i < SASA_SETS; i++) begin
      if (sasa_entries[i][pc_idx].valid && sasa_entries[i][pc_idx] == pc_tag) begin
        sasa_hits[i]          = 1'b1;
        sasa_if.valid         = 1'b1;
        sasa_if.sasa_rs1      = sasa_entries[i][pc_idx].rs1;
        sasa_if.sasa_rs2      = sasa_entries[i][pc_idx].rs2;
        sasa_if.condition     = sasa_entries[i][pc_idx].sasa_cond;
        sasa_if.insts_to_skip = sasa_entries[i][pc_idx].insts_to_skip;
      end
    end
  end

endmodule

