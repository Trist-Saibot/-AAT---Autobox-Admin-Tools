-----
--Extinguish everything
-----
local PLUGIN = {}
PLUGIN.title = "Extinguish"
PLUGIN.author = "Trist"
PLUGIN.description = "Extinguish everything"
PLUGIN.perm = "Extinguish"
PLUGIN.command = "extinguish"


function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has extinguished all fires.")
    for _,v in ipairs(ents.GetAll())do
        v:Extinguish()
    end
end

autobox:RegisterPlugin(PLUGIN)