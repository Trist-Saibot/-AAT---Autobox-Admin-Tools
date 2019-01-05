-----
--Changes the default hp bar
-----
local PLUGIN = {}
PLUGIN.title = "HPBox"
PLUGIN.author = "Trist"
PLUGIN.description = "Changes the default hp bar"
PLUGIN.suggestions = {}

function PLUGIN:HUDShouldDraw(name)
    if(name=="CHudHealth" or name=="CHudBattery")then
        return false
    end
end

autobox:RegisterPlugin(PLUGIN)