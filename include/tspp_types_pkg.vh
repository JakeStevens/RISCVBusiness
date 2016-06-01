/*
*		Copyright 2016 Purdue University
*		
*		Licensed under the Apache License, Version 2.0 (the "License");
*		you may not use this file except in compliance with the License.
*		You may obtain a copy of the License at
*		
*		    http://www.apache.org/licenses/LICENSE-2.0
*		
*		Unless required by applicable law or agreed to in writing, software
*		distributed under the License is distributed on an "AS IS" BASIS,
*		WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*		See the License for the specific language governing permissions and
*		limitations under the License.
*
*
*		Filename:			tspp_types_pkg.vh
*
*		Created by:	  Jacob R. Stevens	
*		Email:				steven69@purdue.edu
*		Date Created:	06/01/2016
*		Description:	Package containing types used in the two stage pipeline
*		              implementation.
*/

`ifndef TSPP_TYPES_PKG_VH
`define TSPP_TYPES_PKG_VH

// include the packages needed for TSPP
`include "rv32i_types_pkg"

package tspp_types_pkg;
  // import those packages
  import rv32i_types_pkg::*;
endpackage
`endif
