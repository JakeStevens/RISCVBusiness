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
*		Filename:			tspp.sv
*
*		Created by:		John Skubic
*		Email:				jskubic@purdue.edu
*		Date Created:	06/01/2016
*		Description:	Two Stage Pipeline
*/

`include "ram_if.vh"

module tspp (
  input logic CLK, nRST,
  output logic halt,
  ram_if.cpu iram_if,
  ram_if.cpu dram_if
);

  // TODO: Implement two stage pipeline
  // Assign halt to one so testbench stops
  assign halt = 1'b1;

endmodule
