/*
 * compute the min/max of two integers without branching
 *     https://graphics.stanford.edu/~seander/bithacks.html#IntegerMinOrMax
 */

#include <stdio.h>
#include <assert.h>

static int n_failed = 0;
#define PASS "\e[92mPASS\e[39m"
#define FAIL "\e[91mFAIL\e[39m"

#define max_int_nobranch(_x, _y) \
    ({ \
        int x = (_x); \
        int y = (_y); \
        x ^ ((x ^ y) & -(x < y)); \
    })

#define min_int_nobranch(_x, _y) \
    ({ \
        int x = (_x); \
        int y = (_y); \
        y ^ ((x ^ y) & -(x < y)); \
    })

#define test_max_int_nobranch(x, y, res) do { \
    assert(max_int_nobranch(x, y) == res); \
} while (0)

#define test(expr, res) do { \
    int fail = ((expr) != (res)); \
    printf("%s == %s ... %s\n", #expr, #res, fail ? FAIL : PASS); \
    n_failed += fail; \
} while (0)

int main(void)
{
    /* test the tester */
    printf("testing test()... "); test(1 + 1, 2);
    assert(n_failed == 0);
    printf("testing test()... "); test(1 + 1, 9);
    assert(n_failed-- == 1);

    /* test min() */
    test(min_int_nobranch(1, 2), 1);
    test(min_int_nobranch(2, 1), 1);
    test(min_int_nobranch(0, 100), 0);
    test(min_int_nobranch(100, 0), 0);
    test(min_int_nobranch(0, -14), -14);
    test(min_int_nobranch(-14, 0), -14);
    test(min_int_nobranch(-100, -1), -100);
    test(min_int_nobranch(-1, -100), -100);

    /* test max() */
    test(max_int_nobranch(1, 2), 2);
    test(max_int_nobranch(2, 1), 2);
    test(max_int_nobranch(0, 100), 100);
    test(max_int_nobranch(100, 0), 100);
    test(max_int_nobranch(0, -14), 0);
    test(max_int_nobranch(-14, 0), 0);
    test(max_int_nobranch(-100, -1), -1);
    test(max_int_nobranch(-1, -100), -1);

    printf("\nTest status: %s\n\n", n_failed ? FAIL : PASS);
    return n_failed;
}
