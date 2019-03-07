-----
--Set the frags of a player
-----
local PLUGIN = {}
PLUGIN.title = "Frags"
PLUGIN.author = "Trist"
PLUGIN.description = "Set the frags of a player"
PLUGIN.perm = "Frags"
PLUGIN.command = "frags"
PLUGIN.usage = "<players> [frags]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    local frags = tonumber(args[#args]) or 0
    for _,v in ipairs(players) do
        v:SetFrags(frags)
    end
    if (#players == 1 and players[1] == ply) then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has set their frags to ",autobox.colors.red,frags,autobox.colors.white,".")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has set the frags of ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white," to ",autobox.colors.red,frags,autobox.colors.white,".")
    end
end

autobox:RegisterPlugin(PLUGIN)