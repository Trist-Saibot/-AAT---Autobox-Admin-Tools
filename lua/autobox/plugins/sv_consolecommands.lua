-----
--Provides Console Commands
-----
local PLUGIN = {}
PLUGIN.title = "Console Commands"
PLUGIN.description = "Provides console commands to run plugins."
PLUGIN.author = "Trist"

function PLUGIN:GetArguments(allargs)
    local newargs = {}
    for i = 2,#allargs do
        table.insert(newargs,allargs[i])
    end
    return newargs
end

function PLUGIN:CCommand(ply,com,cargs)
    if (#cargs == 0 ) then return end
    local command = cargs[1]
    local args = self:GetArguments(cargs)

    for _,plugin in ipairs(autobox.plugins) do
        if (plugin.command == string.lower(command or "")) then
            plugin:Call(ply,args)
            return ""
        end
    end

    autobox:Notify( "Unknown command '" .. command .. "'")
end
concommand.Add("ev",function(ply,com,args) PLUGIN:CCommand(ply,com,args) end)
concommand.Add("evs",function(ply,com,args) autobox.silentNotify = true PLUGIN:CCommand(ply,com,args) autobox.silentNotify = false end)
autobox:RegisterPlugin(PLUGIN)