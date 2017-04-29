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
*   Filename:     ram_sim_model.sv
*   
*   Created by:   John Skubic	
*   Email:        jskubic@purdue.edu
*   Date Created: 04/27/2017
*   Description:  SRAM model.  This is NOT SYNTHESIZABLE but allows this
*                 project to run independent of tools in simulation. 
*/

`include "generic_bus_if.vh"

module ram_sim_model (
  input logic CLK, nRST,
  generic_bus_if.generic_bus gen_bus_if
);
  parameter LAT = 0; // ram latency
  parameter ENDIANNESS = "little";
  parameter WIDTH = 32;
  parameter DEPTH = 8192;
  parameter MEM_INIT_FILE  = "meminit.hex";
  parameter MEM_DEFAULT = 32'h0000_0000;
    
  localparam ADDR_BITS = $clog2(DEPTH);
  localparam COUNT_BITS = $clog2(LAT) + 1;

  // Memory as associative array to try and save space at runtime
  logic [WIDTH-1:0] memory [*];
  
  // Variables for file IO
  integer fptr;
  logic [ADDR_BITS-1:0] faddr;
  logic [7:0] line_type;
  logic [31:0] fdata;
  logic [1:0] t0, t1;

  // RAM signals
  logic [COUNT_BITS-1:0] counter;
  logic [ADDR_BITS-1:0] addr, addr_r, addr_ram;
  logic ren, ren_r, ren_ram;
  logic wen, wen_r, wen_ram;
  logic [(WIDTH/8)-1:0] byte_en;
  logic [WIDTH-1:0] rdata, wdata, wdata_r, wdata_ram, mask;
  logic input_diff;
  logic access;
  string line;
  int res;

  // Load in meminit
  initial begin
    if (MEM_INIT_FILE != "") begin
      fptr = $fopen(MEM_INIT_FILE, "r");
      if (!fptr) begin
        $info("Warning: Couldn't open memory init file %s", MEM_INIT_FILE);
      end else begin
        while (!$feof(fptr)) begin
          res = $fgets(line, fptr);
          res = $sscanf(line, ":%2h%4h%2h%8h%2h", t0, faddr, line_type, fdata, t1); 
          if (line_type == 8'h00) //data
            memory[faddr] = fdata;
        end
        $fclose(fptr);
      end
    end
  end

  /*
  *
  * Begin steady state ram functionality
  *
  */

  // Changes for bus endianness
  generate
    if (ENDIANNESS == "big") begin
      endian_swapper write_swap(.word_in(gen_bus_if.wdata), .word_out(wdata));
      endian_swapper read_swap(.word_in(rdata), .word_out(gen_bus_if.rdata));
      // TODO: byte enable swap should be based off parameters
      assign byte_en = {gen_bus_if.byte_en[0], gen_bus_if.byte_en[1],
                        gen_bus_if.byte_en[2], gen_bus_if.byte_en[3]};
    end else if (ENDIANNESS == "little") begin
      assign wdata = gen_bus_if.wdata;
      assign byte_en = gen_bus_if.byte_en;
      assign gen_bus_if.rdata = rdata;
    end
  endgenerate

  genvar i;
  generate 
    for(i=0; i < WIDTH/8; i++) 
      assign mask[i*8+:8] = {8{byte_en[i]}};
  endgenerate
  
  always begin
    @(posedge CLK);
    if (access && wen_ram) begin
      if (memory.exists(addr_ram))
        memory[addr_ram] = (wdata_ram & mask) | (memory[addr_ram] & ~mask);
      else 
        memory[addr_ram] = wdata_ram & mask;
    end
  end

  assign addr = gen_bus_if.addr[ADDR_BITS+1:2]; //shift to be word addressed
  assign ren  = gen_bus_if.ren;
  assign wen  = gen_bus_if.wen;

  always_ff @ (posedge CLK, negedge nRST) begin
    if (~nRST) begin
      addr_r  <= '0;
      ren_r   <= '0;
      wen_r   <= '0;
      wdata_r <= '0;
    end else begin
      addr_r  <= addr;
      ren_r   <= ren;
      wen_r   <= wen;
      wdata_r <= wdata;
    end
  end
  
  assign input_diff = (addr_r !== addr) || (ren_r !== ren) || 
                      (wen_r !== wen) || (wdata_r !== wdata);

  // mux inputs to ram
  assign addr_ram   = input_diff ? addr : addr_r;
  assign ren_ram    = input_diff ? ren  : ren_r;
  assign wen_ram    = input_diff ? wen  : wen_r;
  assign wdata_ram  = input_diff ? wdata: wdata_r;

  always_ff @ (posedge CLK, negedge nRST) begin
    if (~nRST) 
      counter <= '0;
    else if (input_diff) 
      counter <= '0;
    if (counter != LAT) 
      counter <= counter + 1;
  end

  assign access = (counter == LAT) && !input_diff;

  assign rdata = (^addr_ram !== 1'bx) && memory.exists(addr_ram) ? memory[addr_ram] : MEM_DEFAULT;
  assign gen_bus_if.busy  = ~access;

endmodule
