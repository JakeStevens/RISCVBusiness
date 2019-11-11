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
*   Filename:     csr_accesses.S
*
*   Created by:   Jacob R. Steves
*   Email:        steven69@purdue.edu
*   Date Created: 09/08/2016
*   Description:  Test various CSR accesses 
*/

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

#test asm code goes here
  csrrw x0, mscratch, x0
  ori x1, x0, 0xF0
  ori x2, x0, 0x0F
  ori x3, x0, 0x1
  ori x4, x0, 0xFF
  csrrs x3, mscratch, x1
  # F0 SHOULD NOW BE IN mscratch
  # x3 should have gotten the original value of 0x0
  bne x0, x3, failure
  ori x3, x0, 0x1
  csrrs x3, mscratch, x0
  # x3 should have F0
  bne x3, x1, failure
  csrrs x3, mscratch, x2
  # x3 should still F0
  bne x3, x1, failure
  RVTEST_PASS
failure:
  RVTEST_FAIL


RVTEST_CODE_END

.data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
