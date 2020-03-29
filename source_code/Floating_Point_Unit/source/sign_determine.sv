module sign_determine
  (
   input 	 temp_sign,
   input [31:0]  temp_floating_point_out,
   input 	 cmp_out,
   input [31:0]  floating_point1,
   input [31:0]  floating_point2,
   output [31:0] floating_point_out
   );
   wire [31:0] 	 temp_result;
   reg 		 dummy;	 
   assign temp_result[30:0] = temp_floating_point_out[30:0];
   
   always_comb begin
      if ((floating_point1[31] == 0) & (floating_point2[31] == 1)) begin
	 dummy = 1'b0;
      end else if ((floating_point1[31] == 1) & (floating_point2[31] == 0)) begin
	 dummy = 1'b1;
      end else begin //1 1 or 00
	 if ((floating_point1[31] == 1) & (floating_point2[31] == 1)) begin
	    if (cmp_out == 1) begin
	       dummy = 0;
	    end else if (cmp_out == 0) begin
	       dummy = 1;
	    end
	 end else if ((floating_point1[31] == 0) & (floating_point2[31] == 0)) begin
	    if (cmp_out == 1) begin
	       dummy = 1;
	    end else if (cmp_out == 0) begin
	       dummy = 0;
	    end
	    // dummy  = cmp_out ? ~temp_sign : temp_sign;
	 end
      end
   end // always_comb
   
   //assign temp_result[31]  = cmp_out ? ~temp_sign : temp_sign;

   assign floating_point_out[31:0] = {dummy, temp_result[30:0]};
   
endmodule // sign_determine

