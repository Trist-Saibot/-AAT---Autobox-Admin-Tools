-----
--Respawn a player
-----
local PLUGIN = {}
PLUGIN.title = "Respawn"
PLUGIN.author = "Trist"
PLUGIN.description = "Respawn a player"
PLUGIN.perm = "Respawn"
PLUGIN.command = "respawn"
PLUGIN.usage = "[players]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({args[1] or ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    for _,v in ipairs(players) do
        v:Spawn()
    end
    if (#players == 1 and players[1] == ply) then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has respawned themself.")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has respawned ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end

autobox:RegisterPlugin(PLUGIN)