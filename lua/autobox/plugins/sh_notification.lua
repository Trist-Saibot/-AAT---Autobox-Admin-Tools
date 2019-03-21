-----
--Display a notification
-----
local PLUGIN = {}
PLUGIN.title = "Notice"
PLUGIN.author = "Trist"
PLUGIN.description = "Display a notification"
PLUGIN.perm = "Notice"
PLUGIN.command = "notice"
PLUGIN.usage = "<message> [time=10]"

if (SERVER) then
    util.AddNetworkString("AAT_Custom_Notification")
end

function PLUGIN:Call( ply, args )
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local time = tonumber(args[#args]) or 10
    if (tonumber(args[#args])) then args[#args] = nil end
    local msg = table.concat(args," ")
    if (#msg > 0) then
        net.Start("AAT_Custom_Notification")
            net.WriteInt(time,16)
            net.WriteString(msg)
        net.Broadcast()
    end
end

if (CLIENT) then
    net.Receive("AAT_Custom_Notification",function()
        local time = net.ReadInt(16)
        local msg = net.ReadString()
        notification.AddLegacy(msg,0,time)
        surface.PlaySound( "ambient/water/drip" .. math.random( 1, 4 ) .. ".wav" )
    end)
end

autobox:RegisterPlugin( PLUGIN )