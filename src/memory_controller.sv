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
*   Filename:     memory_controller.sv
*   
*   Created by:   John Skubic
*   Modified by:  Chuan Yean Tan
*   Email:        jskubic@purdue.edu , tan56@purdue.edu
*   Date Created: 09/12/2016
*   Description:  Memory controller and arbitration between instruction
*                 and data accesses
*/

`include "ram_if.vh"

module memory_controller (
  input logic CLK, nRST,
  ram_if.ram d_ram_if,
  ram_if.ram i_ram_if,
  ram_if.cpu out_ram_if
);

  //Arbitration - give precedence to data transactions
  //always_comb begin
  //  if (d_ram_if.wen || d_ram_if.ren) begin
  //    out_ram_if.wen      = d_ram_if.wen;
  //    out_ram_if.ren      = d_ram_if.ren;
  //    out_ram_if.addr     = d_ram_if.addr;
  //    d_ram_if.busy       = out_ram_if.busy;
  //    i_ram_if.busy       = 1'b1;
  //    out_ram_if.byte_en  = d_ram_if.byte_en;
  //  end else begin
  //    out_ram_if.wen      = i_ram_if.wen;
  //    out_ram_if.ren      = i_ram_if.ren;
  //    out_ram_if.addr     = i_ram_if.addr;
  //    d_ram_if.busy       = 1'b1;
  //    i_ram_if.busy       = out_ram_if.busy;
  //    out_ram_if.byte_en  = i_ram_if.byte_en;
  //  end
  //end

 
  /* State Declaration */ 
  typedef enum { 
                    IDLE, 
                    INSTR_REQ ,
                    INSTR_WAIT, 
                    DATA_REQ ,
                    DATA_INSTR_REQ ,
                    DATA_WAIT
                    } state_t; 

  state_t current_state, next_state; 

  always_ff @ (posedge CLK, negedge nRST) 
  begin 
    if (nRST == 0) 
      current_state <= IDLE; 
    else 
      current_state <= next_state; 
  end 

  /* State Transition Logic */ 
  always_comb 
  begin 
    case(current_state) 
      IDLE: begin
        if(d_ram_if.ren || d_ram_if.wen) 
          next_state = DATA_REQ; 
        else if(i_ram_if.ren) 
          next_state = INSTR_REQ; 
        else 
          next_state = IDLE; 
      end 

      INSTR_REQ: begin 
        if( (d_ram_if.ren || d_ram_if.wen) && !out_ram_if.busy) 
          next_state = DATA_WAIT; 
        else 
          next_state = INSTR_WAIT; 
      end

      DATA_REQ: begin 
        next_state = DATA_INSTR_REQ; 
      end

      DATA_INSTR_REQ: begin 
        if( out_ram_if.busy == 1'b0 ) 
          next_state = INSTR_WAIT; 
        else 
          next_state = DATA_INSTR_REQ; 
      end 

      INSTR_WAIT: begin 
        if ( out_ram_if.busy == 1'b0 ) 
            next_state = IDLE; 
        else 
            next_state = INSTR_WAIT; 
      end 

      DATA_WAIT: begin 
        if ( out_ram_if.busy == 1'b0 ) 
            next_state = IDLE; 
        else 
            next_state = INSTR_WAIT; 
      end 

      default: next_state = IDLE; 
    endcase 
  end 

  /* State Output Logic */ 
  always_comb 
  begin 
    case(current_state) 
      IDLE: begin 
        out_ram_if.wen      = 0;  
        out_ram_if.ren      = 0;  
        out_ram_if.addr     = 0;  
        d_ram_if.busy       = 1'b1;
        i_ram_if.busy       = 1'b1;
        out_ram_if.byte_en  = d_ram_if.byte_en;
      end

      //-- INSTRUCTION REQUEST --// 
      INSTR_REQ: begin 
        out_ram_if.wen      = i_ram_if.wen;
        out_ram_if.ren      = i_ram_if.ren;
        out_ram_if.addr     = i_ram_if.addr;
        d_ram_if.busy       = 1'b1;
        i_ram_if.busy       = out_ram_if.busy;
        out_ram_if.byte_en  = d_ram_if.byte_en;
      end 
      INSTR_WAIT: begin 
        out_ram_if.wen      = 0;  
        out_ram_if.ren      = 0;  
        out_ram_if.addr     = 0;  
        d_ram_if.busy       = 1'b1;
        i_ram_if.busy       = out_ram_if.busy;
        out_ram_if.byte_en  = d_ram_if.byte_en;
      end 

      //-- DATA REQUEST --//
      DATA_REQ: begin 
        out_ram_if.wen      = d_ram_if.wen;
        out_ram_if.ren      = d_ram_if.ren;
        out_ram_if.addr     = d_ram_if.addr;
        d_ram_if.busy       = out_ram_if.busy;
        i_ram_if.busy       = 1'b1;
        out_ram_if.byte_en  = d_ram_if.byte_en;
      end 
      DATA_INSTR_REQ: begin 
        out_ram_if.wen      = i_ram_if.wen;
        out_ram_if.ren      = i_ram_if.ren;
        out_ram_if.addr     = i_ram_if.addr;
        d_ram_if.busy       = out_ram_if.busy;
        i_ram_if.busy       = 1'b1;
        out_ram_if.byte_en  = d_ram_if.byte_en;
      end 
      DATA_WAIT: begin 
        out_ram_if.wen      = d_ram_if.wen;
        out_ram_if.ren      = d_ram_if.ren;
        out_ram_if.addr     = d_ram_if.addr;
        d_ram_if.busy       = 1'b1;
        i_ram_if.busy       = out_ram_if.busy;
        out_ram_if.byte_en  = d_ram_if.byte_en;
      end 
    endcase 
  end 

  /*  align the byte enable with the data being selected 
      based on the byte addressing */
  always_comb begin
    casez (out_ram_if.byte_en)
      4'hf, 4'h1, 4'h3  : out_ram_if.wdata = d_ram_if.wdata;      
      4'h2              : out_ram_if.wdata = d_ram_if.wdata << 8;
      4'h4, 4'hc        : out_ram_if.wdata = d_ram_if.wdata << 16;
      4'h8              : out_ram_if.wdata = d_ram_if.wdata << 24;
    endcase
  end

  assign d_ram_if.rdata   = out_ram_if.rdata;
  assign i_ram_if.rdata   = out_ram_if.rdata;

endmodule
