-----
--Physgun a player
-----
local PLUGIN = {}
PLUGIN.title = "Physgun Players"
PLUGIN.author = "Trist"
PLUGIN.description = "Physgun a player"
PLUGIN.perm = "Physgun Players"

function PLUGIN:PhysgunPickup(ply,tar)
    if (tar:IsPlayer() and ply:AAT_HasPerm(perm) and ply:AAT_BetterThanOrEqual(tar)) then
        tar.AAT_PickedUp = true
        tar:SetMoveType( MOVETYPE_NOCLIP )
        return true
    end
end

function PLUGIN:PhysgunDrop(ply,tar)
    if (tar:IsPlayer()) then
        tar.AAT_PickedUp = false
        tar:SetMoveType( MOVETYPE_WALK )
        return true
    end
end

function PLUGIN:PlayerNoclip( ply )
    if (ply.AAT_PickedUp) then return false end
end

autobox:RegisterPlugin(PLUGIN)