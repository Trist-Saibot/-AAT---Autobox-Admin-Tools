-----
--Imitate a player
-----
local PLUGIN = {}
PLUGIN.title = "Imitate"
PLUGIN.author = "Trist"
PLUGIN.description = "Imitate a player"
PLUGIN.perm = "Imitate"
PLUGIN.command = "im"
PLUGIN.usage = "<player> <message>"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({args[1] or ply})
    if (!autobox:ValidateSingleTarget(ply,players)) then return end
    if (!autobox:ValidateBetterThan(ply,players[1])) then return end
    local msg = table.concat( args, " ", 2 )
    if (#msg > 1) then
        players[1]:Say(msg)
    end
end

autobox:RegisterPlugin(PLUGIN)