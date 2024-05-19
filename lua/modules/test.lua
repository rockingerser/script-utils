local module = {}

print("Thanks for requiring me!")

function module.Test1()
    print("Hello from module!")
end

function module.Sum(a, b)
    local result = a + b
    print("The result is "..result)
end

function module.GetPI()
    return 3.1415
end

function module.YieldMyself()
    print("Yield result"..coroutine.yield())
end

return module
