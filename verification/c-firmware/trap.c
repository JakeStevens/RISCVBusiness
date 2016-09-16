void irq_handler(int *regs, int cause) {

}

void exception_handler(int *regs, int cause) {
  regs[28] = 16;
  regs[9]  = cause;
}
