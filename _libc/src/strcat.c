#include "_libc.h"

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
