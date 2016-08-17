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
  csr_pipe_if.csr csr_pipe_if,
  csr_prv_if.csr  csr_prv_if
);
  import machine_mode_types_pkg::*;
  import rv32i_types_pkg::*;
 
  /* Machine Information Registers */
  
  misa_t      misa;
  mvendorid_t mvendorid;
  marchid_t   marchid;
  mimpid_t    mimpid;
  mhartid_t   mhartid;

  assign misa.base        = BASE_RV32;
  assign misa.wiri        = '0;
  assign misa.extensions  = MCPUID_EXT_I;

  assign mvendorid        = '0;

  assign marchid          = '0; //TODO: Open Source ID

  assign mimpid           = '0; //TODO: Version Numbering Convention

  assign mhartid          = '0; 

  
  /* Machine Trap Setup Registers */

  mstatus_t mstatus, mstatus_next;
  medeleg_t medeleg;
  mideleg_t mideleg;
  mie_t     mie, mie_next;
  mtvec_t   mtvec;

  assign mstatus.wpri_0 = '0;
  assign mstatus.wpri_1 = '0;

  // mstatus bits set due to only Machine Mode Implemented
  assign mstatus.mpp    = M_MODE;
  assign mstatus.hpp    = M_MODE;
  assign mstatus.spp    = 1'b1;
  assign mstatus.hie    = 1'b0;
  assign mstatus.uie    = 1'b0;
  assign mstatus.sie    = 1'b0;
  assign mstatus.hpie   = 1'b0;
  assign mstatus.upie   = 1'b0;
  assign mstatus.spie   = 1'b0;
  assign mstatus_mpie   = 1'b1;

  // No memory protection
  assign mstatus.vm     = VM_MBARE;
  assign mstatus.mprv   = 1'b0;
  assign mstatus.pum    = 1'b0;
  assign mstatus.mxr    = 1'b0;

  // No FPU or Extensions
  assign mstatus.xs     = XS_ALL_OFF;
  assign mstatus.fs     = FS_OFF;
  assign mstatus.sd     = 1'b0;

  assign mtvec = `MTVEC_ADDR;

  // Deleg Registers Zero in Machine Mode Only
  assign medeleg = '0;
  assign mideleg = '0;

  assign mie.heie = 1'b0;
  assign mie.seie = 1'b0;
  assign mie.ueie = 1'b0;
  assign mie.htie = 1'b0;
  assign mie.stie = 1'b0;
  assign mie.utie = 1'b0;
  assign mie.hsie = 1'b0;
  assign mie.ssie = 1'b0;
  assign mie.usie = 1'b0;
  //Timer not implemented
  assign mie.mtie = 1'b0;

 /* Machine Trap Handling */
 
  mscratch_t  mscratch, mscratch_next;
  mepc_t      mepc, mepc_next;
  mcause_t    mcause, mcause_next;
  mbadaddr_t  mbadaddr, mbadaddr_next;
  mip_t       mip, mip_next;
 
  assign mip.wiri = '0;
  assign mip.heip = 1'b0;
  assign mip.seip = 1'b0;
  assign mip.ueip = 1'b0;
  assign mip.htip = 1'b0;
  assign mip.stip = 1'b0;
  assign mip.utip = 1'b0;
  assign mip.hsip = 1'b0;
  assign mip.ssip = 1'b0;
  assign mip.usip = 1'b0;


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
      mstatus.mie <= 1'b1;
      mip.msip    <= 1'b1;
      mip.mtip    <= 1'b1;
      mip.meip    <= 1'b1;
      mie.meie    <= 1'b1;
      mcause      <= '0;
      mepc        <= '0;
      mbadaddr    <= '0;
      mscratch    <= '0;
      mtohost     <= '0;
      mfromhost   <= '0;
    end else begin 
      mstatus.mie <= mstatus_next.mie;
      mip.msip    <= mip_next.msip; // software interrupt
      mip.mtip    <= mip_next.mtip; // timer interrupt
      mip.meip    <= mip_next.meip; // external interrupt
      mie.meie    <= mie_next.meie; // external interrupt enable
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

  assign csr_op = csr_pipe_if.swap | csr_pipe_if.clr | csr_pipe_if.set;
  assign csr_pipe_if.invalid_csr = csr_op & ~valid_csr_addr;
  assign rup_data = csr_pipe_if.swap ? csr_pipe_if.rdata : (
                      csr_pipe_if.clr ? csr_pipe_if.rdata & ~csr_pipe_if.wdata : 
                      csr_pipe_if.rdata | csr_pipe_if.wdata //csr_pipe_if.set is default
                      );

  // Readonly by pipeline, rw by prv
  assign mip_next       = csr_prv_if.mip_rup ? csr_prv_if.mip_next : mip;
  assign mbadaddr_next  = csr_prv_if.mbadaddr_rup ? csr_prv_if.mbadaddr_next : mbadaddr;
  assign mcause_next    = csr_prv_if.mcause_rup ? csr_prv_if.mcause_next : mcause;
  assign mepc_next      = csr_prv_if.mepc_rup ? csr_prv_if.mepc_next : mepc;

  // Read and write by pipeline and prv
  assign mstatus_next   = (csr_pipe_if.addr == 12'h300) ? mstatus_t'(rup_data) : (
                            csr_prv_if.mstatus_rup ? csr_prv_if.mstatus_next :
                            mstatus
                          );

  // Read and write by pipeline
  assign mie_next       = (csr_pipe_if.addr == 12'h304) ? mie_t'(rup_data) : mie;
  assign mscratch_next  = (csr_pipe_if.addr == 12'h340) ? mscratch_t'(rup_data) : mscratch;
  assign mtohost_next   = (csr_pipe_if.addr == 12'h780) ? mtohost_t'(rup_data) : mtohost;

  always_comb begin
    valid_csr_addr = 1'b1;
    casez (csr_pipe_if.addr)
      12'hf10 : csr_pipe_if.rdata = misa;
      12'hf11 : csr_pipe_if.rdata = mvendorid;
      12'hf12 : csr_pipe_if.rdata = marchid;
      12'hf13 : csr_pipe_if.rdata = mimpid;
      12'hf14 : csr_pipe_if.rdata = mhartid;
      
      12'h300 : csr_pipe_if.rdata = mstatus;
      12'h302 : csr_pipe_if.rdata = medeleg;
      12'h303 : csr_pipe_if.rdata = mideleg;
      12'h304 : csr_pipe_if.rdata = mie;
      12'h305 : csr_pipe_if.rdata = mtvec;

      12'h340 : csr_pipe_if.rdata = mscratch;
      12'h341 : csr_pipe_if.rdata = mepc;
      12'h342 : csr_pipe_if.rdata = mcause;
      12'h343 : csr_pipe_if.rdata = mbadaddr;
      12'h344 : csr_pipe_if.rdata = mip;
      
      12'h380 : csr_pipe_if.rdata = '0;
      12'h381 : csr_pipe_if.rdata = '0;
      12'h382 : csr_pipe_if.rdata = '0;
      12'h383 : csr_pipe_if.rdata = '0;
      12'h384 : csr_pipe_if.rdata = '0;
      12'h385 : csr_pipe_if.rdata = '0;

      12'hf00 : csr_pipe_if.rdata = '0;
      12'hf01 : csr_pipe_if.rdata = '0;
      12'hf02 : csr_pipe_if.rdata = '0;
      12'hf80 : csr_pipe_if.rdata = '0;
      12'hf81 : csr_pipe_if.rdata = '0;
      12'hf82 : csr_pipe_if.rdata = '0;
      
      12'h310 : csr_pipe_if.rdata = '0;
      12'h311 : csr_pipe_if.rdata = '0; 
      12'h312 : csr_pipe_if.rdata = '0;
      
      12'h700 : csr_pipe_if.rdata = '0;
      12'h701 : csr_pipe_if.rdata = '0;
      12'h702 : csr_pipe_if.rdata = '0;
      
      12'h704 : csr_pipe_if.rdata = '0;
      12'h705 : csr_pipe_if.rdata = '0;
      12'h706 : csr_pipe_if.rdata = '0;
      
      12'h708 : csr_pipe_if.rdata = '0;
      12'h709 : csr_pipe_if.rdata = '0;
      12'h70a : csr_pipe_if.rdata = '0;

      // Non-Standard mtohost/mfromhost
      12'h780 : csr_pipe_if.rdata = mtohost;
      12'h781 : csr_pipe_if.rdata = mfromhost;
      12'h782 : csr_pipe_if.rdata = '0;
  
      12'h784 : csr_pipe_if.rdata = '0;
      12'h785 : csr_pipe_if.rdata = '0;
      12'h786 : csr_pipe_if.rdata = '0;

      12'h788 : csr_pipe_if.rdata = '0;
      12'h789 : csr_pipe_if.rdata = '0;
      12'h78a : csr_pipe_if.rdata = '0;
  
      default : begin
        valid_csr_addr = 1'b0;
        csr_pipe_if.rdata = '0;
      end
    endcase
  end

  assign csr_prv_if.mtvec     = mtvec;
  assign csr_prv_if.mepc      = mepc;
  assign csr_prv_if.mie       = mie;
  assign csr_prv_if.timer_int = 0;
  assign csr_prv_if.mstatus   = mstatus;
  assign csr_prv_if.mcause    = mcause;
  assign csr_prv_if.mip       = mip;

endmodule
