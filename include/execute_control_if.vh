`ifndef EXECUTE_CONTROL_IF_VH
`define EXECUTE_CONTROL_IF_VH

`include "rv32i_types_pkg.vh"

interface execute_control_if;
  import rv32i_types_pkg::*;

  logic flush, stall, dwait, branch_mispredict;
  word_t branch_jump_addr;

  modport execute(
    input flush, stall,
    output dwait, branch_mispredict, branch_jump_addr
  );

  modport control(
    input dwait, branch_mispredict, branch_jump_addr,
    output flush, stall
  );

endinterface
`endif
