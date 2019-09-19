-----
--Opens a lua console on the client
-----
local PLUGIN = {}
PLUGIN.title = "Lua Console"
PLUGIN.author = "Trist"
PLUGIN.description = "Opens a lua console on the client"
PLUGIN.command = "luaconsole"
PLUGIN.perm = "Lua Console"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    net.Start("aat_start_console")
    net.Send(ply)
end

if (SERVER) then
    util.AddNetworkString("aat_lua_console")
    util.AddNetworkString("aat_start_console")
    net.Receive("aat_lua_console",function(len,ply)
        if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
        local mode = net.ReadString()
        local str = net.ReadString()
        local tar = net.ReadEntity() or nil
        local err func = CompileString(str,ply:SteamID() .. " compiled code")
        if (!err) then
            if (mode == "SERVER" or mode == "SHARED") then
                local __ info = pcall(func)
            end
            if (mode == "CLIENT" or mode == "SHARED") then
                net.Start("aat_lua_console")
                net.WriteString(str)
                net.Broadcast()
            end
            if (mode == "PLAYER") then
                net.Start("aat_lua_console")
                net.WriteString(str)
                net.Send(ply)
            end
            if (tar and tar:IsValid() and tar:IsPlayer()) then
                net.Start("aat_lua_console")
                net.WriteString(str)
                net.Send(tar)
            end
        end
    end)
end

if (CLIENT) then
    net.Receive("aat_lua_console",function()
        local str = net.ReadString()
        local err func = CompileString(str,LocalPlayer():SteamID() .. " compiled code")
        local succ info = pcall(func)
    end)
    net.Receive("aat_start_console",function()
        local DP = vgui.Create("DFrame")
        DP:SetSize( 600, 300 )
        DP:Center()
        DP:SetTitle( "Lua Console" )
        DP:SetDraggable(true)
        DP:MakePopup()

        local txt = vgui.Create("DTextEntry",DP)
        txt:SetPos(5,30)
        txt:SetSize(500,265)
        txt:SetText("")
        txt:SetMultiline(true)

        local DB = vgui.Create("DButton",DP)
        DB:SetSize(85,25)
        DB:SetPos(510,270)
        DB:SetText("server run")
        function DB:DoClick()
            net.Start("aat_lua_console")
            net.WriteString("SERVER")
            net.WriteString(txt:GetText())
            net.SendToServer()
        end

        DB = vgui.Create("DButton",DP)
        DB:SetSize(85,25)
        DB:SetPos(510,240)
        DB:SetText("client run")
        function DB:DoClick()
            net.Start("aat_lua_console")
            net.WriteString("CLIENT")
            net.WriteString(txt:GetText())
            net.SendToServer()
        end

        DB = vgui.Create("DButton",DP)
        DB:SetSize(85,25)
        DB:SetPos(510,210)
        DB:SetText("shared run")
        function DB:DoClick()
            net.Start("aat_lua_console")
            net.WriteString("SHARED")
            net.WriteString(txt:GetText())
            net.SendToServer()
        end

        DB = vgui.Create("DButton",DP)
        DB:SetSize(85,25)
        DB:SetPos(510,180)
        DB:SetText("run on me")
        function DB:DoClick()
            net.Start("aat_lua_console")
            net.WriteString("PLAYER")
            net.WriteString(txt:GetText())
            net.SendToServer()
        end

        local curtar = nil

        DB = vgui.Create("DButton",DP)
        DB:SetSize(85,25)
        DB:SetPos(510,150)
        DB:SetText("run on target")
        function DB:DoClick()
            net.Start("aat_lua_console")
            net.WriteString("TARGET")
            net.WriteString(txt:GetText())
            net.WriteEntity(curtar or nil)
            net.SendToServer()
        end

        local DC = vgui.Create("DComboBox", DP)
        DC:SetSize(85,25)
        DC:SetPos(510,120)
        DC:SetValue("target")
        function DC:RepopList()
            local _,data = self:GetSelected()
            if (!data or !data:IsValid()) then
                self:Clear()
            end
            for _,v in ipairs(player.GetAll()) do
                if (!v:IsBot()) then
                    DC:AddChoice(v:Name(),v)
                end
            end
        end
        DC:RepopList()
        function DC:OnSelect(index,value,ply)
            if (ply:IsValid()) then
                curtar = ply
            else
                self:RepopList()
            end
        end
    end)
end

autobox:RegisterPlugin(PLUGIN)