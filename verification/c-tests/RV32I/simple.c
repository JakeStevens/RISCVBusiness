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
*   Filename:     simple.c
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 09/16/2016
*   Description:  Example C test
*/

#include "../../c-firmware/c_self_test.h"
 
int main(void) { 
  int a=6;
  int b=3; 
  int c;

  //perform test operation
  c = a+b;

  //check if memory is as expected
  if(c == 9) {
    TEST_FINISH_SUCCESS
  }
  // report failing test case
  TEST_FINISH_FAIL(1)
}
