-----
--Freezes everything for a brief respite
-----
local PLUGIN = {}
PLUGIN.title = "Timeout"
PLUGIN.author = "Trist"
PLUGIN.description = "Freezes everything for a brief respite"
PLUGIN.perm = "Timeout"
PLUGIN.command = "timeout"
PLUGIN.usage = "[players] [1/0]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    if(#args>0 and !(#args==1 and tonumber(args[1])))then
        local players = autobox:FindPlayers(args)
        if(!autobox:ValidateHasTarget(ply,players))then return end
    else
        players = player.GetAll()
    end
    local enabled = (tonumber(args[#args]) or 1) > 0
    for _,v in ipairs(ents.GetAll())do
        if(IsValid(v))then
            local owner = v:GetNWString("AAT_Owner",nil)
            local flag = false
            for _,p in ipairs(players)do
                if(p:SteamID()==owner)then
                    flag = true
                    break
                end
            end
            if(flag and IsValid(v:GetPhysicsObject()))then
                local phys = v:GetPhysicsObject()
                if(enabled)then
                    v.AAT_WasFrozen = phys:IsMotionEnabled()
                    phys:EnableMotion(false)
                else
                    if(v.AAT_WasFrozen) then
                        phys:EnableMotion(v.AAT_WasFrozen)
                        phys:Wake()
                    end
                    v.AAT_WasFrozen = nil
                end
            end
        end
    end
    for _,v in ipairs(player.GetAll())do
        if(!v:IsAdmin())then
            if(enabled)then v:Lock() else v:UnLock() end
        end
    end
    if(enabled)then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has given ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white," a time-out.")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has resumed the time of ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end


autobox:RegisterPlugin(PLUGIN)