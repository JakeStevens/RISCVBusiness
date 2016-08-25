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

`include "prv_pipeline_if.vh"

module pipeline_control
(
  input logic [1:0] prv_intr, prv_ret,
  prv_pipeline_if.pipe_ctrl prv_pipe_if
);
  import rv32i_types_pkg::*;
  
  assign prv_pipe_if.insert_pc = prv_pipe_if.ret || prv_pipe_if.pipe_clear;
  
  always_comb begin
    if(prv_pipe_if.intr)
      case(prv_intr)
        2'b00:  prv_pipe_if.priv_pc = prv_pipe_if.xtvec[2'b00];
        2'b01:  prv_pipe_if.priv_pc = prv_pipe_if.xtvec[2'b01];
        2'b10:  prv_pipe_if.priv_pc = prv_pipe_if.xtvec[2'b10];
        2'b11:  prv_pipe_if.priv_pc = prv_pipe_if.xtvec[2'b11]; 
      endcase
    else if (prv_pipe_if.ret)
      case(prv_ret)
        2'b00:  prv_pipe_if.priv_pc = prv_pipe_if.xepc_r[2'b00];
        2'b01:  prv_pipe_if.priv_pc = prv_pipe_if.xepc_r[2'b01];
        2'b10:  prv_pipe_if.priv_pc = prv_pipe_if.xepc_r[2'b10];
        2'b11:  prv_pipe_if.priv_pc = prv_pipe_if.xepc_r[2'b11];
      endcase
    else
      prv_pipe_if.priv_pc = 32'b0;
  end

endmodule
