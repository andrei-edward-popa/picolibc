/* Copyright (c) 2026 Andrei-Edward Popa
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "stm8-string.h"

    .section .text.memmove, "ax", @progbits
    .global _memmove
    .type _memmove, @function
_memmove:
    STM8_CFI_START
    cpw x, (STM8_ARG, sp)
    jrule .Lforward
    ldw y, (STM8_ARG + 2, sp)
    jreq .Lreturn
    pushw x
    .cfi_adjust_cfa_offset 2
    addw x, (STM8_ARG + 4, sp)
    ldw y, (STM8_ARG + 2, sp)
    addw y, (STM8_ARG + 4, sp)
    STM8_COUNT STM8_ARG + 4
.Lcopy:
    decw x
    decw y
    ld a, (y)
    ld (x), a
    dec (STM8_ARG + 5, sp)
    jrne .Lcopy
    dec (STM8_ARG + 4, sp)
    jrne .Lcopy
    popw x
    .cfi_adjust_cfa_offset -2
.Lreturn:
    STM8_RETURN 4
.Lforward:
    jra _memcpy
    .cfi_endproc
    .size _memmove, .-_memmove
