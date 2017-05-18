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
*   Filename:     priv_1_7_block.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 08/24/2016
*   Description:  Top level block for the priv logic version 1.7 
*/

`include "prv_pipeline_if.vh"
`include "priv_1_7_internal_if.vh"

module priv_1_7_block (
  input logic CLK, nRST,
  prv_pipeline_if.priv_block prv_pipe_if
);
  priv_1_7_internal_if prv_intern_if();

  logic [1:0] prv_intr, prv_ret;
  
  priv_1_7_csr_rfile csr_rfile_i(.*, .prv_intern_if(prv_intern_if));
  priv_1_7_control prv_control_i(.*, .prv_intern_if(prv_intern_if));
  priv_1_7_pipeline_control pipeline_control_i(.*, .prv_intern_if(prv_intern_if));

  //Machine Mode Only
  assign prv_intr = 2'b11;
  assign prv_ret  = 2'b11;

  assign prv_intern_if.soft_int = 1'b0;
  //TODO: PIC (Programmable Interrupt Controller) 
  assign prv_intern_if.ext_int =  1'b0;

  // Assign inputs to the prv_block to the corresponding internal signals
  assign prv_intern_if.pipe_clear   = prv_pipe_if.pipe_clear;
  assign prv_intern_if.ret          = prv_pipe_if.ret;
  assign prv_intern_if.epc          = prv_pipe_if.epc;
  assign prv_intern_if.fault_insn   = prv_pipe_if.fault_insn;
  assign prv_intern_if.illegal_insn = prv_pipe_if.illegal_insn;
  assign prv_intern_if.fault_l      = prv_pipe_if.fault_l;
  assign prv_intern_if.mal_l        = prv_pipe_if.mal_l;
  assign prv_intern_if.fault_s      = prv_pipe_if.fault_s;
  assign prv_intern_if.mal_s        = prv_pipe_if.mal_s;
  assign prv_intern_if.breakpoint   = prv_pipe_if.breakpoint;
  assign prv_intern_if.env_m        = prv_pipe_if.env_m;
  assign prv_intern_if.badaddr      = prv_pipe_if.badaddr;
  assign prv_intern_if.swap         = prv_pipe_if.swap;
  assign prv_intern_if.clr          = prv_pipe_if.clr;
  assign prv_intern_if.set          = prv_pipe_if.set;
  assign prv_intern_if.wdata        = prv_pipe_if.wdata;
  assign prv_intern_if.addr         = prv_pipe_if.addr;
  assign prv_intern_if.valid_write  = prv_pipe_if.valid_write;
  assign prv_intern_if.instr_retired= prv_pipe_if.wb_enable & prv_pipe_if.instr;

  assign prv_intern_if.ex_rmgmt = prv_pipe_if.ex_rmgmt;
  assign prv_intern_if.ex_rmgmt_cause = prv_pipe_if.ex_rmgmt_cause;

  // Assign outputs from internal signals to the outputs of the priv block
  assign prv_pipe_if.priv_pc     = prv_intern_if.priv_pc;
  assign prv_pipe_if.insert_pc   = prv_intern_if.insert_pc;
  assign prv_pipe_if.intr        = prv_intern_if.intr;
  assign prv_pipe_if.rdata       = prv_intern_if.rdata;
  assign prv_pipe_if.invalid_csr = prv_intern_if.invalid_csr;
  
endmodule
