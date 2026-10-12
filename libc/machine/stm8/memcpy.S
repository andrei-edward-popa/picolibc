/* Copyright (c) 2026 Andrei-Edward Popa
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "stm8-string.h"

    .section .text.memcpy, "ax", @progbits
    .global _memcpy
    .type _memcpy, @function
_memcpy:
    STM8_CFI_START
    ldw y, (STM8_ARG + 2, sp)
    jreq .Lreturn
    pushw x
    .cfi_adjust_cfa_offset 2
    ldw y, (STM8_ARG + 2, sp)
    STM8_COUNT STM8_ARG + 4
.Lcopy:
    ld a, (y)
    ld (x), a
    incw x
    incw y
    dec (STM8_ARG + 5, sp)
    jrne .Lcopy
    dec (STM8_ARG + 4, sp)
    jrne .Lcopy
    popw x
    .cfi_adjust_cfa_offset -2
.Lreturn:
    STM8_RETURN 4
    .cfi_endproc
    .size _memcpy, .-_memcpy
