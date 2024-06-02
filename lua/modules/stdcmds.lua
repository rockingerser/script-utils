-- Standard commands
return (function(VM)
    VM:CreateCommand({
        name = "echo",
        callback = function(data)
            VM:Print(data)
        end,
        level = 0,
        args = {
            {
                name = "data",
                description = "The data to print."
            }
        },
        description = "Prints data to the console",
        returns = { "nil" }
    })
    VM:CreateCommand({
        name = "true",
        callback = function()
            return true
        end,
        level = 0,
        description = "Returns true",
        returns = { "boolean" }
    })
    VM:CreateCommand({
        name = "false",
        callback = function()
            return false
        end,
        level = 0,
        description = "Returns false",
        returns = { "boolean" }
    })
end)
