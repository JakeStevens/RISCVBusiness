# 
#   Copyright 2016 Purdue University
#   
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#   
#       http://www.apache.org/licenses/LICENSE-2.0
#   
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#
#   Filename:     trap.S
#
#   Created by:   John Skubic
#   Email:        jskubic@purdue.edu
#   Date Created: 09/16/2016
#   Description:  Asm source for interrupt and exception handling code
#

  .section .text
  # Set handler
  la t0, mvec
  csrw mtvec, t0
  #set stack pointer (0x3fff_fffc)
  ori sp, zero, 0x0
  addi sp, sp, -4
  ori t0, zero, 0x0c
  slli t0, t0, 28
  ori t1, zero, 0x0
  addi t1, t1, -1
  xor t0, t0, t1
  and sp, sp, t0
  #load address of main (jump does not return)
  la t0, main
  jr t0

  .global irq_handler
  .global exception_handler

mvec:
  addi sp, sp, -4
  sw ra, 0(sp)
  jal ra, trap
  lw ra, 0(sp)
  addi sp, sp, 4
  mret


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
  #set pointer to reg values
  addi sp, sp, -32*4
  addi a1, sp, 0
  #set pointer to mepc
  csrr a2, mepc
  #set pointer to mbadaddr
  csrr a3, mbadaddr 
  #set value of mcause
  csrr a0, mcause
  #go to int handler if top bit is set, else exception
  addi t0, a0, 0
  srli t0, t0, 31
  beq t0, zero, j_ex
j_int:
  jal irq_handler
  j trap_ret
j_ex:
  jal exception_handler
  csrr t0, mepc
  addi t0, t0, 4
  csrw mepc, t0
trap_ret:
  #pop modified values of registers (ignore 0-4)
  lw x31, 31*4(sp)
  lw x30, 30*4(sp)
  lw x29, 29*4(sp)
  lw x28, 28*4(sp)
  lw x27, 27*4(sp)
  lw x26, 26*4(sp)
  lw x25, 25*4(sp)
  lw x24, 24*4(sp)
  lw x23, 23*4(sp)
  lw x22, 22*4(sp)
  lw x21, 21*4(sp)
  lw x20, 20*4(sp)
  lw x19, 19*4(sp)
  lw x18, 18*4(sp)
  lw x17, 17*4(sp)
  lw x16, 16*4(sp)
  lw x15, 15*4(sp)
  lw x14, 14*4(sp)
  lw x13, 13*4(sp)
  lw x12, 12*4(sp)
  lw x11, 11*4(sp)
  lw x10, 10*4(sp)
  lw x9,  9*4(sp)
  lw x8,  8*4(sp)
  lw x7,  7*4(sp)
  lw x6,  6*4(sp)
  lw x5,  5*4(sp)
  addi sp, sp, 32*4
  #restore return address, update epc and return
  lw ra, 0(sp)
  addi sp, sp, 4
  mret
