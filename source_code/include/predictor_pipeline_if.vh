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
*   Filename:     predictor_pipeline_if.vh
*   
*   Created by:   Jacob R. Stevens	
*   Email:        steven69@purdue.edu
*   Date Created: 06/01/2016
*   Description:  Interface between the branch predictor and pipeline
*/

`ifndef PREDICTOR_PIPELINE_IF_VH
`define PREDICTOR_PIPELINE_IF_VH

interface predictor_pipeline_if;
  import rv32i_types_pkg::*;

  word_t current_pc, target_addr, update_addr;
  logic update_predictor;
  logic predict_taken, prediction, branch_result;

  modport predictor(
    input current_pc, update_predictor, prediction, branch_result, update_addr,
    output predict_taken, target_addr
  );

  modport update(
    output update_predictor, prediction, branch_result,
           update_addr
  );

  modport access(
    input predict_taken, target_addr,
    output current_pc
  );

endinterface
`endif
