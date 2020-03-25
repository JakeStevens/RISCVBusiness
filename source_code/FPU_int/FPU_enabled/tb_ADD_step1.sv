`timescale 1ns/100ps
module tb_ADD_step1();

   reg [31:0] floating_point1_in;   
   reg [31:0] floating_point2_in;   
   reg [2:0]  frm_in;   
   reg [2:0]  frm_out;   
   reg        sign_shifted;   
   reg [25:0] frac_shifted;   
   reg 	      sign_not_shifted;   
   reg [25:0] frac_not_shifted;   
   reg [7:0]  exp_max;

   reg 	      sign1;
   reg [7:0]  exp1;
   reg [22:0] frac1;
   reg 	      sign2;
   reg [7:0]  exp2;
   reg [22:0] frac2;

   assign floating_point1_in[31]    = sign1;
   assign floating_point1_in[30:23] = exp1;
   assign floating_point1_in[22:0]  = frac1;
   assign floating_point2_in[31]    = sign2;
   assign floating_point2_in[30:23] = exp2;
   assign floating_point2_in[22:0]  = frac2;
   
   ADD_step1 DUT (
		  .floating_point1_in(floating_point1_in),
		  .floating_point2_in(floating_point2_in),
		  .frm_in(frm_in),
		  .frm_out(frm_out),
		  .sign_shifted(sign_shifted),
		  .frac_shifted(frac_shifted),
		  .sign_not_shifted(sign_not_shifted),
		  .frac_not_shifted(frac_not_shifted),
		  .exp_max(exp_max)
		  );

   initial begin
      frm_in = 0;
      sign1 = 0;
      sign2 = 1;
      exp1  = 0;
      exp2  = 0;
      frac1 = 0;
      frac2 = 0;

      for(int i = 0; i < 256; i++) begin
	 exp1  = i;
	 frac1 = i * (2 ** 15);
	 for(int j = 0; j <= i; j++) begin
	    exp2  = j;
	    frac2 = j * (2 ** 10);
	    #1;

	 end
      end
   end // initial begin
endmodule // tb_ADD_step1

	    
