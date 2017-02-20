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
*   Filename:     rv32m_execute.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 02/07/2017
*   Description:  Execute stage for standard RV32M 
*/

`include "risc_mgmt_execute_if.vh"

module rv32m_execute (
  input logic CLK, nRST,
  //risc mgmt connection
  risc_mgmt_execute_if.ext eif,
  //stage to stage connection
  input  rv32m_pkg::decode_execute_t idex,
  output rv32m_pkg::execute_memory_t exmem
);

  import rv32m_pkg::*;
  import rv32i_types_pkg::*;

  /* Static assignments */

  assign eif.exception = 1'b0;
  assign eif.reg_w = 1'b1;
  assign eif.branch_jump = 1'b0;

  /* MULTIPLICATION */

  // operand saver
  word_t op_a_save, op_b_save;
  logic [1:0] is_signed_save, is_signed_curr;
  logic operand_diff;

  // multiplier signals
  word_t  multiplicand, multiplier;
  logic [(WORD_SIZE*2)-1:0] product;
  logic [1:0] is_signed;
  logic mul_start, mul_finished;

  // Module instantiations
  shift_add_multiplier #(.N(WORD_SIZE)) mult_i (
    .multiplicand(multiplicand),
    .multiplier(mutliplier),
    .product(product),
    .is_signed(is_signed),
    .start(mul_start),
    .finished(mul_finished)
  );

  // Signal Assignments
  assign mul_start    = operand_diff && idex.mul;
  assign is_signed    = operand_diff ? is_signed_curr : is_signed_save;
  assign multiplicand = operand_diff ? eif.rdata_s_0 : op_a_save;
  assign multiplier   = operand_diff ? eif.rdata_s_1 : op_b_save;
  assign is_signed = idex.usign_usign ? 2'b00 : (
                     idex.sign_sign ? 2'b11 : 2'b10);
 
  // operand saver to detect a new multiplication request

  assign operand_diff = ((op_a_save != eif.rdata_s_0) || 
                        (op_b_save != eif.rdata_s_1) ||
                        (is_signed_save != is_signed_curr)) &&
                        idex.start;

  always_ff @ (posedge CLK, negedge nRST) begin
    if(~nRST) begin
      op_a_save       <= '0;
      op_b_save       <= '0;
      is_signed_save  <= '0; 
    end
    if (operand_diff) begin
      op_a_save       <= eif.rdata_s_0;
      op_b_save       <= eif.rdata_s_1;
      is_signed_save  <= is_signed;
    end
  end


  always_comb begin
    casez ({idex.mul, idex.div, idex.mul})
      3'b1?? : begin
        eif.busy      = ~mul_finished;
        eif.reg_wdata = idex.lower_word ? product[WORD_SIZE-1:0] : product[(WORD_SIZE*2)-1 : WORD_SIZE];
      end
      3'b01? : begin //TODO : DIV
        eif.busy = 1'b0;
        eif.reg_wdata = 32'hBAD1_BAD1;
      end
      3'b001 : begin //TODO : REM
        eif.busy = 1'b0;
        eif.reg_wdata = 32'hBAD2_BAD2;
      end
      default : begin
        eif.busy = 1'b0;
        eif.reg_wdata = 32'hBAD3_BAD3;
      end
    endcase
  end


endmodule
