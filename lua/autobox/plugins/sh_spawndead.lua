-----
--Respawn all dead players
-----
local PLUGIN = {}
PLUGIN.title = "Spawn Dead Players"
PLUGIN.author = "Trist"
PLUGIN.description = "Respawn all dead players"
PLUGIN.perm = "Spawn Dead Players"
PLUGIN.command = "spawndead"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = {}
    for _,v in ipairs(player.GetAll()) do
        if (!v:Alive()) then
            v:Spawn()
            table.insert(players,v)
        end
    end
    if (#players > 0) then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has respawned ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"No players are currently dead.")
    end
end

autobox:RegisterPlugin(PLUGIN)