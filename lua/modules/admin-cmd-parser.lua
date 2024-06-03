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
    local CmdName = self.script:match("^[A-Za-z]+", self.i)
    if CmdName == nil then
        self.error("syntaxerror: Expected command", self.i)
    end
    self.i += #CmdName
    local Cmd = self.VM.Commands[CmdName:upper()]
    if Cmd == nil then
        self.error(string.format("nameerror: Command %q not found", CmdName), init)
    end
    return Cmd
end

function Parser:ParseNumber(init)
    self.i = init
    local number = self.script:match("%S+", self.i)
    if number == nil or tonumber(number) == nil then
        return
    end
    self.i += #number
    return { tonumber(number) }
end

function Parser:ParseStringData(init)
    self.i = init
    if self.script:sub(self.i, self.i) ~= "\"" then
        return
    end

    local str = ""
    self.i += 1

    while self.script:sub(self.i, self.i) ~= "\"" do
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
    end

    self.i += 1
    return { str }
end

function Parser:ParseArrayTableArgs(init)
    self.i = init
    if self.script:sub(self.i, self.i) ~= "[" then
        return
    end
    
    local parsedEntries = {}
    self.i += 1

    while true do
        while self.script:sub(self.i, self.i):find("%s") do
            self.i += 1
            if self.i > #self.script then
                self.error("syntaxerror: Unexpected end", self.i)
            end
        end
        if self.script:sub(self.i, self.i) == "]" then
            break
        end

        table.insert(parsedEntries, self:ParseArg())
    end
    self.i += 1
    return { parsedEntries }
end

function Parser:ParsePlName(init)
    self.i = init
    if self.script:sub(self.i, self.i) ~= "<" then
        return
    end

    local str = ""
    self.i += 1

    while self.script:sub(self.i, self.i) ~= ">" do
        local char = self.script:sub(self.i, self.i)
        str = str..char
        self.i += 1
        if self.i > #self.script then
            return
        end
    end

    self.i += 1
    return { str, self.VM.datatypes.player }
end

function Parser:ParseArg()
    local parsed = nil
    if self.script:sub(self.i, self.i):find("[A-Za-z]") then
        local command = self:ParseCommand(self.i)
        local cmdArgs = self:ParseArgs(command)
        parsed = self.VM.call(command.name, unpack(cmdArgs))
    else
        local init = self.i
        parsed = self:ParseNumber(init) or self:ParseStringData(init) or self:ParseArrayTableArgs(init) or self:ParsePlName(init)
        if parsed == nil then
            self.error(string.format("syntaxerror: Unexpected token %q", self.script:sub(
                self.i,
                self.i
            )), self.i)
        end
        parsed = self.VM.const(unpack(parsed))
    end

    return parsed
end

function Parser:ParseArgs(forCommand)
    local args = forCommand.args or {}
    local parsedArgs = {}
    local numParsedArgs = 0

    for _, arg in ipairs(args) do
        while self.script:sub(self.i, self.i):find("%s") do
            self.i += 1
        end

        if self.i > #self.script or self.script:sub(self.i, self.i) == self.CmdPrefix then
            self.error(string.format("error: Command %q takes %d arguments. Got %d", forCommand.name, #args, numParsedArgs), self.i)
        end

        table.insert(parsedArgs, self:ParseArg())
        numParsedArgs += 1
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
            while self.script:sub(self.i, self.i):find("%s") do
                self.i += 1
            end
            local command = self:ParseCommand(self.i)
            local cmdArgs = self:ParseArgs(command)
            table.insert(output, self.VM.call(command.name, unpack(cmdArgs)))
        else
            self.error(string.format("syntaxerror: Expected %q", self.CmdPrefix), self.i)
        end
    end

    return output
end

--[[
local parser = Parser.new(vm)
vm:Execute(parser:ParseString("!greet <hesok>"))
]]

return Parser
