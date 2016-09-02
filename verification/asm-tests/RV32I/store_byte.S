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
*   Filename:     store_byte.S
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 07/01/2016
*   Description:  Stores a byte to memory
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
    la x1, tdat0
    la x2, tdat1
    lw x3, 0(x1)
    sb x3, 0(x2)
    sb x3, 5(x2)
    sb x3, 11(x2)
RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0xdeadcafe
tdat1:  .word 0x00000000

RVTEST_DATA_DUMP_END



