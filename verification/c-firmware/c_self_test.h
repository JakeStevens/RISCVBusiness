#ifndef C_SELF_TEST_H
#define C_SELF_TEST_H

#define S(x) #x
#define SX(x) S(x)

#define TEST_FINISH_SUCCESS \
asm volatile (              \
  "addi x28, x0, 1;"        \
  "li x1, 1;"               \
  "li x2, 1;"               \
  "1: "                     \
  "j 1b;"                   \
);

#define TEST_FINISH_FAIL(num) \
asm volatile (                \
  "addi x28, x0, " SX(num) ";"\
  "1: beqz x28, 1b;"          \
  "sll x28, x28, 1;"          \
  "or x28, x28, 1;"           \
  "li x1, 1;"                 \
  "li x2, 1;"                 \
  "1: "                       \
  "j 1b;"                     \
);

#define DEFINE_HOST                      \
asm volatile(                            \
  ".global tohost; tohost: .word 0;"     \
  ".global fromhost; fromhost: .word 0;" \
);

#endif //C_SELF_TEST_H
