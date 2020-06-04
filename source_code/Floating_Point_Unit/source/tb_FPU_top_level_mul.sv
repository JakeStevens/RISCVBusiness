`timescale 1ns/100ps
module tb_FPU_top_level();
   reg clk = 0;
   reg nrst;
   reg [31:0] floating_point1;
   reg [31:0] floating_point2;
   reg [2:0]  frm;
   reg [31:0] floating_point_out;
   reg [6:0]  funct7;
   reg [4:0]  flags;
   int       i;
   
   always begin
      clk = ~clk;
      #1;
   end

   FPU_top_level DUT (
		      .clk(clk),
		      .nrst(nrst),
		      .floating_point1(floating_point1),
		      .floating_point2(floating_point2),
		      .frm(frm),
		      .funct7(funct7),
		      .floating_point_out(floating_point_out),
		      .flags(flags)
		      );
   
   real        result_real;
   reg  [31:0] result_binary;
   real        fp1_real;
   real        fp2_real;
   real        fp_out_real;
   real        fp_exp;
   real        fp_frac;

   task random_check;
      begin
 	 funct7 = 7'b0000010;
	 frm       = $random() % 8;

	 /*if (i == 0) begin
	 floating_point1 = 32'b01111111100000000000000000000000; //Inf
	 floating_point2 = 32'b11000010101010000011011111001111; //-94.109
 	 end else if (i == 1) begin
         floating_point1 = 32'b11111111100000000000000000000000; //-Inf
	 floating_point2 = 32'b11000001000001101001001100001100; //-8.4109
	 end else if (i == 2) begin
	 floating_point1 = 32'b11000010101010000011011111001111; //-94.109
	 floating_point2 = 32'b01111111100000000000000000000000; //Inf
 	 end else if (i == 3) begin
         floating_point1 = 32'b11000001000001101001001100001100; //-8.4109
	 floating_point2 = 32'b11111111100000000000000000000000; //-Inf
	 end else if (i == 4) begin
	 floating_point1 = 32'b11000010101010000011011111001111; //-94.109
	 floating_point2 = 32'b10000000000000000000000000000000; //-0
 	 end else if (i == 5) begin
         floating_point1 = 32'b11000010101010000011011111001111; //-94.109
	 floating_point2 = 32'b00000000000000000000000000000000; //0
	 end else if (i == 6) begin
	 floating_point1 = 32'b11111111100000000000000000000000; //-Inf
	 floating_point2 = 32'b10000000000000000000000000000000; //-0
 	 end else if (i == 7) begin
	 floating_point1 = 32'b10000000000000000000000000000000; //-0
	 floating_point2 = 32'b11000010101110010110011001100110; //-92.7
	 //Error: expected = 0 10000101 01110010110011001100110, 
	      //calculated = 0 10000101 11001011001100110011000
	 end else if (i == 8) begin
         floating_point1 = 32'b11111111111111111111111111111111; //NaN
	 floating_point2 = 32'b11000001000001101001001100001100; //-8.4109
	 end else if (i == 9) begin
         floating_point1 = 32'b11000001000001101001001100001100; //-8.4109
	 floating_point2 = 32'b11111111111111111111111111111111; //NaN
	 end*/

	 floating_point1 = $random();
	 floating_point2 = $random();
	 if(floating_point1[30:23] == 8'b11111111) 
	   floating_point1[30:23] = 8'b11111110;
	 if(floating_point2[30:23] == 8'b11111111) 
	   floating_point2[30:23] = 8'b11111110;
	 
	 fp_convert(.val(floating_point1), .fp(fp1_real));
	 fp_convert(.val(floating_point2), .fp(fp2_real));
	 result_real = fp1_real * fp2_real;
	 real_to_fp(.r(result_real), .fp(result_binary));
	 @(negedge clk);
	 @(negedge clk);
	 
	 fp_convert(.val(floating_point_out), .fp(fp_out_real));
	 #1;
	 assert((floating_point_out == result_binary) || (floating_point_out == result_binary + 1)) 
	   else $error("expected = %b, calculated = %b", result_binary, floating_point_out);
	 //if((flags[1] == 0) & (flags[2] == 0)) begin
	   // assert(flags[0] == 0) else $error("asdklfj;as");
	 //end
	 
	 @(negedge clk);
	 floating_point1 = 'x;
	 floating_point2 = 'x;
	 frm             = 'x;
	 funct7          = 'x;
	 result_real     = 'x;
	 fp1_real        = 'x;
	 fp2_real        = 'x;
	 fp_exp          = 'x;
	 fp_frac         = 'x;
	 @(negedge clk);
	 
      end
   endtask // random_check
   
   task real_to_fp;
      input real r;
      output reg [31:0] fp;
      begin
	 
	 int fp_index;
	 real MAX;
	 real MIN;
	 
	 fp_convert(32'b01111111011111111111111111111111, MAX);
	 fp_convert(32'b00000000000000000000000000000000, MIN);
	 
	 
	 fp = 32'b01000000000000000000000000000000;

	 if(r < 0) begin // set sign bit
	    fp[31] = 1'b1;
	    r = -r;
	 end
	 
	 if(r < MIN) // ovf 
	    fp[30:0] = 31'b0000000000000000000000000000000;
	 
         else if(r > MAX) // unf
	    fp[30:0] = 31'b1111111100000000000000000000000;
	 
	 else begin // everything else
	    if(r >= 2) begin 
	       while(r >= 2) begin
	          r /= 2;
		  fp[30:23] += 1;
	       end
	    end
	    else if(r < 1) begin
	       while(r < 1) begin
		  r *= 2;
		  fp[30:23] -= 1;
	       end
	    end
	    
	    r -= 1;
	    fp_index = 22;
	    for(real i = 0.50; i != 2**-24; i /= 2) begin
	       if(r >= i) begin
		  r -= i;
		  fp[fp_index] = 1'b1;
	       end
	       fp_index -= 1;
	    end
	 end // else: !if((r>(1.70141*(10**38))))
      end
   endtask // real_to_fp
         
   task fp_convert;
      input [31:0] val;
      output real  fp;
      begin
         
	 fp_exp  = real'(val[30:23]);
	 fp_frac = real'(val[22:0]);

	 fp_exp = fp_exp - 128;
	 
	 for(int k = 0; k < 23; k = k + 1) begin
	    fp_frac /= 2;
	 end
     	 fp_frac = fp_frac + 1;	 

	 if(val[31]) 
	   fp = -fp_frac * (2 ** fp_exp);
	 else
	   fp = fp_frac * (2 ** fp_exp);
      end
   endtask // fp_convert
   
initial begin
   nrst = 1;
   @(negedge clk);
   nrst = 0;
   @(negedge clk);
   nrst = 1;
   
  /*while(i <= 9) begin
      random_check();
      i = i + 1;
      //break;
      end*/
   while(1) begin
      random_check();
   end    
end
   
endmodule // tb_FPU_top_level
