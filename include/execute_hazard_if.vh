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
*   Filename:     execute_hazard_if.vh
*   
*   Created by:   Jacob R. Stevens	
*   Email:        steven69@purdue.edu
*   Date Created: 06/01/2016
*   Description:  Interface between the execute stage and the hazard unit
*/

`ifndef EXECUTE_HAZARD_IF_VH
`define EXECUTE_HAZARD_IF_VH

interface execute_hazard_if;
  import rv32i_types_pkg::*;

  logic flush, stall, dwait, branch_mispredict;
  word_t branch_jump_addr;

  modport execute(
    input flush, stall,
    output dwait, branch_mispredict, branch_jump_addr
  );

  modport hazard(
    input dwait, branch_mispredict, branch_jump_addr,
    output flush, stall
  );

endinterface
`endif
