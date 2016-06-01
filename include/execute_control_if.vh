/*
*		Copyright 2016 Purdue University
*		
*		Licensed under the Apache License, Version 2.0 (the "License");
*		you may not use this file except in compliance with the License.
*		You may obtain a copy of the License at
*		
*		    http://www.apache.org/licenses/LICENSE-2.0
*		
*		Unless required by applicable law or agreed to in writing, software
*		distributed under the License is distributed on an "AS IS" BASIS,
*		WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*		See the License for the specific language governing permissions and
*		limitations under the License.
*
*
*		Filename:			tspp_types_pkg.vh
*
*		Created by:	  Jacob R. Stevens	
*		Email:				steven69@purdue.edu
*		Date Created:	06/01/2016
*		Description:	Package containing types used in the Two Stage Pipeline
*/

`ifndef EXECUTE_CONTROL_IF_VH
`define EXECUTE_CONTROL_IF_VH

`include "tspp_types_pkg.vh"

interface execute_control_if;
  import tspp_types_pkg::*;

  logic flush, stall, dwait, branch_mispredict;
  word_t branch_jump_addr;

  modport execute(
    input flush, stall,
    output dwait, branch_mispredict, branch_jump_addr
  );

  modport control(
    input dwait, branch_mispredict, branch_jump_addr,
    output flush, stall
  );

endinterface
`endif
