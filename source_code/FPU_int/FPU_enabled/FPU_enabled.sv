`include "FPU_all_if.vh"
`include "f_register_file_if.vh"

module FPU_enabled
(
 input 	       clk,
 input 	       nrst,
 FPU_all_if.fp fpif 
 );
//logic [31:0] f_rs1_data, f_rs2_data;

//logic [6:0] f_funct_7;

//assign f_funct_7 = '0;

//assign f_rs1_data = frif.f_rs1_data;
//assign f_rs2_data = frif.f_rs2_data;
//assign 

FPU_top_level FPU(
.clk(clk), 
.nrst(nrst),
.floating_point1(frif.f_rs1_data),
.floating_point2(frif.f_rs2_data),
.frm(frif.f_frm_out),
.funct7(fpif.f_funct_7),
.floating_point_out(fpif.FPU_out),
.flags(fpif.f_flags)
);

f_register_file_if frif(); 

assign frif.f_rs1 = fpif.f_rs1;
assign frif.f_rs2 = fpif.f_rs2;
assign frif.f_rd  = fpif.f_rd;
assign frif.f_frm_in = fpif.frm;
assign frif.f_wen = fpif.f_wen;
assign frif.f_w_data = fpif.f_LW ? fpif.f_LW_data : fpif.FPU_out;

f_register_file f_reg(
.CLK(clk),
.nRST(nrst),
.frf_if(frif)
);

endmodule
