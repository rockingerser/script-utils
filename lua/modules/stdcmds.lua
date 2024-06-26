-- Basic commands
return (function(VM)
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local Rand = Random.new()

    VM:CreateCommand({
        name = { "yes", "on", "true" },
        callback = function()
            return true
        end,
        description = "Indica que una acción debería realizarse",
        getter = true
    })
    VM:CreateCommand({
        name = { "no", "off", "false" },
        callback = function()
            return false
        end,
        description = "Indica que una acción no debería realizarse",
        getter = true
    })
    VM:CreateCommand({
        name = "others",
        callback = function()
            local players = Players:GetPlayers()
            table.remove(players, table.find(players, Player))
            return players
        end,
        description = "Devuelve una lista de todos los otros jugadores en el servidor",
        getter = true
    })
    VM:CreateCommand({
        name = "all",
        callback = function()
            return Players:GetPlayers()
        end,
        description = "Devuelve una lista de todos los jugadores en el servidor",
        getter = true
    })
    VM:CreateCommand({
        name = { "me", "myself" }, -- 𝅘𝅥𝅮 Me, myself and I 𝅘𝅥𝅮
        callback = function()
            return Player
        end,
        description = "Devuelve al jugador que está ejecutando los comandos",
        getter = true
    })
    VM:CreateCommand({
        name = { "random", "randompl" },
        callback = function()
            local players = Players:GetPlayers()
            return players[Rand:NextInteger(1, #players)]
        end,
        description = "Devuelve un jugador aleatorio",
        getter = true
    })
end)
