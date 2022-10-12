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
*   Filename:     priv_1_12_csr.sv
*
*   Created by:   Hadi Ahmed
*   Email:        ahmed138@purdue.edu
*   Date Created: 03/28/2022
*   Description:  CSR File for Priv Unit 1.12
*/

`include "priv_1_12_internal_if.vh"
`include "priv_ext_if.vh"
`include "component_selection_defines.vh"

module priv_1_12_csr # (
  HARTID = 0 ) (
  input CLK, nRST,
  priv_1_12_internal_if.csr prv_intern_if
  `ifdef RV32F_SUPPORTED
  , priv_ext_if.priv priv_ext_f_if
  `endif // RV32F_SUPPORTED
  `ifdef RV32V_SUPPORTED
  , priv_ext_if.priv priv_ext_v_if
  `endif // RV32V_SUPPORTED
);


  import machine_mode_types_1_12_pkg::*;
  import rv32i_types_pkg::*;

  /* Machine Information */
  csr_reg_t         mvendorid;
  csr_reg_t         marchid;
  csr_reg_t         mimpid;
  csr_reg_t         mhartid;
  csr_reg_t         mconfigptr;
  /* Machine Trap Setup */
  mstatus_t         mstatus, mstatus_next;
  misa_t            misa;
  mie_t             mie, mie_next;
  mtvec_t           mtvec, mtvec_next;
  mstatush_t        mstatush;
  /* Machine Trap Handling */
  csr_reg_t         mscratch, mscratch_next;
  csr_reg_t         mepc, mepc_next;
  mcause_t          mcause, mcause_next;
  csr_reg_t         mtval, mtval_next;
  mip_t             mip, mip_next;
  /* Machine Counters/Timers */
  mcounteren_t      mcounteren, mcounteren_next;
  mcountinhibit_t   mcounterinhibit, mcounterinhibit_next;
  csr_reg_t         mcycle;
  csr_reg_t         minstret;
  csr_reg_t         mcycleh;
  csr_reg_t         minstreth;
  long_csr_t        cycles_full, cf_next;
  long_csr_t        instret_full, if_next;

  csr_reg_t nxt_csr_val;

  // invalid_csr flags
  logic invalid_csr_0, invalid_csr_1;
  assign prv_intern_if.invalid_csr = invalid_csr_0 | invalid_csr_1;

  // Extension Broadcast Signals
  `ifdef RV32F_SUPPORTED
    assign priv_ext_f_if.csr_addr = prv_intern_if.csr_addr;
    assign priv_ext_f_if.value_in = nxt_csr_val;
    assign priv_ext_f_if.csr_active = prv_intern_if.valid_write & (prv_intern_if.csr_write | prv_intern_if.csr_set | prv_intern_if.csr_clear);
  `endif // RV32F_SUPPORTED
  `ifdef RV32V_SUPPORTED
    assign priv_ext_v_if.csr_addr = prv_intern_if.csr_addr;
    assign priv_ext_v_if.value_in = nxt_csr_val;
    assign priv_ext_v_if.csr_active = prv_intern_if.valid_write & (prv_intern_if.csr_write | prv_intern_if.csr_set | prv_intern_if.csr_clear);
  `endif // RV32V_SUPPORTED

  /* Save some logic with this */
  assign mcycle = cycles_full[31:0];
  assign mcycleh = cycles_full[63:32];
  assign minstret = instret_full[31:0];
  assign minstreth = instret_full[63:32];

  /* These info registers are always just tied to certain values */
  assign mvendorid = '0;
  assign marchid = '0;
  assign mimpid = '0;
  assign mconfigptr = '0;
  assign mhartid = HARTID;

  /* These registers are RO fields */
  assign misa.zero = '0;
  assign misa.base = BASE_RV32;
  // NOTE: Per the v1.12 spec, both I and E CANNOT be high - If supporting E, I must be disabled
  assign misa.extensions =      MISA_EXT_I
                            `ifdef RV32C_SUPPORTED
                                | MISA_EXT_C
                             `endif `ifdef RV32E_SUPPORTED
                                | MISA_EXT_E
                            `endif `ifdef RV32F_SUPPORTED
                                | MISA_EXT_F
                            `endif `ifdef RV32M_SUPPORTED
                                | MISA_EXT_M
                            `endif `ifdef RV32U_SUPPORTED
                                | MISA_EXT_U
                            `endif `ifdef RV32V_SUPPORTED
                                | MISA_EXT_V
                            `endif `ifdef CUSTOM_SUPPORTED
                                | MISA_EXT_X
                            `endif;

  assign mstatush.reserved_0 = '0;
  assign mstatush.sbe = 1'b0;
  assign mstatush.mbe = 1'b0;
  assign mstatush.reserved_1 = '0;



  // Control and Status Registers
  always_ff @ (posedge CLK, negedge nRST) begin
    if (~nRST) begin
      /* mstatus reset */
      mstatus.mie <= 1'b0;
      mstatus.mpie <= 1'b0;
      mstatus.mpp <= M_MODE;
      mstatus.mprv <= 1'b0;
      mstatus.tw <= 1'b1;
      mstatus.reserved_0 <= '0;
      mstatus.reserved_1 <= '0;
      mstatus.reserved_2 <= '0;
      mstatus.reserved_3 <= '0;
      mstatus.sie <= 1'b0;
      mstatus.spie <= 1'b0;
      mstatus.ube <= 1'b0;
      mstatus.spp <= 1'b0;
      mstatus.sum <= 1'b0;
      mstatus.mxr <= 1'b0;
      mstatus.tvm <= 1'b0;
      mstatus.tsr <= 1'b0;
      mstatus.sd <= &(mstatus.vs) | &(mstatus.fs) | &(mstatus.xs);
      `ifdef RV32V_SUPPORTED
        mstatus.vs <= VS_INITIAL;
      `else
        mstatus.vs <= VS_OFF;
      `endif
      `ifdef RV32F_SUPPORTED
        mstatus.fs <= FS_INITIAL;
      `else
        mstatus.fs <= FS_OFF;
      `endif
      `ifdef CUSTOM_SUPPORTED
        mstatus.xs <= XS_NONE_D;
      `else
        mstatus.xs <= XS_ALL_OFF;
      `endif

      /* mtvec reset */
      mtvec.mode <= DIRECT;
      mtvec.base <= '0;

      /* mie reset */
      mie <= '0;

      /* mip reset */
      mip <= '0;

      /* msratch reset */
      mscratch <= '0;

      /* mepc reset */
      mepc <= '0;

      /* mtval reset */
      mtval <= '0;

      /* mcounter reset */
      mcounteren <= '1;
      mcounterinhibit <= '0;

      /* perf mon reset */
      cycles_full <= '0;
      instret_full <= '0;

      /* mcause reset */
      mcause <= '0;

    end else begin
      mstatus <= mstatus_next;
      mtvec <= mtvec_next;
      mie <= mie_next;
      mip <= mip_next;
      mscratch <= mscratch_next;
      mepc <= mepc_next;
      mtval <= mtval_next;
      mcounteren <= mcounteren_next;
      mcounterinhibit <= mcounterinhibit_next;
      mcause <= mcause_next;
      cycles_full <= cf_next;
      instret_full <= if_next;
    end
  end

  // Privilege Check and Legal Value Check
  always_comb begin
    mstatus_next = mstatus;
    mtvec_next = mtvec;
    mie_next = mie;
    mip_next = mip;
    mscratch_next = mscratch;
    mepc_next = mepc;
    mtval_next = mtval;
    mcounteren_next = mcounteren;
    mcounterinhibit_next = mcounterinhibit;
    mcause_next = mcause_next;

    nxt_csr_val = (prv_intern_if.csr_write) ? prv_intern_if.new_csr_val :
                  (prv_intern_if.csr_set)   ? prv_intern_if.new_csr_val | prv_intern_if.old_csr_val :
                  (prv_intern_if.csr_clear)   ? ~prv_intern_if.new_csr_val & prv_intern_if.old_csr_val :
                  prv_intern_if.new_csr_val;
    invalid_csr_0 = 1'b0;

    if (prv_intern_if.csr_addr[9:8] & prv_intern_if.curr_priv != 2'b11) begin
      if (prv_intern_if.csr_write | prv_intern_if.csr_set | prv_intern_if.csr_clear) begin
        invalid_csr_0 = 1'b1; // Not enough privilege
      end
    end else begin
      if (prv_intern_if.valid_write) begin
        casez(prv_intern_if.csr_addr)
          MSTATUS_ADDR: begin
            if (prv_intern_if.new_csr_val[12:11] == 2'b10) begin
              mstatus_next.mpp = U_MODE; // If invalid privilege level, dump at 0
            end else begin
              mstatus_next.mpp = priv_level_t'(nxt_csr_val[12:11]);
            end
            mstatus_next.mie = nxt_csr_val[3];
            mstatus_next.mpie = nxt_csr_val[7];
            mstatus_next.mprv = nxt_csr_val[17];
            mstatus_next.tw = nxt_csr_val[21];
          end

          MTVEC_ADDR: begin
            if (prv_intern_if.new_csr_val[1:0] > 2'b01) begin
              mtvec_next.mode = DIRECT;
            end else begin
              mtvec_next.mode = vector_modes_t'(nxt_csr_val[1:0]);
            end
            mtvec_next.base = nxt_csr_val[31:2];
          end

          MIE_ADDR: begin
            mie_next.msie = nxt_csr_val[3];
            mie_next.mtie = nxt_csr_val[7];
            mie_next.meie = nxt_csr_val[11];
          end

          MIP_ADDR: begin
              mip_next.msip = nxt_csr_val[3];
              mip_next.mtip = nxt_csr_val[7];
              mip_next.meip = nxt_csr_val[11];
          end
          MSCRATCH_ADDR: begin
            mscratch_next = nxt_csr_val;
          end
          MEPC_ADDR: begin
            mepc_next = nxt_csr_val;
          end
          MTVAL_ADDR: begin
            mtval_next = nxt_csr_val;
          end
          MCOUNTEREN_ADDR: begin
            mcounteren_next = nxt_csr_val;
          end
          MCOUNTINHIBIT_ADDR: begin
            mcounterinhibit_next = nxt_csr_val;
          end
          MCAUSE_ADDR: begin
            mcause_next = nxt_csr_val;
          end
        endcase
      end
    end

    // inject values
    if (prv_intern_if.inject_mstatus) begin
      mstatus_next = prv_intern_if.next_mstatus;
    end 
    if (prv_intern_if.inject_mtval) begin
      mtval_next = prv_intern_if.next_mtval;
    end 
    if (prv_intern_if.inject_mepc) begin
      mepc_next = prv_intern_if.next_mepc;
    end 
    if (prv_intern_if.inject_mcause) begin
      mcause_next = prv_intern_if.next_mcause;
    end 
    if (prv_intern_if.inject_mie) begin
      mie_next = prv_intern_if.next_mie;
    end 
    if (prv_intern_if.inject_mip) begin
      mip_next = prv_intern_if.next_mip;
    end
  end

  // hw perf mon
  always_comb begin
    cf_next = cycles_full;
    if_next = instret_full;

    if (mcounteren.cy & ~mcounterinhibit.cy) begin
      cf_next = cycles_full + 1;
    end
    if (mcounteren.ir & ~mcounterinhibit.ir) begin
      if_next = instret_full + prv_intern_if.inst_ret;
    end
  end

  // Return proper values to CPU, PMP, PMA
  always_comb begin
    /* CPU return */
    prv_intern_if.old_csr_val = '0;
    invalid_csr_1 = 1'b0;
    casez(prv_intern_if.csr_addr)
      MVENDORID_ADDR: prv_intern_if.old_csr_val = mvendorid;
      MARCHID_ADDR: prv_intern_if.old_csr_val = marchid;
      MIMPID_ADDR: prv_intern_if.old_csr_val = mimpid;
      MHARTID_ADDR: prv_intern_if.old_csr_val = mhartid;
      MCONFIGPTR_ADDR: prv_intern_if.old_csr_val = mconfigptr;
      MSTATUS_ADDR: prv_intern_if.old_csr_val = mstatus;
      MISA_ADDR: prv_intern_if.old_csr_val = misa;
      MIE_ADDR: prv_intern_if.old_csr_val = mie;
      MTVEC_ADDR: prv_intern_if.old_csr_val = mtvec;
      MSTATUSH_ADDR: prv_intern_if.old_csr_val = mstatush;
      MSCRATCH_ADDR: prv_intern_if.old_csr_val = mscratch;
      MEPC_ADDR: prv_intern_if.old_csr_val = mepc;
      MCAUSE_ADDR: prv_intern_if.old_csr_val = mcause;
      MTVAL_ADDR: prv_intern_if.old_csr_val = mtval;
      MIP_ADDR: prv_intern_if.old_csr_val = mip;
      MCOUNTEREN_ADDR: prv_intern_if.old_csr_val = mcounteren;
      MCOUNTINHIBIT_ADDR: prv_intern_if.old_csr_val = mcounterinhibit;
      MCYCLE_ADDR: prv_intern_if.old_csr_val = mcycle;
      MINSTRET_ADDR: prv_intern_if.old_csr_val = minstret;
      MCYCLEH_ADDR: prv_intern_if.old_csr_val = mcycleh;
      MINSTRETH_ADDR: prv_intern_if.old_csr_val = minstreth;
      default: begin
        if (prv_intern_if.csr_write | prv_intern_if.csr_set | prv_intern_if.csr_clear) begin
          `ifdef RV32F_SUPPORTED
            if (priv_ext_f_if.ack) begin
              prv_intern_if.old_csr_val = priv_ext_f_if.value_out;
            end
          `endif // RV32F_SUPPORTED
          `ifdef RV32V_SUPPORTED
            if (priv_ext_v_if.ack) begin
              prv_intern_if.old_csr_val = priv_ext_v_if.value_out;
            end
          `endif // RV32V_SUPPORTED
          
          // CSR address doesn't exist
          invalid_csr_1 = 1'b1
                          `ifdef RV32F_SUPPORTED
                          & (~priv_ext_f_if.ack) & (~priv_ext_f_if.invalid_csr)
                          `endif // RV32F_SUPPORTED
                          `ifdef RV32V_SUPPORTED
                          & (~priv_ext_v_if.ack) & (~priv_ext_v_if.invalid_csr)
                          `endif // RV32V_SUPPORTED
                        ;
        end
      end
    endcase
  end

  /* Priv control return */
  assign prv_intern_if.curr_mip = mip;
  assign prv_intern_if.curr_mie = mie;
  assign prv_intern_if.curr_mcause = mcause;
  assign prv_intern_if.curr_mepc = mepc;
  assign prv_intern_if.curr_mstatus = mstatus;
  assign prv_intern_if.curr_mtvec = mtvec;

endmodule
