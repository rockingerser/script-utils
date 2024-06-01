-- Standard commands
return (function(VM)
    VM:CreateCommand({
        name = "echo",
        callback = function(data)
            VM:Print(data)
        end,
        level = 0,
        __data = {
            args = {
                {
                    name = "data",
                    datatypes = { "any" },
                    description = "The data to print."
                }
            },
            description = "Prints data to the console"
        }
    })
    VM:CreateCommand({
        name = "true",
        callback = function()
            return true
        end,
        level = 0
    })
    VM:CreateCommand({
        name = "false",
        callback = function()
            return false
        end,
        level = 0
    })
end)
