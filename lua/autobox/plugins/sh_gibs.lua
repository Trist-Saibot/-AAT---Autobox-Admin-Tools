-----
--Removes Gibs
-----
local PLUGIN = {}
PLUGIN.title = "Gibs"
PLUGIN.author = "Trist"
PLUGIN.description = "Remove Gibs"
PLUGIN.perm = "Gibs"
PLUGIN.command = "gibs"
PLUGIN.usage = ""

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    autobox:Notify( autobox.colors.blue, ply:Nick(), autobox.colors.white, " has cleaned up gibs." )
    for _, v in pairs( ents.FindByClass( "gib" ) ) do
        v:Remove()
    end
end

autobox:RegisterPlugin(PLUGIN)