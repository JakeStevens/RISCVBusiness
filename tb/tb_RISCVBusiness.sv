/***********************************************************
 *
 *  Author: John Skubic
 *
 *  tb_RISCVBusines
 *
 *  Testbench will allow the core to run while connected 
 *  to a ram module.  The ram module should be loaded with
 *  the program being run.  When the core signals a halt 
 *  condition, the ram is dumped to a hex file in the 
 *  Intel format.  
 *
 * *********************************************************
 */


`include "ram_if.vh"

`define OUTPUT_FILE_NAME "../cpu.hex"

module tb_RISCVBusiness ();
   
  parameter PERIOD = 20;
 
  logic CLK, nRST;
  logic ram_control; // 1 -> CORE, 0 -> TB
  logic halt;
  logic [31:0] addr, data;
  logic [63:0] hexdump_temp;
  logic [7:0] checksum;
  integer fptr;

  //Interface Instantiations
  ram_if ramif();
  ram_if rvb_ramif();
  ram_if tb_ramif();

  //Module Instantiations

  RISCVBusiness DUT (
    .CLK(CLK),
    .nRST(nRST),
    .ramif(rvb_ramif)
  );

  ram_wrapper ram (
    .CLK(CLK),
    .nRST(nRST),
    .ramif(ramif)
  ); 

  //Ramif Mux
  always_comb begin
    if(ram_control) begin
      ramif.addr  =   rvb_ramif.addr;
      ramif.ren   =   rvb_ramif.ren;
      ramif.wen   =   rvb_ramif.wen;
      ramif.wdata =   rvb_ramif.wdata;
    end else begin
      ramif.addr  =   tb_ramif.addr;
      ramif.ren   =   tb_ramif.ren;
      ramif.wen   =   tb_ramif.wen;
      ramif.wdata =   tb_ramif.wdata;
    end
  end

  assign rvb_ramif.rdata  = ramif.rdata;
  assign rvb_ramif.busy   = ramif.busy;
  assign tb_ramif.rdata   = ramif.rdata;
  assign tb_ramif.busy    = ramif.busy;

  //Clock generation
  initial begin : INIT
    CLK = 0;
  end : INIT

  always begin : CLOCK_GEN
    #(PERIOD/2) CLK = ~CLK;
  end : CLOCK_GEN

  //Setup core and let it run
  initial begin : CORE_RUN
    nRST = 0;
    ram_control = 1;

    //for testing tb:
    halt = 1;
 
    @(posedge CLK);
    @(posedge CLK);

    nRST = 1;
    
    while (halt == 0) begin
      @(posedge CLK);
    end

    dump_ram();

    $finish;

  end : CORE_RUN

  task dump_ram ();
    ram_control = 0;
    tb_ramif.addr = 0;
    tb_ramif.ren = 0;
    tb_ramif.wen = 0;
    tb_ramif.wdata = 0;

    fptr = $fopen(`OUTPUT_FILE_NAME, "w");

    for(addr = 32'h200; addr < 32'h1000; addr+=4) begin
      read_ram(addr, data);
      hexdump_temp = {8'h04, addr[15:0]>>2, 8'h00, data};
      checksum = calculate_crc(hexdump_temp);
      if(data != 0)
        $fwrite(fptr, ":%2h%4h00%8h%2h\n", 8'h4, addr[15:0]>>2, data, checksum);
    end
    // add the EOL entry to the file
    $fwrite(fptr, ":00000001FF");  

  endtask

  task read_ram (input logic [31:0] raddr, output logic [31:0] rdata);
    @(posedge CLK);
    tb_ramif.addr = raddr;
    tb_ramif.ren = 1;
    @(posedge CLK);
    while(tb_ramif.busy == 1) @(posedge CLK);
    rdata = tb_ramif.rdata;
    tb_ramif.ren = 0;
  endtask

  function [7:0] calculate_crc (logic [63:0] hex_line);
    static logic [7:0] checksum = 0;
    int i;

    checksum = hex_line[7:0] + hex_line[15:8] + hex_line[23:16] +
                hex_line[31:24] + hex_line[39:32] + hex_line[47:40] +
                hex_line[55:48] + hex_line[63:56];
    
    //take two's complement
    checksum = (~checksum) + 1;
    return checksum;
  endfunction

endmodule
