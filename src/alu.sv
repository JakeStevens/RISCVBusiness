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
*/

`include "alu_if.vh"

module alu (
  alu_if.alu aluif
);
  
  import alu_types_pkg::*;
  import rv32i_types_pkg::*;

  always_comb begin 
    
    casez (aluif.aluop)
      ALU_SLL   : aluif.port_out = aluif.port_a << aluif.port_b;
      ALU_SRL   : aluif.port_out = aluif.port_a >> aluif.port_b;
      ALU_SRA   : aluif.port_out = $signed(aluif.port_a) >>> aluif.port_b;
      ALU_AND   : aluif.port_out = aluif.port_a & aluif.port_b;
      ALU_OR    : aluif.port_out = aluif.port_a | aluif.port_b;
      ALU_XOR   : aluif.port_out = aluif.port_a ^ aluif.port_b;
      ALU_SLT   : aluif.port_out = ($signed(aluif.port_a) < $signed(aluif.port_b));
      ALU_SLTU  : aluif.port_out = aluif.port_a < aluif.port_b;
      ALU_ADD   : aluif.port_out = aluif.port_a + aluif.port_b; 
      ALU_SUB   : aluif.port_out = aluif.port_a - aluif.port_b;
      default   : aluif.port_out = '0;
    endcase
  end

endmodule
