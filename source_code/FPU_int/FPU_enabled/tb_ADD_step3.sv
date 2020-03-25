`timescale 1ns/100ps
module tb_ADD_step3();
   reg [2:0]  frm;
   reg [7:0]  exponent_max_in;
   reg        sign_in;
   reg [25:0] frac_in;
   reg        carry_out;
   reg [31:0] floating_point_out;

   ADD_step3 DUT (
		  .frm(frm),
		  .exponent_max_in(exponent_max_in),
		  .sign_in(sign_in),
		  .frac_in(frac_in),
		  .carry_out(carry_out),
		  .floating_point_out(floating_point_out)
		  );

   initial begin
      frm = 0;
      exponent_max_in = 10;
      sign_in = 0;
      frac_in = 26'b10000000000000000000101011;
      carry_out = 1;
      #1;
      frm = 3'b100;
      exponent_max_in = 20;
      sign_in = 1;
      frac_in = 26'b00001000000000000010100101;
      carry_out = 0;
   end // initial begin
endmodule // tb_ADD_step3

 
