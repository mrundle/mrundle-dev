#!/usr/bin/python2.7
# https://www.geeksforgeeks.org/python-closures/

def strgen():
    localstr = 'localstr'
    def gen():
        return localstr
    return gen

_s = strgen()
print('printing: "%s"' % _s())
