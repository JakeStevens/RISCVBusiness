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
#define ARR_LENGTH 100
void swap(int *x, int *y)
{
  int temp = *x;
  *x = *y;
  *y = temp;
  return;
}

int main(void)
{
  int arr[ARR_LENGTH];

  arr[0] = -79;
  arr[1] = -96;
  arr[2] = 13;
  arr[3] = 60;
  arr[4] = -76;
  arr[5] = -70;
  arr[6] = -11;
  arr[7] = -6;
  arr[8] = 20;
  arr[9] = -68;
  arr[10] = -11;
  arr[11] = -18;
  arr[12] = 9;
  arr[13] = 87;
  arr[14] = 97;
  arr[15] = -100;
  arr[16] = -32;
  arr[17] = 67;
  arr[18] = -63;
  arr[19] = -70;
  arr[20] = 88;
  arr[21] = -17;
  arr[22] = 65;
  arr[23] = 29;
  arr[24] = -87;
  arr[25] = -20;
  arr[26] = 39;
  arr[27] = -25;
  arr[28] = -66;
  arr[29] = 39;
  arr[30] = -92;
  arr[31] = -10;
  arr[32] = 43;
  arr[33] = -57;
  arr[34] = -22;
  arr[35] = -31;
  arr[36] = 69;
  arr[37] = 53;
  arr[38] = 82;
  arr[39] = 16;
  arr[40] = -14;
  arr[41] = -96;
  arr[42] = -84;
  arr[43] = 83;
  arr[44] = 84;
  arr[45] = -82;
  arr[46] = -43;
  arr[47] = 99;
  arr[48] = 50;
  arr[49] = -99;
  arr[50] = 83;
  arr[51] = 10;
  arr[52] = 86;
  arr[53] = 54;
  arr[54] = 33;
  arr[55] = -32;
  arr[56] = -100;
  arr[57] = -65;
  arr[58] = -52;
  arr[59] = 81;
  arr[60] = 62;
  arr[61] = -90;
  arr[62] = -98;
  arr[63] = -44;
  arr[64] = 84;
  arr[65] = 6;
  arr[66] = 45;
  arr[67] = -6;
  arr[68] = 66;
  arr[69] = -19;
  arr[70] = -28;
  arr[71] = 72;
  arr[72] = -49;
  arr[73] = 94;
  arr[74] = -7;
  arr[75] = 74;
  arr[76] = 72;
  arr[77] = -34;
  arr[78] = 36;
  arr[79] = -82;
  arr[80] = -83;
  arr[81] = -27;
  arr[82] = 22;
  arr[83] = 24;
  arr[84] = 12;
  arr[85] = 91;
  arr[86] = -65;
  arr[87] = 78;
  arr[88] = -11;
  arr[89] = 100;
  arr[90] = -33;
  arr[91] = 0;
  arr[92] = -97;
  arr[93] = -23;
  arr[94] = 64;
  arr[95] = 97;
  arr[96] = -77;
  arr[97] = 77;
  arr[98] = -72;
  arr[99] = 29;


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
