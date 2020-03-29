//By            : Joe Nasti
//Last Updated  : 7.16.18
//
//Module Summary: 
//    adds two signed 26 bit fraction values
//
//Inputs:
//    frac1/2 - signed 26 bit values with decimal point fixed after second bit
//Outputs:
//    sum     - output of sum operation regardless of overflow
//    ovf     - high if an overflow has occured 
 
module sub_26b(
	input      [26:0] frac1,
	input      [26:0] frac2, 
	output reg [26:0] sum, 
	output reg        ovf
);
   reg [26:0] 		  frac1_compute;
   reg [26:0] 		  frac2_compute;
   reg [26:0] 		  temp_sum;
   
always_comb begin
   //find the two's complement of the frac2
   /*if (frac2[26] == 1) begin
      frac2_compute[26] = frac2[26];
      frac2_compute[25:0] = (~frac2[25:0] + 1'b1);
   end else if (frac2[26] == 0) begin
      frac2_compute = frac2;
   end
   sum = frac1 + frac2_compute;*/
   //sum = ~temp_sum;
   temp_sum = frac1 + frac2;
   //sum = frac1 + frac2;
   sum[26:0] = ~temp_sum[26:0] + 1'b1;
   
   ovf = 0;
   
   if(frac1[26] == 1 && frac2[26]== 1 && sum[26] == 0) begin
      ovf = 1;
      sum[26] = 1;
   end
   
   if(frac1[26] == 0 && frac2[26]== 0 && sum[26] == 1) begin
      ovf = 1;
      sum[26] = 0;
   end
  
end
endmodule
