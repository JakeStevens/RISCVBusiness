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
*   Filename:     src/endian_swapper.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 06/14/2016
*   Description:  Swaps the endianess of the input word
*/

import rv32i_types_pkg::*;
module endian_swapper (
  input word_t word_in,
  output word_t word_out
);

  generate
    genvar i;
    for(i=0; i < (WORD_SIZE / 8); i++) begin : word_assign
      assign word_out[WORD_SIZE - (8*i) - 1 : WORD_SIZE - (8 * (i+1))] = word_in[((i+1)*8)-1:(i*8)];
    end : word_assign
  endgenerate

endmodule
