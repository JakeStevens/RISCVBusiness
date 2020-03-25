`timescale 1ns/100ps
module tb_subtract();

   reg [7:0] exp1 = 0;
   reg [7:0] shifted_amount = 0;
   reg [7:0] result;

   subtract DUT (.exp1(exp1), .shifted_amount(shifted_amount), .result(result));

   int 	     i;
   int 	     j;
   
   initial begin
      
      for(i = 0; i < 256; i++) begin
	 shifted_amount = 0;
	 for(j = 0; j <= i; j++) begin
	    if(j < 26) #1;
	    shifted_amount = shifted_amount + 1;
	 end
	 exp1 = exp1 + 1;
      end
   end
   
endmodule
