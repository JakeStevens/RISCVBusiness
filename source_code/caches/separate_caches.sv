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
*   Filename:     separate_caches.sv
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 11/08/2016
*   Description: Caches consisting of separate I$ and D$ 
*/

module separate_caches (
  input logic CLK, nRST,
  ram_if.cpu icache_mem_ram_if,
  ram_if.cpu dcache_mem_ram_if,
  ram_if.ram icache_proc_ram_if,
  ram_if.ram dcache_proc_ram_if
);

  pass_through_dcache dcache(
    .CLK(CLK),
    .nRST(nRST),
    .mem_ram_if(dcache_mem_ram_if),
    .proc_ram_if(dcache_proc_ram_if)
  );

  pass_through_icache icache(
    .CLK(CLK),
    .nRST(nRST),
    .mem_ram_if(icache_mem_ram_if),
    .proc_ram_if(icache_proc_ram_if)
  );

endmodule
