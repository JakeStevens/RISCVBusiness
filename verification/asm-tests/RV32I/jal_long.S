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
*   Filename:     jal_long.S
*
*   Created by:   Eric Colter
*   Email:        coltere@purdue.edu
*   Date Created: 04/20/2017
*   Description:  Try to jump to a faraway offset that requires more than 12 bits of offset.
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
    nop
    jal jal_target

    // insert a lot of empty bytes
    .space 20000

    // if it failed to jump far enough, it will overwrite tdat0 
    la x6, tdat0
    sw zero, 0(x6)

jal_target:
    la x6, tdat1
    sw zero, 0(x6)


RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0x00000001
tdat1:  .word 0x00000002

RVTEST_DATA_DUMP_END



