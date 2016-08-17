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
*   Filename:     pipeline_control.sv
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 07/28/2016
*   Description:  Control signals for the pipeline from the exception/IRQ
*                 block 
*/

module pipeline_control
(
  input logic intr, ret, pipe_clear,
  logic [1:0] prv_intr, prv_ret,
  word_t [1:0] xtvec, xepc_r,
  output logic insert_pc,
  word_t npc,
  logic intr_out
);

assign intr_out = intr;
assign insert_pc = ret || pipe_clear;


always_comb begin
  if(intr)
    case(prv_intr)
      2'b00:  npc = xtvec[2'b00];
      2'b01:  npc = xtvec[2'b01];
      2'b10:  npc = xtvec[2'b10];
      2'b11:  npc = xtvec[2'b11]; 
    endcase
  else if (ret)
    case(prv_ret)
      2'b00:  npc = xepc_r[2'b00];
      2'b01:  npc = xepc_r[2'b01];
      2'b10:  npc = xepc_r[2'b10];
      2'b11:  npc = xepc_r[2'b11];
    endcase
  else
    npc = 32'b0;
end

endmodule
