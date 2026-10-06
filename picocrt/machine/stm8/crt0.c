/* SPDX-License-Identifier: BSD-3-Clause */
/* Bare-metal startup hooks. C calls follow the selected SDCC-compatible ABI. */
extern void __libc_init_array(void);
void
_stm8_run_initializers(void)
{
#if !defined(CONSTRUCTORS) || CONSTRUCTORS
    __libc_init_array();
#endif
}
volatile int _stm8_exit_status;
__attribute__((weak, noreturn)) void
_exit(int status)
{
    _stm8_exit_status = status;
    __asm__ volatile(".global __stm8_halt\n__stm8_halt:");
    for (;;)
        __asm__ volatile("sim\n\thalt");
}
