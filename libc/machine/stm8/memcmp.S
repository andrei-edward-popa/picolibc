/* Copyright (c) 2026 Andrei-Edward Popa
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "stm8-string.h"

    .section .text.memcmp, "ax", @progbits
    .global _memcmp
    .type _memcmp, @function
_memcmp:
    STM8_CFI_START
    ldw y, (STM8_ARG + 2, sp)
    jreq .Lequal
    ldw y, (STM8_ARG, sp)
    STM8_COUNT STM8_ARG + 2
.Lcompare:
    ld a, (x)
    cp a, (y)
    jrne .Ldifferent
    incw x
    incw y
    dec (STM8_ARG + 3, sp)
    jrne .Lcompare
    dec (STM8_ARG + 2, sp)
    jrne .Lcompare
.Lequal:
    clrw x
    STM8_RETURN 4
.Ldifferent:
    ldw x, #1
    jrnc .Lreturn
    negw x
.Lreturn:
    STM8_RETURN 4
    .cfi_endproc
    .size _memcmp, .-_memcmp
