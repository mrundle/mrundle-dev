//#include "_libc.h"

#define NULL ((void *)0)
#define size_t unsigned

char *
_strcat(char *dst, const char *src)
{
    if (dst == NULL || src == NULL) return NULL;
    char *dst_orig = dst;
    while (*dst != '\0') dst++;
    while (*src != '\0') *(dst++) = *(src++);
    dst = '\0';
    return dst_orig;
}

void *
_memcpy(void *dst, const void *src, size_t n)
{
    if (n == 0 || dst == NULL || src == NULL) return dst;
    void *dst_orig = dst;
    do { *((char *)dst++) = *((char *)src++); } while (n--);
    return dst_orig;
}
