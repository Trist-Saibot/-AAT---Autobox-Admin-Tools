-----
--Show the current time
-----
local PLUGIN = {}
PLUGIN.title = "Time"
PLUGIN.author = "Trist"
PLUGIN.description = "Show the current time"
PLUGIN.command = "time"


function PLUGIN:Call( ply, args )
    autobox:Notify(ply,{Override = true,Icon = "clock",IconTooltip = "Time"},autobox.colors.white,"It is now ",autobox.colors.red,os.date("%H:%M"),autobox.colors.white,".")
end

autobox:RegisterPlugin( PLUGIN )