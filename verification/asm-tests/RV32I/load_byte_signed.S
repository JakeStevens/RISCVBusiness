#include "riscv_test.h"

RVTEST_DATA_DUMP_BEGIN
RVTEST_CODE_BEGIN

.text
#test asm code goes here
main:
    la x1, tdat0
    la x2, tdat1
    lb x3, 0(x1)
    sw x3, 0(x2)
    lb x3, 1(x1)
    sw x3, 4(x2)
    lb x3, 2(x1)
    sw x3, 8(x2)
    lb x3, 3(x1)
    sw x3, 0(x1)
RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0xdeadcafe
tdat1:  .word 0x00000000
RVTEST_DATA_DUMP_END



