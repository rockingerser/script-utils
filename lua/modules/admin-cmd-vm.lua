local CommandVM = {
    type = {
        GLOBAL_SET = 0x00,
        LOCAL_SET = 0x01
    },
    valueType = {
        nil = 0x00,
        number = 0x01
    }
}
CommandVM.__index = CommandVM

function CommandVM.new()
    local self = setmetatable({}, CommandVM)
    self.LocalVars = {}
    self.GlobalVars = {}
    self.Commands = {}
    self.CmdPrefix = ";"
    self.GetterPrefix = "."
    self.LocalVarPrefix = "@"
    self.GlobalVarPrefix = "$"
    self.Script = {}

    return self
end

function CommandVM.type(value)
    local valueType = typeof(value)
    return if valueType == "number" then
        CommandVM.valueType.number
    else
        -1
end

function CommandVM.value(value)
    local 
end

function CommandVM:Reset(): ()
    for key, _ in pairs(self.LocalVars) do
        self.LocalVars[key] = nil
    end
    while #self.Script > 0 do
        table.remove(self.Script, 1)
    end
end

function CommandVM:GlobalSet(var: string, value: any): ()
    table.insert(self.Script, {
        type = CommandVM.type(value),
        name = var,
        value = CommandVM.value(value)
    })
end

function CommandVM:SetGlobalVar(var: string, value: any): ()
    self.GlobalVars[var] = value
end

function CommandVM:SetLocalVar(var: string, value: any): ()
    self.LocalVars[var] = value
end

return CommandVM
