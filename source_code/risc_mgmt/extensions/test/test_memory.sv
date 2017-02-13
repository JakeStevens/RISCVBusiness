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
*   Filename:     test_memory.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 02/07/2017
*   Description:  ISA extension used for RISC-MGMT testbench
*/

`include "risc_mgmt_memory_if.vh"

module test_memory (
  input logic CLK, nRST,
  //risc mgmt connection
  risc_mgmt_memory_if.ext mif,
  //stage to stage connection
  input test_pkg::execute_memory_t exmem
);

  always_comb begin 
    // default to NOP 
    mif.exception = 0;
    mif.busy = 0;
    mif.reg_w = 0;
    mif.reg_wdata = 0;
    mif.mem_ren = 0;
    mif.mem_wen = 0;
    mif.mem_addr = 0;
    mif.mem_store = 0;

    if          (exmem.mem_lw) begin
      mif.mem_ren = 1;
      mif.mem_addr = exmem.mem_addr;
      mif.reg_w = ~mif.mem_busy;
      mif.reg_wdata = mif.mem_load;
      mif.busy = mif.mem_busy;
    end else if (exmem.mem_sw) begin
      mif.mem_wen = 1;
      mif.mem_addr = exmem.mem_addr;
      mif.mem_store = exmem.mem_store;
      mif.busy = mif.mem_busy;
    end else if (exmem.exception) begin
      mif.exception = 1;
    end

  end
endmodule
