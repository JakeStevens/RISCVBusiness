/*
*   Copyright 2020 Purdue University
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
*   Filename:     tb/tb_rf.sv
*
*   Created by:   Jacob R. Stevens
*   Email:        jskubic@purdue.edu
*   Date Created: 02/10/2020
*   Description:  Testbench for the register file
*/
`timescale 1ns/100ps

`include "rv32i_reg_file_if.vh"

module tb_rf ();
  import rv32i_types_pkg::*;

  parameter PERIOD = 20;

  logic CLK, nRST;
  logic error_found;

  //-- CLOCK INITIALIZATION --//
  initial begin : INIT
    CLK = 0;
  end : INIT

  //-- CLOCK GENERATION --//
  always begin : CLOCK_GEN 
    #(PERIOD/2) CLK = ~CLK;
  end : CLOCK_GEN


  rv32i_reg_file_if rfif();

  rv32i_reg_file DUT (.CLK(CLK), .nRST(nRST), .rf_if(rfif));
 
  initial begin : MAIN
    // Initialize signals and reset the registers
    error_found = 0;
    nRST = 1'b0;
    rfif.wen = 1'b0;
    rfif.rd = 5'b0;
    rfif.rs1 = 5'b0;
    rfif.rs2 = 5'b0;
    rfif.w_data = 32'b0;
    @(posedge CLK);
    #(2*PERIOD);
    nRST = 1'b1;
    @(posedge CLK);
    #(5);

    // Run tests

    // Test Case 1: Simple Write
    rfif.w_data = 32'hDEADBEEF;
    rfif.rd = 5'd3;
    rfif.wen = 1'b1;
    #(PERIOD);
    // Make sure 0xDEADBEEF was written into the register
    assert(DUT.registers[3] == 32'hDEADBEEF)
        else begin
            $display("Failed to write. Register contains: %x", DUT.registers[3]);
            error_found = 1'b1;
        end

    // Test Case 2: Write Enable
    rfif.w_data = 32'hDEAD0000;
    rfif.rd = 5'd3;
    rfif.wen = 1'b0;
    #(PERIOD);
    // Make sure the register is NOT updated since the enable is off
    assert(DUT.registers[3] == 32'hDEADBEEF)
        else begin
            $display("Failed to not write. Register contains: %x", DUT.registers[3]);
            error_found = 1'b1;
        end

    // Test Case 3: Reads
    rfif.w_data = 32'hDEAD0000;
    rfif.rd = 5'd4;
    rfif.wen = 1'b1;
    #(PERIOD);
    // Make sure the register is NOT updated since the enable is off
    rfif.rs1 = 5'd3;
    rfif.rs2 = 5'd4;
    #(5);
    assert(rfif.rs1_data == 32'hDEADBEEF)
        else begin
            $display("Failed to read. Signal read: %x", rfif.rs1_data);
            error_found = 1'b1;
        end
    assert(rfif.rs2_data == 32'hDEAD0000)
        else begin
            $display("Failed to read. Signal read: %x", rfif.rs2_data);
            error_found = 1'b1;
        end

    // Test Case 4: No write to register 0
    rfif.w_data = 32'hDEADBEEF;
    rfif.rd = 5'd0;
    rfif.wen = 1'b1;
    #(PERIOD);
    rfif.wen = 1'b0;
    // Make sure 0xDEADBEEF was not written into the register
    assert(DUT.registers[0] != 32'hDEADBEEF)
        else begin
            $display("Failed to not write. Register contains: %x", DUT.registers[3]);
            error_found = 1'b1;
        end

    #(PERIOD);
    if (~error_found)
        $display("TESTS ALL PASSED");
    $finish;
  end : MAIN
endmodule

