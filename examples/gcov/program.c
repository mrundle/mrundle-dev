#include <stdio.h>
#include "library.h"

int main(void)
{
    const int a = 4;
    const int b = 2;
    printf("%d + %d = %d\n", a, b, lib_add(a,b));
    printf("%d - %d = %d\n", a, b, lib_sub(a,b));
    printf("%d * %d = %d\n", a, b, lib_mul(a,b));
    printf("%d / %d = %d\n", a, b, lib_div(a,b));
    return 0;
}
