
//-------------------------------------------------------
//  ram_wrapper.sv
//
//  Ram wrapper should contain the ram module provided
//  by the simulation environment being used.
//
//  If no ram modules are provided, an emulated ram 
//  module must be created.
//
//  -----------------------------------------------------

`include "ram_if.vh"

module ram_wrapper (
  input logic CLK, nRST,
  ram_if.ram ramif
);

  //  connect ram module or model here

endmodule
