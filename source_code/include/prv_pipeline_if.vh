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
*   Filename:     prv_pipeline_if.vh
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 08/24/2016
*   Description:  Interface connecting the priv block to the pipeline.
*                 Contains connections between modules inside the priv block. 
*                 TODO: These two functionalities should be split into two
*                 separate interfaces.
*/

`ifndef PRV_PIPELINE_IF_VH
`define PRV_PIPELINE_IF_VH

`include "component_selection_defines.vh"

interface prv_pipeline_if();
  import machine_mode_types_1_11_pkg::*;
  import rv32i_types_pkg::*;

  // exception signals
  logic fault_insn, mal_insn, illegal_insn, fault_l, mal_l, fault_s, mal_s,
        breakpoint, env_m, ret;

  // interrupt signals
  logic timer_int, soft_int, ext_int;

  // exception / interrupt control
  word_t epc, priv_pc, badaddr;
  logic insert_pc, intr, pipe_clear;
  word_t [3:0] xtvec, xepc_r;

  // csr rw
  logic       swap, clr, set;
  logic       invalid_csr, valid_write;
  csr_addr_t  addr;
  word_t      rdata, wdata;

  // performance signals
  logic wb_enable, instr;

  // RISC-MGMT 
  logic ex_rmgmt;
  logic [$clog2(`NUM_EXTENSIONS)-1:0] ex_rmgmt_cause;

  modport hazard (
    input priv_pc, insert_pc, intr,
    output pipe_clear, ret, epc, fault_insn, mal_insn, 
            illegal_insn, fault_l, mal_l, fault_s, mal_s,
            breakpoint, env_m, badaddr, wb_enable, 
            ex_rmgmt, ex_rmgmt_cause
  );

  modport pipe (
    output swap, clr, set, wdata, addr, valid_write, instr,
    input  rdata, invalid_csr
  );


  modport priv_block (
    input pipe_clear, ret, epc, fault_insn, mal_insn,
          illegal_insn, fault_l, mal_l, fault_s, mal_s,
          breakpoint, env_m, badaddr, swap, clr, set,
          wdata, addr, valid_write, wb_enable, instr,
          ex_rmgmt, ex_rmgmt_cause,
    output priv_pc, insert_pc, intr, rdata, invalid_csr
  );

endinterface

`endif //PRV_PIPELINE_IF_VH
