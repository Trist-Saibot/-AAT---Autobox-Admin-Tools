-----
--Noclip a player
-----
local PLUGIN = {}
PLUGIN.title = "Noclip"
PLUGIN.author = "Trist"
PLUGIN.description = "Noclip a player"
PLUGIN.perm = "Noclip"
PLUGIN.command = "noclip"
PLUGIN.usage = "<players> [1/0]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    local enabled = (tonumber(args[#args]) or 1) > 0
    if (#args < 1) then
        enabled = ply:GetMoveType() != MOVETYPE_NOCLIP
    end
    for _,v in ipairs(players) do
        if (enabled) then v:SetMoveType(MOVETYPE_NOCLIP) else v:SetMoveType(MOVETYPE_WALK) end
    end
    if (enabled) then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has noclipped ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has un-noclipped ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end

autobox:RegisterPlugin(PLUGIN)