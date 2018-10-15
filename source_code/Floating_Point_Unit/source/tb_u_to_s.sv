`timescale 1ns/100ps
module tb_u_to_s();

   reg        sign = 0;
   reg [24:0] frac_unsigned = 0;
   reg [25:0] frac_signed;
   
   u_to_s DUT (.sign(sign), .frac_unsigned(frac_unsigned), .frac_signed(frac_signed));

   int 	      i;
   
   initial begin
      for(i = 0; i < 2 ** 26; i++) begin
	 #1;
	 
	 {sign, frac_unsigned} = {sign, frac_unsigned} + 1;

      end
   end

endmodule
