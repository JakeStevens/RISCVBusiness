//By            : Joe Nasti
//Last Updated  : 7/23/18
//
//Module Summary: 
//    Third step of addition operation in three-step pipeline.
//    Rounds result based on rounding mode (frm) and left shifts fraction if needed
//
//Inputs:
//    frm              - 3 bit rounding mode
//    exponent_max_in  - exponent of result floating point
//    sign_in          - sign of result floating point
//    frac_in          - fraction of result floating point
//    carry_out        - carry out from step 2
//Outputs:
//    floating_point_out - final floating point

module SUB_step3
  (
   input 	 bothnegsub,
   input 	 cmp_out,
   input [31:0]  floating_point1,
   input [31:0]  floating_point2,
   input [6:0] 	 function_mode,
   input 	 ovf_in,
   input 	 unf_in,
   input 	 dz, // divide by zero flag
   input 	 inv,
   input [2:0] 	 frm,
   input [7:0] 	 exponent_max_in, //exponent 
   input 	 sign_in,
   input [25:0]  frac_in,
   input 	 carry_out,
   output [31:0] before_floating_point_out,
   output [4:0]  flags
   );

   localparam quietNaN = 32'b01111111110000000000000000000000;
   localparam signalNaN = 32'b01111111101000000000000000000000;
   localparam Inf = 32'b01111111100000000000000000000000;
   localparam NegInf = 32'b11111111100000000000000000000000;
   localparam zero = 32'b00000000000000000000000000000000;
   localparam NegZero = 32'b10000000000000000000000000000000;

   wire        inexact;
   wire        sign;
   wire [7:0]  exponent;
   wire [22:0] frac;

   localparam ADD = 7'b0100000;
   localparam MUL = 7'b0000010;
   localparam SUB = 7'b0100100; //add sub mode
   
   assign {sign, exponent, frac} = before_floating_point_out;
   
   reg [7:0] exp_minus_shift_amount;
   reg [25:0] shifted_frac;
   reg [7:0]  shifted_amount;
   reg [7:0]  exp_out;
   reg        ovf;
   reg        unf;
   reg [31:0] temp_floating_point_out;
   reg 	      temp_sign;
   reg [31:0] dummy_floating_point_out;
   reg [7:0]  temp_exp_out; 
   reg [7:0]  temp_exp_value;
   reg [31:0] floating_point_out_dummy;
   reg [31:0] fp_option;
   reg [31:0] hold_value;
   reg [23:0] rounded_frac;
// Left shifts an unsigned 26 bit value until the first '1' is the most significant bit and returns the amount shifted
   left_shift shift_left (
			  .fraction(frac_in),
			  .result(shifted_frac),
			  .shifted_amount(shifted_amount)
			  );

   assign exp_minus_shift_amount = exponent_max_in;

   
   reg [24:0] round_this;
   
