`timescale 1ns/100ps
module tb_mul_26b();
   reg [25:0] frac_in1;
   reg [25:0] frac_in2;
   reg [25:0] frac_out;
   reg        overflow;

   mul_26b DUT (
		.frac_in1(frac_in1),
		.frac_in2(frac_in2),
		.frac_out(frac_out),
		.overflow(overflow)
		);

   initial begin
      frac_in1 = 26'b10101010101010101010101010;
      frac_in2 = 26'b10000000000000000000000000;
      #1;
      frac_in1 = 26'b01010101010101010101010101;
      #1;
      frac_in1 = 26'b11111111111111111111111111;
      frac_in2 = 26'b10000000000000000000000001;
      #1;
      frac_in1 = 26'b00000000000000000000000000;
      #1;
   end
endmodule // tb_mul_26b

      
