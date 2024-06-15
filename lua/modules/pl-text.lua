local HttpService = game:GetService("HttpService")
for _, Event in ipairs(game:GetDescendants()) do
    if Event:IsA("RemoteEvent") then
        Event.OnClientEvent:Connect(function(...)
            print(Event:GetFullName(), ":", ...)
        end)
    end
end
--[[
local args = {
    [1] = {
        [1] = {
            ["RayObject"] = nil,--Ray.new(Vector3.new(835.955078125, 101.48998260498047, 2323.81689453125), Vector3.new(-560.018310546875, 13.421019554138184 + math.random(0, 3), 214.94036865234375)),
            ["Distance"] = 30 * math.random(),
            ["Cframe"] =  CFrame.new(832.008544921875, 101.38705444335938, 2324.81982421875, 0.5327202081680298, 0.08462480455636978, -0.842049777507782, -2.8667814788718715e-09, 0.994987964630127, 0.09999487549066544, 0.8462914228439331, -0.05326928570866585, 0.5300502181053162),
            ["Hit"] = nil
        }
    }
}

while task.wait(.3) do
    for _, Connection in pairs(getconnections(game.ReplicatedStorage.ReplicateEvent.OnClientEvent)) do
        Connection:Fire(unpack(args))
    end
end

--[[
game.ReplicatedStorage.ReplicateEvent.OnClientEvent:Connect(function(Table)
    for _, Value in ipairs(Table) do
        print("sux")
        for Key, _Value in pairs(Value) do
            print(Key)
            print(_Value)
        end
    end
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/BypassedDarkDexV3.lua"))()]]

