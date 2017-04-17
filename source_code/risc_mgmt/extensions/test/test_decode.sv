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
*   Filename:     test_decode.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 02/07/2017
*   Description:  ISA extension used for RISC-MGMT testbench
*/

`include "risc_mgmt_decode_if.vh"

module test_decode (
  input logic CLK, nRST,
  //risc mgmt connection
  risc_mgmt_decode_if.ext dif,
  //stage to stage connection
  output test_pkg::decode_execute_t idex
);

  parameter OPCODE = 7'b000_1011;
  
  import test_pkg::*;

  test_insn_t insn;
  
  assign insn = dif.insn;

  assign dif.insn_claim = (OPCODE == insn.opcode); 
  assign dif.rsel_s_0   = insn.rs_0;
  assign dif.rsel_s_1   = insn.rs_1;
  assign dif.rsel_d     = insn.rs_d;

  /*  decode execute connection */
  assign idex.rtype       = (insn.funct == RTYPE);
  assign idex.rtype_stall = (insn.funct == RTYPE_STALL_5);
  assign idex.br_j        = (insn.funct == BR_J);
  assign idex.mem_lw      = (insn.funct == MEM_LOAD);
  assign idex.mem_sw      = (insn.funct == MEM_STORE);
  assign idex.exception   = (insn.funct == EXCEPTION);
  assign idex.nop         = (insn.funct == NOP);
  assign idex.imm         = insn.imm;

endmodule
