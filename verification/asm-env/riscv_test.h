
#ifndef _ENV_SIMPLE_PHYSICAL_SINGLE_CORE_H
#define _ENV_SIMPLE_PHYSICAL_SINGLE_CORE_H

//-----------------------------------------------------------------------
// Data Dump Section Macro
//-----------------------------------------------------------------------

#define RVTEST_DATA_DUMP_BEGIN .align 4; .global begin_signature; begin_signature:

#define RVTEST_DATA_DUMP_END  .align 4; .global end_signature; end_signature:

//-----------------------------------------------------------------------
// Text Section Macro
//-----------------------------------------------------------------------

#define RVTEST_CODE_BEGIN .align 6; .global _start; _start:

#define RVTEST_CODE_END csrw mtohost, 1; \
  1:  \
  j 1b

#endif
