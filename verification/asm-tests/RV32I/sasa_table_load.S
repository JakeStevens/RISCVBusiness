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
*   Filename:     sasa_table_load.S
*
*   Created by:   Vadim V. Nikiforov 
*   Email:        vnikifor@purdue.edu
*   Date Created: 04/15/2019
*   Description:  Tests loading into the SASA table
*/

#include "riscv_test.h"

RVTEST_DATA_DUMP_BEGIN

RVTEST_INTVEC_USER_BEGIN
  nop
RVTEST_INTVEC_SUPER_BEGIN
  nop
RVTEST_INTVEC_HYPER_BEGIN
  nop
RVTEST_INTVEC_MACH_BEGIN
  nop

RVTEST_CODE_BEGIN

main:
    la x1, tdat00    # Pointer to table
    or x3, x0, x0    # Loop counter
    ori x4, x0, 16   # Loop maximum
    lw x5, sasa_addr # address for writing to the SASA table
sasa_load_loop:
    lw x2, 0(x1)     
    sw x2, 0(x5)
    addi x1, x1, 4
    addi x3, x3, 1
    bne  x3, x4, sasa_load_loop

RVTEST_CODE_END

.data
#test data goes here
tdat00:  .word 0x0f000843 # addr 0F00 (idx 0) rs1=1, rs2=1, cond=OR, skip=3
         .word 0x0d010843 # addr 0F00 (idx 1) rs1=1, rs2=1, cond=OR, skip=3
         .word 0x06020843 # addr 0F00 (idx 2) rs1=1, rs2=1, cond=OR, skip=3
         .word 0x09030843 # addr 0F00 (idx 3) rs1=1, rs2=1, cond=OR, skip=3
         .word 0x11040843 # addr 0F00 (idx 0) rs1=1, rs2=1, cond=OR, skip=3
         .word 0xa0050843 # addr 0F00 (idx 1) rs1=1, rs2=1, cond=OR, skip=3
         .word 0x09060843 # addr 0F00 (idx 2) rs1=1, rs2=1, cond=OR, skip=3
         .word 0x0a070843 # addr 0F00 (idx 3) rs1=1, rs2=1, cond=OR, skip=3
         .word 0x0b080843 # addr 0F00 (idx 0) rs1=1, rs2=1, cond=OR, skip=3
         .word 0x0c090843 # addr 0F00 (idx 1) rs1=1, rs2=1, cond=OR, skip=3
         .word 0x0d0a0843 # addr 0F00 (idx 2) rs1=1, rs2=1, cond=OR, skip=3
         .word 0x0e0b0843 # addr 0F00 (idx 3) rs1=1, rs2=1, cond=OR, skip=3
         .word 0xe20c0843 # addr 0F00 (idx 0) rs1=1, rs2=1, cond=OR, skip=3
         .word 0xe30d0843 # addr 0F00 (idx 1) rs1=1, rs2=1, cond=OR, skip=3
         .word 0xe40e0843 # addr 0F00 (idx 2) rs1=1, rs2=1, cond=OR, skip=3
         .word 0x310f0843 # addr 0F00 (idx 3) rs1=1, rs2=1, cond=OR, skip=3
sasa_addr: .word 0x00001000

RVTEST_DATA_DUMP_END



