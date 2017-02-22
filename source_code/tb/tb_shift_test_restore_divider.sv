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
*   Filename:     tb_shift_test_restore_divider.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 02/22/2017
*   Description:  Tests a 32bitx32bit divider 
*/

module tb_shift_test_restore_divider ();

  parameter PERIOD = 20;

  /*  Signal Instantiations */
  logic CLK, nRST;
  logic [31:0] divisor;
  logic [31:0] dividend;
  logic  is_signed;
  logic start, finished;
  logic [31:0] remainder, quotient;
  logic [31:0] test_num; 

  /*  Module Instantiations */
  shift_test_restore_divider #(32) DUT (.*);

  /*  CLK generation */

  initial begin
    CLK = 0;
  end

  always begin
    CLK = ~CLK;
    #(PERIOD/2);
  end

  task test_div(
    input logic [31:0] a,
    input logic [31:0] b,
    input logic is_signed_t,
    input logic [31:0] exp_quot, exp_rem
    );
    divisor = a;
    dividend = b;
    is_signed = is_signed_t;
    start = 1;
    @(posedge CLK);
    @(posedge CLK);
    #(9);
    start = 0;
    while(!finished) 
      @(posedge CLK);
    
    assert (quotient == exp_quot) else $error("Division failed for test %0d: Expected %h Received %h\n", test_num, exp_quot, quotient);
    assert (remainder == exp_rem) else $error("Remainder failed for test %0d: Expected %h Received %h\n", test_num, exp_rem, remainder);
    test_num++;
  endtask

  /*  Begin Testing   */

  initial begin
    // reset divider 
    test_num = 0;
    nRST = 1'b0;
    divisor = 0;
    dividend = 0;
    is_signed = 0;
    start = 0;
    @(posedge CLK);
    @(posedge CLK);
    #(PERIOD/2);
    nRST = 1'b1;
    @(posedge CLK);
    @(posedge CLK);
    @(posedge CLK);

    //Basic test divisor, dividend, signed, quot, rem
    test_div(32'h80, 32'h2, 1'b0, 32'h40, 32'h0);
 
 
    $finish;
  end
  
endmodule
