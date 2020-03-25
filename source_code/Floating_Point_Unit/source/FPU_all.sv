`include "FPU_all_if.vh"
`include "f_register_file_if.vh"

module FPU_all
(
 input 	       clk,
 input 	       nrst,
 FPU_all_if.fp fpif 
 );
logic [31:0] f_rs1_data, f_rs2_data;

logic [7:0] f_funct_7;

FPU_top_level FPU(
.clk(clk), 
.nrst(nrst),
.floating_point1(f_rs1_data),
.floating_point2(f_rs2_data),
.frm(fpif.frm),
.funct7(f_funct_7),
.floating_point_out(fpif.FPU_out),
.flags(fpif.flags)
);

f_register_file(
.clk(clk),
.nrst(nrst),
.f_w_data(fpif.FPU_out),		//TODO
.f_rs1(fpif.f_rs1), 
.f_rs2(fpif.f_rs2),
.f_rd(fpif.f_rd),
.f_wen(fpif.f_wen),
.f_NV(fpif.flags[4]),
.f_DZ(fpif.flags[3]),  
.f_OF(fpif.flags[2]),
.f_UF(fpif.flags[1]),
.f_NX(fpif.flags[0]),
.f_frm_in(fpif.frm),
.f_frm_out(fpif.frm_out),
.f_rs1_data(fpif.f_rs1_data),
.f_rs2_data(fpif.f_rs2_data),
.f_flags(fpif.f_flags)
);

endmodule
