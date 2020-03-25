`timescale 1ns/100ps 
module tb_left_shift();

   reg [25:0] fraction = 1;
   reg [25:0] result;
   reg [7:0]  shifted_amount;

   left_shift DUT (.fraction(fraction), .result(result), .shifted_amount(shifted_amount));

   int 	      i;
   
   initial begin
      for(i = 0; i < 26; i++) begin
	 #1;
	 assert(result == 26'b10000000000000000000000000) else $error("incorect result");
	 assert(shifted_amount == (25 - i)) else $error("incorrect shifted_amount");
	 
	 fraction = fraction << 1;
      end
   end
   
endmodule
