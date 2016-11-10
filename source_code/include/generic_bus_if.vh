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
*		Filename:     generic_bus_if.vh
*
*		Created by:   John Skubic
*		Email:        jskubic@purdue.edu
*		Date Created: 06/01/2016
*		Description:  Interface for connecting a requestor to ram.	
*/

`ifndef GENERIC_BUS_IF_VH
`define GENERIC_BUS_IF_VH

interface generic_bus_if ();
  import rv32i_types_pkg::*;

  logic [RAM_ADDR_SIZE-1:0] addr;
  word_t wdata;
  word_t rdata;
  logic ren,wen;
  logic busy;
  logic [3:0] byte_en;

  modport generic_bus (
    input addr, ren, wen, wdata, byte_en,
    output rdata, busy
  );

  modport cpu (
    input rdata, busy,
    output addr, ren, wen, wdata, byte_en
  );

endinterface

`endif //GENERIC_BUS_IF_VH
