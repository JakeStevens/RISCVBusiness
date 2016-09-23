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
*   Filename:     array_test.c
*
*   Created by:   John Skubic 
*   Email:        jskubic@purdue.edu
*   Date Created: 09/21/2016
*   Description:  A test that verifies arrays are functional.
*/

#include "../../c-firmware/c_self_test.h"
#define ARR_LENGTH 100
int main(void)
{
  int array1[ARR_LENGTH];
  int array2[ARR_LENGTH];
  int array3[ARR_LENGTH];
  int i;

  for(i = 0; i < ARR_LENGTH;i++) {
    array1[i] = i;
    array2[i] = i*2;
    array3[i] = array1[i] + array2[i];
  }

  for(i = 0; i < ARR_LENGTH;i++) {
    if(array1[i] > array2[i])
      TEST_FINISH_FAIL(1)

    if(array2[i] > array3[i])
      TEST_FINISH_FAIL(2)
  }
  TEST_FINISH_SUCCESS
}
