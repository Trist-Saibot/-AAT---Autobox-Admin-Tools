-----
--Find Playtime
-----
local PLUGIN = {}
PLUGIN.title = "Playtime"
PLUGIN.author = "Trist"
PLUGIN.description = "View a player's playtime"
PLUGIN.command = "playtime"
PLUGIN.usage = "<player>"

function PLUGIN:Call(ply,args)
    local players = autobox:FindPlayers({args[1] or ply:SteamID()})
    if(!autobox:ValidateSingleTarget(ply,players))then return end
    autobox:Notify(ply,autobox.colors.blue,players[1]:Nick(),autobox.colors.white," has spent ",autobox.colors.red,autobox:FormatTime(players[1]:AAT_GetPlaytime()),autobox.colors.white," on this server.")
end

autobox:RegisterPlugin(PLUGIN)