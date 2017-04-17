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

inline int invert(int input) { return (~input + 1);}

void exception_handler(int cause, int *regs, int *epc, int *badaddr) {
  // TODO: More exceptions
  if (ILLEGAL_INSN == cause) { 
    int instr, opcode, rd, rs1, rs2, funct3, funct7;
    int numerator, denominator, quotient, remainder;
    instr = *epc;
    opcode = instr & 0x0000007F;
    rd = (instr & 0x00000F80) >> 7;
    rs1 = (instr & 0x000F8000) >> 15;
    rs2 = (instr & 0x01F00000) >> 20;
    funct3 = (instr & 0x00007000) >> 12;
    funct7 = (instr & 0xFE000000) >> 25;

    if (OPCODE_REGREG == opcode) { 
      if(FUNCT7_MULDIV == funct7) {
        if      (FUNCT3_MUL == funct3) { 
          asm_mul(*(regs + rs2), *(regs + rs1), (regs +rd));
        }
        else if (FUNCT3_MULH == funct3) { 
          ; //TODO implement MULH
        }
        else if (FUNCT3_MULHSU == funct3) { 
          ; //TODO implement MULHSU
        }
        else if (FUNCT3_MULHU == funct3) { 
          ; //TODO implement MULHU
        }
        else if (FUNCT3_DIV == funct3) {
          denominator   = *(regs + rs2);
          numerator     = *(regs + rs1); 
          if (denominator == 0) {
            quotient = -1;
            remainder = numerator;
          }
          else if ((numerator == 0x80000000) && (denominator == -1)) {
            quotient = numerator;
            remainder = 0;
          }
          else {
            if (numerator < 0 && denominator < 0) {
              asm_div(invert(numerator), invert(denominator), &quotient, &remainder);
            }
            else if (numerator < 0) {
              asm_div(invert(numerator), denominator, &quotient, &remainder);
              quotient = invert(quotient);
            }
            else if (denominator < 0) {
              asm_div(numerator, invert(denominator), &quotient, &remainder);
              quotient = invert(quotient);
            }
            else {
              asm_div(numerator, denominator, &quotient, &remainder);
            }
          }
          *(regs + rd) = quotient; 
        }
        else if (FUNCT3_DIVU == funct3) {
          denominator   = *(regs + rs2);
          numerator     = *(regs + rs1); 
          if (denominator == 0) {
            quotient = -1;
            remainder = numerator;
          }
          else {
            asm_div(numerator, denominator, &quotient, &remainder);
          }
          *(regs + rd) = quotient; 
        }
        else if (FUNCT3_REM == funct3) {
          denominator   = *(regs + rs2);
          numerator     = *(regs + rs1); 
          if (denominator == 0) {
            quotient = -1;
            remainder = numerator;
          }
          else if ((numerator == 0x80000000) && (denominator == -1)) {
            quotient = numerator;
            remainder = 0;
          }
          else {
            if (numerator < 0 && denominator < 0) {
              asm_div(invert(numerator), invert(denominator), &quotient, &remainder);
              remainder = invert(remainder);
            }
            else if (numerator < 0) {
              asm_div(invert(numerator), denominator, &quotient, &remainder);
              remainder = invert(remainder);
            }
            else if (denominator < 0) {
              asm_div(numerator, invert(denominator), &quotient, &remainder);
              remainder = invert(remainder);
            }
            else {
              asm_div(numerator, denominator, &quotient, &remainder);
            }
          }
          *(regs + rd) = remainder; 
        }
        else if (FUNCT3_REMU == funct3) {
          denominator   = *(regs + rs2);
          numerator     = *(regs + rs1); 
          if (denominator == 0) {
            quotient = -1;
            remainder = numerator;
          }
          else {
            asm_div(numerator, denominator, &quotient, &remainder);
          }
          *(regs + rd) = remainder; 
        }
      }
    }
  }
}

void asm_mul(int multiplier, int multiplicand, int *product) {
  //registers a0-a2 hold the arguments
  asm volatile (
   "addi t0, a0, 0      \t\n\
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

void asm_div(int numerator, int denominator, int *quotient, int *remainder) {
  //registers a0-a3 hold the arguments
  
  //long division algorithm
  asm volatile (
     "addi t0, zero, 0  \t\n\
      addi t1, zero, 0  \t\n\
      addi t3, zero, 1  \t\n\
      slli t3, t3, 31   \t\n\
      2:                \t\n\
      slli t1, t1, 1    \t\n\
      and t2, a0, t3    \t\n\
      beq t2, zero, 3f  \t\n\
      ori t1, t1, 1     \t\n\
      3:                \t\n\
      blt t1, a1, 1f    \t\n\
      sub t1, t1, a1    \t\n\
      or t0, t0, t3     \t\n\
      1:                \t\n\
      srli t3, t3, 1    \t\n\
      bne t3, zero, 2b  \t\n\
      sw t0, 0(a2)      \t\n\
      sw t1, 0(a3)      \t\n\
  ");
}
