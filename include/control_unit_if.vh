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
*   Filename:     control_unit_if.vh
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 06/07/2016
*   Description:  Interface between the control unit and various parts of
*                 the two stage pipeline
*/

`ifndef CONTROL_UNIT_IF_VH
`define CONTROL_UNIT_IF_VH

interface control_unit_if;
  import alu_types_pkg::*;
  import rv32i_types_pkg::*;

  logic w_en, dwen, dren, j_sel, branch, jump, ex_pc_sel, imm_shamt_sel;
  aluop_t alu_op;
  logic [1:0] alu_a_sel, alu_b_sel, w_sel;
  logic [3:0] byte_en;
  logic [4:0] rd, shamt;
  logic [6:0] opcode;
  logic [11:0] imm_I, imm_S, imm_UJ;
  logic [12:0] imm_SB;
  word_t instr, imm_U;
  load_t load_type;
  branch_t branch_type;

  modport control_unit(
    input instr,
    output w_en, dwen, dren, j_sel, branch, jump, ex_pc_sel, alu_a_sel,
    alu_b_sel, w_sel, byte_en, load_type, branch_type,
    imm_I, imm_S, imm_SB, imm_UJ, imm_U, imm_shamt_sel, alu_op
  );

endinterface
`endif

