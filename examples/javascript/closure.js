#!/usr/bin/node

function foo(x) {
    var v = x;
    function gen() {
        v += 1;
        return v;
    }
    return gen;
}

gen = foo(0);

for (i = 0; i < 10; i++) {
    console.log(gen());
}
