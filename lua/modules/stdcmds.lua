-- Basic commands
return (function(VM)
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer

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
        description = "Prints data to the console"
    })
    VM:CreateCommand({
        name = "true",
        callback = function()
            return true
        end,
        level = 0,
        description = "Returns true"
    })
    VM:CreateCommand({
        name = "false",
        callback = function()
            return false
        end,
        level = 0,
        description = "Returns false"
    })
    VM:CreateCommand({
        name = "nil",
        callback = function()
            return nil
        end,
        level = 0,
        description = "Returns nil"
    })
    VM:CreateCommand({
        name = "others",
        callback = function()
            local players = Players:GetPlayers()
            table.remove(players, table.find(players, Player))
            return players
        end,
        level = 3,
        description = "Returns a table containing all the players in the game but you"
    })
    VM:CreateCommand({
        name = "all",
        callback = function()
            return Players:GetPlayers()
        end,
        level = 3,
        description = "Returns a table containing all the players in the game",
    })
    VM:CreateCommand({
        name = "me",
        callback = function()
            return Player
        end,
        level = 0,
        description = "Returns a player (yourself)"
    })
end)
