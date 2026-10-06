/* Copyright (c) 2026 Andrei-Edward Popa
 * SPDX-License-Identifier: BSD-3-Clause
 */
#ifndef CONSTRUCTORS
#define CONSTRUCTORS 1
#endif
/* Vector entries are opcode 0x82 + 24-bit PC in both memory models. */
#ifdef __STM8_LARGE__
    .stm8_model "large"
#define STM8_CALL callf
#define STM8_JUMP jpf
#else
    .stm8_model "medium"
#define STM8_CALL call
#define STM8_JUMP jp
#endif
    .section .vectors, "ax", @progbits
    .global __vectors
__vectors:
    .byte 0x82
    .3byte __start
    .rept 31
    .byte 0x82
    .3byte __stm8_unhandled_interrupt
    .endr
    .section .text.startup, "ax", @progbits
    .global __start, _start
    .type __start, @function
    .type _start, @function
__start:
_start:
    sim
    ldw x, #___stack-1
    ldw sp, x
    ldw x, #___bss_start
    ldw y, #___bss_end
.Lbss:
    pushw y
    cpw x, (1, sp)
    popw y
    jreq .Ldata_begin
    clr (x)
    incw x
    jra .Lbss
.Ldata_begin:
    ldw x, #___data_source
    ldw y, #___data_start
.Ldata:
    cpw y, #___data_end
    jreq .Lrun
    ld a, (x)
    ld (y), a
    incw x
    incw y
    jra .Ldata
.Lrun:
#if CONSTRUCTORS
    STM8_CALL __stm8_run_initializers
#endif
/* main receives argc=0 in X and argv=NULL on the stack. */
    clrw x
    pushw x
    STM8_CALL _main
/* main(void) and main(int,char **) have different callee-pop sizes. */
    ldw y, #___stack-1
    ldw sp, y
#ifdef CRT0_EXIT
    STM8_JUMP _exit
#else
    STM8_JUMP __exit
#endif
    .size __start, .-__start
    .size _start, .-_start
    .section .text.unhandled, "ax", @progbits
    .global __stm8_unhandled_interrupt
    .type __stm8_unhandled_interrupt, @function
__stm8_unhandled_interrupt:
    sim
    halt
    jra __stm8_unhandled_interrupt
    .size __stm8_unhandled_interrupt, .-__stm8_unhandled_interrupt
