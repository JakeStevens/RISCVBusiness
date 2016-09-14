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
#include "test_macros.h"


RVTEST_RV32U


RVTEST_CODE_BEGIN


main:
  addi x6, x0, 0xFF
  addi x7, x0, 0xFF
  # Read the timer CSR
  csrr x1, mtime
  nop
  nop
  nop
  nop
  nop
  csrr x2, mtime
  sub x2, x2, x1
  # 5 nops * 2 cycles/nop = 10
  ori x1, x0, 10
  beq x2, x1, more_tests
  RVTEST_FAIL

more_tests:
  addi x3, x0, 0x1
  csrw mstatus, x3
  csrr x2, mtime
  addi x2, x2, 20 
  csrw mtimecmp, x2
  ori x3, x0, 0x80
  csrw mie, x3
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  bne x6, x7, pass
  RVTEST_FAIL 
pass:
  RVTEST_PASS

.align 2
mtvec_handler:
  # Write to mtimecmp using the zero register
  # Check that nothing happened to interrupt
  # Actually write to mtimecmp
  # Check that the interrupt cleared
  # Change sigil to show interrupt was entered
  ori x6, x0, 0x0F
  # Return
  eret

RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
  
