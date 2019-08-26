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
*   Filename:     basic_jump.S
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 07/01/2016
*   Description:  Test of basic jump behavior
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

    ori x1, x0, 0xba
    ori x2, x0, 0xdd

    la x3, tdat0
    jal x4, jal_target
    sw x1, 0(x3)

jal_target:
    la x5, tdat1
    auipc x6, 0x0000  
    jalr x7, x6, 12 
    sw x2, 0(x5)

jalr_target:
    la x8, tdat2
    la x9, tdat3
    sw x4, 0(x8)
    sw x7, 0(x9) 
RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0x00000001
tdat1:  .word 0x00000002
tdat2:  .word 0x00000003
tdat3:  .word 0x00000004

RVTEST_DATA_DUMP_END
