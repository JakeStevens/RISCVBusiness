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
*   Filename:     priv_1_7_control.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 08/17/2016
*   Description:  Main control for the priv isa block version 1.7
*/

`include "priv_1_7_internal_if.vh"

module priv_1_7_control (
  input CLK, nRST,
  priv_1_7_internal_if.prv_control prv_intern_if
);
  import rv32i_types_pkg::*;
  import machine_mode_types_pkg::*;

  ex_code_t ex_src;
  logic exception;
  
  int_code_t intr_src;
  logic interrupt;
  logic interrupt_reg, interrupt_fired;

  always_comb begin
    interrupt = 1'b1;
    intr_src = SOFT_INT;

    if (prv_intern_if.timer_int) begin
      intr_src = TIMER_INT;
    end
    else if (prv_intern_if.soft_int) begin
      intr_src = SOFT_INT;
    end
    else if (prv_intern_if.ext_int) begin
      intr_src = EXT_INT;
    end
    else
      interrupt = 1'b0;
  end

  assign prv_intern_if.mip_rup = interrupt || prv_intern_if.clear_timer_int;
  always_comb begin
    prv_intern_if.mip_next = prv_intern_if.mip;
    if (prv_intern_if.timer_int) prv_intern_if.mip_next.mtip = 1'b1;
    if (prv_intern_if.clear_timer_int) prv_intern_if.mip_next.mtip = 1'b0;
    if (prv_intern_if.soft_int) prv_intern_if.mip_next.msip = 1'b1;
    if (prv_intern_if.ext_int) prv_intern_if.mip_next.msip = 1'b1; //external interrupts not specified in 1.7
  end

  always_comb begin
    exception = 1'b1;
    ex_src = INSN_MAL;

    if (prv_intern_if.fault_l)
      ex_src = L_FAULT;
    else if (prv_intern_if.mal_l)
      ex_src = L_ADDR_MAL;
    else if (prv_intern_if.fault_s) 
      ex_src = S_FAULT;
    else if (prv_intern_if.mal_s) 
      ex_src = S_ADDR_MAL;
    else if (prv_intern_if.breakpoint)
      ex_src = BREAKPOINT;
    else if (prv_intern_if.env_m) 
      ex_src = ENV_CALL_M;
    else if (prv_intern_if.illegal_insn) 
      ex_src = ILLEGAL_INSN;
    else if (prv_intern_if.fault_insn)
      ex_src = INSN_FAULT;
    else if (prv_intern_if.mal_insn)
      ex_src = INSN_MAL;
    else if (prv_intern_if.ex_rmgmt)
      ex_src = ex_code_t'(prv_intern_if.ex_rmgmt_cause);
    else 
      exception = 1'b0;
  end

  //output to pipeline control
  assign prv_intern_if.intr = exception | interrupt_reg;
  assign interrupt_fired = (prv_intern_if.mstatus.ie & ((prv_intern_if.mie.mtie & prv_intern_if.mip.mtip) | 
                     (prv_intern_if.mie.msie & prv_intern_if.mip.msip)));
 
  // Register Updates on Interrupt/Exception
  assign prv_intern_if.mcause_rup = exception | interrupt_fired;
  assign prv_intern_if.mcause_next.interrupt = ~exception;
  assign prv_intern_if.mcause_next.cause = exception ? ex_src : intr_src;

  assign prv_intern_if.mstatus_rup = exception | interrupt_fired;

  always_comb begin
    if (prv_intern_if.intr) begin
      prv_intern_if.mstatus_next.ie = 1'b0; 
    end else if (prv_intern_if.ret) begin
      prv_intern_if.mstatus_next.ie = 1'b1;
    end
    else begin
      prv_intern_if.mstatus_next.ie = prv_intern_if.mstatus.ie;
    end
  end

  // Update EPC as soon as interrupt or exception is found 
  assign prv_intern_if.mepc_rup = exception | interrupt_fired;
  assign prv_intern_if.mepc_next = prv_intern_if.epc;

  assign prv_intern_if.mbadaddr_rup = (prv_intern_if.mal_l | prv_intern_if.fault_l | prv_intern_if.mal_s | prv_intern_if.fault_s | 
                                  prv_intern_if.illegal_insn | prv_intern_if.fault_insn | prv_intern_if.mal_insn | prv_intern_if.ex_rmgmt) 
                                  & prv_intern_if.pipe_clear;
  assign prv_intern_if.mbadaddr_next = prv_intern_if.badaddr;

  /* Interrupt needs to be latched until pipeline cleared   */
  /* because mstatus.ie causes the irq to disappear after   */
  /* one cycle. Cannot wait to clear mstatus.ie because     */
  /* then another interrupt can fire during pipeline clear  */
  always_ff @ (posedge CLK, negedge nRST) begin
    if (!nRST)
      interrupt_reg <= '0;
    else if (interrupt_fired)
      interrupt_reg <= 1'b1;
    else if (prv_intern_if.pipe_clear)
      interrupt_reg <= '0;
  end 
endmodule
