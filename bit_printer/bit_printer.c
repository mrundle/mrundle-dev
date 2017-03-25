// This program accepts a number as an arg and prints out
// the binary representation of that number.
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#define exit_error(fmt, args...) do {               \
    fprintf(stderr, fmt "\n", ##args);              \
    exit(EXIT_FAILURE);                             \
} while (0)

// cast everything directly to a size_t
#define print_bits(x) _print_bits((size_t)x)
static void _print_bits(size_t x) {
    bool zero = true;
    for (size_t _i = sizeof(x) * 8; _i > 0; _i--) { 
        if (x & ((typeof(x))1 << (_i - 1))) {       
            printf("1");                            
            zero = false;                           
        } else if (!zero) {                         
            printf("0");                            
        }                                           
    }                                               
    printf("%s\n", zero ? "0" : "");
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

    print_bits(n);

    return 0;
}
