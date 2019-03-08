-----
--Kill a player
-----
local PLUGIN = {}
PLUGIN.title = "Slay"
PLUGIN.author = "Trist"
PLUGIN.description = "Kill a player"
PLUGIN.perm = "Slay"
PLUGIN.command = "slay"
PLUGIN.usage = "[players]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    for _, v in ipairs(players) do
        v:Kill()
        v:SetFrags(v:Frags() + 1)
    end
    autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has slain ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
end

autobox:RegisterPlugin(PLUGIN)