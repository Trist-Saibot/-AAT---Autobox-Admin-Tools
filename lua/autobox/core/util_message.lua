--Handles messages in chat
autobox.chatConst = {}
autobox.chatConst.notallowed = "You are not allowed to do that."
autobox.chatConst.noplayers = "No matching players with an equal or lower immunity found."
autobox.chatConst.noplayers2 = "No matching players with a lower immunity found."
autobox.chatConst.noplayersnoimmunity = "No matching players found."
autobox.chatConst.err = {Override = true,Icon = "cancel",IconTooltip = "Error"}

if (SERVER) then
    util.AddNetworkString("autobox_message")
    autobox.silentNotify = false

    function autobox:Notify(...)

        local ply
        local args = {...}
        if (type(args[1]) == "Player" or args[1] == nil ) then ply = args[1] end
        if (!self.silentNotify) then
            local message = {}
            for _,v in pairs(args) do
                if (type(v) == "string" or type(v) == "table") then
                    table.insert(message,v)
                elseif (type(v) == "number") then
                    table.insert(message,tostring(v))
                end
            end
            net.Start("autobox_message")
            net.WriteTable(message)
            if (ply != nil ) then
                net.Send(ply)
            else
                net.Broadcast()
            end
        end
    end
else
    function autobox:Notify(...)
        local args = {}
        for _,v in ipairs({...}) do
            if (type(v) == "string" or type(v) == "table") then
                table.insert(args,v)
            end
        end
        chat.AddText(unpack(args))
    end
    net.Receive("autobox_message",function()
        local message = net.ReadTable()
        autobox:Notify(unpack(message))
    end)
end

