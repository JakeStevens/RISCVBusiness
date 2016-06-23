/*
*   Copyright 2016 Purdue University
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
*   Filename:     fetch_stage.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 06/19/2016
*   Description:  Fetch stage for the two stage pipeline
*/

`include "fetch_execute_if.vh"
`include "hazard_unit_if.vh"
`include "predictor_pipeline_if.vh"
`include "ram_if.vh"

module fetch_stage (
  input logic CLK, nRST,
  fetch_execute_if.fetch fetch_exif,
  hazard_unit_if.fetch hazardif,
  predictor_pipeline_if.access predictif,
  ram_if.cpu iram_if
);
  import rv32i_types_pkg::*;

  parameter RESET_PC = 32'h200;

  word_t  pc, pc4, npc, instr;

  //PC logic

  always @ (posedge CLK, negedge nRST) begin
    if(~nRST) begin
      pc <= RESET_PC;
    end else if (hazardif.pc_en) begin
      pc <= npc;
    end
  end

  assign pc4 = pc + 4;
  assign predictif.current_pc = pc;
  assign npc = hazardif.npc_sel ? fetch_exif.brj_addr : 
                (predictif.predict_taken ? predictif.target_addr : pc4);

  //Instruction Access logic
  assign hazardif.iren        = 1'b1;
  assign hazardif.i_ram_busy  = iram_if.busy;
  assign iram_if.addr         = pc;
  assign iram_if.ren          = 1'b1;
  assign iram_if.wen          = 1'b0;
  assign iram_if.byte_en      = 4'h0;
  assign iram_if.wdata        = '0;
  
  endian_swapper ltb_endian (
    .word_in(iram_if.rdata),
    .word_out(instr)
  );

  //Fetch Execute Pipeline Signals
  assign fetch_exif.fetch_ex_reg.pc          = pc;
  assign fetch_exif.fetch_ex_reg.pc4         = pc4;
  assign fetch_exif.fetch_ex_reg.instr       = instr;
  assign fetch_exif.fetch_ex_reg.prediction  = predictif.predict_taken;

endmodule


