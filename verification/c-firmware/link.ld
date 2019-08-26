OUTPUT_ARCH( "riscv" )

MEMORY {
  mem : ORIGIN = 0x80000000, LENGTH = 0x0000ffff
}

SECTIONS
{
  .memory : {
    start*(.text);
    *(.text);
    *(*);
    _end = .;
  } > mem
}
