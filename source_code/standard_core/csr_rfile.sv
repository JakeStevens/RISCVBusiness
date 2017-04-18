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
*   Filename:     csr_rfile.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 07/08/2016
*   Description:  CSR Registers for Machine Mode Implementation RV32
*/


`include "prv_internal_if.vh"
`include "component_selection_defines.vh"

module csr_rfile (
  input CLK, nRST,
  prv_internal_if.csr prv_intern_if
);
  import machine_mode_types_pkg::*;
  import rv32i_types_pkg::*;
 
  /* Machine Information Registers */
  
  mcpuid_t      mcpuid;
  mimpid_t      mimpid;
  mhartid_t     mhartid;

  assign mcpuid.base          = BASE_RV32;
  assign mcpuid.zero          = '0;
  assign mcpuid.extensions  = MCPUID_EXT_I `ifdef         RV32M_SUPPORTED |
                              MCPUID_EXT_M `endif `ifdef  RV32C_SUPPORTED |
                              MCPUID_EXT_C `endif `ifdef  RV32F_SUPPORTED | 
                              MCPUID_EXT_F `endif ;

  assign mimpid           = '0; //TODO: Version Numbering Convention

  assign mhartid          = '0; 

  
  /* Machine Trap Setup Registers */

  mstatus_t mstatus, mstatus_next;
  mtdeleg_t mtdeleg;
  mie_t     mie, mie_next;
  mtvec_t   mtvec;

  assign mstatus.zero = '0;

  // mstatus bits set due to only Machine Mode Implemented
  assign mstatus.prv   = M_MODE;
  assign mstatus.prv1  = M_MODE;
  assign mstatus.ie1    = 1'b0;
  assign mstatus.prv2 = M_MODE;
  assign mstatus.ie2    = 1'b0;
  assign mstatus.prv3 = M_MODE;
  assign mstatus.ie3    = 1'b0;

  // No memory protection
  assign mstatus.vm     = VM_MBARE;
  assign mstatus.mprv   = 1'b0;

  // No FPU or Extensions
  assign mstatus.xs     = XS_ALL_OFF;
  assign mstatus.fs     = FS_OFF;
  assign mstatus.sd     = 1'b0;

  assign mtvec = MTVEC_MEMORY_ADDR;

  // Deleg Register Zero in Machine Mode Only
  assign mtdeleg = '0;

  assign mie.zero_0 = '0;
  assign mie.zero_1 = '0;
  assign mie.zero_2 = '0;
  assign mie.htie = 1'b0;
  assign mie.stie = 1'b0;
  assign mie.hsie = 1'b0;
  assign mie.ssie = 1'b0;

 /* Machine Trap Handling */
 
  mscratch_t  mscratch, mscratch_next;
  mepc_t      mepc, mepc_next;
  mcause_t    mcause, mcause_next;
  mbadaddr_t  mbadaddr, mbadaddr_next;
  mip_t       mip, mip_next;
 
  assign mip.zero_0 = '0;
  assign mip.zero_1 = '0;
  assign mip.zero_2 = '0;
  assign mip.htip = 1'b0;
  assign mip.stip = 1'b0;
  assign mip.hsip = 1'b0;
  assign mip.ssip = 1'b0;


  /* Machine Protection and Translation */
  // Unimplemented, only MBARE supported
 
 
  /* Machine Timers and Counters */
  mtimecmp_t    mtimecmp, mtimecmp_next;
  mtime_t       mtime, mtime_next;
  mtimeh_t      mtimeh, mtimeh_next;
  logic [63:0]  mtimefull, mtimefull_next;
  assign mtime          = mtimefull[31:0];
  assign mtimeh         = mtimefull[63:32];
  assign mtimefull_next = mtimefull + 1;
  assign prv_intern_if.timer_int      = (mtime == mtimecmp);
  assign prv_intern_if.clear_timer_int = (prv_intern_if.addr == MTIMECMP_ADDR) &
                                      prv_intern_if.valid_write;

  /* Machine Counter Delta Registers */
  // Unimplemented, only Machine Mode Supported

  /* Performance User Level Registers */
  cycle_t cycle, cycleh, cycle_next, cycleh_next;
  time_t  _time, timeh, time_next, timeh_next;
  instret_t instret, instreth, instret_next, isntreth_next;
  logic [63:0] instretfull, instretfull_next, cyclefull, cyclefull_next;
  logic [63:0] timefull, timefull_next;
  //TODO: Difference between time and cycle?
  assign _time = timefull[31:0];
  assign timeh = timefull[63:32];
  assign timefull_next = timefull + 1;
  assign cycle = cyclefull[31:0];
  assign cycleh = cyclefull[63:32];
  assign cyclefull_next = cyclefull + 1;
  assign instret = instretfull[31:0];
  assign instreth = instretfull[63:32];
  assign instretfull_next = (prv_intern_if.instr_retired == 1'b1) ?
                            instretfull + 1 : instretfull;

  //Non Standard Extensions, used for testing 
  mtohost_t   mtohost, mtohost_next;
  mfromhost_t mfromhost, mfromhost_next;

 
  always_ff @ (posedge CLK, negedge nRST) begin
    if (~nRST) begin
      mstatus.ie  <= 1'b1;
      mie.mtie    <= 1'b0;
      mie.msie    <= 1'b0;
      mip.msip    <= 1'b0;
      mip.mtip    <= 1'b0;
      mcause      <= '0;
      mepc        <= '0;
      mbadaddr    <= '0;
      mscratch    <= '0;
      mtohost     <= '0;
      mfromhost   <= '0;
      mtimecmp    <= '0;
      mtimefull   <= '0;
      /* Performance Counters */
      timefull    <= '0;
      cyclefull   <= '0;
      instretfull <= '0;
    end else if (prv_intern_if.addr == MTIMEH_ADDR)begin
      mstatus.ie  <= mstatus_next.ie;
      mie.mtie    <= mie_next.mtie; 
      mie.msie    <= mie_next.msie;
      mip.msip    <= mip_next.msip; // interrupt
      mip.mtip    <= mip_next.mtip; // interrupt
      mcause      <= mcause_next;
      mepc        <= mepc_next;
      mbadaddr    <= mbadaddr_next;
      mscratch    <= mscratch_next;
      mtohost     <= mtohost_next;
      mfromhost   <= mfromhost_next;
      mtimecmp    <= mtimecmp_next;
      mtimefull   <= {mtimeh_next, mtimefull_next[31:0]};
      /* Performance Counters */
      timefull    <= timefull_next;
      cyclefull   <= cyclefull_next;
      instretfull <= instretfull_next;
    end else if (prv_intern_if.addr == MTIME_ADDR) begin
      mstatus.ie  <= mstatus_next.ie;
      mie.mtie    <= mie_next.mtie; 
      mie.msie    <= mie_next.msie;
      mip.msip    <= mip_next.msip; // interrupt
      mip.mtip    <= mip_next.mtip; // interrupt
      mcause      <= mcause_next;
      mepc        <= mepc_next;
      mbadaddr    <= mbadaddr_next;
      mscratch    <= mscratch_next;
      mtohost     <= mtohost_next;
      mfromhost   <= mfromhost_next;
      mtimecmp    <= mtimecmp_next;
      mtimefull   <= {mtimefull_next[63:32], mtime_next};
      /* Performance Counters */
      timefull    <= timefull_next;
      cyclefull   <= cyclefull_next;
      instretfull <= instretfull_next;
    end else begin      
      mstatus.ie  <= mstatus_next.ie;
      mie.mtie    <= mie_next.mtie; 
      mie.msie    <= mie_next.msie;
      mip.msip    <= mip_next.msip; // interrupt
      mip.mtip    <= mip_next.mtip; // interrupt
      mcause      <= mcause_next;
      mepc        <= mepc_next;
      mbadaddr    <= mbadaddr_next;
      mscratch    <= mscratch_next;
      mtohost     <= mtohost_next;
      mfromhost   <= mfromhost_next;
      mtimecmp    <= mtimecmp_next;
      mtimefull   <= mtimefull_next;
      /* Performance Counters */
      timefull    <= timefull_next;
      cyclefull   <= cyclefull_next;
      instretfull <= instretfull_next;
    end
  end


  /* Pipeline Read/Write Interface */

  logic valid_csr_addr;
  logic csr_op;
  word_t rup_data;

  assign csr_op = prv_intern_if.swap | prv_intern_if.clr | prv_intern_if.set;
  assign prv_intern_if.invalid_csr = csr_op & ~valid_csr_addr;
  assign rup_data = prv_intern_if.swap ? prv_intern_if.wdata : (
                      prv_intern_if.clr ? prv_intern_if.rdata & ~prv_intern_if.wdata : 
                      prv_intern_if.set ? prv_intern_if.rdata | prv_intern_if.wdata :
                      prv_intern_if.rdata
                      );

  // Readonly by pipeline, rw by prv
  assign mip_next       = prv_intern_if.mip_rup ? prv_intern_if.mip_next : mip;
  assign mbadaddr_next  = prv_intern_if.mbadaddr_rup ? prv_intern_if.mbadaddr_next : mbadaddr;
  assign mcause_next    = prv_intern_if.mcause_rup ? prv_intern_if.mcause_next : mcause;

  // Read and write by pipeline and prv
  assign mstatus_next   = (prv_intern_if.addr == MSTATUS_ADDR) ? mstatus_t'(rup_data) : (
                            prv_intern_if.mstatus_rup ? prv_intern_if.mstatus_next :
                            mstatus
                          );

  assign mepc_next      = (prv_intern_if.addr == MEPC_ADDR)  ? mepc_t'(rup_data) : (
                            prv_intern_if.mepc_rup ? prv_intern_if.mepc_next : 
                            mepc
                          );

  // Read and write by pipeline
  assign mie_next       = (prv_intern_if.addr == MIE_ADDR) ? mie_t'(rup_data) : mie;
  assign mscratch_next  = (prv_intern_if.addr == MSCRATCH_ADDR) ? mscratch_t'(rup_data) : mscratch;
  assign mtohost_next   = (prv_intern_if.addr == MTOHOST_ADDR) ? mtohost_t'(rup_data) : mtohost;
  assign mtime_next     = (prv_intern_if.addr == MTIME_ADDR) ? mtime_t'(rup_data) : mtime;
  assign mtimeh_next    = (prv_intern_if.addr == MTIMEH_ADDR) ? mtimeh_t'(rup_data) : mtimeh;
  assign mtimecmp_next  = (prv_intern_if.addr == MTIMECMP_ADDR) ? mtimecmp_t'(rup_data) : mtimecmp;

  always_comb begin
    valid_csr_addr = 1'b1;
    casez (prv_intern_if.addr)
      MCPUID_ADDR     : prv_intern_if.rdata = mcpuid; 
      MIMPID_ADDR     : prv_intern_if.rdata = mimpid;
      MHARTID_ADDR    : prv_intern_if.rdata = mhartid;
      
      MSTATUS_ADDR    : prv_intern_if.rdata = mstatus;
      MTVEC_ADDR      : prv_intern_if.rdata = mtvec;
      MTDELEG_ADDR    : prv_intern_if.rdata = mtdeleg; 
      MIE_ADDR        : prv_intern_if.rdata = mie;
      
      MSCRATCH_ADDR   : prv_intern_if.rdata = mscratch;
      MEPC_ADDR       : prv_intern_if.rdata = mepc;
      MCAUSE_ADDR     : prv_intern_if.rdata = mcause;
      MBADADDR_ADDR   : prv_intern_if.rdata = mbadaddr;
      MIP_ADDR        : prv_intern_if.rdata = mip; 
     
      //machine protection and translation not present 
      MBASE_ADDR      : prv_intern_if.rdata = '0;
      MBOUND_ADDR     : prv_intern_if.rdata = '0;
      MIBASE_ADDR     : prv_intern_if.rdata = '0;
      MIBOUND_ADDR    : prv_intern_if.rdata = '0;
      MDBASE_ADDR     : prv_intern_if.rdata = '0;
      MDBOUND_ADDR    : prv_intern_if.rdata = '0;

      //only machine mode
      HTIMEW_ADDR     : prv_intern_if.rdata = '0;
      HTIMEHW_ADDR    : prv_intern_if.rdata = '0;
            
      //Timers
      MTIMECMP_ADDR   : prv_intern_if.rdata = mtimecmp;
      MTIME_ADDR      : prv_intern_if.rdata = mtime;
      MTIMEH_ADDR     : prv_intern_if.rdata = mtimeh;
      
      // Non-Standard mtohost/mfromhost
      MTOHOST_ADDR    : prv_intern_if.rdata = mtohost;
      MFROMHOST_ADDR  : prv_intern_if.rdata = mfromhost;

      // User level performance counters
      CYCLE_ADDR      : prv_intern_if.rdata = cycle;
      TIME_ADDR       : prv_intern_if.rdata = _time;
      INSTRET_ADDR    : prv_intern_if.rdata = instret;
      CYCLEH_ADDR     : prv_intern_if.rdata = cycleh;
      TIMEH_ADDR      : prv_intern_if.rdata = timeh;
      INSTRETH_ADDR   : prv_intern_if.rdata = instreth;
 
      default : begin
        valid_csr_addr = 1'b0;
        prv_intern_if.rdata = '0;
      end
    endcase
  end

  assign prv_intern_if.mtvec     = mtvec;
  assign prv_intern_if.mepc      = mepc;
  assign prv_intern_if.mie       = mie;
  assign prv_intern_if.mstatus   = mstatus;
  assign prv_intern_if.mcause    = mcause;
  assign prv_intern_if.mip       = mip;

  assign prv_intern_if.xtvec[2'b11]   = mtvec;
  assign prv_intern_if.xepc_r[2'b11]  = mepc;

endmodule
