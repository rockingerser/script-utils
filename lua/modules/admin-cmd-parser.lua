-- Simple Admin Commands Parser

local Parser = {
    datatypes = {
        "number",
        "string",
        "boolean",
        "table",
        "player",
        "nil"
    }
}
Parser.__index = Parser

function Parser.new(VM)
    local self = setmetatable({}, Parser)

    self.CmdPrefix = "!"
    --self.LocalPrefix = "$" Supporting them in a future
    --self.GlobalPrefix = "&"
    self.VM = VM

    return self
end

function Parser.error(msg, where)
    error(string.format( "%d: %s", where, msg))
    --[[return {
        ok = false,
        msg = msg,
        where = where
    }]]
end


function Parser:ParseCommand(init)
    self.i = init
    local CmdName = self.script:match("%w+", self.i)
    if CmdName == nil then
        return
    end
    self.i += #CmdName
    local Cmd = self.VM.Commands[CmdName]
    if Cmd == nil then
        return
    end
    return Cmd
end

function Parser:ParseNumber(init)
    self.i = init
    local number = self.script:match("%d", self.i)
    if number == nil then
        return
    end
    self.i += #number
    return tonumber(number)
end

function Parse:ParseString(init)
    self.i = init
    if self.script:sub(self.i, self.i) ~= "\"" then
        return
    end

    local str = ""
    self.i += 1

    repeat
        local char = self.script:sub(self.i, self.i)
        if char == "\\" then
            if self.i + 1 > #self.script then
                return
            end
            str = str..self.script:sub(self.i + 1, self.i + 1)
            self.i += 2
        else
            str = str..char
            self.i += 1
            if self.i > #self.script then
                return
            end
        end
    until self.script:sub(self.i, self.i) == "\""

    return str
end

function Parse:ParseArrayTableArgs(init)
    self.i = init
    if self.script:sub(self.i, self.i) ~= "[" then
        return
    end
    
end

function Parser:ParsePlName(init)
    self.i = init
    if self.script:sub(self.i, self.i) ~= "<" then
        return
    end

    local str = ""
    self.i += 1

    repeat
        local char = self.script:sub(self.i, self.i)
        str = str..char
        self.i += 1
        if self.i > #self.script then
            return
        end
    until self.script:sub(self.i, self.i) == ">"

    return str
end

function Parser:ParseArgs(forCommand)
    local args = forCommand.args or {}
    local parsedArgs = {}

    for _, arg in ipairs(args) do
        while self.script:sub(self.i, self.i):find("%s") do
            self.i += 1
        end

        local parsed = nil
        if self.script:sub(self.i, self.i):find("%w") then
            local command = self:ParseCommand()
            local cmdArgs = self:ParseArgs(command)
            parsed = self.VM.call(command.name, unpack(cmdArgs))
        else
            local init = self.i
            parsed = self:ParseNumber(init) or self:ParseString(init) or self:ParseArrayTableArgs(init) or self:ParsePlName(init)
        end
        table.insert(parsedArgs, parsed)
    end
    return parsedArgs
end

function Parser:ParseString(script)
    local output = {}
    self.script = script
    self.i = 0

    while self.i < #self.script do
        self.i += 1

        local char = self.script:sub(self.i, self.i)

        if char:find("%s") then
            continue
        end

        if char == self.CmdPrefix then
            self.i += 1
            local command = self:ParseCommand()
            local cmdArgs = self:ParseArgs(command)
            table.insert(output, self.VM.call(command.name, unpack(cmdArgs)))
        else
            self.error(string.format("syntaxerror: Expected %q", self.CmdPrefix), i)
        end
    end

    return output
end

local parser = Parser.new()

parser:ParseString([[!helllo]])

return Parser
