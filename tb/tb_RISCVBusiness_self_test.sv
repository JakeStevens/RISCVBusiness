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
*   Filename:		  tb_RISCVBusiness_self_test.sv	
*   
*   Created by:		John Skubic
*   Email:				jskubic@purdue.edu
*   Date Created:	06/01/2016
*   Description:	Testbench for running RISCVBusiness until a halt condition.
*                 The test bench monitors memory location 0x1000 and prints
*                 the char representation of what is written.   
*/


`include "ram_if.vh"

`define OUTPUT_FILE_NAME "cpu.hex"
`define CLK_TIMEOUT 1000000

module tb_RISCVBusiness_self_test ();
   
  parameter PERIOD = 20;
 
  logic CLK, nRST;
  logic ram_control; // 1 -> CORE, 0 -> TB
  logic halt;
  logic [31:0] addr, data;
  logic [63:0] hexdump_temp;
  logic [7:0] checksum;
  integer fptr;
  integer clk_count;

  //Interface Instantiations
  ram_if ram_if();
  ram_if rvb_ram_if();
  ram_if tb_ram_if();

  //Module Instantiations

  RISCVBusiness DUT (
    .CLK(CLK),
    .nRST(nRST),
    .halt(halt),
    .ram_if(rvb_ram_if)
  );

  ram_wrapper ram (
    .CLK(CLK),
    .nRST(nRST),
    .ram_if(ram_if)
  );

  bind execute_stage cpu_tracker cpu_track1 (
    .CLK(CLK),
    .wb_stall(hazard_if.if_ex_stall & ~hazard_if.jump & ~hazard_if.branch),
    .instr(fetch_ex_if.fetch_ex_reg.instr),
    .pc(fetch_ex_if.fetch_ex_reg.pc),
    .opcode(cu_if.opcode),
    .funct3(cu_if.instr[14:12]),
    .funct12(cu_if.instr[31:20]),
    .rs1(rf_if.rs1),
    .rs2(rf_if.rs2),
    .rd(rf_if.rd),
    .imm_S(cu_if.imm_S),
    .imm_I(cu_if.imm_I),
    .imm_U(cu_if.imm_U),
    .imm_UJ(cu_if.imm_UJ),
    .imm_SB(cu_if.imm_SB),
    .instr_30(fetch_ex_if.fetch_ex_reg.instr[30])
    );
     

  //Ramif Mux
  always_comb begin
    if(ram_control) begin
      ram_if.addr    =   rvb_ram_if.addr;
      ram_if.ren     =   rvb_ram_if.ren;
      ram_if.wen     =   rvb_ram_if.wen;
      ram_if.wdata   =   rvb_ram_if.wdata;
      ram_if.byte_en = rvb_ram_if.byte_en;
    end else begin
      ram_if.addr    =   tb_ram_if.addr;
      ram_if.ren     =   tb_ram_if.ren;
      ram_if.wen     =   tb_ram_if.wen;
      ram_if.wdata   =   tb_ram_if.wdata;
      ram_if.byte_en = tb_ram_if.byte_en;
    end
  end

  assign rvb_ram_if.rdata  = ram_if.rdata;
  assign rvb_ram_if.busy   = ram_if.busy;
  assign tb_ram_if.rdata   = ram_if.rdata;
  assign tb_ram_if.busy    = ram_if.busy;

  //Clock generation
  initial begin : INIT
    CLK = 0;
  end : INIT

  always begin : CLOCK_GEN
    #(PERIOD/2) CLK = ~CLK;
  end : CLOCK_GEN

  //Setup core and let it run
  initial begin : CORE_RUN
    nRST = 0;
    ram_control = 1;
    clk_count = 0;
 
    @(posedge CLK);
    @(posedge CLK);

    nRST = 1;
    
    while (halt == 0 && clk_count != `CLK_TIMEOUT) begin
      @(posedge CLK);
      clk_count++;
    end

    dump_stats();
    dump_ram();

    // Check Register 28 to see if test passed or failed
    if (clk_count == `CLK_TIMEOUT)
      $display("ERROR: Test timed out");
    else if(DUT.pipeline.execute_stage_i.rf.registers[28] != 32'h1)
      $display("ERROR: Test %0d did not pass",
                (DUT.pipeline.execute_stage_i.rf.registers[28] - 1)/2);
    else 
      $display("SUCCESS");
    $finish;

  end : CORE_RUN

  task dump_stats();
    //TODO: Print this to a file?
    //stats_ptr = $fopen(`STATS_FILE_NAME, "w");
    integer instret, cycles;
    instret = DUT.pipeline.prv_block_i.csr_rfile_i.instretfull;
    cycles  = DUT.pipeline.prv_block_i.csr_rfile_i.cyclefull;
    assert (cycles == clk_count) else $error("Cycles CSR != clk_count");
    $display("Instructions retired: %2d", instret);
    $display("Cycles taken: %2d", cycles);
    $display("CPI: %5f", real'(cycles)/instret);
    $display("IPC: %5f", real'(instret)/cycles);
  endtask

  task dump_ram ();
    ram_control = 0;
    tb_ram_if.addr = 0;
    tb_ram_if.ren = 0;
    tb_ram_if.wen = 0;
    tb_ram_if.wdata = 0;
    tb_ram_if.byte_en = 4'hf;

    fptr = $fopen(`OUTPUT_FILE_NAME, "w");

    for(addr = 32'h100; addr < 32'h2000; addr+=4) begin
      read_ram(addr, data);
      hexdump_temp = {8'h04, addr[15:0]>>2, 8'h00, data};
      checksum = calculate_crc(hexdump_temp);
      if(data != 0)
        $fwrite(fptr, ":%2h%4h00%8h%2h\n", 8'h4, addr[15:0]>>2, data, checksum);
    end
    // add the EOL entry to the file
    $fwrite(fptr, ":00000001FF");  

  endtask

  task read_ram (input logic [31:0] raddr, output logic [31:0] rdata);
    @(posedge CLK);
    tb_ram_if.addr = raddr;
    tb_ram_if.ren = 1;
    @(posedge CLK);
    while(tb_ram_if.busy == 1) @(posedge CLK);
    rdata = tb_ram_if.rdata;
    tb_ram_if.ren = 0;
  endtask

  function [7:0] calculate_crc (logic [63:0] hex_line);
    static logic [7:0] checksum = 0;
    int i;

    checksum = hex_line[7:0] + hex_line[15:8] + hex_line[23:16] +
                hex_line[31:24] + hex_line[39:32] + hex_line[47:40] +
                hex_line[55:48] + hex_line[63:56];
    
    //take two's complement
    checksum = (~checksum) + 1;
    return checksum;
  endfunction

endmodule
