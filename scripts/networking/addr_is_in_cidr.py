#!/bin/env python3
# Given an input file with one ip address per line, outputs a
# single cidr that spans the lowest and highest.

import sys
from ipaddress import ip_network, ip_address

if len(sys.argv) != 3:
    print("usage: {} <addr> <cidr>".format(sys.argv[0]))
    exit(0)

ip = ip_address(sys.argv[1])
net = ip_network(sys.argv[2])

if ip_address(ip) in ip_network(net):
    print('True: {} is in {}'.format(ip, net))
    exit(0)
else:
    print('False: {} is not in {}'.format(ip, net))
    exit(1)
