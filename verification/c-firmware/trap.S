  .section .text
  .global irq_handler
  .global exception_handler

  .balign 0x40
  nop
  .balign 0x40
  nop
  .balign 0x40
  nop
  .balign 0x40
  addi sp, sp, -4
  sw ra, 0(sp)
  jal ra, trap
  lw ra, 0(sp)
  addi sp, sp, 4
  eret

  .balign 0x40
  j main

trap:
  #store return address
  addi sp, sp, -4
  sw ra, 0(sp)
  #push registers on the stack
  sw x31, -1*4(sp)
  sw x30, -2*4(sp)
  sw x29, -3*4(sp)
  sw x28, -4*4(sp)
  sw x27, -5*4(sp)
  sw x26, -6*4(sp)
  sw x25, -7*4(sp)
  sw x24, -8*4(sp)
  sw x23, -9*4(sp)
  sw x22, -10*4(sp)
  sw x21, -11*4(sp)
  sw x20, -12*4(sp)
  sw x19, -13*4(sp)
  sw x18, -14*4(sp)
  sw x17, -15*4(sp)
  sw x16, -16*4(sp)
  sw x15, -17*4(sp)
  sw x14, -18*4(sp)
  sw x13, -19*4(sp)
  sw x12, -20*4(sp)
  sw x11, -21*4(sp)
  sw x10, -22*4(sp)
  sw x9,  -23*4(sp)
  sw x8,  -24*4(sp)
  sw x7,  -25*4(sp)
  sw x6,  -26*4(sp)
  sw x5,  -27*4(sp)
  sw x4,  -28*4(sp)
  sw x3,  -29*4(sp)
  sw x2,  -30*4(sp)
  sw x1,  -31*4(sp)
  sw x0,  -32*4(sp)
  #push pointer to reg values
  addi sp, sp, -32*4
  addi a0, sp, 0
  #push value of mcause
  csrrs x0, mcause, a1
  #go to int handler if top bit is set, else exception
  addi t0, a1, 0
  srli t0, t0, 31
  beq t0, zero, j_ex
j_int:
  jal irq_handler
  j trap_ret
j_ex:
  jal exception_handler
trap_ret:
  #pop modified values of registers (ignore 0-4)
  lw x31, 1*4(sp)
  lw x30, 2*4(sp)
  lw x29, 3*4(sp)
  lw x28, 4*4(sp)
  lw x27, 5*4(sp)
  lw x26, 6*4(sp)
  lw x25, 7*4(sp)
  lw x24, 8*4(sp)
  lw x23, 9*4(sp)
  lw x22, 10*4(sp)
  lw x21, 11*4(sp)
  lw x20, 12*4(sp)
  lw x19, 13*4(sp)
  lw x18, 14*4(sp)
  lw x17, 15*4(sp)
  lw x16, 16*4(sp)
  lw x15, 17*4(sp)
  lw x14, 18*4(sp)
  lw x13, 19*4(sp)
  lw x12, 20*4(sp)
  lw x11, 21*4(sp)
  lw x10, 22*4(sp)
  lw x9,  23*4(sp)
  lw x8,  24*4(sp)
  lw x7,  25*4(sp)
  lw x6,  26*4(sp)
  lw x5,  27*4(sp)
  addi sp, sp, 32*4
  #restore return address, update epc and return
  lw ra, 0(sp)
  sw t0, 0(sp)
  csrr t0, mepc
  addi t0, t0, 4
  csrw mepc, t0
  lw t0, 0(sp)
  addi sp, sp, 4
  ret
  
