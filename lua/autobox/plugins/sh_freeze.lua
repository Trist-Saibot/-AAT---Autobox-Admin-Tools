-----
--Freeze a player
-----
local PLUGIN = {}
PLUGIN.title = "Freeze"
PLUGIN.author = "Trist"
PLUGIN.description = "Freeze a player"
PLUGIN.perm = "Freeze"
PLUGIN.command = "freeze"
PLUGIN.usage = "[players] [1/0]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    local enabled = (tonumber(args[#args]) or 1) > 0
    for _,v in ipairs(players) do
        if (enabled) then
            v:Lock()
        else
            v:UnLock()
        end
    end
    if (enabled) then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has frozen ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has unfrozen ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end

autobox:RegisterPlugin(PLUGIN)