-----
--Clean up the decals
-----
local PLUGIN = {}
PLUGIN.title = "Decals"
PLUGIN.author = "Trist"
PLUGIN.description = "remove all decals from the map"
PLUGIN.perm = "Decal Cleanup"
PLUGIN.command = "decals"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has cleaned up the decals.")
    for _,v in ipairs(player.GetAll())do
        v:ConCommand("r_cleardecals")
    end
end

autobox:RegisterPlugin(PLUGIN)