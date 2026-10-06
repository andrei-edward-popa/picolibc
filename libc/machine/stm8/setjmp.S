#ifdef __STM8_LARGE__
    .stm8_model "large"
#else
    .stm8_model "medium"
#endif
/* STM8 SDCC call(1): jmp_buf = SP, PC, software FP, scratch pointer.
    SP is the value after setjmp returns. The last word is longjmp scratch;
    the saved environment remains reusable. */
    .section .text.setjmp, "ax", @progbits
    .global _setjmp
_setjmp:
#ifdef __STM8_LARGE__
/* Large model: SP[0:2], PC[2:5], FP[5:7], scratch[7:9]. */
    ldw y, sp
    addw y, #3
    ldw (0, x), y
    ld a, (1, sp)
    ld (2, x), a
    ldw y, (2, sp)
    ldw (3, x), y
    ldw y, __stm8_frame_pointer
    ldw (5, x), y
    clrw x
    retf
    .section .text.longjmp, "ax", @progbits
    .global _longjmp
_longjmp:
    ldw y, (4, sp)
    jrne .Lnonzero
    incw y
.Lnonzero:
    pushw y
    ldw y, sp
    incw y
    ldw (7, x), y
    ld a, (5, x)
    ld __stm8_frame_pointer, a
    ld a, (6, x)
    ld __stm8_frame_pointer+1, a
    ld a, (x)
    ld yh, a
    ld a, (1, x)
    ld yl, a
    ldw sp, y
    ld a, (7, x)
    ld yh, a
    ld a, (8, x)
    ld yl, a
    ldw y, (y)
    ld a, (4, x)
    push a
    ld a, (3, x)
    push a
    ld a, (2, x)
    push a
    ldw x, y
    retf
#else
    ldw y, sp
    addw y, #2
    ldw (0, x), y
    ldw y, (1, sp)
    ldw (2, x), y
    ldw y, __stm8_frame_pointer
    ldw (4, x), y
    clrw x
    ret
    .section .text.longjmp, "ax", @progbits
    .global _longjmp
_longjmp:
    ldw y, (3, sp)
    jrne .Lnonzero
    incw y
.Lnonzero:
    pushw y
    ldw y, sp
    incw y
    ldw (6, x), y
    ld a, (4, x)
    ld __stm8_frame_pointer, a
    ld a, (5, x)
    ld __stm8_frame_pointer+1, a
    ld a, (x)
    ld yh, a
    ld a, (1, x)
    ld yl, a
    ldw sp, y
    ld a, (6, x)
    ld yh, a
    ld a, (7, x)
    ld yl, a
    ldw y, (y)
    ldw x, (2, x)
    pushw x
    ldw x, y
    ret
#endif
    .comm __stm8_frame_pointer, 2, 1
