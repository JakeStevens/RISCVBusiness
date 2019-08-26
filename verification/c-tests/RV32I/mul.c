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
*   Filename:     mul.c
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 09/16/2016
*   Description:  Multiplication c test.  Tests hardware if mul extension is
*                 implemented, or tests software multiply trap handler
*/

#include "../../c-firmware/c_self_test.h"
 
int main(void) {
  int a=6;
  int b=3; 
  int c, d;

  //perform test operation
  c = a*b;
  d = 2*c;

  //check if memory is as expected
  if(d == 36) {
    TEST_FINISH_SUCCESS
  }
  TEST_FINISH_FAIL(1)
}
