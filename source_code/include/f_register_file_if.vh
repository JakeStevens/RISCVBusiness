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
*   Filename:     f_register_file_if.vh
*   
*   Created by:   Sean Hsu	
*   Email:        hsu151@purdue.edu
*   Date Created: 02/24/2020
*   Description:  floating point register file header for the FPU; based on integer reg file header
*/

`ifndef F_REGISTER_FILE_IF_VH
`define F_REGISTER_FILE_IF_VH

interface f_register_file_if();

 // import rv32i_types_pkg::*;

  logic [31:0]        f_w_data, f_rs1_data, f_rs2_data;
  logic   [4:0] f_rs1, f_rs2, f_rd;
  logic         f_wen, f_NV, f_DZ, f_OF, f_UF, f_NX;
  logic [2:0] f_frm_in;
  logic [2:0] f_frm_out;
  logic [4:0] f_flags;

  modport rf (
    input f_w_data, f_rs1, f_rs2, f_rd, f_wen, f_NV, f_DZ, f_OF, f_UF, f_NX, f_frm_in, 
    output f_rs1_data, f_rs2_data, f_frm_out, f_flags
  );



endinterface

`endif //F_REGISTER_FILE_IF_VH

