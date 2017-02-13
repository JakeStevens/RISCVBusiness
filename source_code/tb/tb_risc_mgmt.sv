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
*   Filename:     tb_risc_mgmt.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 02/10/2017
*   Description:  RISC-MGMT testbench.  Tests a two stage pipeline
*   implementation of RISC-MGMT
*                     
*/

`include "risc_mgmt_if.vh"

module tb_risc_mgmt();

  import test_pkg::*;
  import alu_types_pkg::*;

  parameter PERIOD = 20;

  /*  Signal Instantiations */
  logic CLK, nRST;
  test_insn_t insn;
  logic [5:0] counter;

  /*  Interface Instantiations */
  risc_mgmt_if rmif();

  /*  Module Instantiations */
  risc_mgmt DUT (.*);

  /*  CLK generation */

  initial begin
    CLK = 0;
  end

  always begin
    CLK = ~CLK;
    #(PERIOD/2);
  end

  /*  TB Run  */
  
  assign rmif.insn = insn;
  assign rmif.alu_res = rmif.alu_data_1 + rmif.alu_data_0;
  
  initial begin
    // Reset DUT
    nRST = 1'b0;
    insn = '0;
    rmif.rdata_s_0 = 0;
    rmif.rdata_s_1 = 0;
    rmif.mem_load = 0;
    rmif.mem_busy = 0;
    counter = 0;
    
    #(PERIOD);
    @(posedge CLK);
    nRST = 1'b1;
    @(posedge CLK);

    /* Begin Testing */
    
    // Test coming out of reset
    assert (rmif.req_reg_r == 0)  else $error("req_reg_r incorrect on PU\n");
    assert (rmif.req_reg_w == 0)  else $error("req_reg_w incorrect on PU\n");
    assert (rmif.req_alu == 0)    else $error("req_alu incorrect on PU\n");
    assert (rmif.req_br_j == 0)   else $error("req_br_j incorrect on PU\n");
    assert (rmif.req_mem == 0)    else $error("req_mem incorrect on PU\n");
    assert (rmif.exception == 0)  else $error("exception incorrect on PU\n");

    // Test RTYPE insn
    @(posedge CLK);
    // Constant settings
    insn.opcode = 7'b000_1011;
    insn.rs_0   = 5'h09;
    insn.rs_1   = 5'h1f;
    insn.rs_d   = 5'h10;
    insn.imm    = 6'h05;

    rmif.rdata_s_0 = 32'h1000_0011;
    rmif.rdata_s_1 = 32'h0100_1000;

    insn.funct = RTYPE;
    #(1);
    assert (rmif.req_reg_r == 1)  else $error("req_reg_r incorrect on RTYPE\n");
    assert (rmif.req_reg_w == 1)  else $error("req_reg_w incorrect on RTYPE\n");
    assert (rmif.req_alu == 0)    else $error("req_alu incorrect on RTYPE\n");
    assert (rmif.req_br_j == 0)   else $error("req_br_j incorrect on RTYPE\n");
    assert (rmif.req_mem == 0)    else $error("req_mem incorrect on RTYPE\n");
    assert (rmif.exception == 0)  else $error("exception incorrect on RTYPE\n");
    assert (rmif.reg_wdata == 32'h1100_1016) else $error("reg_data incorrect on RTYPE\n");

    // Test RTYPE_STALL insn
    @(posedge CLK);
    insn.funct = RTYPE_STALL_5;
    #(1);

    assert (rmif.req_reg_w == 1)  else $error("req_reg_w incorrect on RTYPE_STALL before stall.\n");

    while(rmif.execute_stall) begin
      counter++;
      @(posedge CLK);
    end

    assert (counter == 5'd16)     else $error("counter was %d, expected %d on RTYPE_STALL\n", counter, 16);
    assert (rmif.req_reg_r == 1)  else $error("req_reg_r incorrect on RTYPE_STALL\n");
    assert (rmif.req_reg_w == 1)  else $error("req_reg_w incorrect on RTYPE_STALL\n");
    assert (rmif.req_alu == 0)    else $error("req_alu incorrect on RTYPE_STALL\n");
    assert (rmif.req_br_j == 0)   else $error("req_br_j incorrect on RTYPE_STALL\n");
    assert (rmif.req_mem == 0)    else $error("req_mem incorrect on RTYPE_STALL\n");
    assert (rmif.exception == 0)  else $error("exception incorrect on RTYPE_STALL\n");
    assert (rmif.reg_wdata == 32'h1100_1016) else $error("reg_data incorrect on RTYPE_STALL\n");
    

    // Test RTYPE_ALU insn
    @(posedge CLK);
    insn.funct = RTYPE_ALU;
    #(1);

    assert (rmif.req_reg_r == 1)  else $error("req_reg_r incorrect on RTYPE_ALU\n");
    assert (rmif.req_reg_w == 1)  else $error("req_reg_w incorrect on RTYPE_ALU\n");
    assert (rmif.req_alu == 1)    else $error("req_alu incorrect on RTYPE_ALU\n");
    assert (rmif.req_br_j == 0)   else $error("req_br_j incorrect on RTYPE_ALU\n");
    assert (rmif.req_mem == 0)    else $error("req_mem incorrect on RTYPE_ALU\n");
    assert (rmif.exception == 0)  else $error("exception incorrect on RTYPE_ALU\n");
    assert (rmif.reg_wdata == 32'h1100_1011) else $error("reg_data incorrect on RTYPE_ALU\n");


    // Test BR_J insn
    @(posedge CLK);
    insn.funct = BR_J;
    #(1);

    assert (rmif.req_reg_r == 1)  else $error("req_reg_r incorrect on BR_J\n");
    assert (rmif.req_reg_w == 0)  else $error("req_reg_w incorrect on BR_J\n");
    assert (rmif.req_alu == 0)    else $error("req_alu incorrect on BR_J\n");
    assert (rmif.req_br_j == 1)   else $error("req_br_j incorrect on BR_J\n");
    assert (rmif.req_mem == 0)    else $error("req_mem incorrect on BR_J\n");
    assert (rmif.exception == 0)  else $error("exception incorrect on BR_J\n");
    assert (rmif.branch_jump == 1)else $error("branch_jump incorrect on BR_J\n");
    assert (rmif.br_j_addr == 32'h1000_0011) else $error("br_j_addr incorrect on BR_J\n");


    // Test MEM_LOAD insn
    @(posedge CLK);
    insn.funct = MEM_LOAD;
    rmif.mem_busy = 1;
    #(1);

    assert (rmif.memory_stall == 1)  else $error("memory_stall incorrect on MEM_LOAD while mem_busy\n");
    @(posedge CLK);
    rmif.mem_busy = 0;
    rmif.mem_load = 32'h1234_abcd;
    #(1);

    assert (rmif.memory_stall == 0)  else $error("memory_stall incorrect on MEM_LOAD\n");
    assert (rmif.req_reg_r == 1)  else $error("req_reg_r incorrect on MEM_LOAD\n");
    assert (rmif.req_reg_w == 1)  else $error("req_reg_w incorrect on MEM_LOAD\n");
    assert (rmif.req_alu == 0)    else $error("req_alu incorrect on MEM_LOAD\n");
    assert (rmif.req_br_j == 0)   else $error("req_br_j incorrect on MEM_LOAD\n");
    assert (rmif.req_mem == 1)    else $error("req_mem incorrect on MEM_LOAD\n");
    assert (rmif.exception == 0)  else $error("exception incorrect on MEM_LOAD\n");

    assert(rmif.mem_addr == 32'h1000_0011) else $error("mem_addr incorrect on MEM_LOAD\n");
    assert(rmif.mem_load == 32'h1234_abcd) else $error("mem_load incorrect on MEM_LOAD\n");
    assert (rmif.mem_ren == 1)    else $error("mem_ren incorrect on MEM_LOAD\n");
    assert (rmif.req_mem == 1)    else $error("req_wen incorrect on MEM_LOAD\n");
    
    // Test MEM_STORE insn
    @(posedge CLK);
    insn.funct = MEM_STORE;
    rmif.mem_busy = 1;
    #(1);

    assert (rmif.memory_stall == 1)  else $error("memory_stall incorrect on MEM_STORE while mem_busy\n");
    @(posedge CLK);
    rmif.mem_busy = 0;
    rmif.mem_load = 32'h1234_abcd;
    #(1);

    assert (rmif.memory_stall == 0)  else $error("memory_stall incorrect on MEM_STORE\n");
    assert (rmif.req_reg_r == 1)  else $error("req_reg_r incorrect on MEM_STORE\n");
    assert (rmif.req_reg_w == 0)  else $error("req_reg_w incorrect on MEM_STORE\n");
    assert (rmif.req_alu == 0)    else $error("req_alu incorrect on MEM_STORE\n");
    assert (rmif.req_br_j == 0)   else $error("req_br_j incorrect on MEM_STORE\n");
    assert (rmif.req_mem == 1)    else $error("req_mem incorrect on MEM_STORE\n");
    assert (rmif.exception == 0)  else $error("exception incorrect on MEM_STORE\n");

    assert(rmif.mem_addr == 32'h1000_0011) else $error("mem_addr incorrect on MEM_STORE\n");
    assert(rmif.mem_store == 32'h0100_1000) else $error("mem_store incorrect on MEM_STORE\n");
    assert (rmif.mem_ren == 0)    else $error("mem_ren incorrect on MEM_STORE\n");
    assert (rmif.req_mem == 1)    else $error("req_wen incorrect on MEM_STORE\n");

    // Test EXCEPTION insn
    @(posedge CLK);
    insn.funct = EXCEPTION;
    #(1);

    assert (rmif.req_reg_r == 1)  else $error("req_reg_r incorrect on EXCEPTION\n");
    assert (rmif.req_reg_w == 0)  else $error("req_reg_w incorrect on EXCEPTION\n");
    assert (rmif.req_alu == 0)    else $error("req_alu incorrect on EXCEPTION\n");
    assert (rmif.req_br_j == 0)   else $error("req_br_j incorrect on EXCEPTION\n");
    assert (rmif.req_mem == 0)    else $error("req_mem incorrect on EXCEPTION\n");
    assert (rmif.exception == 1)  else $error("exception incorrect on EXCEPTION\n");

    // Test NOP insn
    @(posedge CLK);
    insn.funct = NOP;
    #(1);
    assert (rmif.req_reg_r == 1)  else $error("req_reg_r incorrect on NOP\n");
    assert (rmif.req_reg_w == 0)  else $error("req_reg_w incorrect on NOP\n");
    assert (rmif.req_alu == 0)    else $error("req_alu incorrect on NOP\n");
    assert (rmif.req_br_j == 0)   else $error("req_br_j incorrect on NOP\n");
    assert (rmif.req_mem == 0)    else $error("req_mem incorrect on NOP\n");
    assert (rmif.exception == 0)  else $error("exception incorrect on NOP)\n");

    @(posedge CLK);
    insn.opcode = 7'b000_1010;
    @(posedge CLK);

    $display("Testing Finished\n");
    $finish;
  end

endmodule
