-----
--Clear the PAC of somebody
-----
local PLUGIN = {}
PLUGIN.title = "Clear Pac"
PLUGIN.author = "Trist"
PLUGIN.description = "Clear the PAC of somebody"
PLUGIN.perm = "Clear PAC"
PLUGIN.command = "clearpac"
PLUGIN.usage = "<player>"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({args[1]})
    if (!autobox:ValidateSingleTarget(ply,players)) then return end
    players[1]:ConCommand("pac_clear_parts")
end

autobox:RegisterPlugin(PLUGIN)