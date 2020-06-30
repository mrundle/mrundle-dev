#!/usr/bin/env python3

class MyMock1():
    pass
#        __repr__:
#        __hash__
#        __str__
#        __getattribute__
#        __setattr__
#        __delattr__
#        __lt__
#        __le__
#        __eq__
#        __ne__
#        __gt__
#        __ge__
#        __init__
#        __new__
#        __reduce_ex__
#        __reduce__
#        __subclasshook__
#        __init_subclass__
#        __format__
#        __sizeof__
#        __dir__
#        __class__
#        __doc__

a = MyMock1()
#a += 2 # not supported!

class MyMock2():
    __dict__ = {}

    def __add__(self, value):
        # e.g. `mock_obj += 2`
        return self

    def __sub__(self, value):
        # e.g. `mock_obj -= 2`
        return self

    def __mul__(self, value):
        # e.g. `mock_obj *= 2`
        return self

    def __getattr__(self, attr):
        # e.g. `mock_obj.foo`
        try:
            return self.__dict__[attr]
        except KeyError:
            return None

    def __setattr__(self, name, val):
        self.__dict__[name] = val


b = MyMock2()
print(b)
b += 2
b -= 2
b *= 2
print(b.foo)
b.foo = 'bar'
assert b.foo == 'bar'

print('ok')
