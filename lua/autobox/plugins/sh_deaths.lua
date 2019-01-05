-----
--Set the deaths of a player
-----
local PLUGIN = {}
PLUGIN.title = "Deaths"
PLUGIN.author = "Trist"
PLUGIN.description = "Set the deaths of a player"
PLUGIN.perm = "Deaths"
PLUGIN.command = "deaths"
PLUGIN.usage = "<players> [deaths]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if(!autobox:ValidateHasTarget(ply,players))then return end
    local deaths = tonumber(args[#args]) or 0
    for _,v in ipairs(players)do
        v:SetDeaths(deaths)
    end    
    if(#players==1 and players[1]==ply)then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has set their deaths to ",autobox.colors.red,deaths,autobox.colors.white,".") 
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has set the deaths of ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white," to ",autobox.colors.red,deaths,autobox.colors.white,".") 
    end
end

autobox:RegisterPlugin(PLUGIN)