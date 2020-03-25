// functional test bench

`timescale 1ns/100ps
module tb_adder_26b();

reg [26:0] frac1;
reg [26:0] frac2;
reg [26:0] sum;
reg 	   carry_out;

adder_26b DUT (.frac1(frac1), .frac2(frac2), .sum(sum), .ovf(carry_out));

initial begin
        frac1 = 0;
        frac2 = 0;
	// check some inputs of frac1 and frac2
	for(int i = 0; i < 2 ** 27; i = i + 2 ** 20) begin 
		for(int j = 0; j < 2 ** 27; j = j + 2 ** 20) begin
		    #1;
	      	    assert(sum == (frac1 + frac2)) else $error("incorrect sum");
		    if((frac1[26] == 1 && frac2[26]== 1 && sum[26] == 0) || (frac1[26] == 0 && frac2[26]== 0 && sum[26] == 1)) assert(carry_out == 1) else $error("incorrect 0 ovf. Expected 1"); 
	            else assert(carry_out == 0) else $error("incorrect 1 ovf. Expeected 0");
		    frac2 = frac2 + 2 ** 20;
		  
		end
	   frac1 = frac1 + 2 ** 20;
	   frac2 = 0;
	end
end
endmodule
