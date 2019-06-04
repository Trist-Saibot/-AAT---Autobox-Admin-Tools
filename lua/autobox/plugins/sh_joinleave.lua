-----
-- Handles Join and Leave messages
-----

local PLUGIN = {}
PLUGIN.title = "JoinLeave"
PLUGIN.author = "Trist"
PLUGIN.description = "Handles Join and Leave messages"

function PLUGIN:ChatText( index, name, text, typ ) --disable joinleave
    if ( typ == "joinleave" ) then return true end
end

function PLUGIN:PlayerDisconnected( ply ) --show disconnect message
    autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has disconnected.")
end

autobox:RegisterPlugin(PLUGIN)