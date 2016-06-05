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
*		Filename:     ram_wrapper.sv
*
*		Created by:   John Skubic	
*		Email:        jskubic@purdue.edu
*		Date Created: 06/01/2016
*		Description:  Ram wrapper should contain the ram module provided by the 
*		              simulation environment being used. If no ram modules are 
*		              provided, an emulated ram module must be created.
*/

`include "ram_if.vh"

module ram_wrapper (
  input logic CLK, nRST,
  ram_if.ram ramif
);

  ram #(.LAT(0)) v_lat_ram (
    .CLK(CLK),
    .nRST(nRST),
    .ramif(ramif)
  );

endmodule
