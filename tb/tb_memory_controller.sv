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
*   Filename:     tb/tb_memory_controller.sv
*
*   Created by:   Chuan Yean Tan
*   Email:        tan56@purdue.edu
*   Date Created: 09/08/2016
*   Description:  Testbench for the alu 
*/

`include "ram_if.vh" 

module tb_memory_controller ();

  parameter NUM_TESTS = 1;
  parameter PERIOD = 20; 

  logic CLK, nRST; 

  ram_if d_ram_if(); 
  ram_if i_ram_if(); 
  ram_if out_ram_if(); 

  memory_controller DUT ( CLK, nRST, d_ram_if, i_ram_if, out_ram_if );

  //-- CLOCK INITIALIZATION --// 
  initial begin : INIT 
    CLK = 0; 
  end : INIT 

  //-- CLOCK GENERATION --// 
  always begin : CLOCK_GEN 
    #(PERIOD/2) CLK = ~CLK; 
  end : CLOCK_GEN

  initial begin : MAIN
     
    //-- Initial reset --// 
    nRST = 0; 
    d_ram_if.ren = 0; 
    d_ram_if.wen = 0;
    i_ram_if.ren = 0; 
    i_ram_if.wen = 0;

    i_ram_if.addr = 32'h00000000; 
    i_ram_if.wdata = 32'h00000000; 
    i_ram_if.byte_en = 4'h1;
    d_ram_if.addr = 32'h00000000; 
    d_ram_if.wdata = 32'h00000000; 
    d_ram_if.byte_en = 4'h1;

    out_ram_if.rdata = 32'hDEADBEEF; 
    out_ram_if.busy = 0;

    @(posedge CLK); 
    @(posedge CLK); 

    nRST = 1; 
    d_ram_if.ren = 1; 
    d_ram_if.wen = 0;
    i_ram_if.ren = 1; 
    i_ram_if.wen = 0;

    i_ram_if.addr = 32'h00000010; 
    d_ram_if.addr = 32'h00000080; 

    out_ram_if.rdata = 32'hDEADBEEF; 
    out_ram_if.busy = 1; 

    #(2 * PERIOD) 
    #(2 * PERIOD) 
    //#(PERIOD/2) 
    out_ram_if.busy = 0; 
    #(2 * PERIOD) 
    #(2 * PERIOD) 
    out_ram_if.busy = 1; 
    #(2 * PERIOD) 
    #(2 * PERIOD) 
    out_ram_if.busy = 0; 
    #(2 * PERIOD) 

    $finish;
  end : MAIN
endmodule
