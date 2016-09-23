OUTPUT_ARCH( "riscv" )

MEMORY {
  mem : ORIGIN = 0x00000000, LENGTH = 0x0000ffff
}

SECTIONS
{
  .memory : {
    . = 0x100;
    start*(.text);
    *(.text);
    *(*);
    _end = .;
  } > mem
}
