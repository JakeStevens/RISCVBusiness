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
*   Filename:     csr_prv_if.vh
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 07/27/2016
*   Description:  Interface between the csr regfile and the prv logic 
*/

`ifndef CSR_PRV_IF_VH
`define CSR_PRV_IF_VH

interface csr_prv_if;
  import machine_mode_types_pkg::*;
  import rv32i_types_pkg::*;

  logic mip_rup;
  logic mbadaddr_rup;
  logic mcause_rup;
  logic mepc_rup;
  logic mstatus_rup;
  logic timer_int;

  mip_t       mip, mip_next;
  mbadaddr_t  mbadaddr_next;
  mcause_t    mcause, mcause_next;
  mepc_t      mepc, mepc_next;
  mstatus_t   mstatus, mstatus_next;

  mtvec_t     mtvec;
  mie_t       mie;

  modport csr (
    input mip_rup, mbadaddr_rup, mcause_rup, mepc_rup, mstatus_rup,
      mip_next, mbadaddr_next, mcause_next, mepc_next, mstatus_next, 
    output mtvec, mepc, mie, timer_int, mip, mcause
  );

  modport prv (
    output mip_rup, mbadaddr_rup, mcause_rup, mepc_rup, mstatus_rup,
      mip_next, mcause_next, mepc_next, mstatus_next, 
    input mepc, mie, mip, mcause, mstatus
  );

endinterface

`endif //CSR_PRV_IF_VH
