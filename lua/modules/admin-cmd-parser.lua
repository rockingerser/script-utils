-- Simple Admin Commands Parser

local Parser = {
    datatypes = {
        "number",
        "string",
        "boolean",
        "array",
        "player",
        "any"
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

function Parser:ParseString(script)
    local output = {}
    local i = 0

    local function parseCommand()
        local CmdName = script:match("%w*", i + 1)
        if CmdName == nil then
            self.error("syntaxerror: Expected command", i)
        end
        i += #CmdName
        local Cmd = self.VM.Commands[CmdName]
        if Cmd == nil then
            self.error(string.format("nameerror: Command %q not found", CmdName), i)
        end
        return Cmd
    end

    local function parseNumber()
        local number = script:match("%d", i)
        if number == nil then
            self.error("syntaxerror: Expected number", i)
        end
        i += #number
        return tonumber(number)
    end

    local function parseString()
        if script:sub(i, i) ~= "\"" then
            self.error("syntaxerror: Expected string", i)
        end

        local str = ""
        local startIndex = i
        i += 1

        repeat
            local char = script:sub(i, i)
            if char == "\\" then
                if i + 1 > #script then
                    self.error("syntaxerror: Malformed string", startIndex)
                end
                str = str..script:sub(i + 1, i + 1)
                i += 2
            else
                str = str..char
                i += 1
                if i > #script then
                    self.error("syntaxerror: Malformed string", startIndex)
                end
            end
        until script:sub(i, i) == "\""
    end

    local function parseArgs(forCommand)
        local data = forCommand.__data or {}
        local args = data.args or {}
        local parsedArgs = {}

        for _, arg in ipairs(args) do
            if table.find(self.datatypes, arg.type) == nil or arg.name == nil then
                error(string.format("fatalerror: Command %q contains bad params and cannot be parsed", forCommand.name), i)
            end
            
            local parsed
            while script:sub(i, i):find("%s") do
                i += 1
            end
            if script:sub(i, i):find("%w") then
                local command = parseCommand()
                local cmdArgs = parseArgs(command)
                parsed = self.VM.call(command.name, unpack(cmdArgs))
            elseif arg.type == "number" then
                parsed = self.VM.const(parseNumber())
            elseif arg.type == "string" then
                parsed = self.VM.const(parseString())
            end
            table.insert(parsedArgs, parsed)
        end

        return parsedArgs
    end

    while i < #script do
        i += 1

        local char = script:sub(i, i)

        if char:find("%s") then
            continue
        end

        if char == self.CmdPrefix then
            i += 1
            local command = parseCommand()
            local cmdArgs = parseArgs(command)
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
