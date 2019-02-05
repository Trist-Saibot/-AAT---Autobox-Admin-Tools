-----
--Hide a player's physgun beam
-----
local PLUGIN = {}
PLUGIN.title = "Hide Physgun Beam"
PLUGIN.author = "Trist"
PLUGIN.description = "Hide a player's physgun beam"
PLUGIN.perm = "Hide Physgun Beam"
PLUGIN.command = "hidebeam"
PLUGIN.usage = "[players] [1/0]"

if(SERVER)then
    util.AddNetworkString("AAT_HideBeam")
    function PLUGIN:SendBeamStatus(ply,target)
        net.Start("AAT_HideBeam")
            net.WriteEntity(target)
            net.WriteBool(target.AAT_HidePhysgun)
        net.Send(ply)
    end
    function PLUGIN:AAT_InitializePlayer(ply)
        for _,target in ipairs(player.GetAll())do
            PLUGIN:SendBeamStatus(ply,target)
        end
    end
end
if(CLIENT)then
    net.Receive("AAT_HideBeam",function()
        local ply = net.ReadEntity()
        ply.AAT_HidePhysgun = net.ReadBool()
    end)
end
function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if(!autobox:ValidateHasTarget(ply,players))then return end
    local beamState = tonumber(args[#args]) or 1
    for _,v in ipairs(players)do
        v.AAT_HidePhysgun = tobool(beamState)
    end
    for _,v in ipairs(player.GetAll())do
        for _,p in ipairs(player.GetAll())do
            PLUGIN:SendBeamStatus(v,p)
        end
    end
    local beamString = ""
    if(tobool(beamState))then
        beamString = "hidden"
    else
        beamString = "unhidden"
    end
    local plural = ""
    if(#players>1)then
        plural = "s"
    end
    if(#players==1 and players[1]==ply)then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has "..beamString.." their physgun beam.")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has "..beamString.." the physgun beam"..plural.." of ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end
function PLUGIN:DrawPhysgunBeam(ply)
    if(!ply.AAT_HidePhysgun)then
        return true
    else
        return false
    end
end
autobox:RegisterPlugin(PLUGIN)