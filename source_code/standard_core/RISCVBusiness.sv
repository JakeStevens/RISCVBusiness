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

`include "generic_bus_if.vh"

module RISCVBusiness (
  input logic CLK, nRST,
  output logic halt,
  generic_bus_if.cpu gen_bus_if
);

  // Interface instantiations

  generic_bus_if tspp_icache_gen_bus_if();
  generic_bus_if tspp_dcache_gen_bus_if();
  generic_bus_if icache_mc_if();
  generic_bus_if dcache_mc_if();
  generic_bus_if pipeline_trans_if(); 

  // Module Instantiations

  tspp pipeline (
    .CLK(CLK),
    .nRST(nRST),
    .halt(halt),
    .igen_bus_if(tspp_icache_gen_bus_if),
    .dgen_bus_if(tspp_dcache_gen_bus_if)
  );

  caches caches (
    .CLK(CLK),
    .nRST(nRST),
    .icache_proc_gen_bus_if(tspp_icache_gen_bus_if),
    .icache_mem_gen_bus_if(icache_mc_if),
    .dcache_proc_gen_bus_if(tspp_dcache_gen_bus_if),
    .dcache_mem_gen_bus_if(dcache_mc_if)
  );

  memory_controller mc (
    .CLK(CLK),
    .nRST(nRST),
    .d_gen_bus_if(dcache_mc_if),
    .i_gen_bus_if(icache_mc_if),
    .out_gen_bus_if(pipeline_trans_if)
  );

  generic_nonpipeline bt(
    .CLK(CLK), 
    .nRST(nRST), 
    .pipeline_trans_if(pipeline_trans_if), 
    .out_gen_bus_if(gen_bus_if)
  );

endmodule
