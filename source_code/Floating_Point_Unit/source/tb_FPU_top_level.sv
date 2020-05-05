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
   int       i;
   

   task random_check;
      begin
	 /*if($random() % 2) funct7 = 7'b0100000;
	 else              funct7 = 7'b0000010;
	 frm       = $random() % 8;
	 */
	 //floating_point1 = $random(); //-2367.4
	 //floating_point2 = $random(); //-46772.414
	 //currently works if 1st number is less than second one(if both are positive)
	 if (i == 0) begin
         floating_point1 = 32'b01000001000111000000000000000000; //9.75
	 floating_point2 = 32'b00111111000100000000000000000000; //0.5625
	 end else if (i == 1) begin
         floating_point1 = 32'b01000010101110010110011001100110; //92.7
	 floating_point2 = 32'b01000001110110110011001100110011; //27.4
	 end else if (i == 2) begin
	 floating_point1 = 32'b01000101100011110101110101100010; //4587.673
         floating_point2 = 32'b01000011111100111101011000101011; //487.6732
	 end else if (i == 3) begin
	 floating_point1 = 32'b01001011000100110011000110001111; //9646479.12357
         floating_point2 = 32'b01000111111100010010011111010110; //123471.6732
	 end else if (i == 4) begin
	 floating_point1 = 32'b01000111001101101011010001101010; //46772.414
         floating_point2 = 32'b01000101000100111111011001100110; //2367.4
	 end else if (i == 5) begin
         floating_point1 = 32'b11000001000111000000000000000000; //-9.75
	 floating_point2 = 32'b10111111000100000000000000000000; //-0.5625
	 end else if (i == 6) begin
         floating_point1 = 32'b11000010101110010110011001100110; //-92.7
	 floating_point2 = 32'b11000001110110110011001100110011; //-27.4
	 end else if (i == 7) begin
	 floating_point1 = 32'b11000101100011110101110101100010; //-4587.673
         floating_point2 = 32'b11000011111100111101011000101011; //-487.6732
	 end else if (i == 8) begin
	 floating_point1 = 32'b11001011000100110011000110001111; //-9646479.12357
         floating_point2 = 32'b11000111111100010010011111010110; //-123471.6732
	 end else if (i == 9) begin
	 floating_point1 = 32'b11000111001101101011010001101010; //-46772.414
         floating_point2 = 32'b11000101000100111111011001100110; //-2367.4
	 end else if (i == 10) begin
	 floating_point1 = 32'b00111111000100000000000000000000; //0.5625
         floating_point2 = 32'b01000001000111000000000000000000; //9.75
	 end else if (i == 11) begin
	 floating_point1 = 32'b01000001110110110011001100110011; //27.4
         floating_point2 = 32'b01000010101110010110011001100110; //92.7
	 end else if (i == 12) begin
         floating_point1 = 32'b01000011111100111101011000101011; //487.6732
	 floating_point2 = 32'b01000101100011110101110101100010; //4587.673
	 end else if (i == 13) begin
         floating_point1 = 32'b01000111111100010010011111010110; //123471.6732
	 floating_point2 = 32'b01001011000100110011000110001111; //9646479.12357
	 end else if (i == 14) begin
         floating_point1 = 32'b01000101000100111111011001100110; //2367.4
	 floating_point2 = 32'b01000111001101101011010001101010; //46772.414
	 end else if (i == 15) begin
	 floating_point1 = 32'b10111111000100000000000000000000; //-0.5625
         floating_point2 = 32'b11000001000111000000000000000000; //-9.75
	 end else if (i == 16) begin
	 floating_point1 = 32'b11000001110110110011001100110011; //-27.4
         floating_point2 = 32'b11000010101110010110011001100110; //-92.7
	 end else if (i == 17) begin
	 floating_point1 = 32'b11000101000100100011011001100110; //-2367.3999
	 floating_point2 = 32'b11000111001110101011010101101010; //-46773.4141
	 end else if (i == 18) begin
         floating_point1 = 32'b11000010100100011111111101111101; //-72.999
	 floating_point2 = 32'b11001110001100100110011001001001; //-748261946.14893
	 end else if (i == 19) begin
	 floating_point1 = 32'b11000010110101101101011100001010; //-107.42
	 floating_point2 = 32'b11000111101110111110011110001110; //-96207.111
	 end else if (i == 20) begin
         floating_point1 = 32'b11000000011001011011001000101101; //-3.589 //3
	 floating_point2 = 32'b11000001000001101001001100001100; //-8.4109 //8
	 //Error: expected = 0 10000001 00110100100110100000001, 
	 //	calculated = 0 10000010 10011010010011010000001
	 end else if (i == 21) begin
	 floating_point1 = 32'b11000010000011111000111101011100; //-45.89
	 floating_point2 = 32'b11000010101010000011011111001111; //-94.109
	 //Error: expected = 0 10000100 10000001110000001000010, 
	 //     calculated = 0 10000101 11000000111000000100001
	 end
	 funct7 = 7'b0100100; //subtraction
	 //funct7 = 7'b0100000; //addition
	 //funct7 = 7'b0000010; //multiplication
	 //funct7 = 7'b0001000; //division
	 frm = funct7 % 8;

	//error message
	//Error: expected = 0 10000001 00010010101111010000001, 
	     //calculated = 0 10000001 01110110101000011000000

	 if(floating_point1[30:23] == 8'b11111111) 
	   floating_point1[30:23] = 8'b11111110;
	 if(floating_point2[30:23] == 8'b11111111) 
	   floating_point2[30:23] = 8'b11111110;

	 //convert from floating point to 2 real values
	 fp_convert(.val(floating_point1), .fp(fp1_real));
	 fp_convert(.val(floating_point2), .fp(fp2_real));

	 //performing real number arithemetic
	 //
	 if(funct7 == 7'b0100000) begin
	    result_real = fp1_real + fp2_real; //addition
	 end else if (funct7 == 7'b0000010) begin
	    result_real = fp1_real * fp2_real; //multiplication
         end else if (funct7 == 7'b0100100) begin
	    result_real = fp1_real - fp2_real; //subtraction
	 end else if (funct7 == 7'b0001000) begin
	    result_real = fp1_real / fp2_real;
         end
	 
	 else result_real = 'x;
	 
	 real_to_fp(.r(result_real), .fp(result_binary)); //convert the real number back to floating point
	 @(negedge clk);
	 @(negedge clk);
	 
	 fp_convert(.val(floating_point_out), .fp(fp_out_real));
	 #1;
	 assert((floating_point_out == result_binary) || (floating_point_out == result_binary + 1)) 
	   else begin 
	      $error("expected = %b, calculated = %b", result_binary, floating_point_out);
	      $display(fp1_real);//
	      $display(fp2_real);//
	      $display(result_real); //expected
	      $display(fp_out_real); //computed
	   end
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
   i = 0;
   
   while(i <= 19) begin
      random_check();
      i = i + 1;
      //break;
      end
  /*while (1) begin
	random_check();
  end*/
end
   
endmodule // tb_FPU_top_level
