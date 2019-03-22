-----
--Spectate a player
-----
local PLUGIN = {}
PLUGIN.title = "Spectate"
PLUGIN.author = "Trist"
PLUGIN.description = "Spectate a player"
PLUGIN.perm = "Spectate"
PLUGIN.command = "spec"
PLUGIN.usage = "<player> or nothing to disable"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({args[1]})
    if (#players == 0 and ply:GetNWBool("AAT_Spectating",false)) then
        --cancel spectating if no args
        ply:Spectate( OBS_MODE_NONE )
        ply:UnSpectate()
        ply:SetMoveType( MOVETYPE_WALK )
        ply:SetNWBool("AAT_Spectating",false)
        ply:Spawn()
        timer.Simple(0.05, function() ply:SetPos(ply.AAT_SpecOrigPos) ply.AAT_SpecOrigPos = nil end)
        return
    end
    if (!autobox:ValidateSingleTarget(ply,players)) then return end
    if (players[1] == ply) then
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"You cannot spectate yourself!")
        return
    end
    --initiate spectating
    ply.AAT_SpecOrigPos = ply:GetPos()
    ply:SetNWBool("AAT_Spectating", true)
    ply:Spectate( OBS_MODE_CHASE )
    ply:SpectateEntity(players[1])
    ply:SetMoveType( MOVETYPE_OBSERVER )
    ply:StripWeapons()
end

autobox:RegisterPlugin(PLUGIN)