-- Basic commands
return (function(VM)
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local Rand = Random.new()

    VM:CreateCommand({
        name = { "si", "yes", "on", "true" },
        callback = function()
            return true
        end,
        description = "(Comando de entrada) si/yes/on/true -> booleano | Indica que una acción debería realizarse"
    })
    VM:CreateCommand({
        name = { "no", "off", "false" },
        callback = function()
            return false
        end,
        description = "(Comando de entrada) no/off/false -> booleano | Indica que una acción no debería realizarse"
    })
    VM:CreateCommand({
        name = { "vacio", "empty", "nil", "null" },
        callback = function()
            return nil
        end,
        description = "(DESUSO) (Comando de entrada) vacio/empty/nil/null -> ? | Omite el argumento de un comando como si no se hubiera especificado. Este comando está en desuso y será quitado en el futuro"
    })
    VM:CreateCommand({
        name = { "otros", "others" },
        callback = function()
            local players = Players:GetPlayers()
            table.remove(players, table.find(players, Player))
            return players
        end,
        description = "(Comando de entrada) otros/others -> [jugador ... jugador] | Devuelve una lista de todos los otros jugadores en el servidor"
    })
    VM:CreateCommand({
        name = { "todos", "all" },
        callback = function()
            return Players:GetPlayers()
        end,
        description = "(Comando de entrada) todos/all -> [jugador ... jugador] | Devuelve una lista de todos los jugadores en el servidor",
    })
    VM:CreateCommand({
        name = { "yo", "me", "myself" }, -- 𝅘𝅥𝅮 Me, myself and I 𝅘𝅥𝅮
        callback = function()
            return Player
        end,
        description = "(Comando de entrada) yo/me/myself -> jugador | Devuelve al jugador que está ejecutando los comandos"
    })
    VM:CreateCommand({
        name = { "aleatorio", "random", "randompl" }
        callback = function()
            local players = Players:GetPlayers()
            return players[Rand:NextInteger(1, #players)]
        end,
        level = 0,
        description = "(Comando de entrada) aleatorio/random/randompl -> jugador | Devuelve un jugador aleatorio"
    })
end)
