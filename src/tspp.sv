`include "ram_if.vh"

module tspp (
  input logic CLK, nRST,
  output logic halt,
  ram_if.cpu iram_if,
  ram_if.cpu dram_if
);

  // TODO: Implement two stage pipeline
  // Assign halt to one so testbench stops
  assign halt = 1'b1;

endmodule
