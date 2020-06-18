// This program accepts a number as an arg and prints out
// the binary representation of that number.
#include <limits.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define PAD_TO 8

#define exit_error(fmt, args...) do {               \
    fprintf(stderr, fmt "\n", ##args);              \
    exit(EXIT_FAILURE);                             \
} while (0)

// cast everything directly to a size_t
#define print_bits(x, buf, buflen) _print_bits((size_t)x, buf, buflen)

static int
_print_bits(size_t x, char *const buf, const unsigned len)
{
    bool zero = true;
    unsigned buf_i = 0;
    for (size_t _i = sizeof(x) * CHAR_BIT; _i > 0; _i--) {
        if (buf_i >= (len - 1)) {
            fprintf(stderr, "out of space");
            exit(EXIT_FAILURE);
        }
        if (x & ((typeof(x))1 << (_i - 1))) {
            buf[buf_i++] = '1';
            zero = false;
        } else if (!zero) {
            buf[buf_i++] = '0';
        }
    }
    if (zero) {
        if (buf_i >= (len - 1)) {
            fprintf(stderr, "out of space");
            exit(EXIT_FAILURE);
        }
        buf[buf_i++] = '0';
    }
    /* already checked buf_i */
    buf[buf_i] = '\0';
    return 0;
}

int main(int argc, char **argv)
{
    if (argc != 2) {
        exit_error("usage: %s <unsigned>", argv[0]);
    }

    ssize_t n;
    if (sscanf(argv[1], "%zd", &n) !=  1) {
        exit_error("failed to parse input '%s' "
                   "(need number)", argv[1]);
    }

    char buf_nopad[65];
    char buf_pad[65];
    print_bits(n, buf_nopad, sizeof(buf_nopad));

    /* zero-pad to the nearest 8 bits */
    const int rem = strlen(buf_nopad) % PAD_TO;
    if (rem <= 0) {
        printf("%s\n", buf_nopad);
    } else {
        // rem > 0; pad
        memset(buf_pad, '0', PAD_TO - rem);
        strcpy(&buf_pad[PAD_TO - rem], buf_nopad);
        printf("%s\n", buf_pad);
    }

    return 0;
}
