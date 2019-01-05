-----
--Set the health of a player
-----
local PLUGIN = {}
PLUGIN.title = "Health"
PLUGIN.author = "Trist"
PLUGIN.description = "Set the health of a player"
PLUGIN.perm = "Health"
PLUGIN.command = "hp"
PLUGIN.usage = "<players> [health]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if(!autobox:ValidateHasTarget(ply,players))then return end
    local health = tonumber(args[#args]) or 100
    for _,v in ipairs(players)do
        v:SetHealth(health)
    end    
    if(#players==1 and players[1]==ply)then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has set their health to ",autobox.colors.red,health,autobox.colors.white,".") 
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has set the health of ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white," to ",autobox.colors.red,health,autobox.colors.white,".") 
    end
end
autobox:RegisterPlugin(PLUGIN)