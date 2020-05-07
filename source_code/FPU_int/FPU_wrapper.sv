`include "FPU_all_if.vh"
`include "component_selection_defines.vh"

module FPU_wrapper(
  input logic CLK, nRST,
  FPU_all_if fpif
);

generate
  case(FPU_ENABLED)
    "disabled" : FPU_disabled FPU(.*);
    "enabled" : FPU_enabled FPU(.clk(CLK), .nrst(nRST), .fpif(fpif));
  endcase
endgenerate

endmodule
