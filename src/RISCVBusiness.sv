/*
*   Copyright 2016 Purdue University
*   
*   Licensed under the Apache License, Version 2.0 (the "License");
*   you may not use this file except in compliance with the License.
*   You may obtain a copy of the License at
*   
*       http://www.apache.org/licenses/LICENSE-2.0
*   
*   Unless required by applicable law or agreed to in writing, software
*   distributed under the License is distributed on an "AS IS" BASIS,
*   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*   See the License for the specific language governing permissions and
*   limitations under the License.
*   
*   
*   Filename:     RISCVBusiness.sv
*   
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 06/01/2016
*   Description:  Top level module for RISCVBusiness
*/

`include "ram_if.vh"

module RISCVBusiness (
  input logic CLK, nRST,
  output logic halt,
  ram_if.cpu ram_if
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
    .proc_ram_if(tspp_icache_ram_if),
    .mem_ram_if(icache_mc_if)
  );

  dcache dcache_m (
    .CLK(CLK),
    .nRST(nRST),
    .proc_ram_if(tspp_dcache_ram_if),
    .mem_ram_if(dcache_mc_if)
  );

  memory_controller mc (
    .CLK(CLK),
    .nRST(nRST),
    .d_ram_if(dcache_mc_if),
    .i_ram_if(icache_mc_if),
    .out_ram_if(ram_if)
  );


endmodule
