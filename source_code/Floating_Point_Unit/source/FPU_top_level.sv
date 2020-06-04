//By            : Joe Nasti
//Edited by 	: Xinlue Liu
//Last Updated  : 6/1/2020
//
//Module Summary:
//    Three-stage floating point unit supporting operations:
//    addition
//    subtraction (in progress)
//    multiplication 
//
//Inputs:
//    clk                - system clock
//    nrst               - active low reset
//    floating_point1/2  - floating points to be operated on
//    frm                - rounding mode
//    funct7             - 7 bit operation code
//Outputs:
//    floating_point_out - result of operation 
//    flags              - 5 error flags (overflow,  underflow, divide by zero, inexact result, invalid operation)

module FPU_top_level
(
 input 	       clk,
 input 	       nrst,
 input  [31:0] floating_point1,
 input  [31:0] floating_point2,
 input  [2:0]  frm,
 input  [6:0]  funct7,
 output [31:0] floating_point_out,
 output [4:0]  flags
 );

   reg [31:0]  temp_floating_point_out;
   reg 	       temp_sign;
   
   reg [2:0]   frm2;
   reg [2:0]   frm3;
   reg [6:0]   funct7_2;
   reg [6:0]   funct7_3;

   //funct7 definitions
   localparam ADD = 7'b0100000;
   localparam MUL = 7'b0000010;
   localparam SUB = 7'b0100100; //add sub mode
   
   // ADD step1 outputs -> step2 inputs
   //reg 	       nxt_sign_shifted;
   reg 	       sign_shifted;
   reg         sign_shifted_minus;	       
   //reg [25:0]  nxt_frac_shifted;
   reg [25:0]  frac_shifted;
   //reg [22:0]  frac_shifted_minus;
   reg [25:0]  frac_shifted_minus;
   
   //reg 	       nxt_sign_not_shifted;
   reg 	       sign_not_shifted;
   reg         sign_not_shifted_minus;
   //reg [25:0]  nxt_frac_not_shifted;
   reg [25:0]  frac_not_shifted;
   //reg [22:0]  frac_not_shifted_minus;
   reg [25:0]  frac_not_shifted_minus;
   //reg [7:0]   nxt_exp_max;
   reg [7:0]   exp_max;
   reg [7:0]   exp_max_minus; //MSB for subtraction  
   
   // MUL step1 outputs -> step2 inputs
   reg         mul_sign1;
   reg         mul_sign2;
   reg [7:0]   mul_exp1;
   reg [7:0]   mul_exp2;
   reg [25:0]  product;
   reg         mul_carry_out;
   
   reg [61:0]  step1_to_step2;
   reg [61:0]  nxt_step1_to_step2;
   
   
   // ADD step2 outputs -> step3 inputs
   reg        add_sign_out;
   //reg        nxt_sign_out;
   reg [25:0] add_sum;
    //reg [25:0] nxt_sum;
   reg 	      add_carry_out;
   //reg 	      nxt_carry_out;
   reg [7:0]  add_exp_max;
   //reg [7:0]  nxt_exp_max_out;


   reg        minus_sign_out;
   reg [25:0] minus_sum;
   reg        minus_carry_out;
   reg [7:0]  minus_exp_max;
   reg        cmp_out;
   reg 	      cmp_out_det;
   reg        fp1_sign;
   reg [25:0] fp1_frac;
   reg        fp2_sign;
   reg [25:0] fp2_frac;

   // MUL step2 outputs -> step3 inputs
   reg        mul_sign_out;
   reg [7:0]  sum_exp;
   reg        mul_ovf;
   reg        mul_unf;

   // invalid operation flag
   reg        inv;
   reg        inv2;
   reg        inv3;  

   reg [37:0] step2_to_step3;
   reg [37:0] nxt_step2_to_step3;
   reg exp_determine;
   wire bothnegsub;
   reg [25:0] fp1_frac_hold;
   reg [25:0] fp2_frac_hold;
   reg        fp1_sign_hold;
   reg        fp2_sign_hold;
<<<<<<< HEAD

        //compare two floating points and use signal cmp_out_det to indicate greater/less relationship
=======
   /*always_comb begin
   	if (funct7 == SUB) begin
		if ((floating_point1[31] == 1) && (floating_point2[31] == 1)) begin
			floating_point2[31] = 1'b0;
			funct7 = ADD;
		end else begin
			floating_point2[31] = 1'b1;
			funct7 = SUB;
		end
   	end
   end*/
   // right shift smaller fraction by difference in exponents
