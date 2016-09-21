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
*   Filename:     trap.c
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 09/16/2016
*   Description:  C source for interrupt and exception handling code
*/

#include "trap.h"

void irq_handler(int cause) {
  /* TODO: Interrupt Handling Code */
}

void exception_handler(int cause, int *regs, int *epc, int *badaddr) {
  // TODO: More exceptions
  if (ILLEGAL_INSN == cause) { 
    int instr, opcode, rd, rs1, rs2, funct3, funct7;
    int multiplier, multiplicand, product;
    instr = *epc;
    opcode = instr & 0x0000007F;
    rd = (instr & 0x00000F80) >> 7;
    rs1 = (instr & 0x000F8000) >> 15;
    rs2 = (instr & 0x01F00000) >> 20;
    funct3 = (instr & 0x00007000) >> 12;
    funct7 = (instr & 0xFE000000) >> 25;

    if (OPCODE_REGREG == opcode) //REGREG
      if(FUNCT7_MULDIV == funct7) //M/D instruction
        if (FUNCT3_MUL == funct3) { //MUL
          // rs2 = multiplier
          // rs1 = multiplicand
          /*multiplier = *(regs + rs2);
          multiplicand = *(regs + rs1);
          product = 0;
          while(multiplier > 0) {
            product += multiplicand;
            multiplier--;
          }
          *(regs + rd) = product;*/

          asm_mul(*(regs + rs2), *(regs + rs1), (regs +rd));
        }
        else if (FUNCT3_MULH == funct3) { //MULH
          ; //TODO implement MULH
        }
        else if (FUNCT3_MULHSU == funct3) { //MULHSU
          ; //TODO implement MULHSU
        }
        else if (FUNCT3_MULHU == funct3) { //MULHU
          ; //TODO implement MULHU
        }
        else if (FUNCT3_DIV == funct3) {
          ; //TODO implement DIV
        }
        else if (FUNCT3_DIVU == funct3) {
          ; //TODO implement DIVU
        }
        else if (FUNCT3_REM == funct3) {
          ; //TODO implement REM
        }
        else if (FUNCT3_REMU == funct3) {
          ; //TODO implement REMU
        }
  }
}

void asm_mul(int multiplier, int multiplicand, int *product) {
  asm volatile (
    "addi t0, a0, 0     \t\n\
    addi a0, zero, 0    \t\n\
    2:                  \t\n\
    andi t1, a1, 0x1    \t\n\
    beq t1, zero, 1f    \t\n\
    add a0, t0, a0      \t\n\
    1:                  \t\n\
    slli t0, t0, 1      \t\n\
    srli a1, a1, 1      \t\n\
    bne  a1, zero, 2b   \t\n\
    sw   a0, 0(a2)      \t\n\
  ");
}
