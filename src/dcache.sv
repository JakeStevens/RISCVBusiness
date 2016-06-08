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
*   Filename:     dcache.sv
*   
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 06/01/2016
*   Description:  Data Cache	
*/

`include "ram_if.vh"

module dcache (
  input logic CLK, nRST,
  ram_if.cpu ram_in_if,
  ram_if.ram ram_out_if
);

  //passthrough layer
  assign ram_in_if.addr  = ram_out_if.addr;
  assign ram_in_if.ren   = ram_out_if.ren;
  assign ram_in_if.wen   = ram_out_if.wen;
  assign ram_in_if.wdata = ram_out_if.wdata;
  
  assign ram_out_if.rdata  = ram_in_if.rdata;
  assign ram_out_if.busy   = ram_in_if.busy;

endmodule
