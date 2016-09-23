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
*   Filename:     quicksort.c
*
*   Created by:   John Skubic 
*   Email:        jskubic@purdue.edu
*   Date Created: 09/21/2016
*   Description:  Quicksort algorithm
*/

#include "../../c-firmware/c_self_test.h"

#define CRC_POLY 0xedb88320
#define SEED 0x32
#define ARR_LENGTH 100

int crc32(int crc_in);
void qsort(int lb, int ub, int *arr);
int partition(int lb, int ub, int *arr);
void swap(int ptr1, int ptr2, int *arr);

int main(void)
{
  int data[ARR_LENGTH];
  int i;
  int rand_val;

  //generate pseudorandom data
  rand_val = SEED;
  for(i = 0; i < ARR_LENGTH; i++) {
    rand_val = crc32(rand_val);
    data[i] = rand_val;
  }

  //run quicksort
  qsort(0, ARR_LENGTH-1, data);

  //evaluate correctness
  for(i = 1; i < ARR_LENGTH;i++) {
    if(data[i-1] > data[i])
      TEST_FINISH_FAIL(1)
  }
  TEST_FINISH_SUCCESS
}

void qsort(int lb, int ub, int *arr) {
  int q;
  if(lb < ub) {
    q = partition(lb, ub, arr);
    qsort(lb, q-1, arr);
    qsort(q+1, ub, arr);
  }
}

int partition(int lb, int ub, int *arr) {
  int pivot;
  int currPtr = lb;
  int smallPtr = lb-1;
  int mid = (lb + ub) >> 1; // divide by 2
  
  //choose the median of three pivots
  if(arr[lb] < arr[ub]){
    if(arr[lb] > arr[mid]){
      swap(lb, ub, arr);
    }
    else if (arr[ub] > arr[mid]) {
      swap(ub, mid, arr);
    }
  }
  else{ 
    if(arr[ub] < arr[mid]){
      swap(ub, mid, arr);
    }
    else if (arr[lb] < arr[mid]){
      swap(lb, ub, arr);
    }
  }
  
  pivot = arr[ub];
  
  for(currPtr = lb; currPtr < ub; currPtr++){
    if(arr[currPtr] <= pivot){
      smallPtr++;
      swap(smallPtr, currPtr, arr);
    }
  }
  smallPtr++;
  swap(smallPtr, ub, arr);
  
  return smallPtr; // holds the value of q 
}

void swap(int ptr1, int ptr2, int *arr) {
  int temp = arr[ptr1];
  arr[ptr1] = arr[ptr2];
  arr[ptr2] = temp;
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
