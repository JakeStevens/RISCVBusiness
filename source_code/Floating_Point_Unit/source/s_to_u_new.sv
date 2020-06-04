//By            : Joe Nasti
//Last Updated  : 7/18/18
//
//Module Summary:
//    converts a signed 27 value to a 26 bit magnitude and a one bit sign
//
//Inputs:
//    frac_signed   - 27 bit signed value
//Outputs: 
//    sign          - 1 bit sign 'frac_unsigned'
//    frac_unsigned - 26 bit magnitude of 'frac_signed'

module s_to_u_new(
	input      [26:0] frac_signed,
	input reg exp_determine,
	output reg        sign,
	output     [25:0] frac_unsigned
);

reg [26:0] rfrac_signed;

assign frac_unsigned = rfrac_signed[25:0];
   
always_comb begin
	if (exp_determine == 0) begin
        	sign = 0;
		rfrac_signed = frac_signed;
		if(frac_signed[26] == 1) begin
			rfrac_signed = -frac_signed;
			sign         = 1;
		end
	end else if (exp_determine == 1) begin
	  	rfrac_signed = {1'b0,frac_signed[24:0],1'b0};
  		sign = frac_signed[26];
	end
end
endmodule
