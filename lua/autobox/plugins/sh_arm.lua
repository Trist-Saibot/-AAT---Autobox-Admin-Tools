-----
--Arm a player with the default loadout
-----
local PLUGIN = {}
PLUGIN.title = "Arm"
PLUGIN.author = "Trist"
PLUGIN.description = "Arm a player with the default loadout"
PLUGIN.perm = "Arm"
PLUGIN.command = "arm"
PLUGIN.usage = "[players]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({args[1] or ply})
    if(!autobox:ValidateHasTarget(ply,players))then return end
    for _,v in ipairs(players)do
        GAMEMODE:PlayerLoadout(v)
    end
    if(#players==1 and players[1]==ply)then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has armed themself.")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has armed ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end

autobox:RegisterPlugin(PLUGIN)