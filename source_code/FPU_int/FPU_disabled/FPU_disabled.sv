`include "FPU_all_if.vh"
`include "f_register_file_if.vh"

module FPU_disabled
(
 input 	       clk,
 input 	       nrst,
 FPU_all_if.fp fpif 
 );

// all outputs set to '0

assign fpif.FPU_out = '0;
assign fpif.f_flags = '0;
assign fpif.frm_out = '0;

endmodule
