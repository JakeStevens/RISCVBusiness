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
*   Filename:     memory_controller.sv
*   
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 06/01/2016
*   Description:  Memory controller and arbitration between instruction
*                 and data accesses
*/

`include "ram_if.vh"

module memory_controller (
  input CLK, nRST,
  ram_if.ram d_ram_if,
  ram_if.ram i_ram_if,
  ram_if.cpu out_ram_if
);

  //Arbitration - give precedence to data transactions
  always_comb begin
    if (d_ram_if.wen || d_ram_if.ren) begin
      out_ram_if.wen      = d_ram_if.wen;
      out_ram_if.ren      = d_ram_if.ren;
      out_ram_if.addr     = d_ram_if.addr;
      d_ram_if.busy       = out_ram_if.busy;
      i_ram_if.busy       = 1'b1;
      out_ram_if.byte_en  = d_ram_if.byte_en;
    end else begin
      out_ram_if.wen      = i_ram_if.wen;
      out_ram_if.ren      = i_ram_if.ren;
      out_ram_if.addr     = i_ram_if.addr;
      d_ram_if.busy       = 1'b1;
      i_ram_if.busy       = out_ram_if.busy;
      out_ram_if.byte_en  = i_ram_if.byte_en;
    end
  end

  /*  align the byte enable with the data being selected 
      based on the byte addressing */
  always_comb begin
    casez (out_ram_if.byte_en)
      4'hf, 4'h1, 4'h3  : out_ram_if.wdata = d_ram_if.wdata;      
      4'h2              : out_ram_if.wdata = d_ram_if.wdata << 8;
      4'h4, 4'hc        : out_ram_if.wdata = d_ram_if.wdata << 16;
      4'h8              : out_ram_if.wdata = d_ram_if.wdata << 24;
    endcase
  end

  assign d_ram_if.rdata   = out_ram_if.rdata;
  assign i_ram_if.rdata   = out_ram_if.rdata;

endmodule
