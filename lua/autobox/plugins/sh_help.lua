-----
--View the usage of a command, if available
-----

local PLUGIN = {}
PLUGIN.title = "Help"
PLUGIN.author = "Trist"
PLUGIN.description = "View the usage of a command, if available"
PLUGIN.command = "help"
PLUGIN.usage = "<command>"

function PLUGIN:Call(ply,args)
    if (#args > 0) then
        local plug = nil
        for _,v in ipairs(autobox.plugins) do
            if (v.command == string.lower(args[1])) then
               plug = v
               break
            end
        end
        if (plug) then
            if (!(plug.usage and plug.description)) then
                autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"No help is available for that command.")
            else
                if (plug.description) then autobox:Notify(ply,autobox.colors.blue,plug.title,autobox.colors.white," - " .. plug.description) end
                if (plug.usage) then autobox:Notify(ply,autobox.colors.white,"Usage: !" .. plug.command .. " " .. plug.usage) end
            end
        else
            autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"Command not found. Did you type it in correctly?")
        end
        return
    end
    autobox:Notify(ply,autobox.colors.blue,PLUGIN.title,autobox.colors.white," - " .. PLUGIN.description)
    autobox:Notify(ply,autobox.colors.white,"Usage: !" .. PLUGIN.command .. " " .. PLUGIN.usage)
end

autobox:RegisterPlugin(PLUGIN)