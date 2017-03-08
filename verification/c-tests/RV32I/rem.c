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
*   Filename:     rem.c
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 09/21/2016
*   Description:  Remainder c test.  Tests hardware if mul extension is
*                 implemented, or tests software multiply trap handler
*/

#include "../../c-firmware/c_self_test.h"
 
int main(void) { 
  int a=28;
  int b=5; 
  int c;

  c = a%b;
  if(c != 3) 
    TEST_FINISH_FAIL(1) 

  a = -513;
  b = 10;
  c = a%b;
  if(c != -3) 
    TEST_FINISH_FAIL(2)  

  a = -31;
  b = -6;
  c = a%b;
  if(c != -1)
    TEST_FINISH_FAIL(3)

  //divide by zero
  a = 9;
  b = 0;
  c = a%b;
  if(c != 9)
    TEST_FINISH_FAIL(4)

  //overflow
  a = 0x80000000;
  b = -1;
  c = a%b;
  if(c != 0)
    TEST_FINISH_FAIL(5)

  TEST_FINISH_SUCCESS
}
