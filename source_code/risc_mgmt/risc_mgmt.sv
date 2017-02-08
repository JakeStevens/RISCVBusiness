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
*   Filename:     risc_mgmt.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 02/07/2017
*   Description:  Top Level Module for RISC-MGMT
*                 Provides the interface between extensions 
*                 and the standard core. 
*
*                 This version will connect extensions
*                 to a two stage pipeline.
*/

`include "risc_mgmt_macros.vh"

module risc_mgmt (
  input logic CLK, nRST
  //TODO
);
  import rv32i_types_pkg::*;
  import alu_types_pkg::*;

  parameter N_EXTENSIONS = 1;

  /* Signal Instantiations */

  // Decode Stage Signals
  logic   [N_EXTENSIONS-1:0]        d_insn_claim;
  logic   [N_EXTENSIONS-1:0]        d_bubble_req;  
  logic   [N_EXTENSIONS-1:0][4:0]   d_rsel_s_0;
  logic   [N_EXTENSIONS-1:0][4:0]   d_rsel_s_1;      
  logic   [N_EXTENSIONS-1:0][4:0]   d_rsel_d;

  //Execute Stage Signals
  logic   [N_EXTENSIONS-1:0]        e_exception;
  logic   [N_EXTENSIONS-1:0]        e_busy;
  word_t  [N_EXTENSIONS-1:0]        e_rdata_s_0;
  word_t  [N_EXTENSIONS-1:0]        e_rdata_s_1;
  logic   [N_EXTENSIONS-1:0]        e_branch_jump;
  logic   [N_EXTENSIONS-1:0]        e_br_j_addr;
  word_t  [N_EXTENSIONS-1:0]        e_reg_wdata;
  logic   [N_EXTENSIONS-1:0]        e_reg_w;
  logic   [N_EXTENSIONS-1:0]        e_alu_access;
  word_t  [N_EXTENSIONS-1:0]        e_alu_data_0; 
  word_t  [N_EXTENSIONS-1:0]        e_alu_data_1;
  word_t  [N_EXTENSIONS-1:0]        e_alu_res;
  aluop_t [N_EXTENSIONS-1:0]        e_alu_op;

  //Memory Stage Signals
  logic   [N_EXTENSIONS-1:0]        m_exception; 
  logic   [N_EXTENSIONS-1:0]        m_busy;
  word_t  [N_EXTENSIONS-1:0]        m_mem_addr; 
  logic   [N_EXTENSIONS-1:0]        m_mem_ren;
  logic   [N_EXTENSIONS-1:0]        m_mem_wen;
  logic   [N_EXTENSIONS-1:0]        m_mem_busy;
  word_t  [N_EXTENSIONS-1:0]        m_mem_load;
  word_t  [N_EXTENSIONS-1:0]        m_mem_store; 
  logic   [N_EXTENSIONS-1:0]        m_reg_wdata;
  logic   [N_EXTENSIONS-1:0]        m_reg_w;


  /******************************************************************
  *   Extension connections
  *
  *   This is where the ADD_EXTENSION macro should be used to connect
  *   extensions to RISC-MGMT
  *  
  ******************************************************************/ 
  
  `ADD_EXTENSION(template,0) 
   
  
endmodule
