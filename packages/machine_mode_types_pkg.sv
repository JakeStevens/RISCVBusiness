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
*   Filename:     machine_mode_types_pkg.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 07/05/2016
*   Description:  Types needed to implement machine mode priv. isa 
*/

`ifndef MACHINE_MODE_TYPES_PKG_SV
`define MACHINE_MODE_TYPES_PKG_SV

package machine_mode_types_pkg;

  typedef logic [11:0] csr_addr_t;

  /* Priv Levels */
  typedef enum logic [1:0] {
    U_MODE = 2'b00,
    S_MODE = 2'b01,
    H_MODE = 2'b10,
    M_MODE = 2'b11
  } prv_lvl_t;
  
  /* Machine Mode Register Types */

  /* mcpuid types */

  typedef enum logic [1:0] {
    BASE_RV32   = 2'h1,
    BASE_RV64   = 2'h2,
    BASE_RV128  = 2'h3
  } mcpuid_base_t;

  parameter MCPUID_EXT_A   = 26'h1 << 0;
  parameter MCPUID_EXT_B   = 26'h1 << 1;
  parameter MCPUID_EXT_C   = 26'h1 << 2;
  parameter MCPUID_EXT_D   = 26'h1 << 3;
  parameter MCPUID_EXT_E   = 26'h1 << 4;
  parameter MCPUID_EXT_F   = 26'h1 << 5;
  parameter MCPUID_EXT_G   = 26'h1 << 6;
  parameter MCPUID_EXT_H   = 26'h1 << 7;
  parameter MCPUID_EXT_I   = 26'h1 << 8;
  parameter MCPUID_EXT_J   = 26'h1 << 9;
  parameter MCPUID_EXT_K   = 26'h1 << 10;
  parameter MCPUID_EXT_L   = 26'h1 << 11;
  parameter MCPUID_EXT_M   = 26'h1 << 12;
  parameter MCPUID_EXT_N   = 26'h1 << 13;
  parameter MCPUID_EXT_O   = 26'h1 << 14;
  parameter MCPUID_EXT_P   = 26'h1 << 15;
  parameter MCPUID_EXT_Q   = 26'h1 << 16;
  parameter MCPUID_EXT_R   = 26'h1 << 17;
  parameter MCPUID_EXT_S   = 26'h1 << 18;
  parameter MCPUID_EXT_T   = 26'h1 << 19;
  parameter MCPUID_EXT_U   = 26'h1 << 20;
  parameter MCPUID_EXT_V   = 26'h1 << 21;
  parameter MCPUID_EXT_W   = 26'h1 << 22;
  parameter MCPUID_EXT_X   = 26'h1 << 23;
  parameter MCPUID_EXT_Y   = 26'h1 << 24;
  parameter MCPUID_EXT_Z   = 26'h1 << 25;

  typedef struct packed {
    mcpuid_base_t   base;
    logic [5:0]     wiri;
    logic [25:0]    extensions;
  } misa_t;

  /* mstatus types */

  typedef enum logic [4:0] {
    VM_MBARE  = 5'h0,
    VM_MBB    = 5'h1,
    VM_MBBID  = 5'h2,
    VM_SV32   = 5'h8,
    VM_SV39   = 5'h9,
    VM_SV48   = 5'ha,
    VM_SV57   = 5'hb,
    VM_SV64   = 5'hc
  } vm_t;

  typedef enum logic [1:0] {
    FS_OFF = 2'h0,
    FS_INITIAL = 2'h1,
    FS_CLEAN    = 2'h2,
    FS_DIRTY    = 2'h3
  } fs_t;

  typedef enum logic [1:0] {
    XS_ALL_OFF  = 2'h0,
    XS_NONE_DC  = 2'h1,
    XS_NONE_D   = 2'h2,
    XS_SOME_D   = 2'h3
  } xs_t;
  
  typedef struct packed {
    logic       sd;    
    logic [1:0] wpri_1;
    vm_t        vm; 
    logic [3:0] wpri_0;
    logic       mxr;
    logic       pum;
    logic       mprv;
    xs_t        xs;
    fs_t        fs;
    prv_lvl_t   mpp;
    prv_lvl_t   hpp;
    logic       spp;
    logic       mpie; 
    logic       hpie;
    logic       spie;
    logic       upie; 
    logic       mie; 
    logic       hie;
    logic       sie;
    logic       uie;
  } mstatus_t;

  /* mip and mie types */

  typedef struct packed {
    logic [19:0]  wiri;
    logic         meip;
    logic         heip;
    logic         seip;
    logic         ueip;
    logic         mtip;
    logic         htip;
    logic         stip; 
    logic         utip;
    logic         msip;
    logic         hsip;
    logic         ssip;
    logic         usip;
  } mip_t;

  typedef struct packed {
    logic [19:0]  wiri;
    logic         meie;
    logic         heie;
    logic         seie;
    logic         ueie;
    logic         mtie;
    logic         htie;
    logic         stie; 
    logic         utie;
    logic         msie;
    logic         hsie;
    logic         ssie;
    logic         usie;
  } mie_t;

  /* mcause register variables */

  typedef struct packed {
    logic         interrupt;
    logic [30:0]  cause;
  } mcause_t;

  // ex_code_t should be cast from an 
  // instantiation of mcause_t
  typedef enum logic [30:0] {
    INSN_MAL      = 31'h0,
    INSN_FAULT    = 31'h1,
    ILLEGAL_INSN  = 31'h2,
    BREAKPOINT    = 31'h3,
    L_ADDR_MAL    = 31'h4,
    L_FAULT       = 31'h5,
    S_ADDR_MAL    = 31'h6,
    S_FAULT       = 31'h7,
    ENV_CALL_U    = 31'h8,
    ENV_CALL_S    = 31'h9,
    ENV_CALL_H    = 31'ha, 
    ENV_CALL_M    = 31'hb
  } ex_code_t;

  typedef enum logic [30:0] {
    USER_SOFT_INT     = 31'h0,
    SUPER_SOFT_INT    = 31'h1,
    HYPER_SOFT_INT    = 31'h2,
    MACH_SOFT_INT     = 31'h3,
    USER_TIMER_INT    = 31'h4,
    SUPER_TIMER_INT   = 31'h5,
    HYPER_TIMER_INT   = 31'h6,
    MACH_TIMER_INT    = 31'h7,
    USER_EXT_INT      = 31'h8,
    SUPER_EXT_INT     = 31'h9,
    HYPER_EXT_INT     = 31'ha,
    MACH_EXT_INT      = 31'hb
  } int_code_t;

  /* Simple registers */

  typedef logic [63:0] mtime_t;
  typedef logic [63:0] mcycle_t;
  typedef logic [63:0] minstret_t;
  typedef logic [31:0] mtimecmp_t;
  typedef logic [31:0] mscratch_t;
  typedef logic [31:0] mbadaddr_t;
  typedef logic [31:0] mvendorid_t;
  typedef logic [31:0] marchid_t;
  typedef logic [31:0] mimpid_t;
  typedef logic [31:0] mhartid_t;
  typedef logic [31:0] mideleg_t;
  typedef logic [31:0] medeleg_t;
  typedef logic [31:0] mtvec_t;
  typedef logic [31:0] mepc_t;

  `define MTVEC_ADDR 32'h100

  //Non Standard Extentions 
  typedef logic [31:0] mtohost_t;
  typedef logic [31:0] mfromhost_t;
  
endpackage

`endif //MACHINE_MODE_TYPES_PKG_SV
