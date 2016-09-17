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
*   Filename:     bus_trans.sv
*   
*   Created by:   Chuan Yean Tan
*   Email:        tan56@purdue.edu
*   Date Created: 09/14/2016
*   Description:  Translates pipeline bus to a non-pipeline bus  
*/

`include "ram_if.vh"

module bus_trans (
  input logic CLK, nRST,
  ram_if pipeline_trans_if, 
  ram_if.cpu out_ram_if
);

  logic [31:0] next_wdata;
  logic next_busy; 

  always_ff @ ( posedge CLK, negedge nRST )
  begin 
    if(!nRST) 
    begin 
      out_ram_if.wen <= pipeline_trans_if.wen; 
      out_ram_if.ren <= pipeline_trans_if.ren; 
      out_ram_if.addr <= pipeline_trans_if.addr; 
      out_ram_if.byte_en <= pipeline_trans_if.byte_en; 
      out_ram_if.wdata <= next_wdata;
    end 
    else 
    begin 
      if ( out_ram_if.busy == 0 ) 
      begin 
        out_ram_if.wen <= pipeline_trans_if.wen; 
        out_ram_if.ren <= pipeline_trans_if.ren; 
        out_ram_if.addr <= pipeline_trans_if.addr; 
        out_ram_if.byte_en <= pipeline_trans_if.byte_en; 
        out_ram_if.wdata <= next_wdata;
      end 
    end 
  end 


  assign pipeline_trans_if.busy = (out_ram_if.addr == 0) ? 1 : out_ram_if.busy; 
  assign pipeline_trans_if.rdata = out_ram_if.rdata;
  assign next_wdata = pipeline_trans_if.wdata;

endmodule
