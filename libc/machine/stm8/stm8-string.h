/* Copyright (c) 2026 Andrei-Edward Popa
 * SPDX-License-Identifier: BSD-3-Clause
 */

#ifdef __STM8_LARGE__
    .stm8_model "large"
#define STM8_ARG 4
#else
    .stm8_model "medium"
#define STM8_ARG 3
#endif

/* CFI belongs to the non-allocated debug section. The saved PC is narrower
 * than its four-byte debugger representation.
 */
    .macro STM8_CFI_START
    .cfi_sections .debug_frame
    .cfi_startproc
    .cfi_escape 0x16,11,5,0x11,130-STM8_ARG,0x22,0x94,STM8_ARG-1
    .endm

/* Pointers and size_t are 16-bit.  HI results use callee cleanup only
 * in the medium model; X holds the result and Y is caller clobbered.
 */
    .macro STM8_RETURN bytes
#ifdef __STM8_LARGE__
    retf
#else
    .if \bytes
    .cfi_remember_state
    popw y
    .cfi_adjust_cfa_offset -2
    .cfi_escape 0x16,11,2,0x7a,0
    addw sp, #\bytes
    .cfi_adjust_cfa_offset -\bytes
    jp (y)
    .cfi_restore_state
    .else
    ret
    .endif
#endif
    .endm

/* Encode a nonzero count as an initial partial byte block followed by
 * full 256-byte blocks.  The high-byte increment may wrap: zero then
 * represents 256 blocks.  Check the original count before using this.
 */
    .macro STM8_COUNT offset
    ld a, (\offset + 1, sp)
    jreq .Lcount_ready\@
    inc (\offset, sp)
.Lcount_ready\@:
    .endm
