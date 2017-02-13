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
*   Filename:     component_selection_defines.vh
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 12/01/2016
*   Description:  This file will eventuall be automatically generated 
*/

`ifndef COMPONENT_SELECTION_DEFINES_VH
`define COMPONENT_SELECTION_DEFINES_VH

localparam BR_PREDICTOR_TYPE  = "not_taken";
localparam DCACHE_TYPE        = "pass_through";
localparam ICACHE_TYPE        = "pass_through";
localparam CACHE_CONFIG       = "separate";
localparam BUS_ENDIANNESS     = "big";

/*  
 *  Only one of the BUS_INTERFACE defines should be uncommented 
 *  The parameter BUS_INTERFACE_TYPE should match the uncommented bus if
 */

//`define BUS_INTERFACE_AHB 
`define BUS_INTERFACE_GENERIC 
localparam BUS_INTERFACE_TYPE = "generic_bus_if";

/* RISC-MGMT Configurations */
`define NUM_EXTENSIONS 1
// Add RISC-MGMT Extensions here: 
// ADD_EXTENSION(<extension_name>,<extension_id>)
// ADD_EXTENSION_WITH_OPCODE(<extension_name>,<extension_id>,<extension_opcode>)
`define RISC_MGMT_EXTENSIONS \
  `ADD_EXTENSION_WITH_OPCODE(template,1,7'b000_1011)

`endif // COMPONENT_SELECTION_DEFINES_VH
