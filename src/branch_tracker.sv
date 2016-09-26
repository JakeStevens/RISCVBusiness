/*
*   Copyright 2016 Purdue University
*   
*   Licensed under the Apache License, Version 2.0 (the "License");
*   you may not use this file except in compliance with the License.
*   You may obtain a copy of the License at
*   
*       http://www.apache.org/licenses/LICENSE-2.0
*   
*   Unless required by applicable law or agreed to in writing, software
*   distributed under the License is distributed on an "AS IS" BASIS,
*   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*   See the License for the specific language governing permissions and
*   limitations under the License.
*
*
*   Filename:     branch_tracker.sv
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 09/26/2016
*   Description:  Track performance stats associated with branch prediction 
*/
module branch_tracker(
  input logic CLK, nRST,
  input logic update_predictor,
  input logic prediction,
  input logic branch_result
);
  // Branch Performance Signals
  logic [63:0] prediction_count, misprediction_count, correct_pred_count,
                pred_taken_count, pred_not_taken_count,
                taken_incorrect_count, not_taken_incorrect_count; 
  
  always_ff @(posedge CLK, negedge nRST) begin : tracked_registers
    if (!nRST) begin
      prediction_count <= '0;
      misprediction_count <= '0;
      correct_pred_count <= '0;
      pred_taken_count <= '0;
      pred_not_taken_count <= '0;
      taken_incorrect_count <= '0;
      not_taken_incorrect_count <= '0;
    end else if (update_predictor & !prediction & !branch_result) begin
    // Predicted not taken and branch result is not taken
      prediction_count <= prediction_count + 1;
      correct_pred_count <= correct_pred_count + 1;
      pred_not_taken_count <= pred_not_taken_count + 1;
    end else if (update_predictor & !prediction & branch_result) begin
    // Predicted not taken and branch result is taken
      prediction_count <= prediction_count + 1;
      misprediction_count <= misprediction_count + 1;
      pred_not_taken_count <= pred_not_taken_count + 1;
      not_taken_incorrect_count <= not_taken_incorrect_count + 1;
    end else if (update_predictor & prediction & !branch_result) begin
    // Predicted taken and branch result is not taken
      prediction_count <= prediction_count + 1;
      misprediction_count <= misprediction_count + 1;
      pred_taken_count <= pred_taken_count + 1;
      taken_incorrect_count <= taken_incorrect_count + 1;
    end else if (update_predictor & prediction & branch_result) begin
    // Predicted taken and branch result is taken
      prediction_count <= prediction_count + 1;
      correct_pred_count <= correct_pred_count + 1;
      pred_taken_count <= pred_taken_count + 1;
    end
  end : tracked_registers

  final begin : OUTPUT_STATS
    $display("Conditional branches predicted: %2d", prediction_count);
    $display("Conditional branches predicted incorrectly: %2d",
              misprediction_count);
    $display("Conditional branches predicted correctly: %2d",
              correct_pred_count);
    $display("Branch prediction accuracy: %5f",
              real'(correct_pred_count)/prediction_count);
    $display("Branches predicted as taken: %2d",
              pred_taken_count);
    $display("Branches predicted as taken, incorrect: %2d",
              taken_incorrect_count);
    $display("Branches predicted as taken, correct: %2d",
              pred_taken_count - taken_incorrect_count);
    $display("Branches predicted as not taken: %2d",
              pred_not_taken_count);
    $display("Branches predicted as not taken, incorrect: %2d",
              not_taken_incorrect_count);
    $display("Branches predicted as not taken, correct: %2d",
              pred_not_taken_count - not_taken_incorrect_count);

  end : OUTPUT_STATS
endmodule
