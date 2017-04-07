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
*   Filename:     crc32.c
*
*   Created by:   John Skubic
*   Email:        jskubic@purdue.edu
*   Date Created: 09/16/2016
*   Description:  CRC32 C test
*/

#include "../../c-firmware/c_self_test.h"
#include "../../c-firmware/custom_instruction_calls.h"

#define CRC32_RESET 0
#define CRC32_CALC  1

int main(void) { 
  char data[5] = {0xa1, 0xb4, 0xc3, 0x20, 0x05}; 
  unsigned int temp;
  unsigned int result;
  int i;

  //perform test operation

  CALL_CUSTOM_INSTRUCTION_R_TYPE(crc32, CRC32_RESET, temp, temp, result)
  for (i=0; i < 5; i++) {
    temp = (unsigned int)data[i];
    CALL_CUSTOM_INSTRUCTION_R_TYPE(crc32, CRC32_CALC, temp, temp, result)
  }

  //check if memory is as expected
  if(result == 0x6F7260C2) {
    TEST_FINISH_SUCCESS
  }
  // report failing test case
  TEST_FINISH_FAIL(1)
}
