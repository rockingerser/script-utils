-- Standard commands
return {
    vars = {
        HELP_PAGES = {
            type = "dictionary",
            value = {
                
            }
        }
    },
    commands = {
        {
            type = "getter",
            name = "echo",
            priority = math.huge,
            callback = function(...)
                return unpack(...)
            end
        }
    }
}
