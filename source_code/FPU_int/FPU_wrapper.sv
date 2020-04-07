`include "FPU_all_if.vh"

module FPU_wrapper(
  input logic CLK, nRST,
  FPU_all_if.fp fpif
);

generate
  case(FPU_ENABLED)
    "disabled" : FPU_disabled FPU(.*);
    "enabled" : FPU_enabled FPU(.*);
  endcase
endgenerate

endmodule
