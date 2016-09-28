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
*   Filename:     print.c
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 09/27/2016
*   Description: Simple print functions for debug/testing purposes 
*/
#include "print.h"
#include <stdint.h>
#define PRINT_PORT (*((volatile uint32_t *) 0x0000))

void print_str(char *str)
{
  while (*str != '\0')
    PRINT_PORT = *(str++);
}

void print_char(char c)
{
  PRINT_PORT = c;
}
