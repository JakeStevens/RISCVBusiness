`include "ram_if.vh"

module dcache (
  input logic CLK, nRST,
  ram_if.cpu ram_in_if,
  ram_if.ram ram_out_if
);

  //passthrough layer
  assign ram_out_if.addr  = ram_in_if.addr;
  assign ram_out_if.ren   = ram_in_if.ren;
  assign ram_out_if.wen   = ram_in_if.wen;
  assign ram_out_if.wdata = ram_in_if.wdata;
  
  assign ram_in_if.rdata  = ram_out_if.rdata;
  assign ram_in_if.busy   = ram_out_if.busy;

endmodule
