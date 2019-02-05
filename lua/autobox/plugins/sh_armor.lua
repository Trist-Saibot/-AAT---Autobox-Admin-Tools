-----
--Set the armor of a player
-----
local PLUGIN = {}
PLUGIN.title = "Armor"
PLUGIN.author = "Trist"
PLUGIN.description = "Set the armor of a player"
PLUGIN.perm = "Armor"
PLUGIN.command = "armor"
PLUGIN.usage = "<players> [armor]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if(!autobox:ValidateHasTarget(ply,players))then return end
    local armor = tonumber(args[#args]) or 100
    for _,v in ipairs(players)do
        v:SetArmor(armor)
    end
    if(#players==1 and players[1]==ply)then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has set their armor to ",autobox.colors.red,armor,autobox.colors.white,".")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has set the armor of ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white," to ",autobox.colors.red,armor,autobox.colors.white,".")
    end
end
autobox:RegisterPlugin(PLUGIN)