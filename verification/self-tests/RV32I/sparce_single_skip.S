# See LICENSE for license details.

#*****************************************************************************
# sparce_single_skip.S
#-----------------------------------------------------------------------------
#
# This is the most basic test for the SparCE optimizations. An entry is loaded
# into the SASA table, and the conditions for skipping are met. The test fails
# when any of the instructions to be skipped are executed, and passes otherwise.
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
  li TESTNUM, 0
  li TESTNUM, 0
  li TESTNUM, 0
  li TESTNUM, 0

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN
sasa_entry_0:
CREATE_SASA_MEMORY_ENTRIES(skip_point, 3, 4, SASA_COND_AND, 4)

TEST_DATA

RVTEST_DATA_END
