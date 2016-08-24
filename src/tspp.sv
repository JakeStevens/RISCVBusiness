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
*   Filename:     tspp.sv
*   
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 06/01/2016
*   Description:  Two Stage Pipeline
*/

`include "fetch_execute_if.vh"
`include "hazard_unit_if.vh"
`include "predictor_pipeline_if.vh"
`include "ram_if.vh"
`include "csr_pipe_if.vh"
`include "csr_prv_if.vh"
`include "prv_ex_int_if.vh"

module tspp (
  input logic CLK, nRST,
  output logic halt,
  ram_if.cpu iram_if,
  ram_if.cpu dram_if
);

  //interface instantiations
  fetch_execute_if      fetch_ex_if();
  predictor_pipeline_if predict_if();
  hazard_unit_if        hazard_if();
  csr_pipe_if           csr_pi_if();
  csr_prv_if            csr_pr_if();
  prv_ex_int_if         ex_int_if();

  //module instantiations
  fetch_stage fetch_stage_i (.*);
  execute_stage execute_stage_i (.*);
  hazard_unit hazard_unit_i (.*);
  branch_predictor branch_predictor_i (.*);
  csr_rfile csr_rfile_i (.*);
  prv_control prv_control_i(.*); 

endmodule
