module SUB_step2
  (
   input         bothnegsub,
   input  [25:0] frac1,
   input         sign1,
   input  [25:0] frac2,
   input         sign2,
   input  [7:0]  exp_max_in, //
   input reg exp_determine,
   output        sign_out,
   output [25:0] sum,
   output        carry_out,
   output reg [7:0]  exp_max_out//
   );

   reg [26:0] 	 frac1_signed;
   reg [26:0] 	 frac2_signed;
   reg [26:0] 	 sum_signed;
   reg [25:0] 	 frac2_complement; //25
   reg [26:0]	 frac2_signedout;
	 
   
   always_comb begin : exp_max_assignment
      if(sum_signed == 0) exp_max_out = 8'b00000000;
      else exp_max_out = exp_max_in;
   end

   /*always_comb begin : exp_determine
   if (bothnegsub) begin
	exp_determine = 1'b1;
   end
   end*/
   //change to signed value. either {0, frac} or {0, ~frac} if sign is 1
   u_to_s change_to_signed1(
			    .sign(sign1),
			    .frac_unsigned(frac1),
			    .frac_signed(frac1_signed)
			    );
   
   u_to_s change_to_signed2(
			    .sign(sign2),
			    .frac_unsigned(frac2),
			    .frac_signed(frac2_signed)
			    );
   
   //change the floating points to its two's complement
   c_to_cp change_to_complement(
				.frac2_input(frac2),
				.frac2_signedin(frac2_signed),
<<<<<<< HEAD
				.frac2_output(frac2_complement), //unsigned output
				.frac2_signedout(frac2_signedout) //signed output
				);
   //perform subtraction
=======
				.frac2_output(frac2_complement),
				.frac2_signedout(frac2_signedout)
				);
	/*c_to_cp change_to_complement(
				.frac2_input(frac2_signed),
				//.frac2_signedin(frac2_signed),
				.frac2_output(frac2_complement)
				//.frac2_signedout(frac2_signedout)
				);*/
   
>>>>>>> fa4bb25b0b7f0da1f3fd01824f72305558abd74b
   sub_26b sub_signed_fracs(
			     .exp_determine(exp_determine),
			     .frac1({1'b0,frac1[25:0]}),
			     .frac1_s({1'b0,frac1_signed[26:1]}),
			     .frac2({1'b0,frac2_complement}),
			     .frac2_s(frac2_signedout),
			     .sum(sum_signed),
			     .ovf(carry_out)
			     );
/*sub_26b sub_signed_fracs(
			     .frac1({1'b0,frac1_signed[26:1]}),
			     .frac2(frac2_complement),
			     .sum(sum_signed),
			     .ovf(carry_out)
			     );*/
  //assign sum = {sum_signed[24:0],1'b0};
  //assign sign_out = sum_signed[26];

   s_to_u_new change_to_unsigned_new(
			     .frac_signed(sum_signed),
			     .sign(sign_out),
			     .frac_unsigned(sum),
			     .exp_determine(exp_determine)
			     );
   
   
endmodule
		
