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
*   Filename:     tspp_fetch_execute_if.vh
*   
*   Created by:   Jacob R. Stevens	
*   Email:        steven69@purdue.edu
*   Date Created: 06/01/2016
*   Description:  Interface between the fetch and execute pipeline stages
*/

`ifndef TSPP_FETCH_EXECUTE_IF_VH
`define TSPP_FETCH_EXECUTE_IF_VH

interface tspp_fetch_execute_if;
  import rv32i_types_pkg::*;
 
  fetch_ex_pipeline_reg_t fetch_ex_reg;
  word_t brj_addr;

  modport fetch(
    output fetch_ex_reg,
    input brj_addr
  );

  modport execute(
    input fetch_ex_reg, 
    output brj_addr
  );

endinterface
`endif
