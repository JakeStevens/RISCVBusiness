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
*   Filename:     tb_shift_add_multiplier.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 02/15/2017
*   Description:  Tests a 32bitx32bit multiplier
*/

module tb_shift_add_multiplier ();

  parameter PERIOD = 20;

  /*  Signal Instantiations */
  logic CLK, nRST;
  logic [31:0] multiplicand;
  logic [31:0] multiplier;
  logic [1:0] is_signed;
  logic start, finished;
  logic [63:0] product;
  logic [31:0] test_num; 

  /*  Module Instantiations */
  shift_add_multiplier #(32) DUT (.*);

  /*  CLK generation */

  initial begin
    CLK = 0;
  end

  always begin
    CLK = ~CLK;
    #(PERIOD/2);
  end

  task test_mult(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic [1:0] is_signed_t,
    input logic [63:0] expected_out
  );
    multiplicand = a;
    multiplier = b;
    is_signed = is_signed_t;
    start = 1;
    @(posedge CLK);
    start = 0;
    while(!finished) 
      @(posedge CLK);
    
    assert (product == expected_out) else $error("Multiplication failed for test %0d\n", test_num);
    test_num++;
  endtask

  /*  Begin Testing   */

  initial begin
    // reset multiplier
    test_num = 0;
    nRST = 1'b0;
    multiplicand = 0;
    multiplier = 0;
    is_signed = 0;
    start = 0;
    @(posedge CLK);
    #1;
    nRST = 1'b1;
    @(posedge CLK);

    // basic multiplication test
    test_mult(32'd8, 32'd11, 2'b00, 32'd88);
 
    // both signed multiplication test
    test_mult(-1, -108, 2'b11, 108);

    // one signed one unsigned
    test_mult(-8, 100001, 2'b10, -800008); 
    test_mult(100001, -8, 2'b01, -800008); 

    //  negative number and 1
    test_mult(32'hffff_ffff, 32'h1, 2'b11, 32'hffff_ffff);
    test_mult(32'h1, 32'hffff_ffff, 2'b11, 32'hffff_ffff);

    // largest negative number and 1
    test_mult(32'h8000_0000, 32'h1, 2'b11, 32'h8000_0000);    
    test_mult(32'h8000_0000, 32'h1, 2'b00, 32'h8000_0000); 

    // multiply by 0
    test_mult(32'h0, 32'habcd_1234, 2'b00, 32'h0);   
 
    $finish;
  end
  
endmodule
