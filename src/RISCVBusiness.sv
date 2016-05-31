`include "ram_if.vh"

module RISCVBusiness (
  input logic CLK, nRST,
  output logic halt,
  ram_if.cpu ramif
);
  
  // Interface instantiations

  ram_if tspp_icache_ram_if();
  ram_if tspp_dcache_ram_if();
  ram_if icache_mc_if();
  ram_if dcache_mc_if();

  // Module Instantiations

  tspp pipeline (
    .CLK(CLK),
    .nRST(nRST),
    .halt(halt),
    .iram_if(tspp_icache_ram_if),
    .dram_if(tspp_dcache_ram_if)
  );

  icache icache_m (
    .CLK(CLK),
    .nRST(nRST),
    .ram_in_if(tspp_icache_ram_if),
    .ram_out_if(icache_mc_if)
  );

  dcache dcache_m (
    .CLK(CLK),
    .nRST(nRST),
    .ram_in_if(tspp_dcache_ram_if),
    .ram_out_if(dcache_mc_if)
  );

  memory_controller mc (
    .CLK(CLK),
    .nRST(nRST),
    .d_ram_if(dcache_mc_if),
    .i_ram_if(icache_mc_if),
    .out_ram_if(ramif)
  );


endmodule
