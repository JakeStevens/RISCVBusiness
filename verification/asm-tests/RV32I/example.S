#include "riscv_test.h"

RVTEST_DATA_DUMP_BEGIN
RVTEST_CODE_BEGIN

.text
#test asm code goes here
main:
  addi x1,x1,0x200

RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0xf00ff00f
tdat1:  .word 0xf00ff00e

RVTEST_DATA_DUMP_END



