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
  branch_res_if.bres br_if
);
  
  import rv32i_types_pkg::*;
  
  word_t offset;

  assign offset = $signed(br_if.imm_sb);
  assign br_if.branch_addr = br_if.pc + offset;

  always_comb begin
    casez (br_if.branch_type) 
      BEQ   : br_if.branch_taken = (br_if.rs1_data == br_if.rs2_data);
      BNE   : br_if.branch_taken = (br_if.rs1_data != br_if.rs2_data);
      BLT   : br_if.branch_taken = ($signed(br_if.rs1_data) <  $signed(br_if.rs2_data));
      BGE   : br_if.branch_taken = ($signed(br_if.rs1_data) >= $signed(br_if.rs2_data));
      BLTU  : br_if.branch_taken = (br_if.rs1_data < br_if.rs2_data);
      BGEU  : br_if.branch_taken = (br_if.rs1_data >= br_if.rs2_data);
      default : br_if.branch_taken = 1'b0;
    endcase
  end

endmodule
