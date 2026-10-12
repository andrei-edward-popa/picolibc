/* Copyright (c) 2026 Andrei-Edward Popa
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "stm8-string.h"

    .section .text.strcmp, "ax", @progbits
    .global _strcmp
    .type _strcmp, @function
_strcmp:
    STM8_CFI_START
    ldw y, (STM8_ARG, sp)
.Lcompare:
    ld a, (x)
    cp a, (y)
    jrne .Ldifferent
    tnz a
    jreq .Lequal
    incw x
    incw y
    jra .Lcompare
.Lequal:
    clrw x
    STM8_RETURN 2
.Ldifferent:
    ldw x, #1
    jrnc .Lreturn
    negw x
.Lreturn:
    STM8_RETURN 2
    .cfi_endproc
    .size _strcmp, .-_strcmp
