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
*   Filename:     bubble.c
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 09/17/2016
*   Description:  BUBBLE SORT.
*/

#include "../../c-firmware/c_self_test.h"
#define CRC_POLY 0xedb88320
#define ARR_LENGTH 100
#define SEED 0x32

void swap(int *x, int *y)
{
  int temp = *x;
  *x = *y;
  *y = temp;
  return;
}

int crc32(int crc_in) {
  int j;

  for(j = 0; j < 8; j++) {
    if (crc_in & 1) 
      crc_in = (crc_in >> 1) ^ CRC_POLY;
    else 
      crc_in = crc_in >> 1;
  }
  return crc_in;
}

int main(void)
{
  int arr[ARR_LENGTH];
  // Generate pseudorandom data
  int rand_val = SEED;
  for (int i = 0; i < ARR_LENGTH; i++) {
    rand_val = crc32(rand_val);
    arr[i] = rand_val;
  }

  // Sort using bubble sort in ascending order
  for (int i = 0; i < ARR_LENGTH - 1; i++)
    for(int j = 0; j < ARR_LENGTH - i - 1; j++)
      if(arr[j] > arr[j+1])
        swap(&arr[j], &arr[j+1]);

  // Check to make sure it is sorted
  for (int i = 0; i < ARR_LENGTH - 1; i++)
    if(arr[i] > arr[i+1])
      TEST_FINISH_FAIL(1)
  TEST_FINISH_SUCCESS
}
