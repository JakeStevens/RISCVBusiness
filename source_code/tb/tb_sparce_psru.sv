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
*   Filename:     tb/tb_sparce_psru.sv
*
*   Created by:   Wengyan Chan
*   Email:        cwengyan@purdue.edu
*   Date Created: 08/27/2019
*   Description:  Testbench for the Pre-identify and Skip Redundancy Unit
*/

`include "sparce_internal_if.vh"
  import rv32i_types_pkg::*;

 // modport psru (
 // output skipping, sparce_target,
 // input valid, insts_to_skip, preceding_pc, condition, rs1_sparsity,         rs2_sparsity, is_sparse, 
 // );


module tb_sparce_psru ();

  parameter PERIOD = 20;
  integer i;
  logic tb_clk;

  sparce_internal_if sparce_if();
  sparce_psru DUT(sparce_if);

  always begin
    #(PERIOD/2);
    tb_clk <= ~tb_clk;
  end

  initial begin
    tb_clk  = 0;
    $display("TEST0: Verify Sparce skipping and target values when SASA is invalid");
    initialize;
    test_sasa_invalid;
    $display("TEST1: Verify Sparce skipping when SASA is valid");
    initialize;
    test_psru_skipping;
    $display("TEST2: Verify Sparce target when SASA is valid");
    test_psru_target;
    $finish;
  end

  // initialize psru port values 
  task initialize;
    i = 0;
    sparce_if.valid = 1'b0;
    sparce_if.insts_to_skip = 16'd4;
    sparce_if.preceding_pc = 32'h3000;
    sparce_if.condition = SASA_COND_OR;
    sparce_if.rs1_sparsity= 1'b0;
    sparce_if.rs2_sparsity= 1'b0;
  endtask

  // Test0: Verify sparce skipping and target values when SASA is invalid
  task test_sasa_invalid;
    for (i = 0; i < 8; i++) begin
      @(negedge tb_clk);
      sparce_if.condition = sasa_cond_t'(i[2]);
      sparce_if.rs1_sparsity = i[1];
      sparce_if.rs2_sparsity = i[0];
      @(posedge tb_clk);
      assert (sparce_if.skipping == 1'b0) $display ("PASSED: PSRU not skipped when SASA invalid");
      else $error("FAILED: SASA invalid but psru skipped");
    end
  endtask

  // Test1: Verify sparce skipping when SASA is valid
  task test_psru_skipping;
    sparce_if.valid = 1'b1;
    sparce_if.condition = SASA_COND_OR;
    for (i = 0; i < 4; i++) begin
      @(negedge tb_clk);
      sparce_if.rs1_sparsity = i[1];
      sparce_if.rs2_sparsity = i[0];
      @(posedge tb_clk);
      assert (sparce_if.skipping == (i[0] | i[1])) $display ("PASSED: PSRU skipped correctly when SASA valid");
      else $error("FAILED: SASA valid but psru skipped incorrectly");
    end

    sparce_if.condition = SASA_COND_AND;
    for (i = 0; i < 4; i++) begin
      @(negedge tb_clk);
      sparce_if.rs1_sparsity = i[1];
      sparce_if.rs2_sparsity = i[0];
      @(posedge tb_clk);
      assert (sparce_if.skipping == (i[0] & i[1])) $display ("PASSED: PSRU skipped correctly when SASA valid");
      else $error("FAILED: SASA valid but psru skipped incorrectly");
    end
  endtask

  // Test2: Verify sparce target when SASA is valid
  task test_psru_target;
    sparce_if.valid = 1'b1;
    sparce_if.condition = SASA_COND_OR;
    sparce_if.rs1_sparsity = 1'b1;
    sparce_if.rs2_sparsity = 1'b1;
    for (i = 0; i <= 16'hFFFF; i++) begin
      @(negedge tb_clk);
      sparce_if.insts_to_skip = i;
      @(posedge tb_clk);
      assert (sparce_if.sparce_target == sparce_if.preceding_pc + (i << 2) + 4) 
      else $error("FAILED: Skip target incorrect");
    end
    $display("Test2 finished. PASSED if no assertion errors");
  endtask
endmodule
