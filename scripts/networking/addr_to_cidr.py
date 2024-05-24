#!/bin/env python3
# Given a cidr, output a single random address from it.

import sys
from ipaddress import ip_network, ip_address
import random

if len(sys.argv) != 3:
    print(f"""\
usage: {sys.argv[0]} <addr> <mask>

Example:

    $ {sys.argv[0]} 99.88.77.66 20
    99.88.64.0/20

    $ {sys.argv[0]} 3951:0ade:d6d0:2c64:2db0:a600:873f:1053 56
    3951:ade:d6d0:2c00::/56
""")
    exit(0)

addr = sys.argv[1]
mask = sys.argv[2]
net = ip_network(f'{addr}/{mask}', strict=False)
print(net)
