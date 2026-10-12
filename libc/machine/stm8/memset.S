/* Copyright (c) 2026 Andrei-Edward Popa
 * SPDX-License-Identifier: BSD-3-Clause
 */

#include "stm8-string.h"

    .section .text.memset, "ax", @progbits
    .global _memset
    .type _memset, @function
_memset:
    STM8_CFI_START
    pushw x
    .cfi_adjust_cfa_offset 2
    ldw y, (STM8_ARG + 4, sp)
    jreq .Lreturn
    ld a, (STM8_ARG + 3, sp)
.Lfill:
    ld (x), a
    incw x
    decw y
    jrne .Lfill
.Lreturn:
    popw x
    .cfi_adjust_cfa_offset -2
    STM8_RETURN 4
    .cfi_endproc
    .size _memset, .-_memset
