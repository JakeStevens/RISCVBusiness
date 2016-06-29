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
*   Filename:     src/alu.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 06/12/2016
*   Description:  Arithmetic Logic Unit
*                 The ALU is optimized to use the minimal
*                  amount of adders.
*/

`include "alu_if.vh"

module alu (
  alu_if.alu aluif
);
  
  import alu_types_pkg::*;
  import rv32i_types_pkg::*;

  word_t adder_result, op_a, op_b, twos_comp_b;
  logic carry_out, sign_r, sign_a, sign_b;
  logic [WORD_SIZE : 0] adder_out, op_a_ext, op_b_ext;

  //sign bits of adder result and operands
  assign sign_r = adder_out[WORD_SIZE-1];
  assign sign_a = aluif.port_a[WORD_SIZE-1];
  assign sign_b = aluif.port_b[WORD_SIZE-1];

  //assign adder operands (2's compilment b for subtraction)
  assign op_a = aluif.port_a;
  assign op_b = (aluif.aluop == ALU_ADD) ? aluif.port_b : twos_comp_b;
  assign twos_comp_b = (~aluif.port_b) + 1;

  //extend operands a and b for the adder 
  assign op_a_ext[WORD_SIZE] = (aluif.aluop == ALU_SLTU) ? 1'b0 : op_a[WORD_SIZE-1];
  assign op_b_ext[WORD_SIZE] = (aluif.aluop == ALU_SLTU) ? 1'b0 : op_b[WORD_SIZE-1];
  assign op_a_ext[WORD_SIZE-1:0] = op_a;
  assign op_b_ext[WORD_SIZE-1:0] = op_b;

  //separate the carry out and result
  assign adder_out = op_a_ext + op_b_ext;
  assign adder_result = adder_out[WORD_SIZE-1:0];
  assign carry_out = adder_out[WORD_SIZE];

  always_comb begin 
    casez (aluif.aluop)
      ALU_SLL   : aluif.port_out = aluif.port_a << aluif.port_b;
      ALU_SRL   : aluif.port_out = aluif.port_a >> aluif.port_b;
      ALU_SRA   : aluif.port_out = $signed(aluif.port_a) >>> aluif.port_b;
      ALU_AND   : aluif.port_out = aluif.port_a & aluif.port_b;
      ALU_OR    : aluif.port_out = aluif.port_a | aluif.port_b;
      ALU_XOR   : aluif.port_out = aluif.port_a ^ aluif.port_b;
      ALU_SLT   : begin
        aluif.port_out = (sign_a & !sign_b) ? 1 : 
                          ((!sign_a & sign_b) ? 0 : sign_r);
      end
      ALU_SLTU  : aluif.port_out = !carry_out;
      ALU_ADD   : aluif.port_out = adder_result;
      ALU_SUB   : aluif.port_out = adder_result;
      default   : aluif.port_out = '0;
    endcase
  end

endmodule
