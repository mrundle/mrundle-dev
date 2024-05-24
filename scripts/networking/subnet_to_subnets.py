#!/bin/env python3
# Given a cidr, output a single random address from it.

import sys
from ipaddress import ip_network, ip_address
import random

if len(sys.argv) != 3:
    print(f"""\
usage: {sys.argv[0]} <subnet> <new_prefix>

Example:

    $ ./subnet_to_subnets.py 99.88.64.0/20 24
    99.88.64.0/24
    99.88.65.0/24
    99.88.66.0/24
    ...
    99.88.77.0/24
    99.88.78.0/24
    99.88.79.0/24

    $ {sys.argv[0]} 3951:ade:d6d0:2c00::/56 64
    3951:ade:d6d0:2c00::/64
    3951:ade:d6d0:2c01::/64
    3951:ade:d6d0:2c02::/64
    ...
    3951:ade:d6d0:2cfd::/64
    3951:ade:d6d0:2cfe::/64
    3951:ade:d6d0:2cff::/64
""")
    exit(0)

cidr = sys.argv[1]
new_prefix = int(sys.argv[2])
net = ip_network(cidr, strict=False)
subnets = net.subnets(new_prefix=new_prefix)
for subnet in subnets:
    print(subnet)
