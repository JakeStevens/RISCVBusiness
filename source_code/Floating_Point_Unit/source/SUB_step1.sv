//By            : Joe Nasti
//Edited by	: Xinlue Liu
//Last updated  : 6/1/20
//
//Module summary:
//    First step for subtraction operation in three-step pipline.
//    Shifts smaller fraction by difference in exponents
//
//Inputs:
//    floating_point1/2_in - single precision floating point values
//Outputs:
//    sign_shifted         - sign of the floating point that gets shifted
//    frac_shifted         - fraction of the floating point that gets shifted
//    sign_not_shifted     - sign of the floating point that does not get shifted
//    frac_not_shifted     - fraction of the floating point that does not get shifted
//    exp_max              - max exponent of the two given floating points
//    cmp		   - indicator of which floating point is bigger or smaller
module SUB_step1
  (
   input 	bothnegsub,
   input [31:0]  floating_point1_in,
   input [31:0]  floating_point2_in,
   output 	 sign_shifted,
   output [25:0] frac_shifted,
   output 	 sign_not_shifted,
   output [25:0] frac_not_shifted,
   output [7:0]  exp_max,
   output 	 cmp
   );
   reg [31:0] floating_point1_in_temp;
   reg [31:0] floating_point2_in_temp;
   reg  [7:0] 	 unsigned_exp_diff;
   reg 		 cmp_out; //exp1 >= exp2 -> cmp_out == 0
                          //exp1 <  exp2 -> cmp_out == 1
   wire [31:0] 	 floating_point_shift;
   wire [31:0] 	 floating_point_not_shift;
   reg  [31:0] 	 shifted_floating_point;
   reg [22:0] 	 temp_frac_shifted;

   always_comb begin: determine_input
	if (bothnegsub == 1'b1) begin
		floating_point1_in_temp = floating_point2_in;
		floating_point2_in_temp = floating_point1_in;
	end else begin
		floating_point1_in_temp = floating_point1_in;
		floating_point2_in_temp = floating_point2_in;
   	end
   end
   //compare the exponents of two floating points
   int_compare cmp_exponents (
			      .exp1(floating_point1_in_temp[30:23]), 
			      .exp2(floating_point2_in_temp[30:23]),
			      .u_diff(unsigned_exp_diff),
			      .cmp_out(cmp_out)
			      );
   //determine which one to shift
   //shift the smaller exponent
   assign floating_point_shift = cmp_out ? floating_point1_in_temp : floating_point2_in_temp;
   assign floating_point_not_shift = cmp_out ? floating_point2_in_temp : floating_point1_in_temp;
   //set the result exponent to the bigger exponent between X and Y
   assign exp_max = cmp_out ? floating_point2_in_temp[30:23] : floating_point1_in_temp[30:23];

   //right shift the smaller fp the amount of the difference of two fps.
   //right_shift_minus shift_frac (
   right_shift shift_frac(
	       .fraction({1'b1, floating_point_shift[22:0], 2'b0}),
	       .shift_amount(unsigned_exp_diff),
	       //.result_final(temp_frac_shifted)
	       .result(frac_shifted)
	       );

   assign frac_not_shifted = {1'b1, floating_point_not_shift[22:0], 2'b0};
   //assign frac_not_shifted = floating_point_not_shift[22:0];
   //assign frac_shifted = temp_frac_shifted;
   assign sign_not_shifted = floating_point_not_shift[31];
   //negate the sign bit
           //assign sign_shifted     = ~floating_point_shift[31];
   assign sign_shifted     = floating_point_shift[31];
   assign cmp = cmp_out;

endmodule
