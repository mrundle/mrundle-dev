#!/usr/bin/python2.7

def generator(x):
    def gen():
        return x
    return gen

gen = generator(10)
for i in range(10):
    print gen()
