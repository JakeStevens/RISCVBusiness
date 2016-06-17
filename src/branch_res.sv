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
*   Filename:     src/branch_res.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 06/14/2016
*   Description:  Determines if a branch should be taken and outputs
*                 the target address. 
*/

`include "branch_res_if.vh"

module branch_res (
  branch_res_if.bres brif
);
  
  import rv32i_types_pkg::*;
  
  word_t offset, offset_m2;

  assign offset = $signed(imm_b);
  assign offset_m2 = offset << 1;
  assign brif.branch_addr = brif.pc + offset_m2;

  always_comb begin
    casez (brif.branch_type) 
      BEQ   : brif.branch_taken = (brif.rs1_data == brif.rs2_data);
      BNE   : brif.branch_taken = (brif.rs1_data != brif.rs2_data);
      BLT   : brif.branch_taken = ($signed(brif.rs1_data) <  $signed(brif.rs2_data));
      BGE   : brif.branch_taken = ($signed(brif.rs1_data) >= $signed(brif.rs2_data));
      BLTU  : brif.branch_taken = (brif.rs1_data < brif.rs2_data);
      BGEU  : brif.branch_taken = (brif.rs1_data >= brif.rs2_data);
      default : brif.branch_taken = 1'b0;
    endcase
  end

endmodule
