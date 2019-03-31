/*
*   Copyright 2019 Purdue University
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
*   Filename:     sparce_enabled.sv
*
*   Created by:   Vadim V. Nikiforov 
*   Email:        vnikifor@purdue.edu
*   Date Created: 04/29/2019
*   Description:  The top level file for sparsity enabled for the CPU
*/

`include "sparce_pipeline_if.vh"

module sparce_enabled(
  input logic CLK, nRST,
  sparce_pipeline_if.sparce sparce_if
);

  // all inputs are to be ignored
  assign sparce_if.skipping = 1'b0;
  assign sparce_if.sparce_target = '1;


endmodule
