#!/bin/env python3
import lib
import pickle
import sys
from urllib.request import urlopen

url='http://www.pythonchallenge.com/pc/def/banner.p'

# array of tuple lists
# [[(' ', 95)], [(' ', 14), ..., ('#', 6)], [(' ', 95)]]
data = pickle.load(urlopen(url))

# print characters in each line
for tup_line in data:
    for tup in tup_line:
        sys.stdout.write(tup[0] *  tup[1])
    sys.stdout.write('\n')
