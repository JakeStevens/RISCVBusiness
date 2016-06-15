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
*   Filename:     src/rv32i_reg_file.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 06/14/2016
*   Description:   Integer Register File.  Register 0 will always output 0.
*/

`include "rv32i_reg_file_if.vh"

module rv32i_reg_file (
  input CLK, nRST,
  rv32i_reg_file_if.rf rfif
);

  import rv32i_types_pkg::*;

  parameter NUM_REGS = 32;

  word_t  registers [NUM_REGS-1:0];

  always_ff @ (posedge CLK, negedge nRST) begin
    if (~nRST) begin
      registers <= '{default:'0};
    end else if (rfif.wen) begin
      registers[rfif.rd] <= rfif.w_data;
    end
  end 

  assign rfif.rs1_data = (!rfif.rs1) ? '0 : registers[rfif.rs1];
  assign rfif.rs2_data = (!rfif.rs2) ? '0 : registers[rfif.rs2];

endmodule
