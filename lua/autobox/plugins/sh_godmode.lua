-----
--Toggle godmode on a player
-----
local PLUGIN = {}
PLUGIN.title = "Godmode"
PLUGIN.author = "Trist"
PLUGIN.description = "Toggle godmode on a player"
PLUGIN.perm = "God"
PLUGIN.command = "god"
PLUGIN.usage = "<players> [1/0]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({ply,unpack(args)})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    local enabled = (tonumber(args[#args]) or 1) > 0
    for _,v in ipairs(players) do
        if (enabled) then v:GodEnable() else v:GodDisable() end
        v.AAT_God = enabled
    end
    if (enabled) then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has enabled godmode for ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has disabled godmode for ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end
function PLUGIN:PlayerSpawn(ply)
    if (ply.AAT_God) then ply:GodEnable() end
end

autobox:RegisterPlugin(PLUGIN)