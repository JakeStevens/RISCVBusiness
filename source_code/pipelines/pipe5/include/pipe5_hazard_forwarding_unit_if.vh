

`ifndef PIPE5_HAZARD_UNIT_IF_VH
`define PIPE5_HAZARD_UNIT_IF_VH

interface pipe5_hazard_forwarding_unit_if();

    import rv32i_types_pkg::word_t;

    // Pipeline Control Signals
    logic pc_en, npc_sel;
    logic fd_stall, dx_stall, xm_stall, mw_stall;
    logic fd_flush, dx_flush, xm_flush, mw_flush;
    logic iren; // TODO: Should hazard unit generate this?

    // Pipeline status signals
    logic f_busy, x_busy, m_busy;
    logic dren, dwen;
    logic fence_stall;
    logic branch_taken, prediction, jump, branch,
          mispredict, halt, ret;
    word_t pc;

    // Pipeline exception signals
    logic fault_insn, mal_insn, illegal_insn, 
          fault_ld, mal_ld, fault_st, mal_st,
          breakpoint, env_m;
    // TODO: Exception handling: Do we force it to wait for memory?
    word_t epc_f, epc_m, badaddr_f, badaddr_m;

    // Priv unit status signals
    word_t priv_pc;
    logic insert_priv_pc;

    // Dependency Tracking Signals
    logic [4:0] rs1_x, rs2_x, rd_m, rd_w;
    logic regWEN_m, regWEN_w;

    // Forwarding control
    pipe5_types_pkg::bypass_t bypass_a, bypass_b; // Forwarding paths into ALU
    // Forwarding paths for non-ALU uses of rs1 and rs2. Covers cases like JALR, CSRRW, Branch, etc.
    // TODO: Do we need the above ones? We could place forwarding muxes such that their
    // outputs feed to both the ALU and the next pipeline stage...
    pipe5_types_pkg::bypass_t bypass_rs1, bypass_rs2;

    
    modport hazard_forwarding_unit(
        input   f_busy, x_busy, m_busy, dren, dwen, fence_stall, branch_taken,
                prediction, jump, branch, mispredict, halt, ret, pc,
                fault_insn, mal_insn, illegal_insn, fault_ld, mal_ld, fault_st, mal_st,
                breakpoint, env_m, epc_f, epc_m, badaddr_f, badaddr_m,
                rs1_x, rs2_x, rd_m, rd_w, regWEN_m, regWEN_w,

        output  pc_en, npc_sel, fd_stall, dx_stall, xm_stall, mw_stall,
                fd_flush, dx_flush, xm_flush, mw_flush, iren,
                priv_pc, insert_priv_pc,
                bypass_a, bypass_b, bypass_rs1, bypass_rs2
    );

    modport fetch(
        input   pc_en, npc_sel, fd_stall, fd_flush, 
                iren, priv_pc, insert_priv_pc,

        output  f_busy, fault_insn, mal_insn, epc_f, badaddr_f
    );

    modport decode(
        input   dx_stall, dx_flush
    );

    modport execute(
        input   xm_stall, xm_flush, x_busy, bypass_a, bypass_b,
                bypass_rs1, bypass_rs2, rs1_x, rs2_x,

        output  rs1_x, rs2_x
    );

    modport memory(
        input   mw_stall, mw_flush, npc_sel,

        output  m_busy, dren, dwen, jump, branch, mispredict, halt, ret,
                fault_ld, mal_ld, fault_st, mal_st, epc_m, badaddr_m, 
                fence_stall, breakpoint, env_m,
                rd_m, regWEN_m
    );

    modport writeback(
        output rd_w, regWEN_w
    );

endinterface
`endif
