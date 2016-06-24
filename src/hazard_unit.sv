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
*   Filename:     hazard_unit.sv
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 06/14/2016
*   Description:  Hazard unit that controls the flushing and stalling of
*                 the stages of the Two Stage Pipeline 
*/

`include "hazard_unit_if.vh"
module hazard_unit
(
  hazard_unit_if.hazard_unit hazard_if
);
  import alu_types_pkg::*;
  import rv32i_types_pkg::*;
  logic dmem_access;
  logic branch_jump;

  assign dmem_access = (hazard_if.dren || hazard_if.dwen);
  assign branch_jump = hazard_if.jump || 
                        (hazard_if.branch && hazard_if.mispredict);

  assign hazard_if.npc_sel = branch_jump;
  
  assign hazard_if.pc_en = ~hazard_if.if_ex_stall  | branch_jump; 

  assign hazard_if.if_ex_flush = branch_jump;

  assign hazard_if.if_ex_stall = (dmem_access && hazard_if.d_ram_busy) ||
                                 (hazard_if.iren && hazard_if.i_ram_busy && !(dmem_access)) ||
                                  hazard_if.halt;
endmodule
