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
*   Filename:     tb_risc_mgmt.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 02/10/2017
*   Description:  RISC-MGMT testbench.  Tests:
*                     - //TODO 
*/

`include "risc_mgmt_if.vh"

module tb_risc_mgmt();

  parameter PERIOD = 20;

  /*  Signal Instantiations */
  logic CLK, nRST;

  /*  Interface Instantiations */
  risc_mgmt_if rmif();

  /*  Module Instantiations */
  risc_mgmt DUT (.*);

  /*  CLK generation */
  initial begin
    CLK = 0;
  end
  always begin
    CLK = ~CLK;
    #(PERIOD);
  end

  /*  TB Run  */

  initial begin
    // Reset DUT
    nRST = 1'b0;
    #(PERIOD);
    @(posedge CLK);
    nRST = 1'b1;

    // Begin Testing
    
    $display("Testing Finished\n");
    $finish;
  end

endmodule
