-----
--Hotload plugins
-----
local PLUGIN = {}
PLUGIN.title = "Hotload Plugins"
PLUGIN.author = "Trist"
PLUGIN.description = "Allows you to hotload unloaded plugins"
PLUGIN.command = "hotload"
PLUGIN.perm = "Plugin Hotloading"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    autobox:HotloadPlugins()
end

autobox:RegisterPlugin(PLUGIN)
