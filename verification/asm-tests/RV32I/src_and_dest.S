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
*   Filename:     src_and_dest.S
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 07/01/2016
*   Description:  Tests instructions where the source and 
*                 and destination registers are the same
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
    #itype
    la x4, tdat0
    lui x1, 0xf5432
    ori x1, x1, 89
    sw x1, 0(x4)

    #rtype - one source
    la x4, tdat1
    lui x1, 0xf5432
    ori x2, x0, 89
    or x1, x1, x2
    sw x1, 0(x4)

    #rtype - two sources
    la x4, tdat2
    lui x1, 0xf5432
    xor x1, x1, x1
    sw x1, 0(x4)

RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0xbad0bad0
tdat1:  .word 0xbad1bad1
tdat2:  .word 0xbad2bad2

RVTEST_DATA_DUMP_END



