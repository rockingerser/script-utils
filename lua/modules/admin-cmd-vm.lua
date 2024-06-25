-- Simple Admin commands VM

local CommandVM = {
    opcode = {
        GLOBAL_SET = 0x00,
        LOCAL_SET = 0x01,
        GLOBAL_GET = 0x02,
        LOCAL_GET = 0x03,
        CONST = 0x04,
        COMMAND_CALL = 0x05,
        GETTER_CALL = 0x06
    },
    datatypes = {
        number = 0x00,
        string = 0x01,
        boolean = 0x02,
        table = 0x03,
        player = 0x04,
        ["nil"] = 0x05
    },
}
CommandVM.__index = CommandVM

local Players = game:GetService("Players")

function CommandVM.new()
    local self = setmetatable({}, CommandVM)
    self.LocalVars = {}
    self.GlobalVars = {}
    self.Commands = {}

    return self
end

function CommandVM.type(value)
    local valueType = typeof(value)
    return CommandVM.datatypes[valueType:lower()]
end

function CommandVM.global_get(var)
    return {
        opcode = CommandVM.opcode.GLOBAL_GET,
        value = var:upper()
    }
end

function CommandVM.local_get(var)
    return {
        opcode = CommandVM.opcode.LOCAL_GET,
        value = var:upper()
    }
end

function CommandVM.value(value)
    return value
end

function CommandVM.const(value, overrideType)
    return {
        opcode = CommandVM.opcode.CONST,
        type = overrideType or CommandVM.type(value),
        value = CommandVM.value(value)
    }
end

function CommandVM:CreateCommand(options)
    if options.name == nil then
        error("name required")
    end
    if options.callback == nil then
        error("callback required")
    end

    if typeof(options.name) ~= "table" then
        options.name = { options.name }
    end

    for _, Name in ipairs(options.name) do
        self.Commands[Name:upper()] = options
    end
end

function CommandVM:Open()
    for key, _ in pairs(self.LocalVars) do
        self.LocalVars[key] = nil
    end
end

function CommandVM:Print(...)
    print(...)
end

function CommandVM:Warn(...)
    warn(...)
end

function CommandVM:Error(...)
    warn(...)
end

function CommandVM.global_set(var, value)
    return {
        opcode = CommandVM.opcode.GLOBAL_SET,
        name = var:upper(),
        value = value
    }
end

function CommandVM.local_set(var, value)
    return {
        opcode = CommandVM.opcode.LOCAL_SET,
        name = var:upper(),
        value = value
    }
end

-- Return Original Value (eval)
function CommandVM:GetValue(value)
    local opcode = value.opcode
    if opcode == self.opcode.GLOBAL_GET then
        return self:GetValue(self.GlobalVars[value.value])
    elseif opcode == self.opcode.LOCAL_GET then
        return self:GetValue(self.LocalVars[value.value])
    elseif opcode == self.opcode.CALL or opcode == self.opcode.CONST and typeof(value.value) == "table" then
        local Params = value.value
        local DecodedParams = {}

        for i, Raw in ipairs(Params) do
            DecodedParams[i] = self:GetValue(Raw)
        end

        if opcode == self.opcode.CONST then
            return DecodedParams
        end
        return self.Commands[value.name].callback(unpack(DecodedParams))
    elseif opcode == self.opcode.CONST then
        if value.type == self.datatypes.player then
            local PlayerName = value.value
            for _, Player in ipairs(Players:GetPlayers()) do
                if Player.DisplayName:lower():find("^"..PlayerName:lower()) then
                    return Player
                end
            end
            return
        end
        return value.value
    end
end

function CommandVM.call(name, ...)
    return {
        opcode = CommandVM.opcode.CALL,
        name = name:upper(),
        value = {...}
    }
end

function CommandVM:Close()

end

function CommandVM:RuntimeGlobalSet(var, value)
    self.GlobalVars[var] = value
end

function CommandVM:RuntimeLocalSet(var, value)
    self.LocalVars[var] = value
end

function CommandVM:RuntimeGlobalGet(var)
    return self:GetValue(self.GlobalVars[var])
end

function CommandVM:RuntimeLocalGet(var)
    return self:GetValue(self.LocalVars[var])
end
--[[
            level param here pls |
                                 v   ]]
function CommandVM:Execute(script)
    for _, Code in ipairs(script) do
        if Code.opcode == CommandVM.opcode.GLOBAL_SET then
            self:RuntimeGlobalSet(Code.name, self:GetValue(Code.value))
        elseif Code.opcode == CommandVM.opcode.LOCAL_SET then
            self:RuntimeLocalSet(Code.name, self:GetValue(Code.value))
        elseif Code.opcode == CommandVM.opcode.CALL then
            local Command = self.Commands[Code.name].callback
            local Params = Code.value
            local DecodedParams = {}

            for i, Raw in ipairs(Params) do
                DecodedParams[i] = self:GetValue(Raw)
            end

            Command(unpack(DecodedParams))
        end
    end
end

--[[
local vm = CommandVM.new()
vm:CreateCommand({
    name = "greet",
    callback = function(plt)
        print("Hello, "..plt.DisplayName.."!")
    end,
    level = 0,
    args = {
        {
            name = "targetpl",
            type = "player",
            description = "The player to greet"
        }
    },
    description = "Testing purposes",
    returns = "nil"
})
]]

return CommandVM
