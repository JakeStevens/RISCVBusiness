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
  ram_if.cpu dramif,
  output halt 
);

  // Interface declarations
  control_unit_if   cuif();
  rv32i_reg_file_if rfif(); 
  alu_if            aluif();
  jump_calc_if      jumpif();
  branch_res_if     branchif(); 
 
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

  branch_res branch_res (
    .brif(branchif)
  ); 

  word_t store_swapped;
  endian_swapper store_swap (
    .word_in(rfif.rs2_data),
    .word_out(store_swapped)
  );

  word_t dload_ext;
  dmem_extender dmem_ext (
    .dmem_in(dramif.rdata),
    .load_type(cuif.load_type),
    .byte_en(cuif.byte_en),
    .ext_out(dload_ext)
  );
 
  assign cuif.instr = fetch_exif.fetch_ex_reg.instr;

  /*******************************************************
  *** Sign Extensions 
  *******************************************************/
  word_t imm_I_ext, imm_S_ext, imm_UJ_ext;
  assign imm_I_ext  = {{20{cuif.imm_I[11]}}, cuif.imm_I};
  assign imm_UJ_ext = {{20{cuif.imm_UJ[11]}}, cuif.imm_UJ};
  assign imm_S_ext  = {{20{cuif.imm_S[11]}}, cuif.imm_S};

  /*******************************************************
  *** Jump Target Calculator and Associated Logic 
  *******************************************************/
  word_t jump_addr;
  always_comb begin
    if (cuif.j_sel) begin
      jumpif.base = fetch_exif.fetch_ex_reg.pc;
      jumpif.offset = imm_UJ_ext;
      jump_addr = jumpif.jal_addr;
    end else begin
      jumpif.base = rfif.rs1_data;
      jumpif.offset = imm_I_ext;
      jump_addr = jumpif.jalr_addr;
    end
  end 

  /*******************************************************
  *** ALU and Associated Logic 
  *******************************************************/
  word_t imm_or_shamt;
  assign imm_or_shamt = (cuif.imm_shamt_sel == 1'b1) ? cuif.shamt : imm_I_ext;
  assign aluif.aluop = cuif.alu_op;
 
  always_comb begin
    case (cuif.alu_a_sel)
      2'd0: aluif.port_a = rfif.rs1_data;
      2'd1: aluif.port_a = imm_S_ext;
      2'd2: aluif.port_a = fetch_exif.fetch_ex_reg.pc;
      2'd3: aluif.port_a = '0; //Not Used 
    endcase
  end

  always_comb begin
    case(cuif.alu_b_sel)
      2'd0: aluif.port_b = rfif.rs1_data;
      2'd1: aluif.port_b = rfif.rs2_data;
      2'd2: aluif.port_b = imm_or_shamt;
      2'd3: aluif.port_b = cuif.imm_U;
    endcase
  end

  always_comb begin
    case(cuif.w_sel)
      2'd0: rfif.w_data = dload_ext;
      2'd1: rfif.w_data = fetch_exif.fetch_ex_reg.pc4;
      2'd2: rfif.w_data = cuif.imm_U;
      2'd3: rfif.w_data = aluif.port_out;
    endcase
  end

  assign rfif.wen = cuif.wen & (~hazardif.if_ex_stall | hazard_if.npc_sel); 
  /*******************************************************
  *** Branch Target Resolution and Associated Logic 
  *******************************************************/
  word_t resolved_addr;
  assign branchif.rs1_data    = rfif.rs1_data;
  assign branchif.rs2_data    = rfif.rs2_data;
  assign branchif.pc          = fetch_exif.fetch_ex_reg.pc;
  assign branchif.imm_sb      = cuif.imm_SB;
  assign branchif.branch_type = cuif.branch_type;

  assign resolved_addr = branchif.branch_taken ?
                          branchif.branch_addr : fetch_exif.fetch_ex_reg.pc4;
  
  assign fetch_exif.brj_addr = (cuif.ex_pc_sel == 1'b1) ?
                                jump_addr : resolved_addr;
  
  assign hazardif.mispredict =  fetch_exif.fetch_ex_reg.prediction ^
                                branchif.branch_taken;
  
  /*******************************************************
  *** Data Ram Interface Logic 
  *******************************************************/
  assign dramif.ren           = cuif.dren;
  assign dramif.wen           = cuif.dwen;
  assign dramif.byte_en       = cuif.dren ? cuif.byte_en:
                                {cuif.byte_en[0], cuif.byte_en[1], cuif.byte_en[2], cuif.byte_en[3]};
  assign dramif.addr          = aluif.port_out;
  assign hazardif.d_ram_busy  = dramif.busy;
  assign cuif.byte_offset     = aluif.port_out[1:0]; 
  
  always_comb begin
    // load_type can be used for store_type as well
    case(cuif.load_type)
      LB: dramif.wdata = {4{store_swapped[31:24]}};
      LH: dramif.wdata = {2{store_swapped[31:16]}};
      LW: dramif.wdata = store_swapped; 
    endcase
  end

  /*******************************************************
  *** Hazard Unit Interface Logic 
  *******************************************************/
  assign hazardif.dren    = cuif.dren;
  assign hazardif.dwen    = cuif.dwen;
  assign hazardif.jump    = cuif.jump;
  assign hazardif.branch  = cuif.branch;
  assign hazardif.halt    = halt;
  
  assign halt = cuif.halt;
endmodule

