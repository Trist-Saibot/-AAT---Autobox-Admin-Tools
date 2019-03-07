-----
--Run a console command on someone
-----
local PLUGIN = {}
PLUGIN.title = "Client Exec"
PLUGIN.author = "Trist"
PLUGIN.description = "Run a console command on someone"
PLUGIN.perm = "Client Exec"
PLUGIN.command = "cexec"
PLUGIN.usage = "<players> <command> [args]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({args[1]})
    if (!autobox:ValidateSingleTarget(ply,players)) then return end
    if (!autobox:ValidateBetterThan(ply,players[1])) then return end
    local command = table.concat(args," ",2)
    if (#command > 0) then
        players[1]:ConCommand(command)
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"No command specified.")
    end
end

autobox:RegisterPlugin(PLUGIN)