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
*   Filename:     rtype.S
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 07/01/2016
*   Description:  Tests rtype instructions 
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
    ori x1, x0, 0xf0
    ori x2, x0, 0x55

    #AND
    la x4, tdat0
    and x9, x1, x2
    sw x9, 0(x4)

    #OR
    la x4, tdat1
    or x9, x1, x2
    sw x9, 0(x4)

    #XOR
    la x4, tdat2
    xor x9, x1, x2
    sw x9, 0(x4)

    #ADD
    la x4, tdat3
    add x9, x1, x2
    sw x9, 0(x4)

    #SUB
    la x4, tdat4
    sub x9, x1, x2
    sw x9, 0(x4)

RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0xbad0bad0
tdat1:  .word 0xbad1bad1
tdat2:  .word 0xbad2bad2
tdat3:  .word 0xbad3bad3
tdat4:  .word 0xbad4bad4

RVTEST_DATA_DUMP_END



