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
*   Description:  Two Stage In-Order Pipeline
*/

`include "fetch_execute_if.vh"
`include "hazard_unit_if.vh"
`include "predictor_pipeline_if.vh"
`include "generic_bus_if.vh"
`include "prv_pipeline_if.vh"
`include "risc_mgmt_if.vh"

module tspp (
  input logic CLK, nRST,
  output logic halt,
  generic_bus_if.cpu igen_bus_if,
  generic_bus_if.cpu dgen_bus_if,
  prv_pipeline_if prv_pipe_if,
  predictor_pipeline_if predict_if,
  risc_mgmt_if rm_if
);
  //interface instantiations
  fetch_execute_if      fetch_ex_if();
  hazard_unit_if        hazard_if();

  //module instantiations
  fetch_stage fetch_stage_i (.*);
  execute_stage execute_stage_i (.*);
  hazard_unit hazard_unit_i (.*);

endmodule
