
//-------------------------------------------------------
//  ram_wrapper.sv
//
//  Ram wrapper should contain the ram module provided
//  by the simulation environment being used.
//
//  If no ram modules are provided, an emulated ram 
//  module must be created.
//  -----------------------------------------------------

`include "ram_if.vh"

module ram_wrapper (
  input logic CLK, nRST,
  ram_if.ram ramif
);

  ram #(.LAT(0)) v_lat_ram (
    .CLK(CLK),
    .nRST(nRST),
    .ramif(ramif)
  );

endmodule
