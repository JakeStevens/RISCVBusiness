`timescale 1ns/10ps
module tb_max_select();

   reg [7:0] exp1 = 0;
   reg [7:0] exp2 = 0;
   reg [7:0] max;
   int       i    = 0;
   
   max_select DUT (.exp1(exp1), .exp2(exp2), .max(max));

   initial begin
      for(exp1 = 0; i <= 255; i++) begin
	 for(exp2 = 0; exp2 < i; exp2++) begin
	    #1;
	    assert(max == exp1) else $error("Wrong max output");
	 end
	 exp1++;
      end
					    
      i = 0;
      for(exp2 = 0; i <= 255; i++) begin
	 for(exp1 = 0; exp1 < i; exp1++) begin
	    #1;
	    assert(max == exp2) else $error("Wrong max output");
	 end
	 exp2++;
      end
      
   end
      
	 
endmodule
