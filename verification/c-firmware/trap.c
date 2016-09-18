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
#include "c_self_test.h"

void irq_handler(int cause) {
  /* TODO: Interrupt Handling Code */
}

void exception_handler(int cause, int *regs, int *epc, int *badaddr) {
  // TODO: More exceptions
  // TODO: header for constants like cause
  if (2 == cause) {
    int instr, opcode, rd, rs1, rs2, funct3, funct7;
    int multiplier, multiplicand, product;
    instr = *epc;
    opcode = instr & 0x0000007F;
    rd = (instr & 0x00000F80) >> 7;
    rs1 = (instr & 0x000F8000) >> 15;
    rs2 = (instr & 0x01F00000) >> 20;
    funct3 = (instr & 0x00007000) >> 12;
    funct7 = (instr & 0xFE000000) >> 25;
    if (0x33 == opcode) //REGREG
      if(0x1 == funct7) //M/D instruction
        if (0 == funct3) { //MUL
          // rs2 = multiplier
          // rs1 = multiplicand
          multiplier = *(regs + rs2);
          multiplicand = *(regs + rs1);
          product = 0;
          while(multiplier > 0) {
            product += multiplicand;
            multiplier--;
          }
          *(regs + rd) = product;
        }
        else if (0x1 == funct3) { //MULH
          ; //TODO implement MULH
        }
        else if (0x2 == funct3) { //MULHSU
          ; //TODO implement MULHSU
        }
        else if (0x3 == funct3) { //MULHU
          ; //TODO implement MULHU
        }
  }
}
