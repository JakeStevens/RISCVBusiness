/*
*		Copyright 2016 Purdue University
*		
*		Licensed under the Apache License, Version 2.0 (the "License");
*		you may not use this file except in compliance with the License.
*		You may obtain a copy of the License at
*		
*		    http://www.apache.org/licenses/LICENSE-2.0
*		
*		Unless required by applicable law or agreed to in writing, software
*		distributed under the License is distributed on an "AS IS" BASIS,
*		WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*		See the License for the specific language governing permissions and
*		limitations under the License.
*
*
*		Filename:			ram_if.vh
*
*		Created by:		John Skubic
*		Email:				jskubic@purdue.edu
*		Date Created:	06/01/2016
*		Description:  Interface for connecting a requestor to ram.	
*/

`ifndef RAM_IF_VH
`define RAM_IF_VH

interface ram_if ();

  parameter ADDR_BITS = 16;
  parameter DATA_BITS = 32;
  
  logic [ADDR_BITS-1:0]addr;
  logic [DATA_BITS-1:0]wdata;
  logic [DATA_BITS-1:0]rdata;
  logic ren,wen;
  logic busy;

  modport ram (
    input addr, ren, wen, wdata,
    output rdata, busy
  );

  modport cpu (
    input rdata, busy,
    output addr, ren, wen, wdata
  );

endinterface

`endif //RAM_IF_VH
