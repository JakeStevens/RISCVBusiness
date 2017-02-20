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
*   Filename:     multiply.S
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 02/17/2017
*   Description:  multiply test case
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
  eret

RVTEST_CODE_BEGIN

main:
  la x1, tdat0
  la x2, tdat1
  mul x3, x1, x2
  mulh x4, x1, x2
  mulhsu x5, x1, x2
  mulhu x6, x1, x2
  la x7, tdat1
  sw x3, 4(x7)
  sw x4, 8(x7)
  sw x5, 12(x7)
  sw x6, 16(x7)

RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0xf00ff00f
tdat1:  .word 0x00550000

RVTEST_DATA_DUMP_END



