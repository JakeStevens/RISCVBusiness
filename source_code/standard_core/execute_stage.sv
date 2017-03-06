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
`include "component_selection_defines.vh"
`include "rv32i_reg_file_if.vh"
`include "generic_bus_if.vh"
`include "alu_if.vh"
`include "prv_pipeline_if.vh"
`include "risc_mgmt_if.vh"

module execute_stage(
  input logic CLK, nRST,
  fetch_execute_if.execute fetch_ex_if,
  hazard_unit_if.execute hazard_if,
  predictor_pipeline_if.update predict_if,
  generic_bus_if.cpu dgen_bus_if,
  prv_pipeline_if.pipe  prv_pipe_if,
  output halt,
  risc_mgmt_if.ts_execute rm_if
);

  import rv32i_types_pkg::*;

  // Interface declarations
  control_unit_if   cu_if();
  rv32i_reg_file_if rf_if(); 
  alu_if            alu_if();
  jump_calc_if      jump_if();
  branch_res_if     branch_if(); 
 
  // Module instantiations
  control_unit cu (.*);
  rv32i_reg_file rf (.*);
  alu alu (.*);
  jump_calc jump_calc (.*);
  
  branch_res branch_res (
    .br_if(branch_if)
  ); 

  word_t store_swapped;
  endian_swapper store_swap (
    .word_in(rf_if.rs2_data),
    .word_out(store_swapped)
  );

  word_t dload_ext;
  logic [3:0] byte_en, byte_en_temp;
  dmem_extender dmem_ext (
    .dmem_in(dgen_bus_if.rdata),
    .load_type(cu_if.load_type),
    .byte_en(byte_en),
    .ext_out(dload_ext)
  );


  /*******************************************************
  * MISC RISC-MGMT Logic
  *******************************************************/

  assign rm_if.rdata_s_0 = rf_if.rs1_data;
  assign rm_if.rdata_s_1 = rf_if.rs2_data;


  /*******************************************************
  *** Choose the Endianness Coming into the processor
  *******************************************************/
  generate
    if (BUS_ENDIANNESS == "big")
    begin
      assign byte_en = byte_en_temp;
    end else if (BUS_ENDIANNESS == "little")
    begin
      assign byte_en = cu_if.dren ? byte_en_temp :
              {byte_en_temp[0], byte_en_temp[1],
              byte_en_temp[2], byte_en_temp[3]};
    end
  endgenerate

  assign cu_if.instr = fetch_ex_if.fetch_ex_reg.instr;
  assign rm_if.insn  = fetch_ex_if.fetch_ex_reg.instr;

  /*******************************************************
  *** Sign Extensions 
  *******************************************************/
  word_t imm_I_ext, imm_S_ext, imm_UJ_ext;
  assign imm_I_ext  = {{20{cu_if.imm_I[11]}}, cu_if.imm_I};
  assign imm_UJ_ext = {{20{cu_if.imm_UJ[11]}}, cu_if.imm_UJ};
  assign imm_S_ext  = {{20{cu_if.imm_S[11]}}, cu_if.imm_S};

  /*******************************************************
  *** Jump Target Calculator and Associated Logic 
  *******************************************************/
  word_t jump_addr;
  always_comb begin
    if (cu_if.j_sel) begin
      jump_if.base = fetch_ex_if.fetch_ex_reg.pc;
      jump_if.offset = imm_UJ_ext;
      jump_addr = jump_if.jal_addr;
    end else begin
      jump_if.base = rf_if.rs1_data;
      jump_if.offset = imm_I_ext;
      jump_addr = jump_if.jalr_addr;
    end
  end 

  /*******************************************************
  *** ALU and Associated Logic 
  *******************************************************/
  word_t imm_or_shamt;
  assign imm_or_shamt = (cu_if.imm_shamt_sel == 1'b1) ? cu_if.shamt : imm_I_ext;
  assign alu_if.aluop = cu_if.alu_op;
  logic mal_addr;
 
  always_comb begin
    case (cu_if.alu_a_sel)
      2'd0: alu_if.port_a = rf_if.rs1_data;
      2'd1: alu_if.port_a = imm_S_ext;
      2'd2: alu_if.port_a = fetch_ex_if.fetch_ex_reg.pc;
      2'd3: alu_if.port_a = '0; //Not Used 
    endcase
  end

  always_comb begin
    case(cu_if.alu_b_sel)
      2'd0: alu_if.port_b = rf_if.rs1_data;
      2'd1: alu_if.port_b = rf_if.rs2_data;
      2'd2: alu_if.port_b = imm_or_shamt;
      2'd3: alu_if.port_b = cu_if.imm_U;
    endcase
  end

  always_comb begin
    if(rm_if.req_reg_w) begin
      rf_if.w_data = rm_if.reg_wdata;
    end else begin
      case(cu_if.w_sel)
        3'd0    : rf_if.w_data = dload_ext;
        3'd1    : rf_if.w_data = fetch_ex_if.fetch_ex_reg.pc4;
        3'd2    : rf_if.w_data = cu_if.imm_U;
        3'd3    : rf_if.w_data = alu_if.port_out;
        3'd4    : rf_if.w_data = prv_pipe_if.rdata;
        default : rf_if.w_data = '0; 
      endcase
    end
  end

  assign rf_if.wen = (cu_if.wen | (rm_if.req_reg_w & rm_if.reg_w)) & (~hazard_if.if_ex_stall | hazard_if.npc_sel) & 
                    ~(cu_if.dren & mal_addr); 
  /*******************************************************
  *** Branch Target Resolution and Associated Logic 
  *******************************************************/

  //TODO: RISC-MGMT tie in to branch/jump logic

  word_t resolved_addr;
  assign branch_if.rs1_data    = rf_if.rs1_data;
  assign branch_if.rs2_data    = rf_if.rs2_data;
  assign branch_if.pc          = fetch_ex_if.fetch_ex_reg.pc;
  assign branch_if.imm_sb      = cu_if.imm_SB;
  assign branch_if.branch_type = cu_if.branch_type;

  assign resolved_addr = branch_if.branch_taken ?
                          branch_if.branch_addr : fetch_ex_if.fetch_ex_reg.pc4;
  
  assign fetch_ex_if.brj_addr = (cu_if.ex_pc_sel == 1'b1) ?
                                jump_addr : resolved_addr;
  
  assign hazard_if.mispredict =  fetch_ex_if.fetch_ex_reg.prediction ^
                                branch_if.branch_taken;
  
  /*******************************************************
  *** Data Ram Interface Logic 
  *******************************************************/

  //TODO: RISC-MGMT memory tie in

  logic [1:0] byte_offset;

  assign dgen_bus_if.ren           = cu_if.dren & ~mal_addr;
  assign dgen_bus_if.wen           = cu_if.dwen & ~mal_addr;
  assign dgen_bus_if.byte_en       = byte_en;
  assign dgen_bus_if.addr          = alu_if.port_out;
  assign hazard_if.d_mem_busy  = dgen_bus_if.busy;
  assign byte_offset          = alu_if.port_out[1:0]; 
  
  always_comb begin
    // load_type can be used for store_type as well
    dgen_bus_if.wdata = '0;
    case(cu_if.load_type)
      LB: dgen_bus_if.wdata = {4{rf_if.rs2_data[7:0]}};
      LH: dgen_bus_if.wdata = {2{rf_if.rs2_data[15:0]}};
      LW: dgen_bus_if.wdata = rf_if.rs2_data; 
    endcase
  end


  // Assign byte_en based on load type 
  // funct3 for loads and stores are the same bit positions
  // byte_en is valid for both loads and stores 
  always_comb begin
    unique case(cu_if.load_type)
      LB : begin
        unique case(byte_offset)
          2'b00   : byte_en_temp = 4'b0001;
          2'b01   : byte_en_temp = 4'b0010;
          2'b10   : byte_en_temp = 4'b0100;
          2'b11   : byte_en_temp = 4'b1000;
          default : byte_en_temp = 4'b0000;
        endcase
      end
      LBU : begin
        unique case(byte_offset)
          2'b00   : byte_en_temp = 4'b0001;
          2'b01   : byte_en_temp = 4'b0010;
          2'b10   : byte_en_temp = 4'b0100;
          2'b11   : byte_en_temp = 4'b1000;
          default : byte_en_temp = 4'b0000;
        endcase
      end
      LH : begin
        unique case(byte_offset)
          2'b00   : byte_en_temp = 4'b0011;
          2'b10   : byte_en_temp = 4'b1100;
          default : byte_en_temp = 4'b0000;
        endcase
      end
      LHU : begin
        unique case(byte_offset)
          2'b00   : byte_en_temp = 4'b0011;
          2'b10   : byte_en_temp = 4'b1100;
          default : byte_en_temp = 4'b0000;
        endcase
      end
      LW:           byte_en_temp = 4'b1111;
      default :     byte_en_temp = 4'b0000;
    endcase
  end

  /*******************************************************
  *** Hazard Unit Interface Logic 
  *******************************************************/
  assign hazard_if.dren    = cu_if.dren;
  assign hazard_if.dwen    = cu_if.dwen;
  assign hazard_if.jump    = cu_if.jump;
  assign hazard_if.branch  = cu_if.branch;
  assign hazard_if.halt    = halt;
  
  assign halt = cu_if.halt;

  /*******************************************************
  *** CSR / Priv Interface Logic 
  *******************************************************/ 
  assign prv_pipe_if.swap  = cu_if.csr_swap  & cu_if.csr_rw_valid & ~hazard_if.if_ex_stall;
  assign prv_pipe_if.clr   = cu_if.csr_clr   & cu_if.csr_rw_valid & ~hazard_if.if_ex_stall;
  assign prv_pipe_if.set   = cu_if.csr_set   & cu_if.csr_rw_valid & ~hazard_if.if_ex_stall;
  assign prv_pipe_if.wdata = cu_if.csr_imm ? {27'h0, cu_if.zimm} : rf_if.rs1_data;
  assign prv_pipe_if.addr  = cu_if.csr_addr;
  assign prv_pipe_if.valid_write = (prv_pipe_if.swap | prv_pipe_if.clr |
                                    prv_pipe_if.set) & cu_if.not_zero;
  assign prv_pipe_if.instr = (cu_if.instr != '0);

  always_comb begin
    if(byte_en == 4'hf) 
      mal_addr = (dgen_bus_if.addr[1:0] != 2'b00);
    else if (byte_en == 4'h3 || byte_en == 4'hc) begin
      mal_addr = (dgen_bus_if.addr[1:0] == 2'b01 || dgen_bus_if.addr[1:0] == 2'b11);
    end
    else 
      mal_addr = 1'b0;
  end

  //Send exceptions to Hazard Unit
  assign hazard_if.illegal_insn = (cu_if.illegal_insn & ~rm_if.ex_token) | prv_pipe_if.invalid_csr;
  assign hazard_if.fault_l      = 1'b0; 
  assign hazard_if.mal_l        = cu_if.dren & mal_addr;
  assign hazard_if.fault_s      = 1'b0;
  assign hazard_if.mal_s        = cu_if.dwen & mal_addr;
  assign hazard_if.breakpoint   = cu_if.breakpoint;
  assign hazard_if.env_m        = cu_if.ecall_insn;
  assign hazard_if.ret          = cu_if.ret_insn;
  assign hazard_if.badaddr_e    = dgen_bus_if.addr;

  assign hazard_if.epc_e = fetch_ex_if.fetch_ex_reg.pc;
  assign hazard_if.token_ex = fetch_ex_if.fetch_ex_reg.token;

  /*********************************************************
  *** Branch Predictor Logic
  *********************************************************/
  assign predict_if.update_predictor = cu_if.branch;
  assign predict_if.prediction = fetch_ex_if.fetch_ex_reg.prediction;
  assign predict_if.branch_result = branch_if.branch_taken;
  //predict_if.update_addr = ;
endmodule

