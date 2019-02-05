-----
--Strip a player's weapons
-----
local PLUGIN = {}
PLUGIN.title = "Strip Weapons"
PLUGIN.author = "Trist"
PLUGIN.description = "Strip a player's weapons"
PLUGIN.perm = "Strip"
PLUGIN.command = "strip"
PLUGIN.usage = "[players]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({args[1] or ply})
    if(!autobox:ValidateHasTarget(ply,players))then return end
    for _,v in ipairs(players)do
        v:StripWeapons()
    end
    if(#players==1 and players[1]==ply)then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has stripped themself of all weapons.")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has stripped the weapons of ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")        
    end
end

autobox:RegisterPlugin(PLUGIN)