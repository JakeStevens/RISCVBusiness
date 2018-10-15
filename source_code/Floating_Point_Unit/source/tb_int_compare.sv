`timescale 1ns/100ps
module tb_int_compare();

   reg [7:0] exp1    = 0;
   reg [7:0] exp2    = 0;
   reg [7:0] u_diff;
   reg       cmp_out;
   int 	     i       = 0;
   
   int_compare DUT (.exp1(exp1), .exp2(exp2), .u_diff(u_diff), .cmp_out(cmp_out));

   initial begin
      
      for(exp2 = 0; i <= 255; exp2++) begin
	 for(exp1 = 0; exp1 < exp2; exp1++) begin
	    #1;
	    assert(cmp_out == 1'b1) else $error("incorrect cmp_out of 1");
	 end
	 i = i + 1;
      end

      for(exp1 = 0; exp1 <= 255; exp1++) begin
	 for(exp2 = 0; exp1 >= exp2; exp2++) begin
	    #1;
	    assert(cmp_out == 1'b0) else $error("incorrect cmp_out of 0");
	 end
      end
   end // initial begin
   
endmodule
