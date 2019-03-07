-----
--Ignite a player
-----
local PLUGIN = {}
PLUGIN.title = "Ignite"
PLUGIN.author = "Trist"
PLUGIN.description = "Ignite a player"
PLUGIN.perm = "Ignite"
PLUGIN.command = "ignite"
PLUGIN.usage = "<players> [1/0]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    local enabled = (tonumber(args[#args]) or 1) > 0
    for _,v in ipairs(players) do
        if (enabled) then v:Ignite(99999,1) else v:Extinguish() end
    end
    if (enabled) then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has ignited ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has extinguished ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end
function PLUGIN:PlayerDeath(ply)
    if (ply:IsOnFire()) then
        ply:Extinguish()
    end
end
if (SERVER) then
    function PLUGIN:Move(ply)
        if (ply:IsOnFire() and ply:WaterLevel() == 3 ) then
            ply:Extinguish()
            autobox:Notify( autobox.colors.blue, ply:Nick(), autobox.colors.white, " extinguished themselves by jumping into water." )
        end
    end
end

autobox:RegisterPlugin(PLUGIN)