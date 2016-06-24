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
*   Filename:     hazard_unit_if.vh
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 06/15/2016
*   Description:  Interface for the hazard unit of the two stage pipeline 
*/

`ifndef HAZARD_UNIT_IF_VH
`define HAZARD_UNIT_IF_VH
interface hazard_unit_if();

  import rv32i_types_pkg::word_t;
  logic pc_en, npc_sel, i_ram_busy, d_ram_busy, dren, dwen, iren;
  logic branch_taken, prediction, jump, branch, if_ex_stall;
  logic if_ex_flush, mispredict, halt;  

  modport hazard_unit (
    input i_ram_busy, d_ram_busy, dren, dwen, iren, jump,
          branch, mispredict, halt,
    output pc_en, npc_sel, if_ex_stall, if_ex_flush
  );

  modport fetch (
    input pc_en, npc_sel, if_ex_stall, if_ex_flush,
    output i_ram_busy, iren
  );

  modport execute (
    output d_ram_busy, dren, dwen, jump, branch, mispredict, halt
  );
 
endinterface
`endif
