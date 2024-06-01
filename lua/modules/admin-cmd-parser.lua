-- Simple Admin Commands Parser

local Parser = {
    parseStatus = {
        EXPECTING_PREFIX = "\00",
        EXPECTING_CMD_NAME = "\01",
        EXPECTING_ARGS = "\02"
    }
}
Parser.__index = Parser

function Parser.new(VM)
    local self = setmetatable({}, Parser)

    self.CmdPrefix = "!"
    self.LocalPrefix = "$"
    self.GlobalPrefix = "&"
    self.VM = VM

    return self
end

function Parser:ParseString(script)
    local Whitespace = true
    local Output = {}

    local i = 0

    local function 
    while i < #script do
        i += 1

        local char = script:sub(i, i)

        if char:find("%s") then
            continue
        end

        if char == self.CmdPrefix then
            local CmdName = script:match("%w*", i + 1)
            if CmdName == nil then
                CmdName = ""
            end
            i += #CmdName
            print(CmdName)
        end
    end

    return Output
end

local parser = Parser.new()

parser:ParseString("!helllo")

return Parser
