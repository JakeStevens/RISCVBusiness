//By            : Joe Nasti
//Last Updated  : 7/18/18
//
//Module Summary: 
//    rounds floating point after the operation according to the frm (rounding mode)
//
//Inputs:
//    frm       - rounding mode
//    sign      - one bit sign of floating point
//    exp_in    - 8 bit exponent of floating point
//    fraction  - 25 bit fraction of floating point (2 extra least significant bits used for rounding)
//Ouputs:
//    rount_out - resulting floating point after rounding operation

module rounder_sub(
	       input      cmp_out,
	       input      [31:0] fp1,
	       input      [31:0] fp2,
	       input      [2:0]  frm,
	       input 		 sign,
	       input      [7:0]  exp_in,
	       input      [24:0] fraction,
	       input 	  carry_out,
	       output reg [31:0] round_out,
	       output            rounded,
	       output 	  [23:0] sol_frac
	       );
   reg        round_amount;
   reg 	[31:0] temp_round_out;
   reg  [22:0] temp_faction;
   reg  [7:0]  temp_exp;
   localparam RNE = 3'b000;
   localparam RZE = 3'b001;
   localparam RDN = 3'b010;
   localparam RUP = 3'b011;
   localparam RMM = 3'b100;
   reg diff_sign_determine;   

   assign diff_sign_determine = ((fp1[31] == 1) & (fp2[31] == 0)) ? 1:0;
   //assign temp_faction = fraction;
   assign same_sign_determine = (((fp1[31] == 0) & (fp2[31] == 0))) ? 1:0;
   always_comb begin
      round_amount = 0;
      if(fraction[24:2] != '1) begin
	 if(frm == RNE) begin
	    if(fraction[1:0] == 2'b11)
	      round_amount = 1;
	 end
	 else if(frm == RZE) begin
	    round_amount = 0;
	 end
	 else if(frm == RDN) begin
	 if(sign == 1 && ((fraction[0] == 1) || (fraction[1] == 1)))
	    round_amount = 1;
	 end
	 else if(frm == RUP) begin
	    if(sign == 0 && ((fraction[0] == 1) || (fraction[1] == 1)))
	      round_amount = 1;
	 end
	 else if(frm == RMM) begin
	    if(fraction[1] == 1)
	      round_amount = 1;
	 end
      end // if (fraction[24:2] != '1)
   end // always_comb

   assign rounded   = round_amount;
   assign temp_round_out = {sign, exp_in, fraction[24:2] + round_amount};
   //assign round_out = {sign, exp_in, fraction[24:2] + round_amount};
   assign sol_frac = fraction[24:2] + round_amount;

always_comb begin
	//if ((fraction[24] == 1'b1) & (carry_out == 1))begin
	if ((fraction[24] == 1'b1) & (carry_out == 1) & (same_sign_determine == 0)) begin
			temp_faction = fraction[23:1];
			temp_exp = exp_in - 1'b1;
	end else if ((fraction[24] == 1'b1) & (carry_out == 0) & (diff_sign_determine == 1))begin
			temp_faction = fraction[23:1];
			temp_exp = exp_in;
	//first value is greater than second one
	end else if ((fraction[24] == 1'b1) & (carry_out == 1) & (same_sign_determine == 1))begin
			temp_faction = fraction[24:2];
			temp_exp = exp_in;
	end else begin
		temp_faction = sol_frac[22:0];
		temp_exp = exp_in;
	end
end
   assign round_out = {sign, temp_exp, temp_faction};
endmodule
	    
	    
