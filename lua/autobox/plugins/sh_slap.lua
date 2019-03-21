-----
--Slap a player
-----
local PLUGIN = {}
PLUGIN.title = "Slap"
PLUGIN.author = "Trist"
PLUGIN.description = "Slap a player"
PLUGIN.perm = "Slap"
PLUGIN.command = "slap"
PLUGIN.usage = "<players> [damage]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    local dmg = tonumber(args[#args]) or 10
    for _,v in ipairs(players) do
        v:SetHealth(v:Health() - dmg)
        v:ViewPunch(Angle(-10,0,0))
        if (v:Health() < 1) then v:Kill() end
    end
    if (#players == 1 and players[1] == ply) then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has slapped themselves with ",autobox.colors.red,dmg,autobox.colors.white," damage.")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has slapped ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white," with ",autobox.colors.red,dmg,autobox.colors.white," damage.")
    end
end
autobox:RegisterPlugin(PLUGIN)