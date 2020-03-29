module SUB_step2
  (
   input  [25:0] frac1,
   input         sign1,
   input  [25:0] frac2,
   input         sign2,
   input  [7:0]  exp_max_in, //
   output        sign_out,
   output [25:0] sum,
   output        carry_out,
   output reg [7:0]  exp_max_out//
   );

   reg [26:0] 	 frac1_signed;
   reg [26:0] 	 frac2_signed;
   reg [26:0] 	 sum_signed;
   reg [26:0] 	 frac2_complement;
	 
   
   always_comb begin : exp_max_assignment
      if(sum_signed == 0) exp_max_out = 8'b00000000;
      else exp_max_out = exp_max_in;
   end
   

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
   
   c_to_cp change_to_complement(
				.frac2_input(frac2_signed),
				.frac2_output(frac2_complement)
				);
   
   sub_26b sub_signed_fracs(
			     .frac1({1'b0,frac1_signed[26:1]}),//temp_solution. Does not necessary to be 0
			     .frac2(frac2_complement),
			     .sum(sum_signed),
			     .ovf(carry_out)
			     );

   s_to_u change_to_unsigned(
			     .frac_signed(sum_signed),
			     .sign(sign_out),
			     .frac_unsigned(sum)
			     );
   
   
endmodule
		
