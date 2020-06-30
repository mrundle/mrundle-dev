#!/usr/bin/env python3

import sys
from datetime import datetime

constructors = []

def constructor(func):
    '''
    Decorator allowing the collection of functions into a global
    `constructors` list for later use.
    '''
    constructors.append(func)
    def constructor_wrap(*args):
        func(*args)
    return constructor_wrap

def log(func):
    def wrap(*args):
        now = datetime.now()
        print('{}: Running {}({})'.format(now, func.__name__, args))
        func(*args)
    return wrap

@constructor
@log
def foo_constr():
    pass

@constructor
@log
def bar_constr():
    pass

@constructor
@log
def baz_constr():
    pass

# run constructors
for func in constructors:
    func()

# arbitrary params
@log
def lots_of_args(a, b, c, d, e, f):
    print('a -> {}'.format(a))
    print('b -> {}'.format(b))
    print('c -> {}'.format(c))
    print('d -> {}'.format(d))
    print('e -> {}'.format(e))
    print('f -> {}'.format(f))

lots_of_args(1, 2, 3, 4, 5, 6)


# decorate decorators with `@log` to check ordering

@log
def decorator_a(func):
    def wrap(*args):
        func(*args)
    return wrap

@log
def decorator_b(func):
    def wrap(*args):
        func(*args)
    return wrap

@log
def decorator_c(func):
    def wrap(*args):
        func(*args)
    return wrap

print('Testing ordering:')
print('  >> @decorator_a')
print('  >> @decorator_b')
print('  >> @decorator_c')
print('  >> def ordering():')
print('  >>     pass')

@decorator_a
@decorator_b
@decorator_c
def ordering():
    pass

# the above prints:
#     2020-06-30 07:57:07.972309: Running decorator_c((<function ordering at 0x7f49601d7c80>,))
#     2020-06-30 07:57:07.972326: Running decorator_b((None,))
#     2020-06-30 07:57:07.972341: Running decorator_a((None,))
# so we can see that the decorator nearest to the function is applied first,
# then the next, and so on. It was important to put @constructor above @log
# in the earlier examples, in which case the constructor decorates the
# log-wrapped function. otherwise, @log will wrap the constructor wrapper itself:

@log
@constructor
def oops():
    pass

print('Out-of-order decorators')
oops()

print('')
print('ok')
