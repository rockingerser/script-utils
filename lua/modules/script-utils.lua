local ScriptUtils = {}
local RunService = game:GetService("RunService")
ScriptUtils.__index = ScriptUtils

function ScriptUtils.new()

function ScriptUtils.findFirstChild(a, instanceName)
    return a:FindFirstChild(instanceName)
end

function ScriptUtils.waitForChild(a, instanceName, timeout)
    return nil
end

return ScriptUtils
