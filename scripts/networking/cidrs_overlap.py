#!/usr/bin/env python3.6

import sys
import ipaddress

cidrs = []

if len(sys.argv) < 3:
    print(f'usage: {sys.argv[0]} <cidr1> <cidr2> ... <cidrN>')
    exit(1)

for cidr in sys.argv[1:]:
    cidrs.append(ipaddress.IPv4Network(cidr))

overlaps = 0

for cidr_a in cidrs:
    for cidr_b in cidrs:
        if cidr_a != cidr_b:
            if cidr_a.overlaps(cidr_b):
                print(f'{cidr_a} overlaps with {cidr_b}')
                overlaps += 1

if overlaps > 0:
    exit(1)
print('No overlaps')
