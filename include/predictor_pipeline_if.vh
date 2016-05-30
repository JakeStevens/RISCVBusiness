`ifndef PREDICTOR_PIPELINE_IF_VH
`define PREDICTOR_PIPELINE_IF_VH

`include "tspp_types_pkg.vh"

interface predictor_pipeline_if;
  import tspp_types_pkg::*;

  word_t current_PC, target_addr, update_addr;
  logic update_predictor;
  prediction_t predict_taken, prediction, branch_result;

  modport predictor(
    input current_PC, update_predictor, prediction, branch_result, update_addr,
    output predict_taken, target_addr
  );

  modport pipeline(
    input predict_taken, target_addr,
    output current_PC, update_predictor, prediction, branch_result,
           update_addr
  );

endinterface
`endif
