#!/bin/env python3
# Given a cidr, output a single random address from it.

import sys
from ipaddress import ip_network, ip_address
import random

if len(sys.argv) != 2:
    print("usage: {} <cidr>".format(sys.argv[0]))
    exit(0)

net = ip_network(sys.argv[1])
hosts = list(net.hosts())
host = random.choice(hosts)
print(host)
