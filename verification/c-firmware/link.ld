OUTPUT_ARCH( "riscv" )

SECTIONS
{
  . = 0x100;
  .text.init : { *(.text.init) }
  .text : { *(.text) }
  .data : { *(.data) }
  .bss : { *(.bss) }
  _end = .;
}
