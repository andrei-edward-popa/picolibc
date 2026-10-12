/* Copyright (c) 2026 Andrei-Edward Popa
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "stm8-string.h"

    .section .text.strlen, "ax", @progbits
    .global _strlen
    .type _strlen, @function
_strlen:
    STM8_CFI_START
    pushw x
    .cfi_adjust_cfa_offset 2
.Llength:
    tnz (x)
    jreq .Lreturn
    incw x
    jra .Llength
.Lreturn:
    subw x, (1, sp)
    addw sp, #2
    STM8_RETURN 0
    .cfi_endproc
    .size _strlen, .-_strlen
