`ifndef RV32I_TYPES_PKG_VH
`define RV32I_TYPES_PKG_VH
package rv32i_types_pkg;
  parameter WORD_SIZE = 32;

  typedef logic [WORD_SIZE-1:0] word_t;
endpackage
`endif
