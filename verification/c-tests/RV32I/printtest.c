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
*   Filename:     printtest.c
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 09/27/2016
*   Description:  Exercise the functionality from print.c
*/

#include "../../c-firmware/print.h"
#include "../../c-firmware/c_self_test.h"
int main(void)
{
  print_str("Hello world!\nFrom Yosemite.\n");
  print_char('c');
  print_char('h');
  print_char('a');
  print_char('r');
  print_char('\n');
  TEST_FINISH_SUCCESS
  return 0;
}
