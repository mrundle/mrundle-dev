#include "_libc.h"

// TODO malloc a bunch of space, giving out ptrs from that space,
// then more and more as required
void *
_malloc(unsigned size)
{
    unsigned len = size + sizeof(len);
    const int prot = PROT_READ | PROT_WRITE;
    const int flags = MAP_PRIVATE | MAP_ANONYMOUS;
    unsigned *ret = mmap(NULL, len, prot, flags, 0, 0);
    if (ret == MAP_FAILED) ret = NULL;

    // head should contain size
    *((int *)ret++) = len;
    debug("returning %p, len=%d", ret, len);
    debug("   ret-1: %u", *(ret - 1));
    return (void *)ret;
}

// length is stored in (unsigned *)ptr - 1
void
_free(void *ptr)
{
    unsigned *p = ptr;
    const unsigned len = *(--p);
    debug("freeing %p, len=%u",p ,len);
    munmap((void *)p, len);
}
