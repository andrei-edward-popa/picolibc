/* SPDX-License-Identifier: BSD-3-Clause */
/* Default bare-metal hooks; a board can override each weak definition. */
#define _DEFAULT_SOURCE
#include <stdint.h>
#include <stddef.h>
#include <errno.h>
#include <stdio.h>
#include <unistd.h>

extern char      __heap_start[], __heap_end[];
static uintptr_t heap_cursor = (uintptr_t)__heap_start;
__attribute__((weak)) void *
sbrk(intptr_t increment)
{
    uintptr_t old = heap_cursor, amount = (uintptr_t)increment;
    if (increment >= 0) {
        if (amount > (uintptr_t)__heap_end - old)
            goto failure;
        heap_cursor = old + amount;
    } else {
        amount = 0 - amount;
        if (amount > old - (uintptr_t)__heap_start)
            goto failure;
        heap_cursor = old - amount;
    }
    return (void *)old;
failure:
    errno = ENOMEM;
    return (void *)-1;
}

__attribute__((weak)) int
_stm8_putchar(unsigned char c)
{
    (void)c;
    return EOF;
}
__attribute__((weak)) int
_stm8_getchar(void)
{
    return EOF;
}
static int
console_put(char c, FILE *stream)
{
    (void)stream;
    return _stm8_putchar((unsigned char)c) < 0 ? _FDEV_ERR : 0;
}
static int
console_get(FILE *stream)
{
    (void)stream;
    int c = _stm8_getchar();
    return c < 0 ? _FDEV_EOF : c;
}
static FILE console = FDEV_SETUP_STREAM(console_put, console_get, NULL, _FDEV_SETUP_RW);
__attribute__((weak)) FILE * const stdin = &console;
__attribute__((weak)) FILE * const stdout = &console;
__attribute__((weak)) FILE * const stderr = &console;
