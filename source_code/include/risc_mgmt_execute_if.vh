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
*   Filename:     risc_mgmt_execute_if.vh
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 02/08/2017
*   Description:  <add description here>
*/

`ifndef RISC_MGMT_EXECUTE_IF_VH
`define RISC_MGMT_EXECUTE_IF_VH

interface risc_mgmt_execute_if ();
  import rv32i_types_pkg::*;
  import alu_types_pkg::*;

  //general execute stage signals
  logic exception, busy, reg_w;
  word_t rdata_s_0, rdata_s_1, reg_wdata;

  //branch/jump signals
  logic branch_jump;
  word_t br_j_addr;

  //ALU access signals
  logic alu_access;
  word_t alu_data_0, alu_data_1, alu_res;
  aluop_t alu_op;

  modport rmgmt (
    input exception, busy, reg_w, reg_wdata, branch_jump, br_j_addr,
    alu_access, alu_data_0, alu_data_1, alu_op,
    output rdata_s_0, rdata_s_1, alu_res
  );

  modport ext (    
    input rdata_s_0, rdata_s_1, alu_res,
    output exception, busy, reg_w, reg_wdata, branch_jump, br_j_addr,
    alu_access, alu_data_0, alu_data_1, alu_op
  );  

endinterface

`endif //RISC_MGMT_EXECUTE_IF_VH
