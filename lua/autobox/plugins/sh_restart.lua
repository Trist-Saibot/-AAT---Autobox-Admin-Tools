-----
--Restart the server
-----
local PLUGIN = {}
PLUGIN.title = "Restart"
PLUGIN.author = "Trist"
PLUGIN.description = "Restart the server"
PLUGIN.perm = "Server Restart"
PLUGIN.command = "restart"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has restarted the server.")
    RunConsoleCommand("_restart")
end

autobox:RegisterPlugin(PLUGIN)