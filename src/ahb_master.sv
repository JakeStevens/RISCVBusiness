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
*   Filename:    ahb_master.sv 
*   
*   Created by:   Chuan Yean Tan
*   Email:        tan56@purdue.edu
*   Date Created: 08/31/2016
*   Description: Processes read & write request into AHB-Lite protocol 
*   TODO: 1. HRESP -> has to be added to the state transitions                
*/

`include "ram_if.vh"
`include "ahb_if.vh"

module ahb_master (
  input CLK, nRST,
  ahb_if.ahb_m ahb_m,
  ram_if.ram out_ram_if
);


  always_comb 
  begin 
          //-- Read Request --// 
          if ( out_ram_if.ren ) 
          begin
                ahb_m.HTRANS = 2'b10;  
                ahb_m.HWRITE = 1'b0;  
                ahb_m.HADDR = out_ram_if.addr;  
                ahb_m.HWDATA = out_ram_if.wdata;  
                ahb_m.HSIZE = 3'b010;  
                ahb_m.HBURST = 0;  
                ahb_m.HPROT = 0;  
                ahb_m.HMASTLOCK = 0; 
          end 
          //-- Write Request --// 
          else if ( out_ram_if.wen ) 
          begin 
                ahb_m.HTRANS = 2'b10;  
                ahb_m.HWRITE = 1'b1;  
                ahb_m.HADDR = out_ram_if.addr;  
                ahb_m.HWDATA = out_ram_if.wdata;  
                ahb_m.HSIZE = 3'b010;  
                ahb_m.HBURST = 0;  
                ahb_m.HPROT = 0;  
                ahb_m.HMASTLOCK = 0;  
          end
          //-- Default : Not reading / writing --// 
          else 
          begin 
                ahb_m.HTRANS = 2'b00;  
                ahb_m.HWRITE = 1'b0;  
                ahb_m.HADDR = 0; 
                ahb_m.HWDATA = 0;  
                ahb_m.HSIZE = 3'b000;  
                ahb_m.HBURST = 0;  
                ahb_m.HPROT = 0;  
                ahb_m.HMASTLOCK = 0;  
          end 
  end 

  assign out_ram_if.busy = ~ahb_m.HREADY;
  assign out_ram_if.rdata = ahb_m.HRDATA; 

endmodule
