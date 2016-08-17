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
*   Filename:     prv_control.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 08/17/2016
*   Description:  <add description here>
*/

module prv_control (
  import rv32i_types_pkg::*;
  import machine_mode_types_pkg::*;

  // exception sources
  input logic fault_insn, mal_insn, illegal_insn, 
              fault_l, mal_l, fault_s, mal_s, 
              breakpoint, env_m,
  input word_t curr_epc,

  // interrupt sources
  input logic timer_int, 
  input prv_lvl_t timer_prv,
  input logic soft_int,
  input prv_lvl_t soft_prv,
  input logic ext_int,
  input prv_lvl_t ext_prv,

  // return signals
  input logic ret,
  input prv_lvl_t prv_ret,
  
  //signaling interrupt
  output intr, 
  output prv_lvl_t intr_prv,

  //outputs to csr 
  output logic mip_rup, mbadaddr_rup, mcause_rup, mepc_rup, mstatus_rup,
  output mip_t mip_next, mip,
  output mbadaddr_t mbadaddr_next, mbadaddr,
  output mcause_t mcause_next, mcause, 
  output mstatus_t mstatus_next, mstatus,

  //input from csr
  input mbadaddr_t mbadaddr,
  input mip_t mip,
  input mcause_t mcause,
  input mstatus_t mstatus, 
  
);

  ex_code_t ex_src;
  logic exception;
  
  int_code_t int_src;
  logic interrupt;

  always_comb begin
    interrupt = 1'b1;
    int_src = USER_SOFT_INT;

    if (timer_int) begin
      casez (timer_prv) 
        U_MODE : int_src = USER_TIMER_INT;
        S_MODE : int_src = SUPER_TIMER_INT;
        H_MODE : int_src = HYPER_TIMER_INT;
        M_MODE : int_src = MACH_TIMER_INT;
      endcase
    end
    else if (soft_int) begin
      casez (soft_prv) 
        U_MODE : int_src = USER_SOFT_INT;
        S_MODE : int_src = SUPER_SOFT_INT;
        H_MODE : int_src = HYPER_SOFT_INT;
        M_MODE : int_src = MACH_SOFT_INT;
      endcase
    end
    else if (ext_int) begin
      casez (ext_prv) 
        U_MODE : int_src = USER_EXT_INT;
        S_MODE : int_src = SUPER_EXT_INT;
        H_MODE : int_src = HYPER_EXT_INT;
        M_MODE : int_src = MACH_EXT_INT;
      endcase
    end
    else
      interrupt = 1'b0;
  end

  always_comb begin
    exception = 1'b1;
    ex_src = INSN_MAL;

    if (fault_l)
      ex_src = L_FAULT;
    else if (mal_l)
      ex_src = L_ADDR_MAL;
    else if (fault_s) 
      ex_src = S_FAULT;
    else if (mal_s) 
      ex_src = S_ADDR_MAL;
    else if (breakpoint)
      ex_src = BREAKPOINT;
    else if (env_m) 
      ex_src = ENV_CALL_M;
    else if (illegal_insn) 
      ex_src = ILLEGAL_INSN;
    else if (fault_insn)
      ex_src = INSN_FAULT;
    else if (mal_insn)
      ex_src = INSN_MAL;
    else begin
      exception = 1'b0;
  end

  //output to pipeline control
  assign intr = exception | interrupt;
  assign intr_prv = M_MODE; /*TODO: Only Machine Mode supported for now*/


endmodule
