`ifndef RAM_IF_VH
`define RAM_IF_VH

interface ram_if ();

  parameter ADDR_BITS = 16;
  parameter DATA_BITS = 32;
  
  logic [ADDR_BITS-1:0]addr;
  logic [DATA_BITS-1:0]wdata;
  logic [DATA_BITS-1:0]rdata;
  logic ren,wen;
  logic busy;

  modport ram (
    input addr, ren, wen, wdata,
    output rdata, busy
  );

  modport cpu (
    input rdata, busy,
    output addr, ren, wen, wdata
  );

endinterface

`endif //RAM_IF_VH
