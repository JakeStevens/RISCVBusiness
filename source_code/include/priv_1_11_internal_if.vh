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
*   Filename:     priv_1_11_internal_if.vh
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 08/13/2019
*   Description:  Interface for components within the privilege block 
*/

`ifndef PRIV_1_11_INTERNAL_IF_VH
`define PRIV_1_11_INTERNAL_IF_VH

`include "component_selection_defines.vh"

interface priv_1_11_internal_if; // also labeled as prv_intern_if in most modules
  import machine_mode_types_1_11_pkg::*;
  import rv32i_types_pkg::*;

  // Signals that are not being used: clear_timer_int, timer_int, soft_int, ext_int, invalid_csr

  logic mip_rup; // interrupt has occurred or the clear timer int signal has gone high
  logic mtval_rup; // denotes any pipeline hazard
  logic mcause_rup; //denotes either an exception or interrupt fired
  logic mepc_rup; //denotes either an exception or interrupt fired
  logic mstatus_rup; // denotes either an exception or interrupt fired (same as above)
  logic clear_timer_int; // 
  logic intr; // denote whether an exception or interrupt register
  logic pipe_clear; // e_ex_stage is where you check what type of hazard unit instruction you are receiving. Simply, checking whether or not the pipeline is clear of any hazards
  logic ret; //declares whether an instruction is a ret instruction
  logic fault_insn, mal_insn, illegal_insn, fault_l, mal_l, fault_s, mal_s; // fault_insn never occurs, mal_insn only occurs when there is a bad address, illegal_insn only occurs if the actual instruction is illegal, faults are not considered, mal_l occurs for a bad address and read enable is high, mal_s occurs for a bad address and write enable is high
  logic breakpoint, env_m, timer_int, soft_int, ext_int; // breakpoint within the code, env_m is an e-call instruction
  logic insert_pc; // insert the pc either when an instruction is a ret instruction, or pipeline is clear and a proper instruction
  logic swap, clr, set; // these signals will denote whether an instruction is an r-type and its 3rd function op is equal to CSRRW, CSRRC, and CSRRS respectively
  logic valid_write, invalid_csr; // valid write occurs with an r type instruction that does not have any pipeline stalls; invalid_csr
  logic instr_retired; // instruction is done (retired) when there is a write back enable and there is a proper instruction

  // RISC-MGMT 
  logic ex_rmgmt;
  logic [$clog2(`NUM_EXTENSIONS)-1:0] ex_rmgmt_cause;

  word_t epc, mtval, priv_pc;
  word_t [3:0] xtvec, xepc_r;
  word_t wdata, rdata;

  mip_t       mip, mip_next;
  mtval_t     mtval_next;
  mcause_t    mcause, mcause_next;
  mepc_t      mepc, mepc_next;
  mstatus_t   mstatus, mstatus_next;

  mtvec_t     mtvec;
  mie_t       mie;

  csr_addr_t addr;

  modport csr (
    input mip_rup, mtval_rup, mcause_rup, mepc_rup, mstatus_rup,
      mip_next, mtval_next, mcause_next, mepc_next, mstatus_next,
      swap, clr, set, wdata, addr, valid_write, instr_retired, 
    output mtvec, mepc, mie, timer_int, mip, mcause, mstatus, clear_timer_int,
      rdata, invalid_csr, xtvec, xepc_r
  );

  modport prv_control (
    output mip_rup, mtval_rup, mcause_rup, mepc_rup, mstatus_rup,
      mip_next, mcause_next, mepc_next, mstatus_next, mtval_next, intr, 
    input mepc, mie, mip, mcause, mstatus, clear_timer_int, pipe_clear, ret,
      epc, fault_insn, mal_insn, illegal_insn, fault_l, mal_l, fault_s, mal_s,
      breakpoint, env_m, timer_int, soft_int, ext_int, mtval, ex_rmgmt, 
      ex_rmgmt_cause
  );

  modport pipe_ctrl (
    input intr, ret, pipe_clear, xtvec, xepc_r,
    output insert_pc, priv_pc
  );

  modport tb (
    output ext_int
  );

endinterface
`endif // PRIV_1_11_INTERNAL_IF_VH
