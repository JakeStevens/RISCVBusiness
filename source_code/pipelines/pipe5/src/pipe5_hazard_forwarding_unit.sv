
`include "pipe5_hazard_forwarding_unit_if.vh"
`include "prv_pipeline_if.vh"


module pipe5_hazard_forwarding_unit(
    pipe5_hazard_forwarding_unit_if.hazard_unit hazard_if,
    prv_pipeline_if.hazard prv_pipeline_if
);

    import alu_types_pkg::*;
    import rv32i_types_pkg::*;
    import pipe5_types_pkg::*;


    // Pipeline hazard signals
    logic dmem_access;
    logic branch_jump;
    logic wait_for_imem;
    logic wait_for_dmem;


    // IRQ/Exception hazard signals
    logic exception;

    assign prv_pipe_if.ret = hazard_if.ret;
    assign exception =    hazard_if.fault_insn 
                       || hazard_if.mal_insn 
                       || hazard_if.illegal_insn 
                       || hazard_if.fault_ld
                       || hazard_if.mal_ld 
                       || hazard_if.fault_st 
                       || hazard_if.mal_st 
                       || hazard_if.breakpoint 
                       || hazard_if.env_m;
  
    assign intr = ~exception & prv_pipe_if.intr;
    assign prv_pipe_if.pipe_clear = ctl_hazard;
    assign hazard_if.insert_priv_pc = prv_pipe_if.insert_pc;
    assign hazard_if.priv_pc = prv_pipe_if.priv_pc;

    // Connect IRQ/Exception to priv unit
    assign prv_pipe_if.wb_enable    = !hazard_if.mw_stall && !hazard_if.mw_flush;
    assign prv_pipe_if.fault_insn   = hazard_if.fault_insn;
    assign prv_pipe_if.mal_insn     = hazard_if.mal_insn;
    assign prv_pipe_if.illegal_insn = hazard_if.illegal_insn;
    assign prv_pipe_if.fault_l      = hazard_if.fault_l;
    assign prv_pipe_if.mal_l        = hazard_if.mal_l;
    assign prv_pipe_if.fault_s      = hazard_if.fault_s;
    assign prv_pipe_if.mal_s        = hazard_if.mal_s;
    assign prv_pipe_if.breakpoint   = hazard_if.breakpoint;
    assign prv_pipe_if.env_m        = hazard_if.env_m;

    assign prv_pipe_if.epc          = hazard_if.epc;
    assign prv_pipe_if.badaddr      = hazard_if.badaddr;

    /** Data hazards/forwarding **/
    // RAW Hazards
    // The only RAW hazards we cannot forward are things that produce
    // values in 'M', which are loads and CSR instructions.
    // Hazard strategy: detect between D/X, stall frontend of pipeline
    // while flushing X
    logic raw_hazard, dx_forwardable;
    // D->X RAW forwardable if X produces value in X
    assign dx_forwardable = (!hazard_if.d_dwen && !hazard_if.d_dren
                                && !hazard_if.d_csr_access);
    // Hazard if it's 1) not forwardable, 2) input regs of D
    // match either of the output regs of X
    // 3) X output reg is nonzero (0 reg will not change arch state)
    assign raw_hazard = (hazard_if.rd_x != '0 
                        && (hazard_if.rd_x == hazard_if.rs1_d
                        || hazard_if.rd_x == hazard_if.rs2_d)
                        && !dx_forwardable);
    
    // Forwarding
    always_comb begin : FORWARD_RS1
        if(hazard_if.rs1_x == hazard_if.rd_m
            && hazard_if.rd_m != '0) begin
            hazard_if.bypass_rs1 = FWD_M;
        end else if(hazard_if.rs1_x == hazard_if.rd_w
            && hazard_if.rd_w != '0) begin
            hazard_if.bypass_rs1 = FWD_W;
        end else begin
            hazard_if.bypass_rs1 = NO_FWD;
        end
    end

    always_comb begin : FORWARD_RS2
        if(hazard_if.rs2_x == hazard_if.rd_m) begin
            hazard_if.bypass_rs2 = FWD_M;
        end else if(hazard_if.rs2_x == hazard_if.rd_w) begin
            hazard_if.bypass_rs2 = FWD_W;
        end else begin
            hazard_if.bypass_rs2 = NO_FWD;
        end
    end

    // Control flow hazards
    // Interrupts, exceptions, and branch/jump handled in mem stage
    // Consequently, the pipeline stages affected for any of these
    // are identical.
    logic ctl_hazard;
    assign branch_jump = hazard_if.jump || (hazard_if.branch && hazard_if.mispredict);
    assign npc_sel = branch_jump; // TODO: What is this?
    assign ctl_hazard = ;

    // Multicycle operation hazards
    assign wait_for_imem = hazard_if.iren && hazard_if.if_busy; 

    // Pipeline control
    // Controls for flush/stall of stages based on derived control signals
    // TODO: Accomodate multi-cycle, unpipelined operations (RISC-MGMT)
    // TODO: Check this again.
    always_comb begin
        // Default values
        hazard_if.pc_en = 1'b1;
        hazard_if.fd_stall = 1'b0;
        hazard_if.dx_stall = 1'b0;
        hazard_if.xm_stall = 1'b0;
        hazard_if.mw_stall = 1'b0; // MW must stall to preserve forwarding path
        hazard_if.fd_flush = 1'b0;
        hazard_if.dx_flush = 1'b0;
        hazard_if.xm_flush = 1'b0;
        hazard_if.mw_flush = 1'b0;
        
        // Priority here matters:
        // CTL Hazard kills all prior insns, so their hazards would not matter
        // DMEM hazard supercedes RAW, since M stage needs to stall everything behind
        // RAW supercedes imem since we have to advance the pipeline for data read to matter
        // IMEM lowest since everything else can progress normally
        if(ctl_hazard) begin
            hazard_if.xm_flush = 1'b1;
            hazard_if.dx_flush = 1'b1;
            hazard_if.fd_flush = 1'b1;
            hazard_if.pc_en = 1'b1; // TODO: Need to enable PC to get updated value?
        end else if(hazard_if.m_busy) begin
            // This is the case of memory read/write taking multiple cycles.
            // No CTL hazard so it's safe to disable PC. NOT safe to 
            // disable 
            hazard_if.mw_stall = 1'b1; // Could have W->X forwarding path we need to preserve
            hazard_if.xm_stall = 1'b1;
            hazard_if.dx_stall = 1'b1;
            hazard_if.fd_stall = 1'b1;
            hazard_if.pc_en = 1'b0;
        end else if(hazard_if.x_busy) begin
            // This is the case of a multi-cycle operation.
            // No CTL hazard (safe to disable PC). M is single-cycle due to priority scheme,
            // we can let M & W continue while we wait. 
            // TODO: ASSUMPTION: Forwarding completes in first cycle, value is latched into multicycle
            // operation unit. Is this ok?
            // Flush XM to prevent multiple copies of current insn in X
            hazard_if.dx_stall = 1'b1;
            hazard_if.fd_stall = 1'b1;
            hazard_if.pc_en = 1'b0;
            hazard_if.xm_flush = 1'b1;
        end else if(raw_hazard) begin // Can't stall W here
            // This is case of load-use or CSR-use instruction sequence
            // Only stall front of pipeline to allow forwarding path to open from W -> X
            hazard_if.dx_flush = 1'b1;
            hazard_if.fd_stall = 1'b1;
            hazard_if.pc_en = 1'b0;
        end else if(hazard_if.f_busy) begin
            // This is case of waiting on instruction read.
            // Only stall fetching, inject nops into downstream.
            hazard_if.fd_flush = 1'b1;
            hazard_if.pc_en = 1'b0;
        end
    end

endmodule
