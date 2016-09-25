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
*   Filename:     trap.h
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 09/21/2016
*   Description:  C header for interrupt and exception handling code
*/

#ifndef TRAP_H
#define TRAP_H

#define ILLEGAL_INSN    2
#define OPCODE_REGREG   0x33
#define FUNCT7_MULDIV   0x1
#define FUNCT3_MUL      0x0
#define FUNCT3_MULH     0x1
#define FUNCT3_MULHSU   0x2
#define FUNCT3_MULHU    0x3
#define FUNCT3_DIV      0x4
#define FUNCT3_DIVU     0x5
#define FUNCT3_REM      0x6
#define FUNCT3_REMU     0x7

void asm_mul(int multiplier, int multiplicand, int *product);
void asm_div(int numerator, int denominator, int *quotient, int *remainder);
int invert(int);

#endif //TRAP_H
