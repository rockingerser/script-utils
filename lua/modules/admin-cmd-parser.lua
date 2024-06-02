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

function Parser:ParseString(script)
    local output = {}
    local i = 0

    local function parseCommand(init)
        i = init
        local CmdName = script:match("%w+", i)
        if CmdName == nil then
            return
        end
        i += #CmdName
        local Cmd = self.VM.Commands[CmdName]
        if Cmd == nil then
            return
        end
        return Cmd
    end

    local function parseNumber(init)
        i = init
        local number = script:match("%d", i)
        if number == nil then
            return
        end
        i += #number
        return tonumber(number)
    end

    local function parseString(init)
        i = init
        if script:sub(i, i) ~= "\"" then
            return
        end

        local str = ""
        i += 1

        repeat
            local char = script:sub(i, i)
            if char == "\\" then
                if i + 1 > #script then
                    return
                end
                str = str..script:sub(i + 1, i + 1)
                i += 2
            else
                str = str..char
                i += 1
                if i > #script then
                    return
                end
            end
        until script:sub(i, i) == "\""

        return str
    end

    local function parseArrayTable()

    local function parsePlName(init)
        i = init
        if script:sub(i, i) ~= "<" then
            return
        end

        local str = ""
        i += 1

        repeat
            local char = script:sub(i, i)
            str = str..char
            i += 1
            if i > #script then
                return
            end
        until script:sub(i, i) == ">"

        return str
    end

    local function parseArgs(forCommand)
        local args = forCommand.args or {}
        local parsedArgs = {}

        for _, arg in ipairs(args) do
            --[[if arg. table.find(self.datatypes, arg.type) == nil then
                self.error(string.format("fatalerror: Command %q contains bad params and cannot be parsed", forCommand.name), i)
            end]]
            
            while script:sub(i, i):find("%s") do
                i += 1
            end

            local parsed
            if script:sub(i, i):find("%w") then
                local command = parseCommand()
                --[[if arg.type ~= nil and #arg.type command.returns ~= nil and #command.returns > 0 then
                    for _, Type in ipairs(command.returns) do
                        if table.find(arg.type, Type) == nil and (table.find(arg.type, "player") == nil and table.find(arg.type, "string") == nil or Type ~= "string" and Type ~= "player") then
                            self.error(string.format("typeerror: Cannot convert a %s into a %s", Type, table.concat(arg.type, " | ")), i)
                        end
                    end
                end]]
                local cmdArgs = parseArgs(command)
                parsed = self.VM.call(command.name, unpack(cmdArgs))
            else
                local init = i
                parsed = parseNumber(init) or parseString(init) 
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
