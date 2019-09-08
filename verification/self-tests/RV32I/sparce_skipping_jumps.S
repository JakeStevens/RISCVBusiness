
# See LICENSE for license details.

#*****************************************************************************
# sparce_skipping_jumps.S
#-----------------------------------------------------------------------------
#
# This test ensures that the sparce optimizations properly supersede any jump
# instructions that are intended to be skipped.
#

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

li TESTNUM, 1
STORE_SASA_FROM_MEM(sasa_entry_0, x1, x2)
ori x3, x0, 0
ori x4, x0, 0
nop
nop
skip_point:
  nop
  j sasa_test_case_end_fail
  j sasa_test_case_end_fail
  j sasa_test_case_end_fail
  j sasa_test_case_end_fail
  j sasa_test_case_end


sasa_test_case_end_fail:
li TESTNUM, 0

sasa_test_case_end:

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN
sasa_entry_0:
CREATE_SASA_MEMORY_ENTRIES(skip_point, 3, 4, SASA_COND_AND, 4)

TEST_DATA

RVTEST_DATA_END
