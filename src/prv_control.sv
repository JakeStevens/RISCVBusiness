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
*   Description:  Main control for the priv isa block 
*/

`include "prv_ex_int_if.vh"
`include "csr_prv_if.vh"

module prv_control (
  prv_ext_int_if.prv  ext_int_if,
  csr_prv_if.prv      csr_if
);
  import rv32i_types_pkg::*;
  import machine_mode_types_pkg::*;

  ex_code_t ex_src;
  logic exception;
  
  int_code_t intr_src;
  logic interrupt;

  always_comb begin
    interrupt = 1'b1;
    intr_src = USER_SOFT_INT;

    if (ext_int_if.timer_int) begin
      casez (ext_int_if.timer_prv) 
        U_MODE : intr_src = USER_TIMER_INT;
        S_MODE : intr_src = SUPER_TIMER_INT;
        H_MODE : intr_src = HYPER_TIMER_INT;
        M_MODE : intr_src = MACH_TIMER_INT;
      endcase
    end
    else if (ext_int_if.soft_int) begin
      casez (ext_int_if.soft_prv) 
        U_MODE : intr_src = USER_SOFT_INT;
        S_MODE : intr_src = SUPER_SOFT_INT;
        H_MODE : intr_src = HYPER_SOFT_INT;
        M_MODE : intr_src = MACH_SOFT_INT;
      endcase
    end
    else if (ext_int_if.ext_int) begin
      casez (ext_int_if.ext_prv) 
        U_MODE : intr_src = USER_EXT_INT;
        S_MODE : intr_src = SUPER_EXT_INT;
        H_MODE : intr_src = HYPER_EXT_INT;
        M_MODE : intr_src = MACH_EXT_INT;
      endcase
    end
    else
      interrupt = 1'b0;
  end

  assign csr_if.mip_rup = interrupt;
  always_comb begin
    csr_if.mip_next = csr_if.mip;
    if (ext_int_if.timer_int) csr_if.mip_next.mtip = 1'b1;
    if (ext_int_if.soft_int) csr_if.mip_next.msip = 1'b1;
    if (ext_int_if.ext_int) csr_if.mip_next.meip = 1'b1;
  end

  always_comb begin
    exception = 1'b1;
    ex_src = INSN_MAL;

    if (ext_int_if.fault_l)
      ex_src = L_FAULT;
    else if (ext_int_if.mal_l)
      ex_src = L_ADDR_MAL;
    else if (ext_int_if.fault_s) 
      ex_src = S_FAULT;
    else if (ext_int_if.mal_s) 
      ex_src = S_ADDR_MAL;
    else if (ext_int_if.breakpoint)
      ex_src = BREAKPOINT;
    else if (ext_int_if.env_m) 
      ex_src = ENV_CALL_M;
    else if (ext_int_if.illegal_insn) 
      ex_src = ILLEGAL_INSN;
    else if (ext_int_if.fault_insn)
      ex_src = INSN_FAULT;
    else if (ext_int_if.mal_insn)
      ex_src = INSN_MAL;
    else 
      exception = 1'b0;
  end

  //output to pipeline control
  assign ex_int_if.intr = exception | (csr_if.mstatus.mie &  ((csr_if.mie.mtie & csr_if.mip.mtip) | 
                                                              (csr_if.mie.msie & csr_if.mip.msip) |
                                                              (csr_if.mie.meie & csr_if.mip.meip)));
  assign ex_int_if.intr_prv = M_MODE;
 
  // Register Updates on Interrupt/Exception
  assign csr_prv_if.mcause_rup = ex_int_if.intr;
  assign csr_prv_if.mcause_next.interrupt = ~exception;
  assign csr_prv_if.mcause_next.cause = exception ? ex_src : intr_src;

  assign csr_prv_if.mstatus_rup = ex_int_if.intr;

  always_comb begin
    if (ex_int_if.intr) begin
      csr_prv_if.mstatus_next.mpie = 1'b1;
      csr_prv_if.mstatus_next.mie = 1'b0; 
      csr_prv_if.mstatus_next.mpp = M_MODE;  
    end else if (ex_int_if.ret) begin
      csr_prv_if.mstatus_next.mie = csr_prv_if.mstatus.mpie;
      csr_prv_if.mstatus_next.mpie = 1'b0;
      csr_prv_if.mstatus_next.mpp = M_MODE;
    end
    else begin
      csr_prv_if.mstatus_next.mie = csr_prv_if.mstatus.mie;
      csr_prv_if.mstatus_next.mpie = csr_prv_if.mstatus.mpie;
      csr_prv_if.mstatus_next.mpp = csr_prv_if.mstatus.mpp;
    end
  end

  assign csr_prv_if.mepc_rup = ex_int_if.intr;
  assign csr_prv_if.mepc_next = (exception & (ex_int_if.breakpoint | ex_int_if.env_m)) ? ext_int_if.curr_epc_p4 : ext_int_if.curr_epc;

  assign csr_prv_if.mbadaddr_rup = (ext_int_if.mal_l | ext_int_if.fault_l | ext_int_if.mal_s | ext_int_if.fault_s | 
                                    ext_int_if.illegal_insn | ext_int_if.fault_imsn | ext_int_if.mal_insn);
endmodule