>>>>>>> fa4bb25b0b7f0da1f3fd01824f72305558abd74b
 	int_compare cmp_exponent (
			      .exp1(floating_point1[30:23]), 
			      .exp2(floating_point2[30:23]),
			      .cmp_out(cmp_out_det)
			      );
<<<<<<< HEAD
//if both numbers are negative and first one is smaller than the second one
	assign bothnegsub = (floating_point1[31] && floating_point2[31] && cmp_out_det && (funct7 == 7'b0100100)) ? 1:0; 

        //first step of addition. determine the exponent and fraction of the floating point that needs to be shifted
	ADD_step1 addStep1(
=======
	assign bothnegsub = floating_point1[31] && floating_point2[31] && cmp_out_det; //if both numbers are negative and first one is smaller than the second one
        ADD_step1 addStep1(
>>>>>>> fa4bb25b0b7f0da1f3fd01824f72305558abd74b
			   .floating_point1_in(floating_point1),
			   .floating_point2_in(floating_point2),
			   .sign_shifted(sign_shifted),
			   .frac_shifted(frac_shifted),
			   .sign_not_shifted(sign_not_shifted),
			   .frac_not_shifted(frac_not_shifted),
			   .exp_max(exp_max)
			   );

	//first step of subtraction. determine the exponent and fraction of the floating point that needs to be shifted
        SUB_step1 substep1(
			   .bothnegsub(bothnegsub),
		      	   .floating_point1_in(floating_point1),
			   //.floating_point2_in({~floating_point2[31], floating_point2[30:0]}),
			   .floating_point2_in(floating_point2),
			   .sign_shifted(sign_shifted_minus),
			   .frac_shifted(frac_shifted_minus),
			   .sign_not_shifted(sign_not_shifted_minus),
			   .frac_not_shifted(frac_not_shifted_minus),
			   .exp_max(exp_max_minus),
			   .cmp(cmp_out)
		           );

   
// first step of multiplication. multiply two floating points
        MUL_step1 mulStep1(
			   .fp1_in(floating_point1),
			   .fp2_in(floating_point2),
			   .sign1(mul_sign1),
			   .sign2(mul_sign2),
			   .exp1(mul_exp1),
			   .exp2(mul_exp2),
			   .product(product),
			   .carry_out(mul_carry_out)
			   );
   
   
   always_comb begin : check_for_invalid_op
      inv = 0;
      // checking for invalid operation. Subject to change
      if ((funct7 == ADD) || (funct7 == SUB)) begin
	 if((floating_point1[30:0] == 31'h7F800000) && 
	    (floating_point2[30:0] == 31'h7F800000) && 
	    (floating_point1[31] ^ floating_point2[31])) begin
	        inv = 1;
	 end
      end
      
      if(funct7 == MUL) begin
	 if(((floating_point1[30:0] == 31'h00000000)  &&
	     (floating_point2[30:0] == 31'h7F800000)) ||
	    ((floating_point1[30:0] == 31'h7F800000)  &&
	     (floating_point2[30:0] == 31'h00000000))) begin
	        inv = 1;
	 end
      end
   end // block: check_for_invalid_op

<<<<<<< HEAD
	// add signal indicator that indicates which subtraction operation it is going to perform
	always_comb begin: determine_exp
	if (cmp_out == 0) begin //fp1 > fp2.
=======
	// add signed fractions
	always_comb begin: determine_exp
	if (cmp_out == 0) begin //fp1 > fp2. Looking at mantassa
>>>>>>> fa4bb25b0b7f0da1f3fd01824f72305558abd74b
		exp_determine = 1'b1;
	end else if (cmp_out == 1) begin
		exp_determine = 1'b0;
	end
	end

<<<<<<< HEAD
   //reorder the two floating points to pass into the second block of the subtraction routine
=======
   //get the sign for two floating points
>>>>>>> fa4bb25b0b7f0da1f3fd01824f72305558abd74b
   always_comb begin: reorder_the_subtraction
   //if (bothnegsub == 0) begin
   	if (cmp_out == 0) begin //if fp1 >= fp2
      		fp1_sign = sign_not_shifted_minus;
      		fp1_frac = frac_not_shifted_minus;
      		fp2_sign = sign_shifted_minus;
      		fp2_frac = frac_shifted_minus;
   	end else begin //(cmp_out == 1)
      		fp1_sign = sign_shifted_minus;
      		fp1_frac = frac_shifted_minus;
      		fp2_sign = sign_not_shifted_minus;
      		fp2_frac = frac_not_shifted_minus; 
   	end
   end

   always_comb begin : select_op_step1to2
      case(funct7)
	ADD: begin
	   nxt_step1_to_step2[61]    = sign_shifted;
	   nxt_step1_to_step2[60:35] = frac_shifted;
	   nxt_step1_to_step2[34]    = sign_not_shifted;
	   nxt_step1_to_step2[33:8]  = frac_not_shifted; 
	   nxt_step1_to_step2[7:0]   = exp_max;
	end
	SUB: begin
	   nxt_step1_to_step2[61]   = fp1_sign;
	   nxt_step1_to_step2[60:35] = fp1_frac;
	   nxt_step1_to_step2[34]    = fp2_sign;
	   nxt_step1_to_step2[33:8]  = fp2_frac;
	   nxt_step1_to_step2[7:0]   = exp_max_minus;
	end
	MUL: begin
	   nxt_step1_to_step2[61]    = mul_sign1;
	   nxt_step1_to_step2[60]    = mul_sign2;
           nxt_step1_to_step2[59:52] = mul_exp1;
	   nxt_step1_to_step2[51:44] = mul_exp2;
	   nxt_step1_to_step2[43:18] = product;
	   nxt_step1_to_step2[17]    = mul_carry_out;
	end
     
      endcase // case (funct7)
   end // block: select_op
   			       
   always_ff @ (posedge clk, negedge nrst) begin : STEP1_to_STEP2
      if(nrst == 0) begin
         frm2           <= 0;
	 step1_to_step2 <= 0;
         funct7_2       <= 0;
	 inv2           <= 0;/*
         sign_shifted     <= 0;
         frac_shifted     <= 0;
         sign_not_shifted <= 0;
         frac_not_shifted <= 0;
         exp_max          <= 0;*/
      end
      else begin
         frm2           <= frm;
	 step1_to_step2 <= nxt_step1_to_step2;
	 funct7_2       <= funct7;
	 inv2           <= inv;/*
         sign_shifted     <= nxt_sign_shifted;
         frac_shifted     <= nxt_frac_shifted;
         sign_not_shifted <= nxt_sign_not_shifted;
         frac_not_shifted <= nxt_frac_not_shifted;
         exp_max          <= nxt_exp_max;*/
      end
   end 
<<<<<<< HEAD
	 //perform addition
	  ADD_step2 add_step2 (
=======
	 //assign step1_to_step2[61] = bothnegsub ? ~step1_to_step2[61] : step1_to_step2[61];
	 //assign step1_to_step2[34] = bothnegsub ? ~step1_to_step2[34] : step1_to_step2[34];
	 ADD_step2 add_step2 (
>>>>>>> fa4bb25b0b7f0da1f3fd01824f72305558abd74b
			      .frac1(step1_to_step2[60:35]),    // frac_shifted
			      .sign1(step1_to_step2[61]),       // sign_shifted
			      .frac2(step1_to_step2[33:8]),     // frac_not_shhifted
			      .sign2(step1_to_step2[34]),       // sign_not_shifted
			      .exp_max_in(step1_to_step2[7:0]), // exp_max
			      .sign_out(add_sign_out),
			      .sum(add_sum),
			      .carry_out(add_carry_out),
			      .exp_max_out(add_exp_max)
			      );
	 //perform subtraction
          SUB_step2 sub_step2 (
		  	      .bothnegsub(bothnegsub),
			      .frac1(step1_to_step2[60:35]),    // frac_shifted
			      .sign1(step1_to_step2[61]),       // sign_shifted
			      .frac2(step1_to_step2[33:8]),     // frac_not_shhifted
			      .sign2(step1_to_step2[34]),       // sign_not_shifted
			      .exp_max_in(step1_to_step2[7:0]), // exp_max
			      .sign_out(minus_sign_out),
			      .sum(minus_sum),
			      .carry_out(minus_carry_out),
			      .exp_max_out(minus_exp_max),
			      .exp_determine(exp_determine)
			      );
   
         MUL_step2 mul_step2 (
			      .sign1(step1_to_step2[61]),   // mul_sign1
			      .sign2(step1_to_step2[60]),   // mul_sign2
			      .exp1(step1_to_step2[59:52]), // mul_exp1
			      .exp2(step1_to_step2[51:44]), // mul_exp2
			      .sign_out(mul_sign_out),
			      .sum_exp(sum_exp),
			      .ovf(mul_ovf),
			      .unf(mul_unf),
			      .carry(step1_to_step2[17])
			      );
   
   always_comb begin : select_op_step2to3
      case(funct7_2)
	ADD: begin
	   nxt_step2_to_step3[37:36]= 2'b00;
	   nxt_step2_to_step3[35]   = add_sign_out;
	   nxt_step2_to_step3[34:9] = add_sum;
	   nxt_step2_to_step3[8]    = add_carry_out;
	   nxt_step2_to_step3[7:0]  = add_exp_max;
	end
	MUL: begin
	   nxt_step2_to_step3[37]   = mul_ovf;
       	   nxt_step2_to_step3[36]   = mul_unf;	      
	   nxt_step2_to_step3[35]   = mul_sign_out;
	   nxt_step2_to_step3[34:9] = step1_to_step2[43:18]; // product from MUL_step1
	   nxt_step2_to_step3[8]    = step1_to_step2[17];    // mul_carry_out;
	   nxt_step2_to_step3[7:0]  = sum_exp;
	end
	SUB: begin
	   nxt_step2_to_step3[37:36]= 2'b00;
	   nxt_step2_to_step3[35]   = minus_sign_out;
	   //nxt_step2_to_step3[35] = ~minus_sign_out;
	   nxt_step2_to_step3[34:9] = minus_sum;
	   nxt_step2_to_step3[8]    = minus_carry_out;
	   nxt_step2_to_step3[7:0]  = minus_exp_max;
	end
      endcase // case (funct7_2)
   end // block: select_op_step2to3
   
   
   always_ff @ (posedge clk, negedge nrst) begin : STEP2_to_STEP3
      if(nrst == 0) begin
	 funct7_3       <= 0;
         step2_to_step3 <= 0;
	 frm3           <= 0;
	 inv3           <= 0;
      end
      else begin
	 funct7_3       <= funct7_2;
	 step2_to_step3 <= nxt_step2_to_step3;
	 frm3           <= frm2;
	 inv3           <= inv2;
      end 
   end  
   reg o;
   
   always_comb begin
      if((step2_to_step3[7:0] == 8'b11111111) && (step2_to_step3[36] == 1'b0) && (step2_to_step3[8] == 0)) o = 1;
      else o = step2_to_step3[37]; 
   end
<<<<<<< HEAD

   reg [31:0] negmul_floating_point_out;
   reg [31:0] add_floating_point_out;
   //round the results and perform special case checking
   SUB_step3 sub_step3 (
=======
   
   ADD_step3 step3 (
>>>>>>> fa4bb25b0b7f0da1f3fd01824f72305558abd74b
		    .bothnegsub(bothnegsub),
		    .cmp_out(cmp_out),
		    .floating_point1(floating_point1),
		    .floating_point2(floating_point2),
		    .function_mode(funct7_3[6:0]),
		    .ovf_in(o),
		    .unf_in(step2_to_step3[36]),
		    .dz(1'b0),
		    .inv(inv3),
		    .frm(frm3),
		    .exponent_max_in(step2_to_step3[7:0]),
		    .sign_in(step2_to_step3[35]),
		    .frac_in(step2_to_step3[34:9]),
		    .carry_out(step2_to_step3[8]),
		    .before_floating_point_out(negmul_floating_point_out),
		    .flags(flags)
		    );
//round the results 
   ADD_step3 add_step3 (
		    .ovf_in(o),
		    .unf_in(step2_to_step3[36]),
		    .dz(1'b0),
		    .inv(inv3),
		    .frm(frm3),
		    .exponent_max_in(step2_to_step3[7:0]),
		    .sign_in(step2_to_step3[35]),
		    .frac_in(step2_to_step3[34:9]),
		    .carry_out(step2_to_step3[8]),
		    .add_floating_point_out(add_floating_point_out),
		    .flags(flags)
		    );

assign floating_point_out = (funct7 == 7'b0100100) ? negmul_floating_point_out : add_floating_point_out;
   
 endmodule
