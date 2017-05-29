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
*   Filename:     direct_mapped_tpf_cache.sv
*   
*   Created by:   John Skubic
*   Email:        jjs.skubic@gmail.com 
*   Date Created: 05/28/2017
*   Description:  Direct Mapped Cache with tagged prefetch.  The following are configurable:
*                   - Cache Size
*                   - Non-Cacheable start address
*                   - Block Size
*	                  - Prefetch Length
*/

`include "generic_bus_if.vh"

module direct_mapped_tpf_cache (
  input logic CLK, nRST,
  input logic clear, flush,
  generic_bus_if.cpu mem_gen_bus_if,
  generic_bus_if.generic_bus proc_gen_bus_if
);

  import rv32i_types_pkg::*;

  /* --- Parameters --- */

  // configurable parameters
  parameter CACHE_SIZE          = 1024; // In bytes, must be power of 2
  parameter BLOCK_SIZE          = 2;    // must be power of 2
  parameter PREFETCH_LENGTH     = 1;    // must be power of 2
  parameter NONCACHE_START_ADDR = 32'h8000_0000;
 
  // local parameters 
  localparam TAG_BITS         = RAM_ADDR_SIZE - (2 + $clog2(BLOCK_SIZE)); 
  localparam N_BITS_IN_FRAME  = (BLOCK_SIZE * WORD_SIZE) + TAG_BITS + 2;
  localparam N_BYTES_IN_FRAME = N_BITS_IN_FRAME%8 ? N_BITS_IN_FRAME/8 + 1 : N_BITS_IN_FRAME/8;
  localparam N_INDICES        = CACHE_SIZE / (BLOCK_SIZE * WORD_SIZE / 8);
  localparam META_BYTE_L      = (BLOCK_SIZE * WORD_SIZE)/8;
  localparam META_BYTE_H      = N_BYTES_IN_FRAME-1;

  /* --- Custom Data Types --- */

  typedef struct packed {
    word_t [BLOCK_SIZE-1:0] data;
    logic  [TAG_BITS-1:0] tag;
    logic p;
    logic v;
  } cache_frame_t;

  typedef enum logic [2:0] {
    IDLE = 0,
    // flush and clear handling
    FLUSH_PREP, 
    CLEAR_PREP,
    CLEAR,
    // normal operation
    EVAL,
    FETCH,
    PREFETCH,
    UPDATE
  } sm_t;
  
  /* --- Signal Instantiations --- */

  logic [RAM_ADDR_SIZE-1:0] active_addr;
  cache_frame_t frame_buffer;
  logic [N_BYTES_IN_FRAME-1:0] byte_enable;

  logic init_flag;
  logic flush_flag;
  logic clear_flag;

  /* --- Module Instantiations --- */

  

  /* --- Logic --- */

  assign flush_flag = flush | init_flag;
  assign clear_flag = clear;

  //passthrough layer
  assign mem_gen_bus_if.addr     = proc_gen_bus_if.addr;
  assign mem_gen_bus_if.ren      = proc_gen_bus_if.ren;
  assign mem_gen_bus_if.wen      = proc_gen_bus_if.wen;
  assign mem_gen_bus_if.wdata    = proc_gen_bus_if.wdata;
  assign mem_gen_bus_if.byte_en  = proc_gen_bus_if.byte_en; 

  assign proc_gen_bus_if.rdata   = mem_gen_bus_if.rdata;
  assign proc_gen_bus_if.busy    = mem_gen_bus_if.busy;

endmodule
