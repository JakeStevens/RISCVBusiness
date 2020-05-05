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

module ADD_step3
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
   output [31:0] floating_point_out,
   output [4:0]  flags
   );

   wire        inexact;
   wire        sign;
   wire [7:0]  exponent;
   wire [22:0] frac;

   localparam ADD = 7'b0100000;
   localparam MUL = 7'b0000010;
   localparam SUB = 7'b0100100; //add sub mode
   localparam DIV = 7'b0001000; //add dividision mode
   
   assign {sign, exponent, frac} = floating_point_out;
   
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
   left_shift shift_left (
			  .fraction(frac_in),
			  .result(shifted_frac),
			  .shifted_amount(shifted_amount)
			  );
   
   /*subtract SUBTRACT (
		 .exp1(exponent_max_in),
		 .shifted_amount(shifted_amount),
		 .result(exp_minus_shift_amount)
		 );*/
   assign exp_minus_shift_amount = exponent_max_in;

   
   reg [24:0] round_this;
   
   always_comb begin
      ovf = 0;
      unf = 0;
      if(carry_out == 1) begin
	 round_this = frac_in[25:1];
	 if (function_mode == 7'b0100100) begin
	    //temp_exp_out = exponent_max_in;
		exp_out = exponent_max_in;
	 end else begin
	    //temp_exp_out    = exponent_max_in + 1;
		exp_out    = exponent_max_in + 1;
	 end
	 if((exponent_max_in == 8'b11111110) && (~unf_in)) ovf = 1;
      end
      else begin
	 round_this = shifted_frac[24:0];
	 //temp_exp_out    = exp_minus_shift_amount;
	exp_out    = exp_minus_shift_amount;
	 if(({1'b0, exponent_max_in} < shifted_amount) && (~ovf_in)) unf = 1;
      end
      //temp_exp_value = temp_exp_out - 8'b0000010;
   end


   //assign exp_out = (function_mode == 7'b0100100)? temp_exp_value:temp_exp_out;

   reg [31:0] round_out;
   
   rounder ROUND (
		  .frm(frm),
		  .sign(sign_in),
		  .exp_in(exp_out),
		  .fraction(round_this),
		  .round_out(round_out),
		  .rounded(round_flag)
		  );
   
   assign inexact                  = ovf_in | ovf | unf_in | unf | round_flag;
   assign flags                    = {inv, dz, (ovf | ovf_in), (unf | unf_in), inexact};
   assign dummy_floating_point_out[31]   = round_out[31];
   assign dummy_floating_point_out[30:0] = inv    ? 31'b1111111101111111111111111111111 :
				     ovf_in ? 31'b1111111100000000000000000000000 :
				     ovf    ? 31'b1111111100000000000000000000000 :
				     unf_in ? 31'b0000000000000000000000000000000 :
				     unf    ? 31'b0000000000000000000000000000000 :
				     round_out[30:0];
   
   assign temp_sign = dummy_floating_point_out[31];
   sign_determine sign_determine (
					.temp_sign(temp_sign),
					.temp_floating_point_out(dummy_floating_point_out),
					.cmp_out(cmp_out),
					.floating_point1(floating_point1),
					.floating_point2(floating_point2),
					.floating_point_out(temp_floating_point_out)
					);
   reg [31:0] hold_value;
   
   always_comb begin
      if (function_mode == SUB) begin
	 hold_value = temp_floating_point_out;
      end else begin
	 hold_value  = dummy_floating_point_out;
      end
   end

   assign floating_point_out = bothnegsub? {~hold_value[31],hold_value[30:0]}: hold_value;
   //assign floating_point_out = dummy_floating_point_out;
   
   
   
endmodule
