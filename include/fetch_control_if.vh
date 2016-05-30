`ifndef FETCH_CONTROL_IF_VH
`define FETCH_CONTROL_IF_VH

`include "rv32i_types_pkg.vh"

interface fetch_control_if;
  import rv32i_types_pkg::*;

  logic update_pc, flush, stall;
  word_t update_addr;

  modport fetch(
    input update_addr, update_pc, flush, stall
  );

  modport control(
    output update_addr, update_pc, flush, stall
  );

endinterface
`endif
