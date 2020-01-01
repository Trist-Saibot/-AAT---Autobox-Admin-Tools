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
        local BN = nil
        local DF = vgui.Create("DFrame")
        DF:SetSize( 600, 300 )
        DF:Center()
        DF:SetTitle( "Lua Console" )
        DF:SetSizable(true)
        DF:SetDraggable(true)
        DF:MakePopup()

        local DT = vgui.Create("DTree",DF)
        DT:SetSize(125,0)
        DT:Dock(LEFT)

        local DH = vgui.Create( "DHTML", DF )

        timer.Create("LUA_CONSOLE_TITLE_TIMER", 0,0,function()
            if (!DF or !DF:IsValid()) then
                timer.Remove("LUA_CONSOLE_TITLE_TIMER")
                return
            else
                local txt = "Lua Console"
                if (DH.curFile) then
                    local spl = string.Split(DH.curFile,"/")
                    txt = txt .. ": " ..  spl[#spl]
                end
                DF:SetTitle(txt)
            end
        end)


        DH.curFile = nil
        DH:SetHTML([[
        <head>
            <pre id="editor"></pre>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/ace/1.4.6/ace.js"></script>
            <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>
            <style type="text/css" media="screen">
                body {overflow: hidden;}
                #editor {
                    margin: 0;
                    position: absolute;
                    top: 0;
                    bottom: 0;
                    left: 0;
                    right: 0;
                }
            </style>
        </head>
        <body>
            <script>
                var editor = ace.edit("editor");
                editor.getSession().setMode("ace/mode/lua")
                editor.session.on('change',function(delta){
                    lua.updateCode(editor.getValue());
                });
                jQuery(document).keydown(function(event) {
                        if((event.ctrlKey || event.metaKey) && event.which == 83) {
                            lua.save();
                            event.preventDefault();
                            return false;
                        }
                    }
                );
                editor.commands.addCommand({
                    name: "fuck-off",
                    bindKey: { win: "`", mac: "`" },
                    exec: function() {
                        editor.clearSelection();
                    }
                });
            </script>
            </body>
        </html>
        ]])
        DH:SetPos(5,30)
        DH:SetSize(500,265)
        DH:DockMargin(0,0,5,0)
        DH:Dock( FILL )
        DH.code = ""
        DH:AddFunction("lua","updateCode",function(str)
            DH.code = str
        end)
        DH:AddFunction("lua","save",function()
            DH:Save()
        end)
        function DH:ClearFocus()
            DH:Call("document.activeElement.blur();")
        end
        function DH:OnFocusChanged(gained)
            if (!gained) then
                self:ClearFocus()
            end
        end
        function DH:GetCode()
            return self.code
        end
        function DH:Load(inFile)
            local code = file.Read(inFile,"DATA")
            code = string.gsub(code,'\\','\\\\')
            code = string.gsub(code,'`','\\`')
            DH:Call([[
                editor.setValue(`]] .. code .. [[`);
                editor.clearSelection();
            ]])
            self.code = code
        end
        function DH:Save()
            if (!DH.curFile) then
                self:SaveAs('','')
            else
                file.Write(DH.curFile,self:GetCode())
            end
        end
        function DH:SaveAs(filename, path, empty)
            filename = filename or ""
            path = path or "AAT_Code/"
            code = code or ""

            local LDF = vgui.Create("DFrame")
            LDF:SetSize(300,80)
            LDF:Center()
            LDF:MakePopup()
            LDF:SetTitle("Save As?")

            local LDT = vgui.Create("DTextEntry",LDF)
            LDT:SetSize(0,25)
            LDT:SetText("NewFile.txt")
            LDT:Dock(TOP)

            local LDB = vgui.Create("DButton",LDF)
            LDB:SetSize(75,0)
            LDB:SetText("OK")
            function LDB:DoClick()
                local fn = string.lower(LDT:GetText())
                if (!string.EndsWith(fn,".txt")) then fn = fn .. ".txt" end
                DH.curFile = "AAT_Code/" .. fn

                if (empty) then
                    file.Write(DH.curFile,"")
                    DH:Call([[
                        editor.setValue("");
                        editor.clearSelection();
                    ]])
                else
                    DH:Save()
                end
                BN:Refresh()
                LDF:Close()
            end
            LDB:Dock(RIGHT)

            LDB = vgui.Create("DButton",LDF)
            LDB:SetSize(75,0)
            LDB:SetText("Cancel")
            function LDB:DoClick()
                LDF:Close()
            end
            LDB:Dock(RIGHT)
        end


        local DP = vgui.Create("DPanel",DF)
        DP:SetSize(85,0)
        DP:Dock( RIGHT )
        function DP:Paint() end

        local DB = vgui.Create("DButton",DP)
        DB:SetSize(85,25)
        DB:Dock(BOTTOM)
        DB:DockMargin(0, 5, 0, 0)
        DB:SetText("server run")
        function DB:DoClick()
            DH:ClearFocus()
            net.Start("aat_lua_console")
            net.WriteString("SERVER")
            net.WriteString(DH:GetCode())
            net.SendToServer()
        end

        DB = vgui.Create("DButton",DP)
        DB:SetSize(85,25)
        DB:Dock(BOTTOM)
        DB:DockMargin(0, 5, 0, 0)
        DB:SetText("client run")
        function DB:DoClick()
            net.Start("aat_lua_console")
            net.WriteString("CLIENT")
            net.WriteString(DH:GetCode())
            net.SendToServer()
        end

        DB = vgui.Create("DButton",DP)
        DB:SetSize(85,25)
        DB:Dock(BOTTOM)
        DB:DockMargin(0, 5, 0, 0)
        DB:SetText("shared run")
        function DB:DoClick()
            net.Start("aat_lua_console")
            net.WriteString("SHARED")
            net.WriteString(DH:GetCode())
            net.SendToServer()
        end

        DB = vgui.Create("DButton",DP)
        DB:SetSize(85,25)
        DB:Dock(BOTTOM)
        DB:DockMargin(0, 5, 0, 0)
        DB:SetText("run on me")
        function DB:DoClick()
            net.Start("aat_lua_console")
            net.WriteString("PLAYER")
            net.WriteString(DH:GetCode())
            net.SendToServer()
        end

        local curtar = nil

        DB = vgui.Create("DButton",DP)
        DB:SetSize(85,25)
        DB:Dock(BOTTOM)
        DB:DockMargin(0, 5, 0, 0)
        DB:SetText("run on target")
        function DB:DoClick()
            net.Start("aat_lua_console")
            net.WriteString("TARGET")
            net.WriteString(DH:GetCode())
            net.WriteEntity(curtar or nil)
            net.SendToServer()
        end

        local DC = vgui.Create("DComboBox", DP)
        DC:SetSize(85,25)
        DC:Dock(BOTTOM)
        DC:DockMargin(0, 5, 0, 0)
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

        BN = DT:AddNode("Code")
        function BN:Refresh()
            BN:Clear()
            BN:MakeFolder("AAT_Code","DATA",true)
            BN:SetExpanded(true)
        end
        function BN:DoRightClick()
            local filename = self:GetFileName()
            local folder = self:GetFolder()
            local menu = DermaMenu()
            if (filename) then //file
                menu:AddOption("Open File",function()
                    DH:Load(filename)
                    DH.curFile = filename
                end)
                menu:AddOption("Delete File",function()
                    file.Delete(filename)
                    BN:Refresh()
                end)
            else //folder
                menu:AddOption("New File",function()
                    DH:SaveAs('','',true)
                end)
            end
            menu:Open()
        end
        function BN:DoClick()
            if (self.LastClickTime and SysTime() - self.LastClickTime < 0.3) then
                local filename = self:GetFileName()
                if (filename) then
                    DH:Load(filename)
                    DH.curFile = filename
                end
            end
            self.LastClickTime = SysTime()
        end
        BN.OldAddNode = BN.AddNode
        function BN:AddNode(strName,strIcon)
            local pNode = self:OldAddNode(strName,strIcon)
            pNode.DoRightClick = self.DoRightClick
            pNode.AddNode = self.AddNode
            pNode.DoClick = self.DoClick
            return pNode
        end
        BN:Refresh()
    end)
end

autobox:RegisterPlugin(PLUGIN)