//this comb logic is for rounding mode
   always_comb begin
      ovf = 0;
      unf = 0;
      if ((carry_out == 0) & (((floating_point1[31] == 0)&(floating_point2[31] == 0) & (cmp_out == 1)))) begin
      //if ((carry_out == 0) | (((floating_point1[31] == 0)&(floating_point2[31] == 0) & (cmp_out == 1)))) begin
	 //round_this = shifted_frac[24:0];
	 round_this = frac_in[24:0];
	exp_out    = exp_minus_shift_amount;
	 if(({1'b0, exponent_max_in} < shifted_amount) && (~ovf_in)) unf = 1;
      end else begin
	 round_this = frac_in[25:1];
	 if (function_mode == 7'b0100100) begin
		exp_out = exponent_max_in;
	 end else begin
		exp_out    = exponent_max_in + 1;
	 end
	 if((exponent_max_in == 8'b11111110) && (~unf_in)) ovf = 1;
   end
   end

   reg [31:0] round_out;
   
   //round the result
   rounder_sub ROUND (
		  .cmp_out(cmp_out),
		  .fp1(floating_point1),
		  .fp2(floating_point2),
		  .frm(frm),
		  .sign(sign_in),
		  .exp_in(exp_out),
		  .carry_out(carry_out),
		  .fraction(round_this),
		  .round_out(round_out),
		  .rounded(round_flag),
		  .sol_frac(rounded_frac)
		  );
   
   assign inexact                  = ovf_in | ovf | unf_in | unf | round_flag;
   assign flags                    = {inv, dz, (ovf | ovf_in), (unf | unf_in), inexact};
   assign dummy_floating_point_out[31]   = round_out[31];
   /*assign dummy_floating_point_out[30:0] = inv    ? 31'b1111111101111111111111111111111 :
				     ovf_in ? 31'b1111111100000000000000000000000 :
				     ovf    ? 31'b1111111100000000000000000000000 :
				     unf_in ? 31'b0000000000000000000000000000000 :
				     unf    ? 31'b0000000000000000000000000000000 :
				     round_out[30:0];*/
     assign dummy_floating_point_out[30:0] = inv    ? signalNaN :
				     ovf_in ? 31'b1111111100000000000000000000000 :
				     ovf    ? 31'b1111111100000000000000000000000 :
				     unf_in ? 31'b0000000000000000000000000000000 :
				     unf    ? 31'b0000000000000000000000000000000 :
				     round_out[30:0];
   
   assign temp_sign = dummy_floating_point_out[31];

//find the sign of the final result
   sign_determine sign_determine (
					.temp_sign(temp_sign),
					.temp_floating_point_out(dummy_floating_point_out),
					.cmp_out(cmp_out),
					.floating_point1(floating_point1),
					.floating_point2(floating_point2),
					.floating_point_out(temp_floating_point_out)
					);

   
   always_comb begin
      if (function_mode == SUB) begin
	 hold_value = temp_floating_point_out;
      end else begin
	 hold_value  = dummy_floating_point_out;
      end
   end

   
reg [31:0] neg_temp_sol_z1;
reg [31:0] neg_temp_sol_z2;

//reg NaNlogic;

assign neg_temp_sol_z1 = {!floating_point1[31], floating_point1[30:0]};
assign neg_temp_sol_z2 = {!floating_point2[31], floating_point2[30:0]};

assign floating_point_out_dummy = bothnegsub? {~hold_value[31],hold_value[30:0]}: hold_value;
  
/*
reg [31:0] fpout_hidBitOverflowCk;

always_comb begin
	if (floating_point_out_dummy[9] == 1) begin
		fpout_hidBitOverflowCk = {floating_point_out_dummy[31],exp_out - 1'b1, {1'b0,floating_point_out_dummy[
end
*/

//determine special cases like operations between Infinity, negitive Infinity, zero, negative zero, quiet NaN, signaling NaN
   always_comb begin
     if (floating_point1 == Inf) begin
	if (floating_point2 == Inf) begin
		if ((function_mode == ADD) | (function_mode == MUL)) begin
			fp_option = Inf;
		end else if (function_mode == SUB) begin
			fp_option = quietNaN;
		end
	end else if (floating_point2 == NegInf) begin
		if (function_mode == ADD) begin
			fp_option = quietNaN;
		end else if (function_mode == SUB) begin
			fp_option = Inf;
		end else if (function_mode == MUL) begin
			fp_option = NegInf;
		end
	end else if (floating_point2 == quietNaN) begin
		fp_option = quietNaN;
     	end else if ((floating_point1 == zero) | (floating_point2 == NegZero)) begin
		if (function_mode == MUL) begin
			fp_option = quietNaN;
		end else begin
			fp_option = Inf;
		end
	end else begin
		fp_option = Inf;
	end
     end else if (floating_point1 == NegInf) begin
	if (floating_point2 == Inf) begin
		if (function_mode == ADD) begin
			fp_option = quietNaN;
		end else if ((function_mode == SUB) | (function_mode == MUL)) begin
			fp_option = NegInf;
		end
	end else if (floating_point2 == NegInf) begin
		if (function_mode == ADD) begin
			fp_option = NegInf;
		end else if (function_mode == SUB) begin
			fp_option = quietNaN;
		end else if (function_mode == MUL) begin
			fp_option = Inf;
		end
	end else if (floating_point2 == quietNaN) begin
		fp_option = quietNaN;
	end else if ((floating_point1 == zero) | (floating_point2 == NegZero)) begin
		if (function_mode == MUL) begin
			fp_option = quietNaN;
		end else begin
			fp_option = NegInf;
		end
	end else begin
		fp_option = NegInf;
	end
     end else if ((floating_point1 == quietNaN) | (floating_point2 == quietNaN)) begin
	fp_option = quietNaN;
     end else if ((floating_point1 == zero) | (floating_point1 == NegZero)) begin
	if (floating_point2 == Inf) begin
		if (function_mode == ADD) begin
			fp_option = Inf;
		end else if (function_mode == SUB) begin
			fp_option = NegInf;
		end else if (function_mode == MUL) begin
			fp_option = quietNaN;
		end
	end else if (floating_point2 == NegInf) begin
		if (function_mode == ADD) begin
			fp_option = NegInf;
		end else if (function_mode == SUB) begin
			fp_option = Inf;
		end else if (function_mode == MUL) begin
			fp_option = quietNaN;
		end
	end else if (floating_point2 == quietNaN) begin
		fp_option = quietNaN;
	end /*else begin
		if (floating_point1 == zero) begin
			if (function_mode == MUL) begin
				fp_option = zero;
			end else if (function_mode == ADD) begin
				fp_option = floating_point2;
			end else if (function_mode == SUB) begin
				fp_option = {~floating_point2[31],floating_point2[30:0]};
			end
		end else if (floating_point1 == NegZero) begin
			if (function_mode == MUL) begin
				fp_option = NegZero;
			end else if (function_mode == ADD) begin
				fp_option = floating_point2;
			end else if (function_mode == SUB) begin
				fp_option = {~floating_point2[31],floating_point2[30:0]};
			end
		end
	end*/
     end else begin
  	fp_option = floating_point_out_dummy;
     end

     if (floating_point2 == Inf) begin
	if (floating_point1 == Inf) begin
		if ((function_mode == ADD) | (function_mode == MUL)) begin
			fp_option = Inf;
		end else if (function_mode == SUB) begin
			fp_option = quietNaN;
		end
	end else if (floating_point1 == NegInf) begin
		if (function_mode == ADD) begin
			fp_option = quietNaN;
		end else if (function_mode == SUB) begin
			fp_option = Inf;
		end else if (function_mode == MUL) begin
			fp_option = NegInf;
		end
	end else if (floating_point1 == quietNaN) begin
		fp_option = quietNaN;
     	end else if ((floating_point2 == zero) | (floating_point1 == NegZero)) begin
		if (function_mode == MUL) begin
			fp_option = quietNaN;
		end else begin
			fp_option = Inf;
		end
	end else begin
		fp_option = Inf;
	end
     end else if (floating_point2 == NegInf) begin
	if (floating_point1 == Inf) begin
		if (function_mode == ADD) begin
			fp_option = quietNaN;
		end else if ((function_mode == SUB) | (function_mode == MUL)) begin
			fp_option = NegInf;
		end
	end else if (floating_point1 == NegInf) begin
		if (function_mode == ADD) begin
			fp_option = NegInf;
		end else if (function_mode == SUB) begin
			fp_option = quietNaN;
		end else if (function_mode == MUL) begin
			fp_option = Inf;
		end
	end else if (floating_point1 == quietNaN) begin
		fp_option = quietNaN;
	end else if ((floating_point1 == zero) | (floating_point2 == NegZero)) begin
		if (function_mode == MUL) begin
			fp_option = quietNaN;
		end else begin
			fp_option = NegInf;
		end
	end else begin
		fp_option = NegInf;
	end
     end else if ((floating_point1 == quietNaN) | (floating_point2 == quietNaN)) begin
	fp_option = quietNaN;
     end else if ((floating_point2 == zero) | (floating_point2== NegZero)) begin
	if (floating_point1 == Inf) begin
		if (function_mode == ADD) begin
			fp_option = Inf;
		end else if (function_mode == SUB) begin
			fp_option = NegInf;
		end else if (function_mode == MUL) begin
			fp_option = quietNaN;
		end
	end else if (floating_point1 == NegInf) begin
		if (function_mode == ADD) begin
			fp_option = NegInf;
		end else if (function_mode == SUB) begin
			fp_option = Inf;
		end else if (function_mode == MUL) begin
			fp_option = quietNaN;
		end
	end else if (floating_point1 == quietNaN) begin
		fp_option = quietNaN;
	end /*else begin
		if (floating_point2 == zero) begin
			if (function_mode == MUL) begin
				fp_option = zero;
			end else if (function_mode == ADD) begin
				fp_option = floating_point1;
			end else if (function_mode == SUB) begin
				fp_option = floating_point1;
			end
		end else if (floating_point2 == NegZero) begin
			if (function_mode == MUL) begin
				fp_option = NegZero;
			end else if (function_mode == ADD) begin
				fp_option = floating_point1;
			end else if (function_mode == SUB) begin
				fp_option = floating_point1;
			end
		end
	end*/
     end else begin
  	fp_option = floating_point_out_dummy;
     end

	if ((floating_point1 == zero) | (floating_point1 == NegZero)) begin
		if (floating_point2 == zero) begin
			fp_option = zero;
		end else if (floating_point2 == Inf) begin
			if (function_mode == ADD) begin
				fp_option = Inf;
			end else if (function_mode == SUB) begin
				fp_option = NegInf;
			end else if (function_mode == MUL) begin
				fp_option = quietNaN;
			end
		end else if (floating_point2 == NegInf) begin
			if (function_mode == ADD) begin
				fp_option = NegInf;
			end else if (function_mode == SUB) begin
				fp_option = Inf;
			end else if (function_mode == MUL) begin
				fp_option = quietNaN;
			end
		end else if (floating_point2 == quietNaN) begin
			fp_option = quietNaN;
		end else begin
			if (function_mode == ADD) begin
				fp_option = floating_point2;
			end else if (function_mode == SUB) begin
				fp_option = neg_temp_sol_z2;
			end else if (function_mode == MUL) begin
				fp_option = zero;
			end
		end
	end

	if ((floating_point2 == zero) | (floating_point2 == NegZero)) begin
		if ((floating_point1 == zero) | (floating_point1 == NegZero)) begin
			fp_option = zero;
		end else if (floating_point1 == Inf) begin
			if (function_mode == ADD) begin
				fp_option = Inf;
			end else if (function_mode == SUB) begin
				fp_option = Inf;
			end else if (function_mode == MUL) begin
				fp_option = quietNaN;
			end
		end else if (floating_point1 == NegInf) begin
			if (function_mode == ADD) begin
				fp_option = NegInf;
			end else if (function_mode == SUB) begin
				fp_option = NegInf;
			end else if (function_mode == MUL) begin
				fp_option = quietNaN;
			end
		end else if (floating_point1 == quietNaN) begin
			fp_option = quietNaN;
		end else begin
			if (function_mode == ADD) begin
				fp_option = floating_point1;
			end else if (function_mode == SUB) begin
				fp_option = floating_point1;
			end else if (function_mode == MUL) begin
				fp_option = zero;
			end
		end
	end

	if (fp_option[30:23] == 8'b11111111) begin
		fp_option[23] = 8'b11111110;
	end
   end
	
assign before_floating_point_out = (fp_option == 32'b11111111011111111111111111111110) ? 32'b11111111011111111111111111111111 : fp_option;
endmodule
