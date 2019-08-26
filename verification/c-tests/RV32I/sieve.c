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
*   Filename:     sieve.c
*
*   Created by:   Jacob R. Stevens
*   Email:        steven69@purdue.edu
*   Date Created: 09/17/2016
*   Description:  A simple sieve that finds primes in 2-1000
*/

#include "../../c-firmware/c_self_test.h"
#define SIEVE_LENGTH 50
int main(void)
{
  char primes[SIEVE_LENGTH];
  char golden_primes[SIEVE_LENGTH];
  int golden_prime_vals[SIEVE_LENGTH];

  /* Trying to assign all at one time leads to a call to
  *  memcpy by the compiler, which isn't implemented */
  golden_prime_vals[0] = 2;
  golden_prime_vals[1] = 3;
  golden_prime_vals[2] = 5;
  golden_prime_vals[3] = 7;
  golden_prime_vals[4] = 11;
  golden_prime_vals[5] = 13;
  golden_prime_vals[6] = 17;
  golden_prime_vals[7] = 19;
  golden_prime_vals[8] = 23;
  golden_prime_vals[9] = 29;
  golden_prime_vals[10] = 31;
  golden_prime_vals[11] = 37;
  golden_prime_vals[12] = 41;
  golden_prime_vals[13] = 43;
  golden_prime_vals[14] = 47;
  
  primes[0] = -1;
  primes[1] = -1;
  golden_primes[0] = -1;
  golden_primes[1] = -1;

  // Set up the golden model
  for (int i = 2; i < SIEVE_LENGTH; i++)
    golden_primes[i] = 0; 
  for (int i = 0; i < 15; i++)
    golden_primes[golden_prime_vals[i]] = 1;

  // Set all primes to true to begin with
  for (int i = 2; i < SIEVE_LENGTH; i++)
    primes[i] = 1; 

  for (int i = 2; i < SIEVE_LENGTH; i++)
    if (primes[i])
      for(int j = i; i*j < SIEVE_LENGTH; j++)
        primes[i*j] = 0;

  for (int i = 2; i < SIEVE_LENGTH; i++)
    if (primes[i] != golden_primes[i])
      TEST_FINISH_FAIL(1)
  TEST_FINISH_SUCCESS
  //DEFINE_HOST
}
