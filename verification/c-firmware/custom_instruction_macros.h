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
*   Filename:     custom_instruction_macros.h
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 03/27/2017
*   Description:  This file contains macros that can be used to call custom 
*                 instructions. 
*/

#ifndef CUSTOM_INSTRUCTION_MACROS_H
#define CUSTOM_INSTRUCTION_MACROS_H


/* Macros for generating the function call for new insns */

// Register to Register Type instruction

#define INSN_INSERT_R_TYPE(OPCODE,FUNCT7,FUNCT3,RS0,RS1,RSD) \
  INSN_INSERT(OPCODE, FUNCT7, RS1, RS0, FUNCT3, RSD)

#define GENERATE_CUSTOM_INSTRUCTION_R_TYPE(INSN_NAME,OPCODE,OFFSET,FUNCT7,FUNCT3) \
void INSN_NAME ## _ ## OFFSET ##  _AUTOGEN(int arga, int argb, int *result) {     \
  asm volatile (                                                                  \
    "addi t0, a0, 0 \t\n                                                          \
     addi t1, a1, 0 \t\n                                                          \
  ");                                                                             \
  INSN_INSERT_R_TYPE(OPCODE, FUNCT7, FUNCT3, REG_T1, REG_T0, REG_T2)              \
  asm volatile ( "sw t2, 0(a2)");                                                 \
}



/* Macros for calling insn function calls */

// Register to Register Type instruction

#define CALL_CUSTOM_INSTRUCTION_R_TYPE(INSN_NAME, OFFSET, OPA, OPB, RESULT) \
  CALL_CUSTOM_INSTRUCTION_R_TYPE2(INSN_NAME, OFFSET, OPA, OPB, RESULT)

#define CALL_CUSTOM_INSTRUCTION_R_TYPE2(INSN_NAME, OFFSET, OPA, OPB, RESULT) \
  INSN_NAME ## _ ## OFFSET ## _AUTOGEN(OPA, OPB, &RESULT);

/* Helper Macros and Defines */

#define INSN_INSERT(OPCODE, args...) \
  asm volatile (".word 0b"CI_TO_STR(BUILD_INSN(OPCODE, args)));

#define CI_TO_STR(s) CI_TO_STR2(s)
#define CI_TO_STR2(s) #s

#define CI_CONC(a,b) CI_CONC2(a,b)
#define CI_CONC2(a,b) a ## b

#define FE_1(WHAT, X) WHAT(X)
#define FE_2(WHAT, X, ...)  CI_CONC(WHAT(X),FE_1(WHAT, __VA_ARGS__))
#define FE_3(WHAT, X, ...)  CI_CONC(WHAT(X),FE_2(WHAT, __VA_ARGS__))
#define FE_4(WHAT, X, ...)  CI_CONC(WHAT(X),FE_3(WHAT, __VA_ARGS__))
#define FE_5(WHAT, X, ...)  CI_CONC(WHAT(X),FE_4(WHAT, __VA_ARGS__))
#define FE_6(WHAT, X, ...)  CI_CONC(WHAT(X),FE_5(WHAT, __VA_ARGS__))
#define FE_7(WHAT, X, ...)  CI_CONC(WHAT(X),FE_6(WHAT, __VA_ARGS__))
#define FE_8(WHAT, X, ...)  CI_CONC(WHAT(X),FE_7(WHAT, __VA_ARGS__))
#define FE_9(WHAT, X, ...)  CI_CONC(WHAT(X),FE_8(WHAT, __VA_ARGS__))
#define FE_10(WHAT, X, ...) CI_CONC(WHAT(X),FE_9(WHAT, __VA_ARGS__))

#define GET_MACRO(_1,_2,_3,_4,_5,_6,_7,_8,_9,_10,NAME,...) NAME

#define FOR_EACH(action,...) \
  GET_MACRO(__VA_ARGS__,FE_10,FE_9,FE_8,FE_7,FE_6,FE_5,FE_4,FE_3,FE_2,FE_1)(action,__VA_ARGS__)

#define QUALIFIER(X) X

#define BUILD_INSN(OPCODE,...) CI_CONC(FOR_EACH(QUALIFIER,__VA_ARGS__),OPCODE)

#define REG0      00000
#define REG1      00001
#define REG2      00010
#define REG3      00011
#define REG4      00100
#define REG5      00101
#define REG6      00110
#define REG7      00111
#define REG8      01000
#define REG9      01001
#define REG10     01010
#define REG11     01011
#define REG12     01100
#define REG13     01101
#define REG14     01110
#define REG15     01111
#define REG16     10000
#define REG17     10001
#define REG18     10010
#define REG19     10011
#define REG20     10100
#define REG21     10101
#define REG22     10110
#define REG23     10111
#define REG24     11000
#define REG25     11001
#define REG26     11010
#define REG27     11011
#define REG28     11100
#define REG29     11101
#define REG30     11110
#define REG31     11111

#define REG_ZERO  REG0  
#define REG_RA    REG1 
#define REG_SP    REG2 
#define REG_GP    REG3 
#define REG_TP    REG4 
#define REG_T0    REG5 
#define REG_T1    REG6 
#define REG_T2    REG7 
#define REG_S0    REG8 
#define REG_S1    REG9 
#define REG_A0    REG10
#define REG_A1    REG11
#define REG_A2    REG12
#define REG_A3    REG13
#define REG_A4    REG14
#define REG_A5    REG15
#define REG_A6    REG16
#define REG_A7    REG17
#define REG_S2    REG18
#define REG_S3    REG19
#define REG_S4    REG20
#define REG_S5    REG21
#define REG_S6    REG22
#define REG_S7    REG23
#define REG_S8    REG24
#define REG_S9    REG25
#define REG_S10   REG26
#define REG_S11   REG27
#define REG_T3    REG28
#define REG_T4    REG29
#define REG_T5    REG30
#define REG_T6    REG31


#endif //CUSTOM_INSTRUCTION_MACROS_H
