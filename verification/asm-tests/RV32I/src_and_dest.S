#include "riscv_test.h"

RVTEST_DATA_DUMP_BEGIN
RVTEST_CODE_BEGIN

.text
#test asm code goes here
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



