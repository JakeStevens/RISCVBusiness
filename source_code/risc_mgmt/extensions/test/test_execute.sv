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
*   Filename:     test_execute.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 02/07/2017
*   Description:  ISA extension used for RISC-MGMT testbench 
*/

`include "risc_mgmt_execute_if.vh"

module test_execute (
  input logic CLK, nRST,
  //risc mgmt connection
  risc_mgmt_execute_if.ext eif,
  //stage to stage connection
  input   test_pkg::decode_execute_t idex,
  output  test_pkg::execute_memory_t exmem
);

  import alu_types_pkg::*;

  logic stall_insn;
  logic stall_complete;
  logic [3:0] stall_count;

  assign exmem.mem_lw     = idex.mem_lw;
  assign exmem.mem_sw     = idex.mem_sw;
  assign exmem.nop        = idex.nop;
  assign exmem.mem_addr   = eif.rdata_s_0;
  assign exmem.mem_store  = eif.rdata_s_1;
  assign exmem.exception  = eif.exception;

  assign stall_complete = (stall_count == 4'hf);

  always_comb begin
    // default to NOP
    eif.exception   = 0;
    eif.busy        = 0;
    eif.reg_w       = 0;
    eif.reg_wdata   = 0;
    eif.branch_jump = 0;
    eif.br_j_addr   = 0;
    eif.alu_access  = 0;
    eif.alu_data_0  = 0;
    eif.alu_data_1  = 0;
    eif.alu_op      = aluop_t'(0);
    stall_insn      = 0;

    if          (idex.rtype) begin
      eif.reg_w = 1;
      eif.reg_wdata = eif.rdata_s_0 + eif.rdata_s_1 + {{24{1'b0}}, idex.imm};
    end else if (idex.rtype_stall) begin
      stall_insn = 1;
      eif.reg_w =  1;
      eif.busy  = ~stall_complete;
      eif.reg_wdata = eif.rdata_s_0 + eif.rdata_s_1 + {{24{1'b0}}, idex.imm};
    end else if (idex.rtype_alu) begin
      eif.reg_w = 1;
      eif.alu_access = 1;
      eif.alu_op = ALU_ADD;
      eif.alu_data_0 = eif.rdata_s_0;
      eif.alu_data_1 = eif.rdata_s_1;
      eif.reg_wdata = eif.alu_res;
    end else if (idex.br_j) begin
      eif.branch_jump = 1;
      eif.br_j_addr = eif.rdata_s_0;
    end else if (idex.exception) begin
      eif.exception = 1;
    end
  end

  // counter for stalling
  always_ff @ (posedge CLK, negedge nRST) begin
    if(~nRST) 
      stall_count <= '0;
    else if (~stall_insn)
      stall_count <= '0;
    else
      stall_count <= stall_count + 1; 
  end

endmodule
