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
*   Filename:     prv_ex_int_if.vh
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 08/17/2016
*   Description:  <add description here>
*/

`ifndef PRV_EX_INT_IF_VH
`define PRV_EX_INT_IF_VH

interface prv_ex_int_if;
  import machine_mode_types_pkg::*;
  import rv32i_types_pkg::*;

  logic fault_insn, mal_insn, illegal_insn,
        fault_l, mal_l, fault_s, mal_s,
        breakpoint, env_m;

  word_t curr_epc, curr_epc_p4;

  logic timer_int, soft_int, ext_int;
  prv_lvl_t timer_prv, soft_prv, ext_prv;

  logic ret;
  prv_lvl_t prv_ret;

  logic intr;
  prv_lvl_t intr_prv;

  modport prv (
    input fault_insn, mal_insn, illegal_insn, 
          fault_l, mal_l, fault_s, mal_s, 
          breakpoint, env_m, curr_epc, curr_epc_p4,
          timer_int, timer_prv, soft_int, soft_prv,
          ext_int, ext_prv, ret, prv_ret, 
    output intr, intr_prv
  );

endinterface

`endif //PRV_EX_INT_IF_VH
