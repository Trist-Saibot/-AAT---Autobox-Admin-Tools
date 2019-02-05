-----
--Set a player's speed
-----
local PLUGIN = {}
PLUGIN.title = "Speed"
PLUGIN.author = "Trist"
PLUGIN.description = "Set a player's speed"
PLUGIN.perm = "Speed"
PLUGIN.command = "speed"
PLUGIN.usage = "<players> [speed]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if(!autobox:ValidateHasTarget(ply,players))then return end
    local speed = tonumber(args[#args]) or 250
    for _,v in ipairs(players)do
        GAMEMODE:SetPlayerSpeed(v,speed,speed*2)
    end
    if(#players==1 and players[1]==ply)then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has set their speed to ",autobox.colors.red,speed,autobox.colors.white,".")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has set the speed of ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white," to ",autobox.colors.red,speed,autobox.colors.white,".")
    end
end

autobox:RegisterPlugin(PLUGIN)