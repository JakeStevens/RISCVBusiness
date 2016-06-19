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
*   Filename:     branch_predictor.sv
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 06/19/2016
*   Description:  Branch Predictor, BTB, RAS
*                 Predictor is not implemented.  This will be left as an
*                 "always not taken" predictor until it is implemented.
*/

`include "predictor_pipeline_if.vh"

module branch_predictor (
  input logic CLK, nRST,
  predictor_pipeline_if.predictor predict_if
);


endmodule
