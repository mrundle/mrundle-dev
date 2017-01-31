#ifndef __LIB_C
#define __LIB_C

#include <sys/mman.h>

#ifdef _LIBC_DEBUG
#include <stdio.h>
#define debug(args...) do { \
    fprintf(stderr, "_libc_debug: ");  \
    fprintf(stderr, args);             \
    fprintf(stderr, "\n");             \
} while(0)
#else
#define debug(args...)
#endif

#define NULL ((void *)0)

char *_strcat(char *destination, const char *source);
void *_memcpy(void *dst, const void *src, unsigned n);
void *_malloc(unsigned size);
void _free(void *ptr);

#endif
