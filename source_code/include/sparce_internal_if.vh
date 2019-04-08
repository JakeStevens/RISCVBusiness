/*
*   Copyright 2019 Purdue University
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
*   Filename:     sparce_top_if.vh
*   
*   Created by:   Vadim V. Nikiforov 
*   Email:        vnikifor@purdue.edu
*   Date Created: 04/30/2019
*   Description:  Interface containing the modports for all the internal
*                 components of SparCE, including the SVC, SASA Table,
*                 PSRU, and SpRF
*/

`ifndef SPARCE_INTERNAL_IF_VH 
`define SPARCE_INTERNAL_IF_VH 


typedef enum logic [1:0] {
  SASA_COND_OR  = 2'b00,
  SASA_COND_AND = 2'b01
} sasa_cond_t;

interface sparce_internal_if;

  import rv32i_types_pkg::*;

  // SVC
  word_t wb_data;
  logic is_sparse;
  
  // SpRF
  logic wb_en, rs1_sparsity, rs2_sparsity;

  // SASA Table
  word_t pc, sasa_addr, sasa_data, preceding_pc;
  logic sasa_wen;
  logic [4:0] sasa_rs1, sasa_rs2, rd;
  logic [1:0] condition;
  logic [15:0] insts_to_skip;

  // PSRU
  word_t sparce_target;
  logic skipping;

  modport svc (
    output is_sparse,
    input wb_data
  );

  modport sprf (
    output rs1_sparsity, rs2_sparsity,
    input wb_en, rd, is_sparse, sasa_rs1, sasa_rs2
  );

  modport sasa_table (
    output sasa_rs1, sasa_rs2, insts_to_skip, preceding_pc, condition,
    input  pc, sasa_addr, sasa_data, sasa_wen
  );

  modport psru (
    output skipping, sparce_target,
    input insts_to_skip, preceding_pc, condition, rs1_sparsity, rs2_sparsity
  );

endinterface
`endif //SPARCE_PIPELINE_IF
