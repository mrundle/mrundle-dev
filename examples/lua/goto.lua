#!/usr/bin/lua

goto test_marker
assert(false, 'goto failed')
::test_marker::
print('ok')
