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
*   Filename:     control_unit.sv
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 06/09/2016
*   Description:  The control unit combinationally sets all of the control
*                 signals used in the processor based on the incoming instruction. 
*/

`include "control_unit_if.vh"
`include "rv32i_reg_file_if.vh"

module control_unit 
(
  control_unit_if.control_unit  cu_if,
  rv32i_reg_file_if.cu          rf_if 
);
  import alu_types_pkg::*;
  import rv32i_types_pkg::*;
  import machine_mode_types_pkg::*;

  stype_t         instr_s;
  itype_t         instr_i;
  rtype_t         instr_r;
  sbtype_t        instr_sb;
  utype_t         instr_u;
  ujtype_t        instr_uj;

  assign instr_s = stype_t'(cu_if.instr);
  assign instr_i = itype_t'(cu_if.instr);
  assign instr_r = rtype_t'(cu_if.instr);
  assign instr_sb = sbtype_t'(cu_if.instr);
  assign instr_u = utype_t'(cu_if.instr);
  assign instr_uj = ujtype_t'(cu_if.instr);

  assign cu_if.opcode = opcode_t'(cu_if.instr[6:0]);
  assign rf_if.rs1  = cu_if.instr[19:15];
  assign rf_if.rs2  = cu_if.instr[24:20];
  assign rf_if.rd   = cu_if.instr[11:7]; 
  assign cu_if.shamt = cu_if.instr[24:20];
 
  // Assign the immediate values
  assign cu_if.imm_I  = instr_i.imm11_00;
  assign cu_if.imm_S  = {instr_s.imm11_05, instr_s.imm04_00};
  assign cu_if.imm_SB = {instr_sb.imm12, instr_sb.imm11, instr_sb.imm10_05,
                         instr_sb.imm04_01, 1'b0};
  assign cu_if.imm_UJ = {instr_uj.imm20, instr_uj.imm19_12, instr_uj.imm11,
                         instr_uj.imm10_01, 1'b0};
  assign cu_if.imm_U  = {instr_u.imm31_12, 12'b0};

  assign cu_if.imm_shamt_sel = (cu_if.opcode == IMMED &&
                            (instr_i.funct3 == SLLI || instr_i.funct3 == SRI));

  // Assign branch and load type
  assign cu_if.load_type    = load_t'(instr_i.funct3);
  assign cu_if.branch_type  = branch_t'(instr_sb.funct3);

  // Assign memory read/write enables
  assign cu_if.dwen = (cu_if.opcode == STORE);
  assign cu_if.dren = (cu_if.opcode == LOAD);

  // Assign control flow signals
  assign cu_if.branch     = (cu_if.opcode == BRANCH);
  assign cu_if.jump       = (cu_if.opcode == JAL || cu_if.opcode == JALR);
  assign cu_if.ex_pc_sel  = (cu_if.opcode == JAL || cu_if.opcode == JALR);
  assign cu_if.j_sel      = (cu_if.opcode == JAL);

  // Assign alu operands
  always_comb begin
    case(cu_if.opcode)
      REGREG, IMMED, LOAD : cu_if.alu_a_sel = 2'd0;
      STORE               : cu_if.alu_a_sel = 2'd1;
      AUIPC               : cu_if.alu_a_sel = 2'd2;
      default             : cu_if.alu_a_sel = 2'd2;
    endcase
  end

  always_comb begin
    case(cu_if.opcode)
      STORE       : cu_if.alu_b_sel = 2'd0;
      REGREG      : cu_if.alu_b_sel = 2'd1;
      IMMED, LOAD : cu_if.alu_b_sel = 2'd2;
      AUIPC       : cu_if.alu_b_sel = 2'd3;
    endcase
  end

  // Assign write select
  always_comb begin
    case(cu_if.opcode)
      LOAD                  : cu_if.w_sel   = 2'd0;
      JAL, JALR             : cu_if.w_sel   = 2'd1;
      LUI                   : cu_if.w_sel   = 2'd2;
      IMMED, AUIPC, REGREG  : cu_if.w_sel   = 2'd3;
      default               : cu_if.w_sel   = 2'd0;
    endcase
  end

  // Assign register write enable
  always_comb begin
    case(cu_if.opcode)
      STORE, BRANCH       : cu_if.wen   = 1'b0;
      IMMED, LUI, AUIPC,
      REGREG, JAL, JALR,
      LOAD                : cu_if.wen   = 1'b1;
      default:  cu_if.wen   = 1'b0;
    endcase
  end

  // Assign alu opcode
  logic sr, aluop_srl, aluop_sra, aluop_add, aluop_sub, aluop_and, aluop_or;
  logic aluop_sll, aluop_xor, aluop_slt, aluop_sltu, add_sub;


  assign sr = ((cu_if.opcode == IMMED && instr_i.funct3 == SRI) ||
                (cu_if.opcode == REGREG && instr_r.funct3 == SR));
  assign add_sub = (cu_if.opcode == REGREG && instr_r.funct3 == ADDSUB);
  
  assign aluop_sll = ((cu_if.opcode == IMMED && instr_i.funct3 == SLLI) ||
                      (cu_if.opcode == REGREG && instr_r.funct3 == SLL));
  assign aluop_sra = sr && cu_if.instr[30];
  assign aluop_srl = sr && ~cu_if.instr[30];
  assign aluop_add = ((cu_if.opcode == IMMED && instr_i.funct3 == ADDI) ||
                      (cu_if.opcode == AUIPC) ||
                      (add_sub && ~cu_if.instr[30]) ||
                      (cu_if.opcode == LOAD) ||
                      (cu_if.opcode == STORE));
  assign aluop_sub = (add_sub && cu_if.instr[30]);
  assign aluop_and = ((cu_if.opcode == IMMED && instr_i.funct3 == ANDI) ||
                      (cu_if.opcode == REGREG && instr_r.funct3 == AND));
  assign aluop_or = ((cu_if.opcode == IMMED && instr_i.funct3 == ORI) ||
                      (cu_if.opcode == REGREG && instr_r.funct3 == OR));
  assign aluop_xor = ((cu_if.opcode == IMMED && instr_i.funct3 == XORI) ||
                      (cu_if.opcode == REGREG && instr_r.funct3 == XOR));
  assign aluop_slt = ((cu_if.opcode == IMMED && instr_i.funct3 == SLTI) ||
                      (cu_if.opcode == REGREG && instr_r.funct3 == SLT));
  assign aluop_sltu = ((cu_if.opcode == IMMED && instr_i.funct3 == SLTIU) ||
                      (cu_if.opcode == REGREG && instr_r.funct3 == SLTU));

  always_comb begin
    unique if (aluop_sll)
      cu_if.alu_op = ALU_SLL;
    else if (aluop_sra)
      cu_if.alu_op = ALU_SRA;
    else if (aluop_srl)
      cu_if.alu_op = ALU_SRL;
    else if (aluop_add)
      cu_if.alu_op = ALU_ADD;
    else if (aluop_sub)
      cu_if.alu_op = ALU_SUB;
    else if (aluop_and)
      cu_if.alu_op = ALU_AND;
    else if (aluop_or)
      cu_if.alu_op = ALU_OR;
    else if (aluop_xor)
      cu_if.alu_op = ALU_XOR;
    else if (aluop_slt)
      cu_if.alu_op = ALU_SLT;
    else if (aluop_sltu)
      cu_if.alu_op = ALU_SLTU;
    else
      cu_if.alu_op = ALU_ADD;
  end

  // HALT HACK. TODO: FIX ME WHEN IMPLEMENTING INTERRUPTS
  assign cu_if.halt = (cu_if.instr == 32'h7800d073);
  // Privilege Control Signals
  assign cu_if.fault_insn = 'b0;
 
  always_comb begin
    case(cu_if.opcode)
      LUI, AUIPC, JAL, JALR,
      BRANCH, LOAD, STORE,
      IMMED, REGREG, SYSTEM   : cu_if.illegal_insn = 1'b0;
      default                 : cu_if.illegal_insn = 1'b1;
    endcase
  end
 
  always_comb begin
    cu_if.ret_insn = 1'b0;
    cu_if.prv_ret = U_MODE;
    if (cu_if.opcode == SYSTEM) begin
      if (rv32i_system_t'(instr_i.funct3) == NONCSR & instr_i[21] == 1'b1)
        cu_if.prv_ret = prv_lvl_t'(instr_i[29:28]);
    end
  end

endmodule

