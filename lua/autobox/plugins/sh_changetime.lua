-----
--Change a player's playtime
-----
local PLUGIN = {}
PLUGIN.title = "Edit Playtime"
PLUGIN.author = "Trist"
PLUGIN.description = "Change a player's playtime"
PLUGIN.perm = "Edit Playtime"
PLUGIN.command = "changetime"
PLUGIN.usage = "<player> <playtime>"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({args[1]})
    if(!autobox:ValidateSingleTarget(ply,players))then return end
    local time = tonumber(args[#args])
    if(isnumber(time))then
        ply.Playtime = time
        ply.LastSave = autobox:SyncTime()
        autobox:SyncPlaytime()
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"Invalid playtime specified.")
    end    
end

autobox:RegisterPlugin(PLUGIN)