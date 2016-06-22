#include "riscv_test.h"

RVTEST_DATA_DUMP_BEGIN
RVTEST_CODE_BEGIN

.text
#test asm code goes here
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



