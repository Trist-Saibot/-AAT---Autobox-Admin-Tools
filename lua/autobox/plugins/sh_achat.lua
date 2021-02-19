-----
--"Provides admin chat"
-----
local PLUGIN = {}
PLUGIN.title = "AChat"
PLUGIN.author = "Trist"
PLUGIN.description = "Provides admin chat"
PLUGIN.perm = "Admin Chat"
PLUGIN.command = "a"
PLUGIN.usage = "<text>"

function PLUGIN:Call(ply,args)
    if !ply:IsAdmin() then return end
    if #args < 1 then return end
    
    for _,p in ipairs(player.GetAll()) do
        if (p:IsAdmin()) then
            autobox:Notify(p,autobox.colors.red,"(Admin) ",team.GetColor(ply),ply:Nick(),color_white,": ",table.concat(args," "))
        end
    end    
end

autobox:RegisterPlugin(PLUGIN)