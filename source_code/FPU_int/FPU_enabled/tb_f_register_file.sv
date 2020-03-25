`timescale 1ps/1ps
module tb_f_register_file();


   logic [7:0] f_w_data, f_rs1_data, f_rs2_data;
  logic   [4:0] f_rs1, f_rs2, f_rd;
  logic         f_wen, f_NV, f_DZ, f_OF, f_UF, f_NX;
  logic [2:0] f_frm_in;
  logic [2:0] f_frm_out;
  logic [4:0] f_flags;
 
  
   reg clk = 0;
   reg nrst;
    
   always begin
      clk = ~clk;
      #1;
   end

   FPU_top_level DUT (
		      .clk(clk),
		      .nrst(nrst),
		      .f_w_data(f_w_data),
		      .f_rs1_data(f_rs1_data),
		      .f_rs2_data(f_rs2_data),
		      .f_rs1(f_rs1),
		      .f_rs2(f_rs2),
		      .f_rd(f_rd),
		      .f_wen(f_wen),
		      .f_NV(f_NV),
		      .f_DZ(f_DZ),
		      .f_OF(f_OF),
		      .f_UF(f_NX),
		      .f_frm_in(f_frm_in),
		      .f_frm_out(f_frm_out),
		      .f_flags(f_flags)
		      );
   

   
initial begin

end
endmodule
