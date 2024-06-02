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
        "nil" = 0x05
    },
}
CommandVM.__index = CommandVM

function CommandVM.new()
    local self = setmetatable({}, CommandVM)
    self.LocalVars = {}
    self.GlobalVars = {}
    self.Commands = {}

    return self
end

function CommandVM.type(value)
    local valueType = CommandVM.typeof(value)
    return valueType:lower()--[[if valueType == "number" then
        CommandVM.valueType.number
    elseif valueType == "table" then
        CommandVM.valueType.special
    else
        CommandVM.valueType.null]]
end

function CommandVM.global_get(var)
    return {
        opcode = CommandVM.opcode.GLOBAL_GET,
        value = var
    }
end

function CommandVM.local_get(var)
    return {
        opcode = CommandVM.opcode.LOCAL_GET,
        value = var
    }
end

function CommandVM.value(value)
    return value
end

function CommandVM.const(value)
    return {
        opcode = CommandVM.opcode.CONST,
        type = CommandVM.type(value),
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

    --local env = getfenv(options.callback)

    self.Commands[options.name:upper()] = options
end

function CommandVM:Open()
    for key, _ in pairs(self.LocalVars) do
        self.LocalVars[key] = nil
    end
end

function CommandVM.global_set(var, value)
    return {
        opcode = CommandVM.opcode.GLOBAL_SET,
        name = var,
        value = value
    }
end

function CommandVM.local_set(var, value)
    return {
        opcode = CommandVM.opcode.LOCAL_SET,
        name = var,
        value = value
    }
end

-- Return Original Value (eval)
function CommandVM:GetValue(value)
    local opcode = value.opcode
    if opcode == self.opcode.GLOBAL_GET then
        return self.GlobalVars[value.value].value
    elseif opcode == self.opcode.LOCAL_GET then
        return self.LocalVars[value.value].value
    elseif opcode == self.opcode.CALL then
        local Params = value.value
        local DecodedParams = {}

        for _, Raw in ipairs(Params) do
            table.insert(DecodedParams, self:GetValue(Raw))
        end

        return self.Commands[value.name](unpack(DecodedParams))
    elseif opcode == self.opcode.CONST then
        return value.value
    end
end

function CommandVM.call(name, ...)
    return {
        opcode = CommandVM.opcode.CALL,
        name = name,
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

function CommandVM:Execute(script)
    for _, Code in ipairs(script) do
        if Code.opcode == CommandVM.opcode.GLOBAL_SET then
            self:RuntimeGlobalSet(Code.name, Code.value)
        elseif Code.opcode == CommandVM.opcode.LOCAL_SET then
            self:RuntimeLocalSet(Code.name, Code.value)
        elseif Code.opcode == CommandVM.opcode.CALL then
            local Command = self.Commands[Code.name].callback
            local Params = Code.value
            local DecodedParams = {}

            for _, Raw in ipairs(Params) do
                table.insert(DecodedParams, self:GetValue(Raw))
            end

            Command(unpack(DecodedParams))
        end
    end
end

return CommandVM
