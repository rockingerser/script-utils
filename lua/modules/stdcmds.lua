-- Standard commands
return (function(VM)
    VM:CreateCommand({
        name = "echo",
        callback = function(data)
            VM:Print(data)
        end,
        level = 0,
        lib = StdLib,
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
    if game then
        local 

        VM:CreateCommand({
            name = "speed",
            callback = function(newSpeed)
                lo
            end
        })
    end
end)
