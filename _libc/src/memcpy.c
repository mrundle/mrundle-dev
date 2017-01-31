#include "_libc.h"

void *
_memcpy(void *dst, const void *src, unsigned n)
{
    if (n == 0 || dst == NULL || src == NULL) return dst;
    void *dst_orig = dst;
    do { *((char *)dst++) = *((char *)src++); } while (n--);
    return dst_orig;
}
