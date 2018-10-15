`timescale 1ns/100ps
module tb_s_to_u();

   reg        sign;
   reg [24:0] frac_unsigned;
   reg [25:0] frac_signed = 0;
   
   s_to_u DUT (.sign(sign), .frac_unsigned(frac_unsigned), .frac_signed(frac_signed));

   int 	      i;
   
   initial begin
      for(i = 0; i < 2 ** 26; i++) begin
	 #1;
	 
	 frac_signed++;

      end
   end

endmodule
