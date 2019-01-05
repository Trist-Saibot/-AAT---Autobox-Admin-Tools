-----
--DEBUG COMMAND FOR TESTING
-----
local PLUGIN = {}
PLUGIN.title = "Debug"
PLUGIN.author = "Trist"
PLUGIN.description = "DEBUG COMMAND FOR TESTING"
PLUGIN.command = "debug"
PLUGIN.usage = "lol I forgot to remove this"

function PLUGIN:Call(ply,args)
end

autobox:RegisterPlugin(PLUGIN)