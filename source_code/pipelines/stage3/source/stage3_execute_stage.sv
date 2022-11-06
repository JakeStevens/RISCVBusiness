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
*   Filename:     stage3_execute_stage.sv
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 06/16/2016
*   Description:  Execute Stage for the Two Stage Pipeline
*/

`include "stage3_fetch_execute_if.vh"
`include "stage3_hazard_unit_if.vh"
`include "stage3_forwarding_unit_if.vh"
`include "control_unit_if.vh"
`include "component_selection_defines.vh"
`include "rv32i_reg_file_if.vh"
`include "alu_if.vh"
//`include "prv_pipeline_if.vh"
`include "risc_mgmt_if.vh"
`include "rv32c_if.vh"

module stage3_execute_stage (
    input CLK,
    input nRST,
    stage3_fetch_execute_if.execute fetch_ex_if,
    stage3_mem_pipe_if.execute ex_mem_if,
    stage3_hazard_unit_if.execute hazard_if,
    stage3_forwarding_unit_if.execute fw_if,
    //prv_pipeline_if.pipe prv_pipe_if,
    risc_mgmt_if.ts_execute rm_if,
    sparce_pipeline_if.pipe_execute sparce_if,
    rv32c_if.execute rv32cif
);

    import rv32i_types_pkg::*;
    import pma_types_1_12_pkg::*;
    import stage3_types_pkg::*;

    // Interface declarations
    control_unit_if cu_if ();
    rv32i_reg_file_if rf_if ();
    alu_if alu_if ();
    jump_calc_if jump_if ();
    branch_res_if branch_if ();

    // Module instantiations
    control_unit cu (
        .cu_if(cu_if),
        .rf_if(rf_if),
        .rmgmt_rsel_s_0(rm_if.rsel_s_0),
        .rmgmt_rsel_s_1(rm_if.rsel_s_1),
        .rmgmt_rsel_d(rm_if.rsel_d),
        .rmgmt_req_reg_r(rm_if.req_reg_r),
        .rmgmt_req_reg_w(rm_if.req_reg_w)
    );

    assign wfi = cu_if.wfi;  //Added by rkannank

    generate
        if (BASE_ISA == "RV32E") begin : g_rfile_select
            rv32e_reg_file rf (
                .CLK,
                .nRST,
                .rf_if
            );
        end else begin : g_rfile_select
            rv32i_reg_file rf (
                .CLK,
                .nRST,
                .rf_if
            );
        end
    endgenerate

    // Forwarding -- replace rs1/rs2 with post-forwarded versions
    word_t rs1_post_fwd, rs2_post_fwd;
    // TODO: Make sure rs2_post_fwd used everywhere rs2 data is meant to be used!
    assign rs1_post_fwd = fw_if.fwd_rs1 ? fw_if.rd_mem_data : rf_if.rs1_data;
    assign rs2_post_fwd = fw_if.fwd_rs2 ? fw_if.rd_mem_data : rf_if.rs2_data;
    
    alu alu (.*);
    jump_calc jump_calc (.*);

    branch_res branch_res (.br_if(branch_if));

    /*
    word_t store_swapped;
    endian_swapper store_swap (
        .word_in (rf_if.rs2_data),
        .word_out(store_swapped)
    );

    word_t dload_ext;
    logic [3:0] byte_en, byte_en_temp, byte_en_standard;
    dmem_extender dmem_ext (
        .dmem_in  (dgen_bus_if.rdata),
        .load_type(cu_if.load_type),
        .byte_en  (byte_en),
        .ext_out  (dload_ext)
    );
    */

    /*******************************************************
  * MISC RISC-MGMT Logic
  *******************************************************/

    //assign rm_if.rdata_s_0 = rf_if.rs1_data;
    //assign rm_if.rdata_s_1 = rf_if.rs2_data;


    /********************************************************
  *** Choose the Endianness Coming into the processor
  *******************************************************/
    /*
    generate
        if (BUS_ENDIANNESS == "big") begin : g_data_bus_be
            assign byte_en = byte_en_temp;
        end else if (BUS_ENDIANNESS == "little") begin : g_data_bus_le
            assign byte_en = cu_if.dren ? byte_en_temp :
              {byte_en_temp[0], byte_en_temp[1],
              byte_en_temp[2], byte_en_temp[3]};
        end
    endgenerate
    */

    //RV32C
    assign rv32cif.inst16 = fetch_ex_if.fetch_ex_reg.instr[15:0];
    assign rv32cif.halt = cu_if.halt;
    assign rv32cif.ex_busy = cu_if.dren | cu_if.dwen | rm_if.risc_mgmt_start;
    assign cu_if.instr = rv32cif.c_ena ? rv32cif.inst32 : fetch_ex_if.fetch_ex_reg.instr;
    assign rm_if.insn = rv32cif.c_ena ? rv32cif.inst32 : fetch_ex_if.fetch_ex_reg.instr;


    /*******************************************************
  *** Sign Extensions
  *******************************************************/
    word_t imm_I_ext, imm_S_ext, imm_UJ_ext;
    assign imm_I_ext  = {{20{cu_if.imm_I[11]}}, cu_if.imm_I};
    assign imm_UJ_ext = {{11{cu_if.imm_UJ[20]}}, cu_if.imm_UJ};
    assign imm_S_ext  = {{20{cu_if.imm_S[11]}}, cu_if.imm_S};

    /*******************************************************
      *** Jump Target Calculator and Associated Logic
      *******************************************************/
    word_t jump_addr  /* verilator isolate_assignments */;
    always_comb begin
        if (cu_if.j_sel) begin
            jump_if.base = fetch_ex_if.fetch_ex_reg.pc;
            jump_if.offset = imm_UJ_ext;
            jump_addr = jump_if.jal_addr;
        end else begin
            jump_if.base = rs1_post_fwd;
            jump_if.offset = imm_I_ext;
            jump_addr = jump_if.jalr_addr;
        end
    end

    /*******************************************************
  *** ALU and Associated Logic
  *******************************************************/
    word_t imm_or_shamt;
    assign imm_or_shamt = (cu_if.imm_shamt_sel == 1'b1) ? cu_if.shamt : imm_I_ext;
    assign alu_if.aluop = cu_if.alu_op;
    logic mal_addr;

    always_comb begin
        case (cu_if.alu_a_sel)
            2'd0: alu_if.port_a = rs1_post_fwd;
            2'd1: alu_if.port_a = imm_S_ext;
            2'd2: alu_if.port_a = fetch_ex_if.fetch_ex_reg.pc;
            2'd3: alu_if.port_a = '0;  //Not Used
        endcase
    end

    always_comb begin
        case (cu_if.alu_b_sel)
            2'd0: alu_if.port_b = rs1_post_fwd;
            2'd1: alu_if.port_b = rs2_post_fwd;
            2'd2: alu_if.port_b = imm_or_shamt;
            2'd3: alu_if.port_b = cu_if.imm_U;
        endcase
    end

    // TODO: Fix this for correct writeback! Mem stage needs mux this for us
    assign rf_if.w_data = ex_mem_if.reg_wdata;
    assign rf_if.rd = ex_mem_if.rd_m;
    /*
    always_comb begin
        if (rm_if.req_reg_w) begin
            rf_if.w_data = rm_if.reg_wdata;
        end else begin
            
            case (cu_if.w_sel)
                3'd0:    rf_if.w_data = dload_ext;
                3'd1:    rf_if.w_data = fetch_ex_if.fetch_ex_reg.pc4;
                3'd2:    rf_if.w_data = cu_if.imm_U;
                3'd3:    rf_if.w_data = alu_if.port_out;
                3'd4:    rf_if.w_data = prv_pipe_if.rdata;
                default: rf_if.w_data = '0;
            endcase
        end
    end
    */

    // TODO: What is the real condition for writeback?
    // Does checking the stall actually matter? (value is coming from register, no path from register update->register input now)
    /*assign rf_if.wen = (cu_if.wen | (rm_if.req_reg_w & rm_if.reg_w))
                       & (~hazard_if.ex_mem_stall | hazard_if.npc_sel | rv32cif.done_earlier)
                       & ~(cu_if.dren & mal_addr);
    */
    assign rf_if.wen = ex_mem_if.reg_write && !hazard_if.ex_mem_stall; // TODO: The second signal only matters for some miniscule power reduction by not writing each cycle. This is correct with only the wen signal due to no loop from reg read to reg write
    /*******************************************************
  *** Branch Target Resolution and Associated Logic
  *******************************************************/

    word_t resolved_addr;
    logic  branch_taken;
    word_t branch_addr;
    word_t brj_addr;

    assign branch_if.rs1_data = rs1_post_fwd;//rf_if.rs1_data;
    assign branch_if.rs2_data = rs2_post_fwd; //rf_if.rs2_data;
    assign branch_if.pc = fetch_ex_if.fetch_ex_reg.pc;
    assign branch_if.imm_sb = cu_if.imm_SB;
    assign branch_if.branch_type = cu_if.branch_type;

    // Mux resource based on if RISC-MGMT is trying to access it
    assign branch_taken = rm_if.req_br_j ? rm_if.branch_jump : branch_if.branch_taken;
    assign branch_addr = rm_if.req_br_j ? rm_if.br_j_addr : branch_if.branch_addr;
    //assign rm_if.pc = fetch_ex_if.fetch_ex_reg.pc;

    assign resolved_addr = branch_if.branch_taken ? branch_addr : fetch_ex_if.fetch_ex_reg.pc4;

    assign brj_addr = ((cu_if.ex_pc_sel == 1'b1) && ~rm_if.req_br_j) ?
                            jump_addr : resolved_addr;

    //assign hazard_if.mispredict = fetch_ex_if.fetch_ex_reg.prediction ^ branch_taken;

    /********************************
    * Hazard/Forwarding Unit Signals
    *********************************/
    assign hazard_if.rs1_e = rf_if.rs1;
    assign hazard_if.rs2_e = rf_if.rs2;

    assign fw_if.rs1_e = rf_if.rs1;
    assign fw_if.rs2_e = rf_if.rs2;


    // TODO: NEW
    always_ff @(posedge CLK, negedge nRST) begin
        if(!nRST) begin
            ex_mem_if.ex_mem_reg <= '{default: '0}; 
        end else begin
            // TODO: This register is ~180b. Not awful, but can it be smaller?
            // PS: Does it even matter? Synth. tools may be able to merge regs.
            if(!hazard_if.ex_mem_flush && !hazard_if.ex_mem_stall) begin
                // TODO: Handle case of exceptions earlier in the pipe being passed on to handle in the last stage
                // Single bit control signals
                ex_mem_if.ex_mem_reg.branch         <= cu_if.branch;
                ex_mem_if.ex_mem_reg.prediction     <= fetch_ex_if.fetch_ex_reg.prediction;
                ex_mem_if.ex_mem_reg.branch_taken   <= branch_if.branch_taken;
                ex_mem_if.ex_mem_reg.dren           <= cu_if.dren;
                ex_mem_if.ex_mem_reg.dwen           <= cu_if.dwen;
                ex_mem_if.ex_mem_reg.reg_write      <= cu_if.wen;
                ex_mem_if.ex_mem_reg.ifence         <= cu_if.ifence;
                ex_mem_if.ex_mem_reg.jump           <= cu_if.jump;
                ex_mem_if.ex_mem_reg.halt           <= cu_if.halt;
                ex_mem_if.ex_mem_reg.csr_swap       <= cu_if.csr_swap;
                ex_mem_if.ex_mem_reg.csr_clr        <= cu_if.csr_clr;
                ex_mem_if.ex_mem_reg.csr_set        <= cu_if.csr_set;
                ex_mem_if.ex_mem_reg.csr_imm        <= cu_if.csr_imm;
                ex_mem_if.ex_mem_reg.breakpoint     <= cu_if.breakpoint;
                ex_mem_if.ex_mem_reg.ecall_insn     <= cu_if.ecall_insn;
                ex_mem_if.ex_mem_reg.ret_insn       <= cu_if.ret_insn;
                ex_mem_if.ex_mem_reg.was_compressed <= 1'b0; // TODO: RV32C support

                // Bit vectors
                ex_mem_if.ex_mem_reg.w_sel      <= cu_if.w_sel;
                ex_mem_if.ex_mem_reg.zimm       <= cu_if.zimm;
                ex_mem_if.ex_mem_reg.rd_m       <= cu_if.rd;
                ex_mem_if.ex_mem_reg.load_type  <= cu_if.load_type;
                ex_mem_if.ex_mem_reg.csr_addr   <= cu_if.csr_addr;

                // Word sized members
                ex_mem_if.ex_mem_reg.brj_addr   <= brj_addr;
                ex_mem_if.ex_mem_reg.port_out   <= alu_if.port_out;
                ex_mem_if.ex_mem_reg.rs1_data   <= rs1_post_fwd;
                ex_mem_if.ex_mem_reg.rs2_data   <= rs2_post_fwd;
                ex_mem_if.ex_mem_reg.instr      <= cu_if.instr;
                ex_mem_if.ex_mem_reg.pc         <= fetch_ex_if.fetch_ex_reg.pc;
                ex_mem_if.ex_mem_reg.pc4        <= fetch_ex_if.fetch_ex_reg.pc4;
                ex_mem_if.ex_mem_reg.imm_U      <= cu_if.imm_U;

                // CPU Tracker
                ex_mem_if.ex_mem_reg.tracker_signals.opcode <= cu_if.opcode;
                ex_mem_if.ex_mem_reg.tracker_signals.imm_SB <= cu_if.imm_SB;
                ex_mem_if.ex_mem_reg.tracker_signals.imm_S  <= cu_if.imm_S;
                ex_mem_if.ex_mem_reg.tracker_signals.imm_I  <= cu_if.imm_I;
                ex_mem_if.ex_mem_reg.tracker_signals.imm_UJ <= cu_if.imm_UJ;
                ex_mem_if.ex_mem_reg.tracker_signals.imm_U  <= cu_if.imm_U;

            end else if(hazard_if.ex_mem_flush && !hazard_if.ex_mem_stall) begin
                ex_mem_if.ex_mem_reg <= '{default: '0};
            end
            // else: retain state
        end
    end

    ////
    // HERE BELOW WAS MOVED TO MEMORY STAGE
    ////

    /*******************************************************
  *** Data Ram Interface Logic
  *******************************************************/
    /*
    logic [1:0] byte_offset;

    // RISC-MGMT connection
    assign rm_if.mem_load       = dgen_bus_if.rdata;

    assign dgen_bus_if.ren      = rm_if.req_mem ? rm_if.mem_ren : cu_if.dren & ~mal_addr & ~prv_pipe_if.prot_fault_l;
    assign dgen_bus_if.wen      = rm_if.req_mem ? rm_if.mem_wen : cu_if.dwen & ~mal_addr & ~prv_pipe_if.prot_fault_s;
    assign byte_en_temp         = rm_if.req_mem ? rm_if.mem_byte_en : byte_en_standard;
    assign dgen_bus_if.byte_en  = byte_en;
    assign dgen_bus_if.addr     = rm_if.req_mem ? rm_if.mem_addr : alu_if.port_out;
    assign hazard_if.d_mem_busy = dgen_bus_if.busy;
    assign byte_offset          = alu_if.port_out[1:0];

    always_comb begin
        dgen_bus_if.wdata = '0;
        if (rm_if.req_mem) dgen_bus_if.wdata = rm_if.mem_store;
        else begin
            case (cu_if.load_type)  // load_type can be used for store_type as well
                LB: dgen_bus_if.wdata = {4{rf_if.rs2_data[7:0]}};
                LH: dgen_bus_if.wdata = {2{rf_if.rs2_data[15:0]}};
                LW: dgen_bus_if.wdata = rf_if.rs2_data;
            endcase
        end
    end


    // Assign byte_en based on load type
    // funct3 for loads and stores are the same bit positions
    // byte_en is valid for both loads and stores
    always_comb begin
        unique case (cu_if.load_type)
            LB: begin
                unique case (byte_offset)
                    2'b00:   byte_en_standard = 4'b0001;
                    2'b01:   byte_en_standard = 4'b0010;
                    2'b10:   byte_en_standard = 4'b0100;
                    2'b11:   byte_en_standard = 4'b1000;
                    default: byte_en_standard = 4'b0000;
                endcase
            end
            LBU: begin
                unique case (byte_offset)
                    2'b00:   byte_en_standard = 4'b0001;
                    2'b01:   byte_en_standard = 4'b0010;
                    2'b10:   byte_en_standard = 4'b0100;
                    2'b11:   byte_en_standard = 4'b1000;
                    default: byte_en_standard = 4'b0000;
                endcase
            end
            LH: begin
                unique case (byte_offset)
                    2'b00:   byte_en_standard = 4'b0011;
                    2'b10:   byte_en_standard = 4'b1100;
                    default: byte_en_standard = 4'b0000;
                endcase
            end
            LHU: begin
                unique case (byte_offset)
                    2'b00:   byte_en_standard = 4'b0011;
                    2'b10:   byte_en_standard = 4'b1100;
                    default: byte_en_standard = 4'b0000;
                endcase
            end
            LW:      byte_en_standard = 4'b1111;
            default: byte_en_standard = 4'b0000;
        endcase
    end
    */

    // Fence instructions

    // posedge detector for ifence
    // subsequent ifences will have same effect as a single fence
    /*
    logic ifence_reg;
    logic ifence_pulse;

    always_ff @(posedge CLK, negedge nRST) begin
        if (~nRST) ifence_reg <= 1'b0;
        else ifence_reg <= cu_if.ifence;
    end

    assign ifence_pulse = cu_if.ifence && ~ifence_reg;
    assign cc_if.icache_flush = ifence_pulse;
    assign cc_if.icache_clear = 1'b0;
    assign cc_if.dcache_flush = ifence_pulse;
    assign cc_if.dcache_clear = 1'b0;

    //regs to detect flush completion
    logic dflushed, iflushed;

    always_ff @(posedge CLK, negedge nRST) begin
        if (~nRST) iflushed <= 1'b1;
        else if (ifence_pulse) iflushed <= 1'b0;
        else if (cc_if.iflush_done) iflushed <= 1'b1;
    end

    always_ff @(posedge CLK, negedge nRST) begin
        if (~nRST) dflushed <= 1'b1;
        else if (ifence_pulse) dflushed <= 1'b0;
        else if (cc_if.dflush_done) dflushed <= 1'b1;
    end

    assign hazard_if.fence_stall = cu_if.ifence && (~dflushed || ~iflushed);
    */

    /*******************************************************
  *** Hazard Unit Interface Logic
  *******************************************************/
    /*assign hazard_if.dren    = cu_if.dren;
    assign hazard_if.dwen    = cu_if.dwen;
    assign hazard_if.jump    = cu_if.jump;
    assign hazard_if.branch  = cu_if.branch;
    assign hazard_if.halt    = halt;

    always_ff @(posedge CLK, negedge nRST) begin
        if (~nRST) halt <= 1'b0;
        else if (cu_if.halt) halt <= cu_if.halt;
    end*/

    /*******************************************************
  *** CSR / Priv Interface Logic
  *******************************************************/
  /*
    assign prv_pipe_if.swap = cu_if.csr_swap;
    assign prv_pipe_if.clr = cu_if.csr_clr;
    assign prv_pipe_if.set = cu_if.csr_set;
    assign prv_pipe_if.wdata = cu_if.csr_imm ? {27'h0, cu_if.zimm} : rf_if.rs1_data;
    assign prv_pipe_if.csr_addr = cu_if.csr_addr;
    assign prv_pipe_if.valid_write = (prv_pipe_if.swap | prv_pipe_if.clr |
                                    prv_pipe_if.set) & ~hazard_if.if_ex_stall;
    assign prv_pipe_if.instr = (cu_if.instr != '0);

    
    


    //Send exceptions to Hazard Unit
    assign hazard_if.fault_l = 1'b0;
    assign hazard_if.mal_l = cu_if.dren & mal_addr;
    assign hazard_if.fault_s = 1'b0;
    assign hazard_if.mal_s = cu_if.dwen & mal_addr;
    assign hazard_if.breakpoint = cu_if.breakpoint;
    assign hazard_if.env_m = cu_if.ecall_insn;
    assign hazard_if.ret = cu_if.ret_insn;
    assign hazard_if.badaddr_e = dgen_bus_if.addr;

    */
    // TODO: Illegal instruction checks. Maybe pass these on to next stage?
    //assign hazard_if.illegal_insn = (cu_if.illegal_insn & ~rm_if.ex_token)
    //                                | prv_pipe_if.invalid_csr;
    //assign hazard_if.illegal_insn = 1'b0;

    //assign hazard_if.epc_e = fetch_ex_if.fetch_ex_reg.pc;
    //assign hazard_if.token_ex = fetch_ex_if.fetch_ex_reg.token;

    // setup signals for memory protection
    //  not considering risc-mgmt here TODO
    /*
    assign prv_pipe_if.dren  = cu_if.dren & ~mal_addr;
    assign prv_pipe_if.dwen  = cu_if.dwen & ~mal_addr;
    assign prv_pipe_if.daddr = alu_if.port_out;
    assign prv_pipe_if.d_acc_width = WordAcc;
    */

    /*********************************************************
  *** Branch Predictor Logic
  *********************************************************/
    /*
    assign predict_if.update_predictor = cu_if.branch;
    assign predict_if.prediction = fetch_ex_if.fetch_ex_reg.prediction;
    assign predict_if.branch_result = branch_if.branch_taken;
    //predict_if.update_addr = ;
    */

    /*********************************************************
  *** SparCE Module Logic
  *********************************************************/
    assign sparce_if.wb_data = rf_if.w_data;
    assign sparce_if.wb_en = rf_if.wen;
    assign sparce_if.sasa_data = rf_if.rs2_data;
    assign sparce_if.sasa_addr = alu_if.port_out;
    assign sparce_if.sasa_wen = cu_if.dwen;
    assign sparce_if.rd = rf_if.rd;

    /*********************************************************
  *** Signals for Bind Tracking - Read-Only, These don't affect execution
  *********************************************************/
    /*
    logic wb_stall;
    logic [2:0] funct3;
    logic [11:0] funct12;
    logic instr_30;

    assign wb_stall = hazard_if.if_ex_stall & ~hazard_if.jump & ~hazard_if.branch;
    assign funct3   = cu_if.instr[14:12];
    assign funct12  = cu_if.instr[31:20];
    assign instr_30 = cu_if.instr[30];
    */

endmodule
