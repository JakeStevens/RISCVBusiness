OUTPUT_ARCH( "riscv" )

SECTIONS
{

  . = 0x200;
  .text :
  {
  *(.text)
  }
  _end = .;
  . = 0x800;
  .data :
  {
  *(.data)
  }
  _end = .;
}
