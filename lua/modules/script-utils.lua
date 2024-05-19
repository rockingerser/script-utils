local module = {}
local RunService = game:GetService("RunService")

function module.findFirstChild(a, instanceName)
    return a:FindFirstChild(instanceName)
end

function module.waitForChild(a, instanceName, timeout)
    return nil
end

return module
