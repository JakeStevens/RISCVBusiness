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
*   Filename:     tb/tb_sparce_sasa_table.sv
*
*   Created by:   Vadim Nikiforov 
*   Email:        vnikifor@purdue.edu
*   Date Created: 08/23/2019
*   Description:  Testbench for the sasa table file
*/

`include "sparce_internal_if.vh"
  import rv32i_types_pkg::*;

`define GET_IDX(i,j)\
  ((i)*NUM_SETS + (j))

`define SASA_DATA(pc, rs1, rs2, cond, insts_to_skip)\
  (((pc) << 14) + (((rs1) & 'h1F) << 11) + (((rs2) & 'h1F) << 6) + (((cond) & 'h1) << 5) + ((insts_to_skip) & 'h1F))

typedef struct
{
  word_t pc;
  word_t sasa_addr;
  word_t sasa_data;
  word_t preceding_pc;
  logic  sasa_wen;
  logic  valid;
  logic  sasa_enable;
  logic[4:0] sasa_rs1;
  logic[4:0] sasa_rs2;
  logic[4:0] rd;
  sasa_cond_t condition;
  logic [4:0] insts_to_skip;
} tb_sasa_port_t;

module tb_sparce_sasa_table ();

  parameter PERIOD = 20;
  parameter NUM_TABLE_SIZES = 4;
  parameter NUM_SETS = 3;
  parameter NUM_SASA_TABLES = NUM_TABLE_SIZES * NUM_SETS;

  logic tb_clk;
  logic tb_nRST;

  sparce_internal_if sparce_if_arr[NUM_SASA_TABLES]();
  tb_sasa_port_t sasa_port_arr[NUM_SASA_TABLES];

  genvar i, j;
  integer tb_i;
  integer tb_j;

  generate 
  begin : tb_variable_sasa
    for (i=0; i < NUM_TABLE_SIZES; i++) begin
      for (j=0; j < NUM_SETS; j++) begin
        sparce_sasa_table #(.SASA_ENTRIES(2**(i+2)),.SASA_SETS(2**j)) DUT (tb_clk, tb_nRST, sparce_if_arr[`GET_IDX(i,j)]);
        assign sparce_if_arr[`GET_IDX(i,j)].pc = sasa_port_arr[`GET_IDX(i,j)].pc;
        assign sparce_if_arr[`GET_IDX(i,j)].sasa_addr = sasa_port_arr[`GET_IDX(i,j)].sasa_addr;
        assign sparce_if_arr[`GET_IDX(i,j)].sasa_data = sasa_port_arr[`GET_IDX(i,j)].sasa_data;
        assign sparce_if_arr[`GET_IDX(i,j)].sasa_wen = sasa_port_arr[`GET_IDX(i,j)].sasa_wen;
        assign sparce_if_arr[`GET_IDX(i,j)].sasa_enable = sasa_port_arr[`GET_IDX(i,j)].sasa_enable;
        assign sasa_port_arr[`GET_IDX(i,j)].sasa_rs1 = sparce_if_arr[`GET_IDX(i,j)].sasa_rs1;
        assign sasa_port_arr[`GET_IDX(i,j)].sasa_rs2 = sparce_if_arr[`GET_IDX(i,j)].sasa_rs2;
        assign sasa_port_arr[`GET_IDX(i,j)].insts_to_skip = sparce_if_arr[`GET_IDX(i,j)].insts_to_skip;
        assign sasa_port_arr[`GET_IDX(i,j)].preceding_pc = sparce_if_arr[`GET_IDX(i,j)].preceding_pc;
        assign sasa_port_arr[`GET_IDX(i,j)].condition = sparce_if_arr[`GET_IDX(i,j)].condition;
        assign sasa_port_arr[`GET_IDX(i,j)].valid = sparce_if_arr[`GET_IDX(i,j)].valid;
      end
    end
  end
  endgenerate
  
  always begin
    #(PERIOD/2);
    tb_clk <= ~tb_clk;
  end

  initial begin
    tb_clk  = 0;
    tb_nRST = 1;
    for (tb_i=0; tb_i < NUM_TABLE_SIZES ; tb_i++) begin
      for (tb_j=0; tb_j < NUM_SETS; tb_j++) begin
        // test that the table is initialized correctly
        $display("Testing size %d table with %d sets", 2**(tb_i+2),2**tb_j);
        test_default_values(tb_i,tb_j);
        load_sasa_table(tb_i,tb_j);
      end
    end
    //test_default_values(1,2);
    //load_sasa_table(1,2);
    $finish;
  end

  // ensure that when initialized, the SASA table outputs every entry as not
  // valid
  task test_default_values(integer size_idx, integer set_idx);
    integer ii;
    integer idx;
    initialize(size_idx, set_idx);
    idx = `GET_IDX(size_idx, set_idx);
    for (ii = 0; ii < (2**(size_idx+2)); ii++) begin
      @(negedge tb_clk);
      sasa_port_arr[idx].sasa_data = `SASA_DATA(ii << 2, ii, ii, ii, ii);
      sasa_port_arr[idx].pc = ii << 2;
      @(posedge tb_clk);
      assert (sasa_port_arr[idx].valid == 1'b0) else $error("Uninitialized entry in SASA table outputs as valid");
    end
  endtask

  task load_sasa_table(integer size_idx, integer set_idx);
    integer ii;
    integer idx;
    initialize(size_idx, set_idx);
    idx = `GET_IDX(size_idx, set_idx);

    @(negedge tb_clk);

    for (ii = 0; ii < (2**(size_idx+2)); ii++) begin
      sasa_port_arr[idx].pc = ii << 2;
      write_sasa_entry(size_idx, set_idx, `SASA_DATA(ii << 2, ii, ii, ii, ii));
      read_sasa_entry(size_idx, set_idx, `SASA_DATA(ii << 2, ii, ii, ii,ii), 1);
    end

    sasa_port_arr[idx].sasa_wen = '0;
    sasa_port_arr[idx].sasa_data = '1;
    sasa_port_arr[idx].sasa_addr = '1;
    sasa_port_arr[idx].sasa_enable = '0;
    for (ii = 0; ii < (2**(size_idx+2)); ii++) begin
      @(negedge tb_clk);
      sasa_port_arr[idx].pc = ii << 2;
      @(posedge tb_clk);
      read_sasa_entry(size_idx, set_idx, `SASA_DATA(ii << 2, ii, ii, ii,ii), 1);
    end
  endtask

  task read_sasa_entry(integer size_idx, integer set_idx, word_t data, logic valid);
      integer expected;
      integer idx;
      idx = `GET_IDX(size_idx, set_idx);
      #(PERIOD/20);
      if (!valid) begin
        assert (sasa_port_arr[idx].valid == '0) else $error("Unitialized entry in SASA table outputs as valid");
      end else begin
        assert (sasa_port_arr[idx].valid == '1) else $error("Initialized entry in SASA table outputs as invalid");
        expected = (data >> 11) & 'h1F;
        assert (sasa_port_arr[idx].sasa_rs1== expected) else $error("Initialized entry in SASA table outputs incorrect sasa_rs1 value (exp: %d, got: %d)", expected , sasa_port_arr[idx].sasa_rs1);
        expected = (data >> 6) & 'h1F;
        assert (sasa_port_arr[idx].sasa_rs2==  expected) else $error("Initialized entry in SASA table outputs incorrect sasa_rs2 value (exp: %d, got: %d)", expected, sasa_port_arr[idx].sasa_rs2);
        expected = data & 'h1F;
        assert (sasa_port_arr[idx].insts_to_skip ==  expected) else $error("Initialized entry in SASA table outputs incorrect insts_to_skip value (exp: %d, got: %d)", expected, sasa_port_arr[idx].insts_to_skip);
        assert (sasa_port_arr[idx].preceding_pc ==  sasa_port_arr[idx].pc) else $error("Initialized entry in SASA table outputs incorrect preceding_pc value (exp: %d, got: %d)",  sasa_port_arr[idx].pc, sasa_port_arr[idx].insts_to_skip);
        expected = (data >> 5) & '1;
        assert (sasa_port_arr[idx].condition ==  sasa_cond_t'(expected)) else $error("Initialized entry in SASA table outputs incorrect preceding_pc value (exp: %d, got: %d)",  sasa_cond_t'(expected), sasa_port_arr[idx].condition);
      end
  endtask

  task write_sasa_entry(integer size_idx, integer set_idx, word_t data);
      integer idx;
      idx = `GET_IDX(size_idx, set_idx);
      @(negedge tb_clk);
      sasa_port_arr[idx].sasa_wen = '1;
      sasa_port_arr[idx].sasa_data = data;
      sasa_port_arr[idx].sasa_addr = 'h1000;
      sasa_port_arr[idx].sasa_enable = '1;
      @(posedge tb_clk);
  endtask

  task initialize(integer size_idx, integer set_idx);
    int idx;
    idx = `GET_IDX(size_idx, set_idx);
    @(negedge tb_clk);
    tb_nRST = 0;
    sasa_port_arr[idx].pc = '0;
    sasa_port_arr[idx].sasa_addr = '0;
    sasa_port_arr[idx].sasa_data = '0;
    sasa_port_arr[idx].sasa_wen = '0;
    sasa_port_arr[idx].sasa_enable = '0;
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_nRST = 1;
    @(negedge tb_clk);

  endtask


endmodule

