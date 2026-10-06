/* SPDX-License-Identifier: BSD-3-Clause */
/* Exact binary32 decimal digits using native byte arithmetic. */
#ifdef STM8_FTOA_HOST_TEST
#include <stdint.h>
#include <stdbool.h>
#define DTOA_MINUS   1
#define DTOA_ZERO    2
#define DTOA_INF     4
#define DTOA_NAN     8
#define FTOA_MAX_DIG 112
struct dtoa {
    int32_t exp;
    uint8_t flags;
    char    digits[112];
};
#else
#define _NEED_IO_FLOAT32
#include "../../stdio/dtoa.h"
#endif

/* A binary32 significand has at most 24 bits and its smallest exponent
   is -149.  significand * 5^149 needs at most 112 decimal digits. */
static void
decimal_times(uint8_t *digits, unsigned *count, uint8_t factor, uint8_t carry)
{
    for (unsigned i = 0; i < *count; ++i) {
        unsigned value = (unsigned)digits[i] * factor + carry;
        carry = 0;
        while (value >= 10) {
            value -= 10;
            ++carry;
        }
        digits[i] = value;
    }
    if (carry)
        digits[(*count)++] = carry;
}

int
__ftoa_engine(uint32_t bits, struct dtoa *out, int max_digits, bool fmode, int max_decimals)
{
    out->flags = bits >> 31 ? DTOA_MINUS : 0;
    out->exp = 0;
    out->digits[0] = '0';
    unsigned exponent = (bits >> 23) & 255;
    uint8_t  parts[3] = { (bits >> 16) & 127, bits >> 8, bits };
    if (exponent == 255) {
        out->flags |= parts[0] || parts[1] || parts[2] ? DTOA_NAN : DTOA_INF;
        return 0;
    }
    if (!exponent && !parts[0] && !parts[1] && !parts[2]) {
        out->flags |= DTOA_ZERO;
        return 1;
    }
    int binary_exponent = exponent ? (int)exponent - 150 : -149;
    if (exponent)
        parts[0] |= 128;

    uint8_t  digits[113];
    unsigned count = 1;
    digits[0] = 0;
    for (unsigned part = 0; part < 3; ++part) {
        uint8_t value = parts[part];
        for (unsigned bit = 0; bit < 8; ++bit) {
            decimal_times(digits, &count, 2, value >> 7);
            value <<= 1;
        }
    }
    unsigned steps = binary_exponent < 0 ? -binary_exponent : binary_exponent;
    while (steps--)
        decimal_times(digits, &count, binary_exponent < 0 ? 5 : 2, 0);
    int exp = (int)count - 1 + (binary_exponent < 0 ? binary_exponent : 0);
    int keep = max_digits > FTOA_MAX_DIG ? FTOA_MAX_DIG : max_digits;
    if (fmode && max_decimals < keep - exp - 1) {
        /* Compare first, avoiding overflow for extreme int precisions. */
        keep = max_decimals < -exp - 1 ? -1 : max_decimals + exp + 1;
    }
    if (keep <= 0) {
        bool up = false;
        if (keep == 0) {
            up = digits[count - 1] > 5;
            if (digits[count - 1] == 5)
                for (unsigned i = 0; i + 1 < count; ++i)
                    up |= digits[i] != 0;
        }
        if (up) {
            out->digits[0] = '1';
            out->exp = exp + 1;
        } else
            out->flags |= DTOA_ZERO;
        return 1;
    }
    if ((unsigned)keep > count)
        keep = count;
    for (int i = 0; i < keep; ++i)
        out->digits[i] = '0' + digits[count - 1 - i];
    bool up = false;
    if (count > (unsigned)keep) {
        unsigned first = count - keep - 1;
        up = digits[first] > 5;
        if (digits[first] == 5) {
            up = (out->digits[keep - 1] - '0') & 1;
            for (unsigned i = 0; i < first; ++i)
                up |= digits[i] != 0;
        }
    }
    if (up) {
        int i = keep;
        while (i && out->digits[i - 1] == '9')
            out->digits[--i] = '0';
        if (i)
            ++out->digits[i - 1];
        else {
            out->digits[0] = '1';
            ++exp;
        }
    }
    out->exp = exp;
    return keep;
}
