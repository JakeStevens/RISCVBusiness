RVTEST_DATA_DUMP_BEGIN

RVTEST_INTVEC_USER_BEGIN
  nop
RVTEST_INTVEC_SUPER_BEGIN
  nop
RVTEST_INTVEC_HYPER_BEGIN
  nop
RVTEST_INTVEC_MACH_BEGIN
  nop

RVTEST_CODE_BEGIN

#test asm code goes here
main:
  fadd.s x1,x1,0x100

RVTEST_CODE_END

.data
#test data goes here
tdat0:  .word 0xf00ff00f
tdat1:  .word 0xf00ff00e

RVTEST_DATA_DUMP_END
