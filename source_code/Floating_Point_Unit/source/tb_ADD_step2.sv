`timescale 1ns/100ps
module tb_ADD_step2();

   reg [25:0] frac1;
   reg        sign1;
   reg [25:0] frac2;
   reg        sign2;
   reg [7:0]  exp_max_in;
   reg [2:0]  frm_in;
   reg        sign_out;
   reg [25:0] sum;
   reg        carry_out;
   reg [7:0]  exp_max_out;
   reg [2:0]  frm_out;


   ADD_step2 DUT (
		  .frac1(frac1),
		  .sign1(sign1),
		  .frac2(frac2),
		  .sign2(sign2),
		  .exp_max_in(exp_max_in),
		  .frm_in(frm_in),
		  .sign_out(sign_out),
		  .sum(sum),
		  .carry_out(carry_out),
		  .exp_max_out(exp_max_out),
		  .frm_out(frm_out)
		  );

   initial begin
      frac1 = 0;
      frac2 = 0;
      sign1 = 0;
      sign2 = 0;
      exp_max_in = 0;
      frm_in = 0;

      for(int i = 0; 1; i++) begin
	 frac1 = i * (2 ** 20);
	 sign1 = ~sign1;
	 for(int j = 0; j < 10; j++) begin
	    frac2 = j * (2 ** 20) + i * (2 ** 18);
	    sign2 = ~sign2;
	    #1;
	 end
      end
   end // initial begin
endmodule // tb_ADD_step2

	    

   
	      
