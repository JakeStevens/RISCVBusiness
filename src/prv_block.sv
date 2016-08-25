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
*   Filename:     prv_block.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 08/24/2016
*   Description:  <add description here>
*/

`include "csr_prv_if.vh"
`include "prv_ex_int_if.vh"
`include "prv_pipeline_if.vh"

module prv_block (
  input logic CLK, nRST,
  prv_pipeline_if prv_pipe_if
);
  csr_prv_if    csr_pr_if();
  prv_ex_int_if ex_int_if();
  
  csr_rfile csr_rfile_i(.*);
  prv_control prv_control_i(.*);

  assign prv_pipe_if.soft_int = 1'b0;
  //TODO: PIC (Programmable Interrupt Controller) 
  assign prv_pipe_if.ext_int =  1'b0;
  
endmodule
