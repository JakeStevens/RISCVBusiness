`timescale 1ns/100ps
module tb_right_shift();

   reg [24:0] fraction;
   reg [7:0]  shift_amount = 8'b00000000;
   reg [24:0] result;
   int        i;
   
   right_shift DUT (.fraction(fraction), .shift_amount(shift_amount), .result(result));

   initial begin
      i = 0;
      
	for(fraction = 0; i < 32; i++) begin
	   for(shift_amount = 0; shift_amount < 230; shift_amount = shift_amount + 1) begin
	      #1;
	      //if(shift_amount < 20) begin
	      //   assert(fraction[24:20] == result[24 - shift_amount:20 - shift_amount]) else $error("incorrect result");              
	      //end
	   end
	   fraction = fraction + 2 ** 20;
	end
   end
  




endmodule
