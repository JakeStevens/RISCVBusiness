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
*   Filename:     execute_stage.sv
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 06/16/2016
*   Description:  Execute Stage for the Two Stage Pipeline 
*/

`include "fetch_execute_if.vh"
`include "hazard_unit_if.vh"
`include "predictor_pipeline_if.vh"
`include "control_unit_if.vh"
`include "rv32i_reg_file_if.vh"
`include "ram_if.vh"
`include "alu_if.vh"

module execute_stage(
  input logic CLK, nRST,
  fetch_execute_if.execute fetch_exif,
  hazard_unit_if.execute hazardif,
  predictor_pipeline_if.update predictif,
  ram_if.cpu dramif 
);

  // Interface declarations
  control_unit_if   cuif();
  rv32i_reg_file_if rfif(); 
  alu_if            aluif();
  jump_calc_if      jumpif();
 
  // Module instantiations
  control_unit cu (
    .cu_if(cuif),
    .rfif(rfif)
  );

  rv32i_reg_file rf (
    .CLK(CLK),
    .nRST(nRST),
    .rfif(rfif)
  );

  alu alu (
    .aluif(aluif)
  );

  jump_calc jump_calc (
    .jumpif(jumpif)
  );  
 
  assign cuif.instr = fetch_exif.instr;

  /*******************************************************
  *** Sign Extensions 
  *******************************************************/
  word_t imm_I_ext, imm_S_ext, imm_UJ_ext;
  assign imm_I_ext  = {{20{cuif.imm_I[11]}}, cuif.imm_I};
  assign imm_UJ_ext = {{20{cuif.imm_UJ[11]}}, cuif.imm_UJ};
  assign imm_S_ext  = {{20{cuif.imm_UJ[11]}}, cuif.imm_S};

  /*******************************************************
  *** ALU and Associated Logic 
  *******************************************************/
  word_t imm_or_shamt;
  assign imm_or_shamt = (cuif.imm_shamt_sel == 1'b1) ? imm_I_ext : cuif.shamt;
  assign aluif.aluop = cuif.alu_op;
 
  always_comb begin
    case (cuif.alu_a_sel)
      2'd0: aluif.port_a = rfif.rs1_data;
      2'd1: aluif.port_a = imm_or_shamt;
      2'd2: aluif.port_a = fetch_exif.pc;
      2'd3: aluif.port_a = 32'hBAAD_C0DE; //Should never reach here
    endcase
  end

  always_comb begin
    case(cuif.alu_b_sel)
      2'd0: aluif.port_b = rfif.rs1_data;
      2'd1: aluif.port_b = rfif.rs2_data;
      2'd2: aluif.port_b = imm_S_ext;
      2'd3: aluif.port_b = cuif.imm_U;
    endcase
  end

  always_comb begin
    case(cuif.w_sel)
      //2'd0: rfif.w_data = TODO: dload_ext
      2'd1: rfif.w_data = fetch_exif.npc;
      2'd2: rfif.w_data = cuif.imm_U;
      2'd3: rfif.w_data = aluif.port_out;
    endcase
  end
  
  /*******************************************************
  *** Jump Target Calculator and Associated Logic 
  *******************************************************/
  word_t jump_addr;
  always_comb begin
    if (cuif.j_sel) begin
      jumpif.base = fetch_exif.pc;
      jumpif.offset = imm_UJ_ext;
      jump_addr = jumpif.jal_addr;
    end else begin
      jumpif.base = rfif.rs1_data;
      jumpif.offset = imm_I_ext;
      jump_addr = jumpif.jalr_addr;
    end
  end 

endmodule

