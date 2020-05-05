module c_to_cp
  (
   input [25:0] frac2_input,//25
   input [26:0] frac2_signedin,
   output reg [25:0] frac2_output,//25
   output reg [26:0] frac2_signedout
   );
 
   always_comb begin
   //find the two's complement of the frac2
      frac2_output[25:0] = (~frac2_input[25:0] + 1'b1);//25
      frac2_signedout[26:0] = (~frac2_signedin[26:0] + 1'b1);
   end
   
   
endmodule // c_to_cp
