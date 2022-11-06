
module stage3_forwarding_unit(
    stage3_forwarding_unit_if.fw_unit fw_if
);

    logic rs1_match, rs2_match;

    assign rs1_match = (fw_if.rd_mem != 0) && (fw_if.rs1_e == fw_if.rd_mem);
    assign rs2_match = (fw_if.rd_mem != 0) && (fw_if.rs2_e == fw_if.rd_mem);

    assign fw_if.fwd_rs1 = rs1_match && fw_if.regWEN && !fw_if.load;
    assign fw_if.fwd_rs2 = rs2_match && fw_if.regWEN && !fw_if.load;

endmodule
