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
            level = 0,
            callback = function(...)
                return unpack(...)
            end
        }
    }
}
