-----
--Reloads Plugins
-----
local PLUGIN = {}
PLUGIN.title = "Reload Plugin"
PLUGIN.author = "Trist"
PLUGIN.description = "Allows you to reload a plugin"
PLUGIN.command = "reloadplugin"
PLUGIN.usage = "<plugin>"
PLUGIN.perm = "Plugin Reloading"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local arg = table.concat(args," ")
    if (arg) then
        local plugin = autobox:FindPlugin(arg)
        if (plugin) then
            autobox:ReloadPlugin(plugin)
            autobox:Notify({Override = true,Icon = "plugin",IconTooltip = "Plugin Reload"},autobox.colors.blue,ply:Nick(), autobox.colors.white, " has reloaded plugin ", autobox.colors.red, plugin.title, autobox.colors.white, "." )
        else
            autobox:Notify(ply, autobox.colors.red, "Plugin '" .. tostring(arg) .. "' not found!")
        end
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"No plugin specified.")
    end
end

autobox:RegisterPlugin(PLUGIN)
