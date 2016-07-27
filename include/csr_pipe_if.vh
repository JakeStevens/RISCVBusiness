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
*   Filename:     csr_pipe_if.vh
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 07/27/2016
*   Description:  Interface between the csr register file and pipeline 
*/

`ifndef CSR_PIPE_IF_VH
`define CSR_PIPE_IF_VH

interface csr_pipe_if;
  import machine_mode_types_pkg::*;
  import rv32i_types_pkg::*;
  
  logic       swap, clr, set;
  logic       invalid_csr;
  csr_addr_t  addr;
  word_t      rdata, wdata;

  modport csr (
    input  swap, clr, set, wdata, addr,
    output rdata, invalid_csr
  );

  modport csr (
    output swap, clr, set, wdata, addr,
    input  rdata, invalid_csr
  );

endinterface

`endif //CSR_PIPE_IF_VH
