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

  //-- State Declaration --// 
  parameter [2:0] IDLE = 3'b000,
                  READ_DATA = 3'b001, 
                  READ_DATA_WAIT = 3'b010,
                  WRITE_DATA = 3'b011, 
                  WRITE_DATA_WAIT = 3'b100; 

  reg [2:0] current_state, next_state; 

  always_ff @ (posedge CLK, negedge nRST) 
  begin 
    if (nRST == 0) 
      current_state <= IDLE;
    else 
      current_state <= next_state; 
  end 

  //-- State Transition Logic --// 
  always_comb 
  begin 
     case(current_state) 
        IDLE: begin 
          if(out_ram_if.ren) 
            next_state = READ_DATA; 
          else if (out_ram_if.wen) 
            next_state = WRITE_DATA; 
          else 
            next_state = IDLE; 
        end 

        READ_DATA: begin 
          if(!ahb_m.HREADY)
            next_state = READ_DATA_WAIT; 
          else if (ahb_m.HREADY && out_ram_if.ren) 
            next_state = READ_DATA; 
          else 
            next_state = IDLE; 
        end 

        READ_DATA_WAIT: begin
          if(!ahb_m.HREADY) 
            next_state = READ_DATA_WAIT; 
          else if (ahb_m.HEADY && out_ram_if.ren) 
            next_state = READ_DATA; 
          else 
            next_state = IDLE; 
        end 

        WRITE_DATA: begin 
          if(!ahb_m.HREADY)
            next_state = WRITE_DATA_WAIT; 
          else if (ahb_m.HREADY && !out_ram_if.wen) 
            next_state = WRITE_DATA; 
          else 
            next_state = IDLE; 
        end 


        WRITE_DATA_WAIT: begin 
          if(!ahb_m.HREADY) 
            next_state = WRITE_DATA_WAIT; 
          else if (ahb_m.HEADY && out_ram_if.wen) 
            next_state = WRITE_DATA; 
          else 
            next_state = IDLE; 
        end 
         
        default: next_state = IDLE; 
     endcase 
  end 

  //-- AHB Master Output State Logic --// 
  always_comb
  begin 
    case(current_state) 
      IDLE: begin
        ahb_m.HTRANS = 0;  
        ahb_m.HWRITE = 0;  
        ahb_m.HADDR = 0;  
        ahb_m.HWDATA = 0;  
        ahb_m.HSIZE = 0;  
        ahb_m.HBURST = 0;  
        ahb_m.HPROT = 0;  
        ahb_m.HMASTLOCK = 0;  
      end 

      READ_DATA: begin 
        ahb_m.HTRANS = 2'b10;  
        ahb_m.HWRITE = 0;  
        ahb_m.HADDR = out_ram_if.addr;  
        ahb_m.HWDATA = 0;  
        ahb_m.HSIZE = 3'b010;  
        ahb_m.HBURST = 0;  
        ahb_m.HPROT = 0;  
        ahb_m.HMASTLOCK = 0;  

      end 

      READ_DATA_WAIT: begin 
        ahb_m.HTRANS = 2'b10;  
        ahb_m.HWRITE = 0;  
        ahb_m.HADDR = out_ram_if.addr; ;  
        ahb_m.HWDATA = 0;  
        ahb_m.HSIZE = 3'b010;  
        ahb_m.HBURST = 0;  
        ahb_m.HPROT = 0;  
        ahb_m.HMASTLOCK = 0;  

      end 

      WRITE_DATA: begin 
        ahb_m.HTRANS = 2'b10;  
        ahb_m.HWRITE = 1'b1;  
        ahb_m.HADDR = out_ram_if.addr;  
        ahb_m.HWDATA = out_ram_if.wdata;  
        ahb_m.HSIZE = 3'b010;  
        ahb_m.HBURST = 0;  
        ahb_m.HPROT = 0;  
        ahb_m.HMASTLOCK = 0;  
      end 

      WRITE_DATA_WAIT: begin 
        ahb_m.HTRANS = 2'b10;  
        ahb_m.HWRITE = 1'b1;  
        ahb_m.HADDR = out_ram_if.addr;  
        ahb_m.HWDATA = out_ram_if.wdata;  
        ahb_m.HSIZE = 3'b010;  
        ahb_m.HBURST = 0;  
        ahb_m.HPROT = 0;  
        ahb_m.HMASTLOCK = 0;  
      end 

    endcase 

  end

  assign out_ram_if.busy = ~ahb_m.HREADY;
  assign out_ram_if.rdata = ahb_m.HRDATA; 

endmodule
