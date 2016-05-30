`ifndef FETCH_EXECUTE_IF_VH
`define FETCH_EXECUTE_IF_VH

`include "tspp_types_pkg.vh"

interface fetch_execute_if;
  import tspp_types_pkg::*;
 
  word_t pc, instr, npc;

  modport fetch(
    output pc, instr, nc
  );

  modport execute{
    input pc, instr, nc
  );

endinterface
`endif
