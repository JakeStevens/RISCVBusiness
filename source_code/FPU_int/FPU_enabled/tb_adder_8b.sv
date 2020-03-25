`timescale 1ps/1ps
module tb_adder_8b();

reg [7:0] exp1;
reg [7:0] exp2;
reg [7:0] sum;
reg       ovf;
reg 	  unf;
   
	  
adder_8b DUT (
	      .exp1(exp1), 
	      .exp2(exp2), 
	      .sum(sum), 
	      .ovf(ovf), 
	      .unf(unf)
	      );

   reg [7:0] r_j;
   reg [7:0] r_i;
   reg [7:0] r_sum;

   assign r_sum = r_i + r_j - 8'b10000000;
   
initial begin
        exp1 = 0;
        exp2 = 0;
	for(int i = 0; i != 256; i = i + 1) begin 
		for(int j = 0; j != 256; j = j + 1) begin
		        r_j = j;
		        r_i = i;
		   #1;
		   assert(sum == ((r_i + r_j) - 8'b10000000))
		   else $error("incorrect sum: expected = %d | calculated = %d", (r_i + r_j - 8'b10000000), sum);
		   if((i + j) < 128) assert(unf == 1) else $error("incorrect 1 unf");
		   if((i + j) > 383) assert(ovf == 1) else $error("incorrect 1 ovf");
		   #1000;
		   
		   exp2 = exp2 + 1;
		  
		end
	   exp1 = exp1 + 1;
	   exp2 = 0;
	end
end
endmodule
