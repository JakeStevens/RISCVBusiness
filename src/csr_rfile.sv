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


module csr_rfile (
  input CLK, nRST,
  csr_pipe_if.csr csr_pi_if,
  csr_prv_if.csr  csr_pr_if
);
  import machine_mode_types_pkg::*;
  import rv32i_types_pkg::*;
 
  /* Machine Information Registers */
  
  mcpuid_t    mcpuid;
  mimpid_t    mimpid;
  mhartid_t   mhartid;

  assign mcpuid.base          = BASE_RV32;
  assign mcpuid.zero          = '0;
  assign mcpuid.extensions  = MCPUID_EXT_I;

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

  assign mtvec = `MTVEC_ADDR;

  // Deleg Register Zero in Machine Mode Only
  assign mtdeleg = '0;

  assign mie.zero_0 = '0;
  assign mie.zero_1 = '0;
  assign mie.zero_2 = '0;
  assign mie.mtie = 1'b0;
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
  // TODO: Implement Timers.  Non-Critical feature


  /* Machine Counter Setup */
  // TODO: Implement Timers.  Non-Critical feature


  /* Machine Counter Delta Registers */
  // Unimplemented, only Machine Mode Supported


  //Non Standard Extensions, used for testing 
  mtohost_t   mtohost, mtohost_next;
  mfromhost_t mfromhost, mfromhost_next;

 
  always_ff @ (posedge CLK, negedge nRST) begin
    if (~nRST) begin
      mstatus.ie <= 1'b1;
      mip.msip    <= 1'b0;
      mip.mtip    <= 1'b0;
      mcause      <= '0;
      mepc        <= '0;
      mbadaddr    <= '0;
      mscratch    <= '0;
      mtohost     <= '0;
      mfromhost   <= '0;
    end else begin      
      mstatus. ie <= mstatus_next.ie;
      mip.msip    <= mip_next.msip; // interrupt
      mip.mtip    <= mip_next.mtip; // interrupt
      mcause      <= mcause_next;
      mepc        <= mepc_next;
      mbadaddr    <= mbadaddr_next;
      mscratch    <= mscratch_next;
      mtohost     <= mtohost_next;
      mfromhost   <= mfromhost_next;
    end
  end


  /* Pipeline Read/Write Interface */

  logic valid_csr_addr;
  logic csr_op;
  word_t rup_data;

  assign csr_op = csr_pi_if.swap | csr_pi_if.clr | csr_pi_if.set;
  assign csr_pi_if.invalid_csr = csr_op & ~valid_csr_addr;
  assign rup_data = csr_pi_if.swap ? csr_pi_if.rdata : (
                      csr_pi_if.clr ? csr_pi_if.rdata & ~csr_pi_if.wdata : 
                      csr_pi_if.rdata | csr_pi_if.wdata //csr_pi_if.set is default
                      );

  // Readonly by pipeline, rw by prv
  assign mip_next       = csr_pr_if.mip_rup ? csr_pr_if.mip_next : mip;
  assign mbadaddr_next  = csr_pr_if.mbadaddr_rup ? csr_pr_if.mbadaddr_next : mbadaddr;
  assign mcause_next    = csr_pr_if.mcause_rup ? csr_pr_if.mcause_next : mcause;
  assign mepc_next      = csr_pr_if.mepc_rup ? csr_pr_if.mepc_next : mepc;

  // Read and write by pipeline and prv
  assign mstatus_next   = (csr_pi_if.addr == 12'h300) ? mstatus_t'(rup_data) : (
                            csr_pr_if.mstatus_rup ? csr_pr_if.mstatus_next :
                            mstatus
                          );

  // Read and write by pipeline
  assign mie_next       = (csr_pi_if.addr == 12'h304) ? mie_t'(rup_data) : mie;
  assign mscratch_next  = (csr_pi_if.addr == 12'h340) ? mscratch_t'(rup_data) : mscratch;
  assign mtohost_next   = (csr_pi_if.addr == 12'h780) ? mtohost_t'(rup_data) : mtohost;

  always_comb begin
    valid_csr_addr = 1'b1;
    casez (csr_pi_if.addr)
      12'hf00   : csr_pi_if.rdata = mcpuid; 
      12'hf01   : csr_pi_if.rdata = mimpid;
      12'hf10   : csr_pi_if.rdata = mhartid;
      
      12'h300 : csr_pi_if.rdata = mstatus;
      12'h301 : csr_pi_if.rdata = mtvec;
      12'h302 : csr_pi_if.rdata = mtdeleg; 
      12'h304 : csr_pi_if.rdata = mie;
      
      12'h340 : csr_pi_if.rdata = mscratch;
      12'h341 : csr_pi_if.rdata = mepc;
      12'h342 : csr_pi_if.rdata = mcause;
      12'h343 : csr_pi_if.rdata = mbadaddr;
      12'h344 : csr_pi_if.rdata = mip; 
     
      //machine protection and translation not present 
      12'h380 : csr_pi_if.rdata = '0;
      12'h381 : csr_pi_if.rdata = '0;
      12'h382 : csr_pi_if.rdata = '0;
      12'h383 : csr_pi_if.rdata = '0;
      12'h384 : csr_pi_if.rdata = '0;
      12'h385 : csr_pi_if.rdata = '0;

      //only machine mode
      12'hb01 : csr_pi_if.rdata = '0;
      12'hb81 : csr_pi_if.rdata = '0;
            
      //Timers unimplemented
      12'h321 : csr_pi_if.rdata = '0;
      12'h701 : csr_pi_if.rdata = '0;
      12'h741 : csr_pi_if.rdata = '0;
      
      // Non-Standard mtohost/mfromhost
      12'h780 : csr_pi_if.rdata = mtohost;
      12'h781 : csr_pi_if.rdata = mfromhost;
  
      default : begin
        valid_csr_addr = 1'b0;
        csr_pi_if.rdata = '0;
      end
    endcase
  end

  assign csr_pr_if.mtvec     = mtvec;
  assign csr_pr_if.mepc      = mepc;
  assign csr_pr_if.mie       = mie;
  assign csr_pr_if.timer_int = 0;
  assign csr_pr_if.mstatus   = mstatus;
  assign csr_pr_if.mcause    = mcause;
  assign csr_pr_if.mip       = mip;

endmodule
