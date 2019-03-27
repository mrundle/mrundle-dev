#!/usr/bin/lua

-- https://www.lua.org/pil/9.1.html

function echo(s)
    print('echo: called with "' .. s .. '"')
end

function sleep(n)
    os.execute('sleep ' .. tonumber(n))
end

function main()
    local res = -1
    local co = nil

    print('--- Testing function coroutine ---')
    co = coroutine.create(echo)
    print(coroutine.status(co))
    res = coroutine.resume(co, 'well hey there')
    print(coroutine.status(co))
    assert(res, 'Unexpected coroutine failure')

    print('\n--- Testing function coroutine ---')
    co = coroutine.create(function (a, b, c)
            print(string.format('a=%s, b=%s, c=%s', a, b, c))
        end)
    res = coroutine.resume(co, 'foo', 'bar', 'baz')
    assert(res, 'Unexpected coroutine failure')

    print('\n--- Testing failed coroutine ---')
    co = coroutine.create(function() error('msg') end)
    res = coroutine.resume(co)
    assert(not res, 'Unexpected coroutine success')
    print('Failed as expected')

    print('\n--- Testing coroutine with yield ---')
    co = coroutine.create(function(ntimes)
        for i=0,ntimes do
            print(i)
            coroutine.yield()
        end
    end)
    while coroutine.resume(co, 5) do
        -- nothing
    end

    print('\n--- Testing coroutine with yield return ---')
    co = coroutine.create(function(ntimes)
        for i=0,ntimes do
            coroutine.yield(i)
        end
    end)
    while true do
        ok, out = coroutine.resume(co, 5)
        if ok and out then
            print(string.format('yielded: %d', out))
        else
            break
        end
    end
end
    
main()
