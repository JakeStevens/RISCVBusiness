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
   
   shortreal        result_real;
   reg  [31:0] result_binary;
   shortreal        fp1_real;
   shortreal        fp2_real;
   shortreal        fp_out_real;
   shortreal        fp_exp;
   shortreal        fp_frac;
   int       i;
   int       j = 0;
   real val1;
   shortreal val2;
   
   task random_check;
      begin
         //$display($bits(val1));
   	 //$display($bits(val2));
  //subnormal number
	 frm       = $random() % 8;
	 funct7 = 7'b0100100;
	 floating_point1 = $random();
	 floating_point2 = $random();
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
	 floating_point1 = 32'b00111110100000000000000000000000; //.25
	 floating_point2 = 32'b01000010110010000000000000000000; //100
	 end else if (i == 21) begin
	 floating_point1 = 32'b01111111100000000000000000000000; //Inf
	 floating_point2 = 32'b11000010101010000011011111001111; //-94.109
 	 end else if (i == 22) begin
         floating_point1 = 32'b11111111100000000000000000000000; //-Inf
	 floating_point2 = 32'b11000001000001101001001100001100; //-8.4109
	 end else if (i == 23) begin
	 floating_point1 = 32'b11000010101010000011011111001111; //-94.109
	 floating_point2 = 32'b01111111100000000000000000000000; //Inf
 	 end else if (i == 24) begin
         floating_point1 = 32'b11000001000001101001001100001100; //-8.4109
	 floating_point2 = 32'b11111111100000000000000000000000; //-Inf
	 end else if (i == 25) begin
	 floating_point1 = 32'b11000010101010000011011111001111; //-94.109
	 floating_point2 = 32'b10000000000000000000000000000000; //-0
 	 end else if (i == 26) begin
         floating_point1 = 32'b11000010101010000011011111001111; //-94.109
	 floating_point2 = 32'b00000000000000000000000000000000; //0
	 end else if (i == 27) begin
	 floating_point1 = 32'b11111111100000000000000000000000; //-Inf
	 floating_point2 = 32'b10000000000000000000000000000000; //-0
 	 end else if (i == 28) begin
	 floating_point1 = 32'b10000000000000000000000000000000; //-0
	 floating_point2 = 32'b11000010101110010110011001100110; //-92.7
 	 end else if (i == 29) begin
	 floating_point1 = 32'b00000000000000000000000000000000; //0
	 floating_point2 = 32'b11000010101110010110011001100110; //-92.7*/
	 /*end else if (i == 30) begin
         floating_point1 = 32'b01111111110000000000000000000000; //qNaN
	 floating_point2 = 32'b11000001000001101001001100001100; //-8.4109*/
	 end else if (i == 30) begin
	 //if sum overflows the position of the hidden bit, then the mantissa must be shifted one bit to the right and the
	 //exponent incremented
         floating_point1 = 32'b11000000011001011011001000101101; //-3.589
	 floating_point2 = 32'b11000001000001101001001100001100; //-8.4109
	 end else if (i == 31) begin
	 floating_point1 = 32'b11000010000011111000111101011100; //-45.89
	 floating_point2 = 32'b11000010101010000011011111001111; //-94.109
	 end else  if (i == 32) begin
         floating_point1 = 32'b11000000100010010101111010000001; 
	 floating_point2 = 32'b10000100100001001101011000001001;
	 end else if (i == 33) begin
         floating_point1 = 32'b10001001001101110101001000010010; //-2.20664130144e-33 i = 3
	 floating_point2 = 32'b00000000111100111110001100000001; //2.2397459224e-38
	 //frac in is 		             0110111010100011001100001    
	 //# ** Error: expected = 1 00010010 01101110101001010001011, //s1
	 //	     calculated = 1 00010010 01101110101000110011000
         end else if (i == 34) begin
         floating_point1 = 32'b00000101011100111000011100001010; //i = 11
	 floating_point2 = 32'b11000000001110110010001010000000;
	 //frac in is 	     	        01000100110111011000000000
	 //Error: expected = 0 10000000 01110110010001010000000,   //s1
			            //010111011001000101000000000
	 //	calculated = 0 10000000 01000100110111011000000

	 //Error: expected = 0 10000000  01110110010001010000000, 
	      //calculated = 0 10000000 10111011001000101000000

	 end else if (i == 35) begin
         floating_point1 = 32'b01010101011110000100010110101010; // i = 12
	 floating_point2 = 32'b11001110110011001100110010011101;
	 //frac in is 			11110000011111101000011110
	 //Error: expected = 0 10101010 11110000100110000010000,   //s1
	 //     calculated = 0 10101001 11100000111111010000111
	 end else if (i == 36) begin
         floating_point1 = 32'b00110101100111111101110101101011; // i = 14
	 floating_point2 = 32'b11101010101001100010101011010101;
	 //frac in is                   01011001110101010010101100	
	 //Error: expected = 0 11010101 01001100010101011010101,   //s1
	 //	calculated = 0 11010101  01011001110101010010101
 	 end else if (i == 37) begin
         floating_point1 = 32'b10011110001100010100110000111100; // i = 17
	 floating_point2 = 32'b01111001011010001011110111110010;
	 //   expected = 1 11110010  11010001011110111110010, 
	  //calculated = 1 11110010 11101000101111011111001
	 end else if (i == 38) begin
         floating_point1 = 32'b00100000110001001011001101000001; // i = 18
	 floating_point2 = 32'b11101100010010110011010011011000;
	 //frac in is 			00110100110010110010100000
	 //Error: expected = 0 11011000 10010110011010011011000,  //s1
	 //     calculated = 0 11011000 00110100110010110010100
	 end else if (i == 39) begin
         floating_point1 = 32'b11000100100010100001001010001001; // i = 19
	 floating_point2 = 32'b01110101110001010000110111101011;
 	 //Error: expected = 1 11101011  10001010000110111101011, 
	  //    calculated = 1 11101011 11000101000011011110101
	 end else if (i == 40) begin
         floating_point1 = 32'b01100011010010111111100111000110; // i = 20
	 floating_point2 = 32'b01010111000101010001001110101110;
	 //frac in is 			10010111111100111000101100
	 //Error: expected = 0 11000110 10010111111100111000101, //s3, shifting and exponent issue
 	 //	calculated = 0 11000101 00101111111001110001011
	 end

         /*floating_point1 = 32'b11100010110010100100111011000101; //i = 9
	   floating_point2 = 32'b00101110010110000100100101011100;
	 	           frac in is 1001010010011101100010100
	 Error: expected = 1 11000101 10010100100111011000101, 
	      calculated = 1 11000101  00101001001110110001010
	 frm = 000

	  floating_point1 = 32'b11010111010101100011111010101110; //i = 15
	  floating_point2 = 32'b00001110111111111110100100011101;
	                   frac in is   1010110001111101010111000
	 //Error: expected = 1 10101110 10101100011111010101110, 
	 //     calculated = 1 10101110  01011000111110101011100
	
*/


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
	 end
	 
	 else result_real = 'x;
	 
	 real_to_fp(.r(result_real), .fp(result_binary)); //convert the real number back to floating point
	 @(negedge clk);
	 @(negedge clk);
	 
	 fp_convert(.val(floating_point_out), .fp(fp_out_real));
	 #1;
	 assert((floating_point_out == result_binary) || (floating_point_out == result_binary + 1)) 
	   else begin
	      j = j + 1;
	      $error("expected = %b, calculated = %b, wrong case = %d", result_binary, floating_point_out, i);
	      //$display(fp1_real);//
	      //$display(fp2_real);//
	      //$display(result_real); //expected
	      //$display(fp_out_real); //computed
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
      input shortreal r;
      output reg [31:0] fp;
      begin
	 
	 int fp_index;
	 shortreal MAX;
	 shortreal MIN;
	 
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
	    for(shortreal i = 0.50; i != 2**-24; i /= 2) begin
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
      output shortreal  fp;
      begin
         
	 fp_exp  = shortreal'(val[30:23]);
	 fp_frac = shortreal'(val[22:0]);

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
   
   while(i <= 40) begin
      random_check();
      i = i + 1;
      //break;
      end
  /*while (1) begin
	i = i + 1;
	random_check();
  end*/
end
   
endmodule // tb_FPU_top_level
