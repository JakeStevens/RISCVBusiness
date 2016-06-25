#include "riscv_test.h"

RVTEST_DATA_DUMP_BEGIN
RVTEST_CODE_BEGIN

.text
#test asm code goes here
main:
    ori x1, x0, 0xf0
    ori x2, x0, 0x55

    #AND
    la x4, tdat0
    and x9, x1, x2
    sw x9, 0(x4)

    #OR
    la x4, tdat1
    or x9, x1, x2
    sw x9, 0(x4)

    #XOR
    la x4, tdat2
    xor x9, x1, x2
    sw x9, 0(x4)

    #ADD
    la x4, tdat3
    add x9, x1, x2
    sw x9, 0(x4)

    #SUB
    la x4, tdat4
    sub x9, x1, x2
    sw x9, 0(x4)

RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0xbad0bad0
tdat1:  .word 0xbad1bad1
tdat2:  .word 0xbad2bad2
tdat3:  .word 0xbad3bad3
tdat4:  .word 0xbad4bad4

RVTEST_DATA_DUMP_END



