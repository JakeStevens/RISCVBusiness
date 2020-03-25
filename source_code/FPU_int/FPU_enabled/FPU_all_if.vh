`ifndef FPU_ALL_IF_VH
`define FPU_ALL_IF_VH

interface FPU_all_if;

logic [31:0] f_rd, f_rs1, f_rs2, FPU_out;
logic f_LW, f_wen;
logic [2:0] frm, frm_out;
logic [4:0] f_flags;

modport fp(
  input f_rd, f_rs1, f_rs2, frm, f_LW, f_wen, 
  output FPU_out, f_flags, frm_out
);

endinterface
`endif
