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
    valueType = {
        null = 0x00,
        number = 0x01,
        special = 0x02
    }
}
CommandVM.__index = CommandVM

function CommandVM.new()
    local self = setmetatable({}, CommandVM)
    self.LocalVars = {}
    self.GlobalVars = {}
    self.Commands = {}
    self.__finished = Instance.new("BindableEvent")
    self.Finished = self.__finished.Event
    self.Script = {}

    return self
end

function CommandVM.type(value)
    local valueType = typeof(value)
    return if valueType == "number" then
        CommandVM.valueType.number
    elseif valueType == "table" then
        CommandVM.valueType.special
    else
        CommandVM.valueType.null
end

--[[
function CommandVM.globalVar(var)
    return {
        type = CommandVM.opcode.GLOBAL_GET,
        value = var
    }
end

function CommandVM.localVar(var)
    return {
        type = CommandVM.opcode.LOCAL_GET,
        value = var
    }
end
]]

function CommandVM.value(value)
    return value
end

function CommandVM.data(value)
    return {
        type = CommandVM.type(value),
        value = CommandVM.value(value)
    }
end

function Commands:CreateCommand(options)
    if options.name == nil then
        error("name required")
    end
    if options.callback == nil then
        error("callback required")
    end

    local env = getfenv(options.callback)

    function env.
    function env.global_get(var)
        return self:RuntimeGlobalGet(var)
    end

    self.Commands[options.name] = options
end

function CommandVM:Open()
    for key, _ in pairs(self.LocalVars) do
        self.LocalVars[key] = nil
    end
    while #self.Script > 0 do
        table.remove(self.Script, 1)
    end
end

--[[
function CommandVM.global_set(var, value)
    return {
        type = CommandVM.code.GLOBAL_SET,
        name = var,
        value = CommandVM.data(value)
    }
end

function CommandVM.local_set(var, value)
    return {
        type = CommandVM.code.LOCAL_SET,
        name = var,
        value = CommandVM.data(value)
    }
end
]]

function CommandVM:GetValue(value)
    return if value.type == CommandVM.valueType.special then
        if value.value.type == CommandVM.opcode.GLOBAL_GET then
            return self.GlobalVars[value.value.value]
        elseif value.value.type == CommandVM.opcode.LOCAL_GET then
            return self.LocalVars[value.value.value]
        else
            error("Unknown error")
        end
    else
        value.value
end

function CommandVM.call(name, ...)
    local params = {}
    for _, param in ipairs({...}) do
        table.insert(params, CommandVM.data(param))
    end

    return {
        type = CommandVM.opcode.CALL,
        name,
        value = params
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

function CommandVM:Run()
    for _, Code in ipairs(self.Script) do
        if Code.code == CommandVM.code.GLOBAL_SET then
            self:RuntimeGlobalSet(Code.value)
        elseif Code.code == CommandVM.code.LOCAL_SET then
            self:RuntimeLocalSet(Code.value)
        elseif Code.code == CommandVM.code.CALL then
            local Command = self.Commands[Code.name]
        end
    end
end

local test = CommandVM.new()

test:Open()
test:GlobalSet("abc", 123)
test:LocalSet("local", 334)
test:Close()

test:Start()


return CommandVM
