-----
-- Mute a player
-----
local PLUGIN = {}
PLUGIN.title = "Mute"
PLUGIN.author = "Trist"
PLUGIN.description = "Mute a player"
PLUGIN.perm = "Mute"
PLUGIN.command = "mute"
PLUGIN.usage = "<players> [1/0]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    local enabled = (tonumber(args[#args]) or 1) > 0
    for _,v in ipairs(players) do
        v.AAT_Muted = enabled
    end
    if (enabled) then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has muted ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has unmuted ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end

function PLUGIN:PlayerCanHearPlayersVoice(listener, talker)
    if (talker.AAT_Muted) then return false end
end


autobox:RegisterPlugin(PLUGIN)