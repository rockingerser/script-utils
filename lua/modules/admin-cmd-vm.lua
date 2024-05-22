local CommandVM = {
    code = {
        GLOBAL_SET = 0x00,
        LOCAL_SET = 0x01,
        GLOBAL_GET = 0x02,
        LOCAL_GET = 0x03,
        CONST = 0x04,
        CALL = 0x05
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
    --[[
    self.CmdPrefix = ";"
    self.GetterPrefix = "."
    self.LocalVarPrefix = "@"
    self.GlobalVarPrefix = "$"
    ]]
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

function CommandVM.globalVar(var)
    return {
        type = CommandVM.code.GLOBAL_GET,
        value = var
    }
end

function CommandVM.localVar(var)
    return {
        type = CommandVM.code.LOCAL_GET,
        value = var
    }
end

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

    options.level = 30
    options.maxInstances = options.maxInstances or math.huge
    options.priority = options.priority or math.huge
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

function CommandVM:GlobalSet(var, value)
    table.insert(self.Script, {
        type = CommandVM.code.GLOBAL_SET,
        name = var,
        value = CommandVM.data(value)
    })
end

function CommandVM:LocalSet(var, value)
    table.insert(self.Script, {
        type = CommandVM.code.LOCAL_SET,
        name = var,
        value = CommandVM.data(value)
    })
end

function CommandVM:GetValue(value)
    return if value.type == CommandVM.valueType.special then
        if value.value.type == CommandVM.code.GLOBAL_GET then
            return self.GlobalVars[value.value.value]
        elseif value.value.type == CommandVM.code.LOCAL_GET then
            return self.LocalVars[value.value.value]
        else
            error("Unknown error")
        end
    else
        value.value
end

function CommandVM:CommandCall(name, ...)
    local params = {}
    for _, param in ipairs(...) do
        table.insert(params, CommandVM.data(param))
    end

    table.insert(self.Script, {
        type = CommandVM.code.CALL,
        name,
        value = params
    })
end

function CommandVM:Close()

end

function CommandVM:RuntimeGlobalSet(var, value)
    self.GlobalVars[var] = value
end

function CommandVM:RuntimeLocalSet(var, value)
    self.LocalVars[var] = value
end

function CommandVM:Start()
    for _, Code in ipairs(self.Script) do
        if Code.code == CommandVM.code.GLOBAL_SET then
            self.GlobalVars[Code.name] = self:GetValue(Code.value)
        elseif Code.code == CommandVM.code.LOCAL_SET then
            self.LocalVars[Code.name] = self:GetValue(Code.value)
        elseif Code.code == CommandVM.code.CALL then

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
