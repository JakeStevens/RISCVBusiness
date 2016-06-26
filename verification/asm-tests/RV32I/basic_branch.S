#include "riscv_test.h"

RVTEST_DATA_DUMP_BEGIN
RVTEST_CODE_BEGIN

.text
#test asm code goes here
main:

    ori x1, x0, -5 
    ori x2, x0, 1
    ori x3, x0, 1
    ori x4, x0, 2

    ori x5, x0, 0xBA
    slli x5, x5, 2
    ori x5, x5, 0xAD
    
    la x6, tdat0
    beq x2, x3, beq_target
    sw x5, 0(x6)

beq_target: 
    la x6, tdat1
    bne x1, x2, bne_target
    sw x5, 0(x6)

bne_target:
    la x6, tdat2
    blt x1, x4, blt_target
    sw x5, 0(x6)

blt_target:
    la x6, tdat3
    bge x2, x1, bge_target
    sw x5, 0(x6)

bge_target:
    la x6, tdat4
    bltu x2, x1, bgeu_target
    sw x5, 0(x6)

bgeu_target:
    la x7, tdat5
    bgeu x1, x4, end_target
    sw x5, 0(x6)

end_target:
    ori x0, x0, 0x00

RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0x00000001
tdat1:  .word 0x00000002
tdat2:  .word 0x00000003
tdat3:  .word 0x00000004
tdat4:  .word 0x00000005
tdat5:  .word 0x00000006

RVTEST_DATA_DUMP_END



