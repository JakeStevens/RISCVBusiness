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
*   Filename:     basic_branch.S
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 07/01/2016
*   Description:  Test of basic branching behavior
*/

#include "riscv_test.h"

RVTEST_DATA_DUMP_BEGIN

RVTEST_CODE_BEGIN

main:

    ori x1, x0, -5 
    ori x2, x0, 1
    ori x3, x0, 1
    ori x4, x0, 2

    ori x5, x0, 0xBA
    slli x5, x5, 2
    ori x5, x5, 0xAD
    
    la x6, tdat0
    beq x2, x3, beq_target
    sw x5, 0(x6)

beq_target: 
    la x6, tdat1
    bne x1, x2, bne_target
    sw x5, 0(x6)

bne_target:
    la x6, tdat2
    blt x1, x4, blt_target
    sw x5, 0(x6)

blt_target:
    la x6, tdat3
    bge x2, x1, bge_target
    sw x5, 0(x6)

bge_target:
    la x6, tdat4
    bltu x2, x1, bgeu_target
    sw x5, 0(x6)

bgeu_target:
    la x7, tdat5
    bgeu x1, x4, end_target
    sw x5, 0(x6)

end_target:
    ori x0, x0, 0x00


RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0x00000001
tdat1:  .word 0x00000002
tdat2:  .word 0x00000003
tdat3:  .word 0x00000004
tdat4:  .word 0x00000005
tdat5:  .word 0x00000006

RVTEST_DATA_DUMP_END
