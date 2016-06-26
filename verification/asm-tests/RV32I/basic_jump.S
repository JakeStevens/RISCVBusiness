#include "riscv_test.h"

RVTEST_DATA_DUMP_BEGIN
RVTEST_CODE_BEGIN

.text
#test asm code goes here
main:

    ori x1, x0, 0xba
    ori x2, x0, 0xdd

    la x3, tdat0
    jal x4, jal_target
    sw x1, 0(x3)

jal_target:
    la x5, tdat1
    auipc x6, 0x0000  
    jalr x7, x6, 12 
    sw x2, 0(x5)

jalr_target:
    la x8, tdat2
    la x9, tdat3
    sw x4, 0(x8)
    sw x7, 0(x9) 
RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0x00000001
tdat1:  .word 0x00000002
tdat2:  .word 0x00000003
tdat3:  .word 0x00000004

RVTEST_DATA_DUMP_END



