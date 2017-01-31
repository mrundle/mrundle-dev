#include "_libc.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define exit_error(args...) do { \
    fprintf(stderr, "FAILED (line %d) ", __LINE__); \
    fprintf(stderr, args);                          \
    fprintf(stderr, "\n");                          \
    exit(1);                                        \
} while (0)

#define fail() exit_error("(exiting)");

#define test_assert(expr) do { \
    if (!(expr)) exit_error("%s", #expr); \
} while(0)

#define TEST(func)         \
static void __ ## func ## __ (void); \
static void func (void) { \
    fprintf(stderr, "Running %s...", #func); \
    __ ## func ##__(); \
    fprintf(stderr, "OK\n"); \
} \
static void __ ## func ## __ (void)

static void
test_strcat(char *const orig_dst, char *const orig_src)
{
    char dst[128], src[128];
    strcpy(dst, orig_dst);
    strcpy(src, orig_src);

    char *_dst = strdup(dst);
    char *_src = strdup(src);
    char *_dst_cpy = _dst;

    strcat(dst, src);
    char *_dst_ret = _strcat(_dst, _src);

    if (strcmp(dst, _dst) != 0) {
        exit_error("'%s' (strcat) != '%s' (_strcat)",
                   dst, _dst);
    }

    if (_dst_ret != _dst_cpy) {
        exit_error("incorrect return");
    }
}

TEST(run_test_strcat)
{
    test_strcat("Hello", "World");
    test_strcat("Hello", "");
    test_strcat("", "World");
    test_strcat("", "");
}

static void
test_memcpy(const char *const from)
{
    char dst[128], src[128], _dst[128], _src[128];
    strcpy(src, from); 
    strcpy(_src, from); 
    memset(dst, 0, sizeof(dst));
    memset(_dst, 0, sizeof(_dst));

    memcpy(dst, src, sizeof(dst));
    memcpy(_dst, _src, sizeof(_dst));

    test_assert(memcmp(src, _src, sizeof(src)));
    test_assert(memcmp(dst, _dst, sizeof(dst)));
}

TEST(run_test_memcpy)
{
    test_memcpy("");
    test_memcpy("from");
    test_memcpy("la la la la");
}

TEST(run_test_malloc_and_free)
{
    const unsigned big = 10000000;
    char *a = _malloc(big);
    test_assert(a != NULL);
    // poke all of it to ensure no segfault
    for (unsigned i = 0; i < big; i++) {
        a[i] = 1;
    }
    _free(a);
}

int
main(int argc, char **argv)
{
    void (*tests[])(void) = {
        run_test_strcat,
        run_test_memcpy,
        run_test_malloc_and_free
    };

    for (unsigned i = 0; i < sizeof(tests) / sizeof(tests[0]); i++) {
        tests[i]();
    }
    return 0;
}
