#!/bin/env python
# Given an input file with one ip address per line, outputs a
# single cidr that spans the lowest and highest.

import netaddr
import os
import sys

if len(sys.argv) != 2 or not os.path.exists(sys.argv[1]):
    prog = sys.argv[0]
    print("usage: {} <ips.txt>".format(prog))
    print("""
$ cat ips.txt
10.0.0.1
10.0.0.2

$ {} ips.txt
10.0.0.0/30
    """.format(prog))
    exit(1)

print(netaddr.spanning_cidr([
    ip.strip() for ip in open(sys.argv[1]).readlines()
]))

