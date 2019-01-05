-----
--Make a player exit a vehicle
-----
local PLUGIN = {}
PLUGIN.title = "Exit"
PLUGIN.author = "Trist"
PLUGIN.description = "Make a player exit a vehicle"
PLUGIN.perm = "Exit Vehicle"
PLUGIN.command = "exit"
PLUGIN.usage = "[players]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if(!autobox:ValidateHasTarget(ply,players))then return end
    local hits = {}
    for _,v in pairs(players)do
        if(v:GetVehicle():IsValid())then v:ExitVehicle() table.insert(hits,v) end
    end
    if(#hits>0)then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has forced ",autobox.colors.red,autobox:CreatePlayerList(hits),autobox.colors.white," out of their vehicle.")
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"None of the matching players were in vehicles.")
    end
end

autobox:RegisterPlugin(PLUGIN)
