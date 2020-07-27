#!/usr/bin/node
function log(msg) { console.log(msg); }
function assert_equal(a, b) { if (a != b) { throw `failed:, ${a} != ${b}` } }

/*
 * Put very simply, closures in javascript are essentially
 * classes with a single function. When you return a function
 * foo from within another function bar, the returned function
 * maintains access to the state of it's containing function.
 *
 * They are called closures because they "close over" the surrounding
 * lexical scope. Any language that is lexically scoped, has indefinite
 * extent, and has first class functions, must, by definition, have
 * closures.
 */
function bar() {
    var internal = 10;
    function foo() {
        return internal;
    }
    return foo;
}

var f = bar();
assert_equal(f(), 10);

/*
 * This in itself is already pretty cool. The variable "f"
 * is a closure that can be called to execute foo() within
 * a scope of bar(). What's cooler is that this state is
 * maintained over multiple calls to the function. As mentioned
 * previously, a simple way to think about this is an instantiated
 * class object, with state, and one function interface.
 *
 * See the example below, which demonstrates this persistence
 * of state:
 */

function generator(start, iter) {
    cur = start - iter;
    function next() {
        cur += iter;
        return cur;
    }
    return next;
}

iter = generator(0, 5);

    assert_equal(iter(),  0);
    assert_equal(iter(),  5);
    assert_equal(iter(), 10);
    assert_equal(iter(), 15);

iter = generator(3, -1);

    assert_equal(iter(), 3);
    assert_equal(iter(), 2);
    assert_equal(iter(), 1);
    assert_equal(iter(), 0);

iter = generator(-3, 1);

    assert_equal(iter(), -3);
    assert_equal(iter(), -2);
    assert_equal(iter(), -1);
    assert_equal(iter(),  0);

/*
 * The returned function can also accept parameters, which
 * can then be used to interact with the function state.
 */

function make_multiplier(x) {
    function fn(y) {
        return x * y;
    }
    return fn;
}

x5 = make_multiplier(5)
assert_equal(x5(5), 25);

/*
 * And you can actually use this to implement something
 * that resembles a full-fledged class.
 */

function rectangle(length, width) {
    len = length;
    wid = width;
    function get_length()  { return length;         }
    function get_width()   { return width;          }
    function set_length(v) { length = v;            }
    function set_width(v)  { width = v;             }
    function get_area()    { return length * width; }
    functions = {
        'get_length' : get_length,
        'get_width'  : get_width,
        'get_area'   : get_area,
        'set_length' : set_length,
        'set_width'  : set_width,
    }
    return functions
}

rec = rectangle(5, 10);

assert_equal(rec['get_length'](), 5);
assert_equal(rec['get_width'](), 10);
assert_equal(rec['get_area'](),  50);

rec['set_length'](3)
rec['set_width'](4);
assert_equal(rec['get_length'](), 3);
assert_equal(rec['get_width'](),  4);
assert_equal(rec['get_area'](),  12);


log("OK");
