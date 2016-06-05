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
*		Filename:     fetch_hazard_if.vh
*
*		Created by:   Jacob R. Stevens	
*		Email:        steven69@purdue.edu
*		Date Created: 06/01/2016
*		Description:  Interface between the fetch pipeline stage and the hazard
*		              unit.
*/

`ifndef FETCH_HAZARD_IF_VH
`define FETCH_HAZARD_IF_VH

`include "tspp_types_pkg.vh"

interface fetch_hazard_if;
  import tspp_types_pkg::*;

  logic update_pc, flush, stall;
  word_t update_addr;

  modport fetch(
    input update_addr, update_pc, flush, stall
  );

  modport hazard(
    output update_addr, update_pc, flush, stall
  );

endinterface
`endif
