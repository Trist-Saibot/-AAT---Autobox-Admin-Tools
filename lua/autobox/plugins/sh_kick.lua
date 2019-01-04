-----
--Kick a player
-----
local PLUGIN = {}
PLUGIN.title = "Kick"
PLUGIN.author = "Trist"
PLUGIN.description = "Kick a player"
PLUGIN.perm = "Kick"
PLUGIN.command = "kick"
PLUGIN.usage = "<player> [reason]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({args[1]})
    if(!autobox:ValidateSingleTarget(ply,players))then return end
    if(!autobox:ValidateBetterThan(ply,players[1]))then return end

    local reason = table.concat(args," ",2) or ""
    if(#reason==0 or reason == "No reason")then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has kicked ",autobox.colors.red,players[1]:Nick(),autobox.colors.white,".")
        players[1]:Kick("No reason specified.")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has kicked ",autobox.colors.red,players[1]:Nick(),autobox.colors.white," with the reason \""..reason.."\".")
        players[1]:Kick(reason)
    end
end

autobox:RegisterPlugin(PLUGIN)