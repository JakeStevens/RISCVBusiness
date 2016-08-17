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
  
  // Pipeline hazard signals
  logic dmem_access;
  logic branch_jump;
  logic wait_for_imem;
  logic wait_for_dmem;

  // IRQ/Exception hazard signals
  logic ex_flush_hazard; 
  logic[1:0] pc;
  assign pc = hazard_unit.pc[3:2];
  

  assign dmem_access = (hazard_if.dren || hazard_if.dwen);
  assign branch_jump = hazard_if.jump || 
                        (hazard_if.branch && hazard_if.mispredict);
  assign wait_for_imem = hazard_if.iren & hazard_if.i_ram_busy;
  assign wait_for_dmem = dmem_access & hazard_if.d_ram_busy;  
  
  assign hazard_if.npc_sel = branch_jump;
  
  assign hazard_if.pc_en = (~wait_for_dmem&~wait_for_imem&~hazard_if.halt) |
                            branch_jump; 

  assign hazard_if.if_ex_flush = ex_flush_hazard | branch_jump |
                                 (wait_for_imem & dmem_access &
                                    ~hazard_if.d_ram_busy);

  assign hazard_if.if_ex_stall = (wait_for_dmem ||
                                 (wait_for_imem & ~dmem_access) ||
                                 hazard_if.halt) & ~ex_flush_hazard;


  assign hazard_if.mal_instr = !(pc == 2'b00 || pc == 2'b01 ||
                                  pc == 2'b10 || pc == 2'b11);
  /* Hazards due to Interrupts/Exceptions */
  assign hazard_if.priv_sel = hazard_if.insert_pc;
  assign hazard_if.pipeline_finish = hazard_if.interrupt;
  assign ex_flush_hazard = hazard_if.ex_excptn;
endmodule
