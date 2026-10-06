/* SPDX-License-Identifier: BSD-3-Clause */
#ifndef _MACHINE_FENV_H_
#define _MACHINE_FENV_H_

/* GCC STM8 soft-fp uses fixed round-to-nearest and does not maintain
   floating exception flags.  Match the existing soft-float fenv API. */
#define __FLOAT_NOEXCEPT
#define __DOUBLE_NOEXCEPT
#define __LONG_DOUBLE_NOEXCEPT
#define __FLOAT_NOROUND
#define __DOUBLE_NOROUND
#define __LONG_DOUBLE_NOROUND
#define FE_TONEAREST 0

_BEGIN_STD_C
typedef int fenv_t;
typedef int fexcept_t;
_END_STD_C

#if !defined(__declare_fenv_inline) && defined(__declare_extern_inline)
#define __declare_fenv_inline(type) __declare_extern_inline(type)
#endif
#ifdef __declare_fenv_inline
#include <machine/fenv-softfloat.h>
#endif
#endif
