-----
--Run a console command on the server
-----
local PLUGIN = {}
PLUGIN.title = "RCON"
PLUGIN.author = "Trist"
PLUGIN.description = "Run a console command on the server"
PLUGIN.perm = "RCON"
PLUGIN.command = "rcon"
PLUGIN.usage = "<command> [arg1] [arg2] ..."

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    if(#args>0)then
        RunConsoleCommand(unpack(args))
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"No command specified.")
    end
end

autobox:RegisterPlugin(PLUGIN)