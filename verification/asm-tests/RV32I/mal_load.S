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
*   Filename:     mal_load.S
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 07/01/2016
*   Description:  Creates a misaligned data transaction
*/

#include "riscv_test.h"

RVTEST_DATA_DUMP_BEGIN

RVTEST_CODE_BEGIN

main:
  # Define trap vector address
  la t0, mvec
  csrw mtvec, t0
  # Start executing
  ori x4, x0, 1
  la  x3, tdat1
  la  x5, tdat3
  lw  x2, 1(x3)
  la  x3, tdat4
  sw  x2, 0(x3)
  sw  x4, 0(x5)
  lw  x2, 1(x3)
  

RVTEST_CODE_END

mvec:
RVTEST_INTVEC_MACH_BEGIN
  ori x9, x0, 1
  la  x8, tdat2
  sw  x9, 0(x8)
  csrr x10, mepc
  addi x10,x10, 4
  csrw mepc, x10
  mret

.data
#test data goes here
tdat0:  .word 0xdeadcafe
tdat1:  .word 0xbadc0de1
tdat2:  .word 0x00000000
tdat3:  .word 0x00000000
tdat4:  .word 0x00000000
tdat5:  .word 0x00000000

RVTEST_DATA_DUMP_END



