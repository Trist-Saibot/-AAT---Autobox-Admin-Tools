-----
--Make a player enter a vehicle
-----
local PLUGIN = {}
PLUGIN.title = "Enter"
PLUGIN.author = "Trist"
PLUGIN.description = "Make a player enter a vehicle"
PLUGIN.perm = "Enter Vehicle"
PLUGIN.command = "enter"
PLUGIN.usage = "[player]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local vehicle = ply:GetEyeTrace().Entity
    if(!vehicle:IsValid() or !vehicle:IsVehicle()) then
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"You are not looking at a vehicle!")
    else
        local players = autobox:FindPlayers({args[1] or ply:SteamID()})
        if(!autobox:ValidateSingleTarget(ply,players))then return end
        if(vehicle:GetDriver():IsValid())then vehicle:GetDriver():ExitVehicle() end
        players[1]:EnterVehicle(vehicle)
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has forced ",autobox.colors.red,players[1]:Nick(),autobox.colors.white," into a vehicle.")
    end
end

autobox:RegisterPlugin(PLUGIN)