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


module tb_sparce_sasa_table ();

  parameter PERIOD = 20;
  parameter NUM_TABLE_SIZES = 5;
  parameter NUM_SETS = 4;
  parameter NUM_SASA_TABLES = NUM_TABLE_SIZES * NUM_SETS;

  logic tb_clk;
  logic tb_nRST;

  sparce_internal_if sparce_if[NUM_SASA_TABLES]();

  genvar i, j;

  generate 
  begin : tb_variable_sasa
    for (i=0; i < NUM_TABLE_SIZES; i++) begin
      for (j=0; j < NUM_SETS; j++) begin
        sparce_sasa_table #(.SASA_ENTRIES((i+1)*4),.SASA_SETS((j+1)*4)) DUT (tb_clk, tb_nRST, sparce_if[i*NUM_SETS + j]);
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
    $finish;
  end

  task test_default_values(integer size_idx, integer set_idx);
  
  endtask

  task initialize(integer size_idx, integer set_idx);
    integer idx = get_index(size_idx, set_idx);
    @(negedge tb_clk);
    tb_nRST = 0;
    sparce_if[idx].pc = '0;
    sparce_if[idx].sasa_addr = '0;
    sparce_if[idx].sasa_data = '0;
    sparce_if[idx].sasa_wen = '0;
    sparce_if[idx].sasa_enable = '0;
    @(negedge tb_clk);
    @(negedge tb_clk);
    tb_nRST = 1;
    @(negedge tb_clk);

  endtask

  function get_index(integer size_idx, integer set_idx);
    integer idx;
    idx =  size_idx+4+set_idx;
    return idx;
  endfunction



endmodule

