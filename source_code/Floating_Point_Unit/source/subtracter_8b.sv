module subtracter_8b(
	input carry,
	input [7:0]  exp1,
	input [7:0]  exp2, 
	output [7:0] sum, 
	output 	     ovf,
	output 	     unf
);

   reg [7:0] 	     r_exp1;
   reg [7:0] 	     r_exp2;
   reg [7:0] 	     r_sum;
   

   always_comb begin
      r_exp1 = exp1 - 8'b10000000;
      r_exp2 = exp2 - 8'b10000000;
      r_sum  = r_exp1 - r_exp2;
   end
   
   assign sum = (exp1 - exp2) - 8'b10000000; // add with offset
   
   assign ovf = r_sum[7] && ~r_exp1[7] && ~r_exp2[7];
   assign unf = ((carry != 1) || (sum != 8'b11111111)) && (~r_sum[7] && r_exp1[7] && r_exp2[7]);

endmodule
