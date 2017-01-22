#include "library.h"

static void unused_internal_func1(void) {}
static void unused_internal_func2(void) {}

int lib_add(const int a, const int b)
{
 return a + b; 
}

int lib_sub(const int a, const int b)
{
 return a - b; 
}

int lib_mul(const int a, const int b)
{
 return a * b; 
}

int lib_div(const int a, const int b)
{
 return a / b; 
}
