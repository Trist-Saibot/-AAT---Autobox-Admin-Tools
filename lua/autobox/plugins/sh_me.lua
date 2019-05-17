-----
-- emote command
-----

local PLUGIN = {}
PLUGIN.title = "Me"
PLUGIN.author = "Trist"
PLUGIN.description = "Represent an action"
PLUGIN.perm = "Me"
PLUGIN.command = "me"
PLUGIN.usage = "<action>"
function PLUGIN:Call( ply, args )
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local action = table.concat( args, " " )
    if ( #action > 0 ) then
        autobox:Notify( autobox.colors.blue, ply:Nick(), autobox.colors.white, " " .. tostring( action ) )
    end
end

autobox:RegisterPlugin( PLUGIN )