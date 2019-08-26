/*
* Copyright (c) 2012-2015, The Regents of the University of California (Regents).
* All Rights Reserved.
* 
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
* 1. Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
* 3. Neither the name of the Regents nor the
*    names of its contributors may be used to endorse or promote products
*    derived from this software without specific prior written permission.
* 
* IN NO EVENT SHALL REGENTS BE LIABLE TO ANY PARTY FOR DIRECT, INDIRECT,
* SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST PROFITS, ARISING
* OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF REGENTS HAS
* BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* 
* REGENTS SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
* THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
* PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY, PROVIDED
* HEREUNDER IS PROVIDED "AS IS". REGENTS HAS NO OBLIGATION TO PROVIDE
* MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
*/

#ifndef _ENV_SIMPLE_PHYSICAL_SINGLE_CORE_H
#define _ENV_SIMPLE_PHYSICAL_SINGLE_CORE_H

#include "../encoding.h"

//-----------------------------------------------------------------------
// Text Section Macro
//-----------------------------------------------------------------------


#define RVTEST_CODE_BEGIN   \
  .text;                    \
  .align  6; \
  .globl _start;          \
_start:
  

#define RVTEST_CODE_END \
  la x1, tohost; \
  li x2, 1; \
  sw x2, 0(x1); \
  1:  \
  j 1b

#define RVTEST_INTVEC_USER_BEGIN \
  .align ;                 
 
#define RVTEST_INTVEC_SUPER_BEGIN \
  .align ;            

#define RVTEST_INTVEC_HYPER_BEGIN \
  .align ;           

#define RVTEST_INTVEC_MACH_BEGIN \
  .align ;           
//-----------------------------------------------------------------------
// Data Dump Section Macro
//-----------------------------------------------------------------------


#define RVTEST_DATA_DUMP_BEGIN .align 4; .global begin_signature; begin_signature:

#define RVTEST_DATA_DUMP_END  .align 4; .global end_signature; end_signature: \
  .section .statuses; \
  .global tohost; tohost: .word 0; \
  .global fromhost; fromhost: .word 0;


#endif
