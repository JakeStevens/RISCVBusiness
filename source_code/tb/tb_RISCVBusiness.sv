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
*   Filename:		  tb_RISCVBusiness.sv	
*   
*   Created by:		John Skubic
*   Email:				jskubic@purdue.edu
*   Date Created:	06/01/2016
*   Description:	Testbench for running RISCVBusiness until a halt condition.
*                 A hexdump of memory will occur after the halt condition.
*/


`include "ram_if.vh"
`include "generic_bus_if.vh"
`include "component_selection_defines.vh"

`define OUTPUT_FILE_NAME "cpu.hex"
`define STATS_FILE_NAME "stats.txt"
`define CLK_TIMEOUT 10000

module tb_RISCVBusiness ();
   
  parameter PERIOD = 20;
 
  logic CLK, nRST;
  logic ram_control; // 1 -> CORE, 0 -> TB
  logic halt;
  logic [31:0] addr, data_temp, data;
  logic [63:0] hexdump_temp;
  logic [7:0] checksum;
  integer fptr, stats_ptr;
  integer clk_count;

  //Interface Instantiations
  ram_if ram_if();
  generic_bus_if rvb_gen_bus_if();
  ram_if tb_ram_if();

  //Module Instantiations

  RISCVBusiness DUT (
    .CLK(CLK),
    .nRST(nRST),
    .halt(halt),
    .gen_bus_if(rvb_gen_bus_if)
  );

  ram_wrapper ram (
    .CLK(CLK),
    .nRST(nRST),
    .ram_if(ram_if)
  );

  if (BUS_ENDIANNESS == "big")
    endian_swapper swap(data_temp, data);
  else if (BUS_ENDIANNESS == "little")
    assign data = data_temp;
  else ;//TODO:ERROR

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
    .imm_UJ({9'b0, cu_if.imm_UJ}),
    .imm_SB(cu_if.imm_SB),
    .instr_30(fetch_ex_if.fetch_ex_reg.instr[30])
    );

  bind branch_predictor branch_tracker branch_perf(
    .CLK(CLK),
    .nRST(nRST),
    .update_predictor(predict_if.update_predictor),
    .prediction(predict_if.prediction),
    .branch_result(predict_if.branch_result)
  );
     

  

  //Ramif Mux
  always_comb begin
    if(ram_control) begin
      /* No actual bus, so directly connect ram to generic bus interface */
      ram_if.addr    =   rvb_gen_bus_if.addr;
      ram_if.ren     =   rvb_gen_bus_if.ren;
      ram_if.wen     =   rvb_gen_bus_if.wen;
      ram_if.wdata   =   rvb_gen_bus_if.wdata;
      ram_if.byte_en =   rvb_gen_bus_if.byte_en;
    end else begin
      ram_if.addr    =   tb_ram_if.addr;
      ram_if.ren     =   tb_ram_if.ren;
      ram_if.wen     =   tb_ram_if.wen;
      ram_if.wdata   =   tb_ram_if.wdata;
      ram_if.byte_en = tb_ram_if.byte_en;
    end
  end

  /* No actual bus, so directly connect ram to generic bus interface */
  assign rvb_gen_bus_if.rdata  = ram_if.rdata;
  assign rvb_gen_bus_if.busy   = ram_if.busy;
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
      if (ram_if.addr == 16'h0000 & !ram_if.busy & ram_if.wen)
        $write("%c",ram_if.wdata[31:24]);
    end

    dump_stats();
    dump_ram();

    if (clk_count == `CLK_TIMEOUT) 
      $display("ERROR: Test timed out");

    $finish;

  end : CORE_RUN

  task dump_stats();
    integer instret, cycles;
    instret = DUT.pipeline.prv_block_i.csr_rfile_i.instretfull;
    cycles  = DUT.pipeline.prv_block_i.csr_rfile_i.cyclefull;
    assert (cycles == clk_count) else $error("Cycles CSR != clk_count");
    stats_ptr = $fopen(`STATS_FILE_NAME, "w");
    $fwrite(stats_ptr, "Instructions retired: %2d\n", instret);
    $fwrite(stats_ptr, "Cycles taken: %2d\n", cycles);
    $fwrite(stats_ptr, "CPI: %5f\n", real'(cycles)/instret);
    $fwrite(stats_ptr, "IPC: %5f\n", real'(instret)/cycles);
    $fclose(stats_ptr);
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
      read_ram(addr, data_temp);
      #(PERIOD/4);
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
