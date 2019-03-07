-----
--Changes the default chat box
-----
local PLUGIN = {}
PLUGIN.title = "Chatbox"
PLUGIN.author = "Trist"
PLUGIN.description = "Changes the default chat box"
PLUGIN.suggestions = {}
if(SERVER)then
    for _,v in pairs(file.Find("materials/autobox/icon16/*.png","GAME"))do
        resource.AddFile( "materials/autobox/icon16/"..v)
    end
    for _,v in pairs(file.Find("materials/autobox/ui/*.png","GAME"))do
        resource.AddFile( "materials/autobox/ui/"..v)
    end
end
if(CLIENT)then --setup client settings
    PLUGIN.active = 1
    PLUGIN.scrollback = 50 --how many messages we save before we cull
    PLUGIN.alphaShow = 255
    PLUGIN.alphaHide = 0
    PLUGIN.fadeTime = 5
    PLUGIN.alpha = PLUGIN.alphaHide

    PLUGIN.chatTabs = {}
    PLUGIN.chatTabs[1] = {}
    PLUGIN.chatTabs[1].Name = "General"
    PLUGIN.chatTabs[1].Messages = {}
    PLUGIN.chatTabs[1].Filters = {"All"}

    PLUGIN.chatTabs[2] = {}
    PLUGIN.chatTabs[2].Name = "System"
    PLUGIN.chatTabs[2].Messages = {}
    PLUGIN.chatTabs[2].Filters = {"System","Timestamp"}

    PLUGIN.chatTabs[3] = {}
    PLUGIN.chatTabs[3].Name = "Custom"
    PLUGIN.chatTabs[3].Messages = {}
    PLUGIN.chatTabs[3].Filters = {}
end

--preload silkicons
if(CLIENT)then
    PLUGIN.silkicons = {}
    PLUGIN.keyTable = {}
    for _,v in pairs(file.Find("materials/icon16/*.png","GAME"))do
        local key = string.Split(v,".")[1]
        PLUGIN.silkicons[key] = Material("icon16/"..v)
        table.insert(PLUGIN.keyTable,key)
    end
    for _,v in pairs(file.Find("materials/autobox/icon16/*.png","GAME"))do
        local key = string.Split(v,".")[1]
        PLUGIN.silkicons[key] = Material("autobox/icon16/"..v)
        table.insert(PLUGIN.keyTable,key)
    end
    table.sort(PLUGIN.keyTable)
    PLUGIN.chatOpen = false
end

--disable old scoreboard
function PLUGIN:HUDShouldDraw(name)
    if(name=="CHudChat")then
        return false
    end
end

--hook for when chat box is supposed to open
function PLUGIN:StartChat()
    self.chatOpen = true
    if(self.Frame)then
        self.alpha = self.alphaShow
        self.Frame:MakePopup()
        self.TextBox:RequestFocus()
        self.ScrollPanel:ScrollToEnd()
    else
        self:InitializeChatWindow()
        self:StartChat()
    end
end

--kidnaps the player's input for chat opening
function PLUGIN:PlayerBindPress(ply,bind,pressed)
    local team = false
    if(bind=="messagemode")then
        team = false
    elseif(bind=="messagemode2")then
        team = true
    else
        return
    end
    hook.Run("StartChat",team)
    return true
end

if(CLIENT)then
    --make sure the tab closes when it needs to
    function PLUGIN:Think()
        if(self.chatOpen and IsValid(self.Frame))then
            if(!self.Frame:HasHierarchicalFocus())then
                hook.Run("FinishChat")
            end
            if(input.IsMouseDown(MOUSE_LEFT))then
                local x,y = gui.MousePos()
                local px,py,w,h = self.Frame:GetBounds()
                if(x<=px or x>=px+w or y<=py or y>=py+h)then
                    hook.Run("FinishChat")
                end
            end
        end
    end
    --override the original chat.AddText
    if(!autobox.OnChatText)then
        autobox.OnChatText = chat.AddText
    end
    function chat.AddText(...)
        if(!PLUGIN.Frame)then
            PLUGIN:InitializeChatWindow()
        end
        hook.Run("AAT_OnChatText",...)
        local args = {...}
        --make sure to remove any custom chat tables before sending it along
        if(type(args[1])=="table" and !IsColor(args[1]))then
            table.remove(args[1])
            autobox.OnChatText(unpack(args))
        else
            autobox.OnChatText(...)
        end
    end



    --our custom chat function
    function PLUGIN:AAT_OnChatText(...)
        local args = {...}
        local mdata = nil
        if(type(args[1])=="table" and !IsColor(args[1]))then
            mdata = args[1]
            table.remove(args[1])
            if(!mdata.Type)then mdata.Type = "System" end
        else
            mdata = {Type = "System"}
        end
        mdata.Time = os.time()
        mdata.Clock = os.clock()
        if(self.ScrollPanel)then
            for k,chatTab in pairs(self.chatTabs)do
                if(table.HasValue(chatTab.Filters,"All") or table.HasValue(chatTab.Filters,mdata.Type))then
                    local temp = {}
                    temp.args = args
                    temp.mdata = mdata
                    table.insert(chatTab.Messages,temp)
                    if(#chatTab.Messages>PLUGIN.scrollback)then
                        table.remove(chatTab.Messages,1)
                    end
                    if(self.active == k)then
                        self.ScrollPanel:AddChatMessage(args,mdata)

                        --I have no idea why, but for some reason scrolling immediately scrolls to the top and breaks
                        timer.Simple(0.01,function()
                            self.ScrollPanel:ScrollToEnd()
                        end)
                    end
                end
            end
        end
    end

    --create the frame when we start
    function PLUGIN:InitializeChatWindow()
        self.Frame = vgui.Create("DFrame")
        self.Frame:SetSize( ScrW()/3.5+6, 300+6 )
        self.Frame:SetPos(20,ScrH()-320)
        self.Frame:ShowCloseButton(false)
        self.Frame:SetTitle("")
        self.Frame:SetDraggable(false)

        function self.Frame:Paint(w,h)
            surface.SetDrawColor(ColorAlpha(autobox.colors.discord[4],PLUGIN.alpha))
            surface.DrawRect(3,3,w-6,h-6)

            surface.SetDrawColor(ColorAlpha(autobox.colors.discordAlt[1],PLUGIN.alpha))
            surface.DrawRect(3,24,w-6,252)

            autobox.draw:DrawBorder(0,0,w,h,PLUGIN.alpha)
        end
        function self.Frame:PaintOver(w,h)
            if(PLUGIN.chatOpen and PLUGIN.TextBox:HasFocus())then
                local font = "Trebuchet18"
                surface.SetFont("Trebuchet18")
                local longest = 0
                local th = 0
                for _,v in ipairs(PLUGIN.suggestions)do
                    local cx,cy = surface.GetTextSize(v.command)
                    local ux,_ = surface.GetTextSize(v.usage)
                    if(cx+ux>longest)then longest = cx+ux end
                    th = cy
                end

                local y=h-#PLUGIN.suggestions*th-31
                local x=8

                if(#PLUGIN.suggestions>0)then
                    surface.SetDrawColor(autobox.colors.discordAlt[1])
                    surface.DrawRect(3,y,longest+15,#PLUGIN.suggestions*th)
                    surface.SetDrawColor(autobox.colors.discord[4])
                    surface.DrawRect(4,y+1,longest+13,#PLUGIN.suggestions*th)
                end

                for _,v in ipairs(PLUGIN.suggestions)do
                    local sx,sy = surface.GetTextSize(v.command)
                    draw.SimpleText(v.command,font,x,y,autobox.colors.white)
                    draw.SimpleText(" "..v.usage or "",font,x+sx,y,autobox.colors.red)
                    y=y+th
                end
            end
        end

        self.ScrollPanel = vgui.Create("DScrollPanel",self.Frame)
        self.ScrollPanel.Messages = {}
        self.ScrollPanel:SetPos(3,25)
        self.ScrollPanel:SetSize(self.Frame:GetWide()-6,250)
        function self.ScrollPanel:GetAlpha()
            return PLUGIN.alpha
        end
        autobox.draw:CustomVBar(self.ScrollPanel)
        function self.ScrollPanel:ScrollToEnd()
            if(#self.Messages>1 and self.Messages[#self.Messages])then
                self:ScrollToChild(self.Messages[#self.Messages])
            end
        end
        function self.ScrollPanel:Paint(w,h)
            surface.SetDrawColor(ColorAlpha(autobox.colors.discordAlt[2],PLUGIN.alpha))
            surface.DrawRect(0,0,w,h)
        end
        function self.ScrollPanel:AddChatMessage(args,mdata)
            local color = color_white
            local DPanel = self:Add("DPanel")
            DPanel.mdata = mdata
            DPanel:Dock(TOP)
            DPanel:DockMargin(5,0,35,0)
            DPanel.wide = self:GetWide()-40
            DPanel.y = 0
            DPanel.x = 0
            DPanel:SetSize(DPanel.wide,20)
            function DPanel:Think()
                if(os.clock()>mdata.Clock+PLUGIN.fadeTime)then
                    self:AlphaTo(PLUGIN.alpha,0.3,0,function()
                        function self:Think()
                            self:SetAlpha(PLUGIN.alpha)
                        end
                    end)
                    self.Think = nil
                end
            end
            function DPanel:AddIcon(icon)
                local IconPanel = vgui.Create("DPanel",self)
                if(self.x+20>self.wide-15)then
                    self.x=0
                    self.y=self.y+20
                    self:SetSize(self.wide,self.y+20)
                end
                IconPanel:SetSize(16,16)
                IconPanel:SetPos(self.x+2,self.y+2)
                function IconPanel:Paint(w,h)
                    surface.SetMaterial(icon)
                    surface.SetDrawColor(color_white)
                    surface.DrawTexturedRect(0,0,w,h)
                end
                self.x=self.x+20
                return IconPanel
            end
            function DPanel:AddTextElem(text,color,flag)
                local DLabel = vgui.Create("DLabel",self)
                DLabel:SetFont("TristText_Bold")
                DLabel:SetText(text)
                DLabel:SizeToContents()
                DLabel:SetText("")
                DLabel:SetColor(color)
                function DLabel:Paint(w,h)
                    draw.TextShadow({pos={0,0},text=text,font=self:GetFont(),color=self:GetColor()},1)
                end
                local x = DLabel:GetWide()
                if(self.x+x>self.wide-15)then
                    if(!flag)then
                        local words = string.Split(text," ")
                        for k,v in pairs(words)do
                            DLabel:SetText(table.concat(words," ",1,k))
                            DLabel:SizeToContents()
                            x = DLabel:GetWide()
                            if(self.x+x>self.wide-15)then
                                DLabel:SetText(table.concat(words," ",1,k-1))
                                DLabel:SizeToContents()
                                DLabel:SetPos(self.x,self.y)
                                self.x=0
                                self.y=self.y+20
                                self:SetSize(self.wide,self.y+20)
                                self:AddTextElem(table.concat(words," ",k,#words),color,true)
                                break
                            end
                        end
                    else
                        local letters = string.Split(text,"")
                        for k,v in pairs(letters)do
                            DLabel:SetText(table.concat(letters,"",1,k))
                            DLabel:SizeToContents()
                            x = DLabel:GetWide()
                            if(self.x+x>self.wide-15)then
                                DLabel:SetText(table.concat(letters,"",1,k-1))
                                DLabel:SizeToContents()
                                DLabel:SetPos(self.x,self.y)
                                self.y=self.y+20
                                self.x=0
                                self:SetSize(self.wide,self.y+20)
                                self:AddTextElem(table.concat(letters,"",k,#letters),color,true)
                                break
                            end
                        end

                    end
                else
                    DLabel:SetPos(self.x,self.y)
                    self.x=self.x+x
                end
            end
            function DPanel:Paint(w,h)
            end
            if(table.HasValue(PLUGIN.chatTabs[PLUGIN.active].Filters,"Timestamp"))then
                DPanel:AddTextElem(os.date('[%H:%M] ',mdata.Time or 0),color)
            end
            if(mdata)then
                if(mdata.Type == "Message")then
                    local tmp = nil
                    if(mdata.Icon and PLUGIN.silkicons[mdata.Icon])then
                        tmp = DPanel:AddIcon(PLUGIN.silkicons[mdata.Icon])
                        if(mdata.Player:IsValid())then
                            local rankData = autobox:GetRankInfo(mdata.Player:AAT_GetRank())
                            tmp:SetTooltip(rankData.RankName)
                        else
                            tmp:SetTooltip("Console")
                        end
                    elseif(mdata.Player:IsValid() and PLUGIN.silkicons[autobox:GetRankInfo(mdata.Player:AAT_GetRank()).Icon])then
                        local rankData = autobox:GetRankInfo(mdata.Player:AAT_GetRank()).Icon
                        tmp = DPanel:AddIcon(PLUGIN.silkicons[rankData.Icon])
                        tmp:SetTooltip(rankData.RankName)
                    else
                        tmp = DPanel:AddIcon(PLUGIN.silkicons["computer"])
                        tmp:SetTooltip("Console")
                    end
                    if(mdata.IconTooltip)then --putting this at the end so I can override any tooltips
                        tmp:SetTooltip(mdata.IconTooltip)
                    end
                elseif(mdata.Override)then
                    local tmp = nil
                    if(mdata.Icon and PLUGIN.silkicons[mdata.Icon])then
                        tmp = DPanel:AddIcon(PLUGIN.silkicons[mdata.Icon])
                    else
                        tmp = DPanel:AddIcon(PLUGIN.silkicons["world"])
                    end
                    if(mdata.IconTooltip)then
                        tmp:SetTooltip(mdata.IconTooltip)
                    else
                        tmp:SetTooltip("System")
                    end
                elseif(mdata.Type == "System")then
                    local tmp = DPanel:AddIcon(PLUGIN.silkicons["world"])
                    tmp:SetTooltip("System")
                end
            else
                local tmp = DPanel:AddIcon(PLUGIN.silkicons["world"])
                tmp:SetTooltip("System")
            end
            for _,v in pairs(args)do
                if(type(v)=="string")then
                    local words = string.Split(v,":")
                    local temp = ""
                    local flag = false
                    for _,s in ipairs(words)do
                        if(PLUGIN.silkicons[s])then
                            if(string.len(temp)>0)then
                                DPanel:AddTextElem(temp,color)
                                temp = ""
                            end
                            DPanel:AddIcon(PLUGIN.silkicons[s])
                            flag = false
                        else
                            if(!flag)then flag = true else temp=temp..":" end
                            temp=temp..s
                        end
                    end
                    if(string.len(temp)>0)then
                        DPanel:AddTextElem(temp,color)
                        temp = ""
                    end
                elseif(type(v)=="table")then
                    if(IsColor(v))then
                        color=v
                    end
                else
                    DPanel:AddTextElem(tostring(v),color)
                end
            end
            table.insert(self.Messages,DPanel)
            if(#self.Messages>PLUGIN.scrollback)then
                self.Messages[1]:Remove()
                table.remove(self.Messages,1)
            end
        end

        self.TextBox = vgui.Create("DTextEntry",self.Frame)
        self.TextBox:SetSize(self.Frame:GetWide()-25-8,25)
        self.TextBox:SetPos(5,275)
        self.TextBox:SetText("")
        function self.TextBox:Paint(w,h)
            self:DrawTextEntryText(color_white,autobox.colors.blue,color_white)
        end
        function self.TextBox:OnKeyCodeTyped(code)
            if(code==KEY_ESCAPE)then
                hook.Run("FinishChat")
                gui.HideGameUI()
                return true
            elseif(code==KEY_ENTER)then
                if(string.Trim(self:GetText())!="")then
                    LocalPlayer():ConCommand("say "..self:GetText())
                end
                hook.Run("FinishChat")
                return true
            elseif(code==KEY_TAB)then
                self:SetText(hook.Run("OnChatTab",self:GetText()))
                return true
            end
        end
        self.TextBox.OldSetText = self.TextBox.SetText
        function self.TextBox:SetText(text)
            self:OldSetText(text)
            self:CheckText()
            self:SetCaretPos(string.len(self:GetText()))
        end
        function self.TextBox:CheckText()
            if(string.len(self:GetText())>126)then
                self:SetText(string.sub(self:GetText(),1,126))
                self:SetCaretPos(string.len(self:GetText()))
                surface.PlaySound("resource/warning.wav")
            end
        end
        function self.TextBox:OnChange()
            self:CheckText()
            hook.Run("ChatTextChanged",self:GetText())
        end

        self.Emote = vgui.Create("DButton",self.Frame)
        self.Emote:SetSize(25,25)
        self.Emote:SetPos(self.TextBox:GetWide()+3,275+3)
        self.Emote:SetText("")
        function self.Emote:Paint(w,h)
            surface.SetMaterial(PLUGIN.silkicons["emoticon_happy"])
            surface.SetDrawColor(ColorAlpha(color_white,PLUGIN.alpha))
            surface.DrawTexturedRect(4,4,16,16)
        end
        function self.Emote:DoClick()
            if(PLUGIN.EmoteFrame:IsVisible())then
                PLUGIN.EmoteFrame:Hide()
            else
                PLUGIN.EmoteFrame:Show()
                PLUGIN.EmoteFrame:RequestFocus()
            end
        end

        self.EmoteFrame = vgui.Create("DScrollPanel",self.Frame)
        self.EmoteFrame:SetSize(300,200)
        self.EmoteFrame.locx,self.EmoteFrame.locy=self.Emote:GetPos()
        self.EmoteFrame:SetPos(self.EmoteFrame.locx-273-16,self.EmoteFrame.locy-202)
        function self.EmoteFrame:GetAlpha()
            return PLUGIN.alpha
        end
        autobox.draw:CustomVBar(self.EmoteFrame)
        function self.EmoteFrame:Paint(w,h)
            surface.SetDrawColor(autobox.colors.discordAlt[1])
            surface.DrawRect(0,0,w,h)
            surface.SetDrawColor(autobox.colors.discord[4])
            surface.DrawRect(1,1,w-2,h)
        end
        function self.EmoteFrame:Think()
            if(!self:HasHierarchicalFocus())then
                self:Hide()
            end
        end
        self.EmoteFrame.locx = 0
        self.EmoteFrame.locy = 0
        for _,k in pairs(self.keyTable)do
            local DButton = vgui.Create("DButton",self.EmoteFrame)
            DButton:SetSize(25,25)
            DButton:SetText("")
            DButton:SetTooltip(k)
            DButton:SetPos(self.EmoteFrame.locx,self.EmoteFrame.locy)
            function DButton:Paint(w,h)
                surface.SetMaterial(PLUGIN.silkicons[k])
                surface.SetDrawColor(color_white)
                surface.DrawTexturedRect(4,4,16,16)
            end
            function DButton:DoClick()
                PLUGIN.TextBox:SetText(PLUGIN.TextBox:GetText()..":"..k..":")
            end
            self.EmoteFrame.locx=self.EmoteFrame.locx+25
            if(self.EmoteFrame.locx>250)then
                self.EmoteFrame.locx = 0
                self.EmoteFrame.locy=self.EmoteFrame.locy+25
            end
        end

        local x = 0

        --custom chat tabs
        for k,v in pairs(self.chatTabs)do
            local DButton = vgui.Create("DButton",self.Frame)
            DButton:SetText(v.Name)
            DButton:SizeToContentsX(20)
            DButton:SetText("")
            DButton:SetTall(20)
            DButton:SetPos(x+10,5)
            x=x+DButton:GetWide()+4
            function DButton:Paint(w,h)
                draw.NoTexture()
                local color = ColorAlpha(autobox.colors.discordAlt[1],PLUGIN.alpha)
                draw.RoundedBox(8,0,0,w,h*2,color)

                if(PLUGIN.active==k)then
                    color = ColorAlpha(autobox.colors.discordAlt[2],PLUGIN.alpha)
                else
                    color = ColorAlpha(autobox.colors.discord[3],PLUGIN.alpha)
                end
                draw.RoundedBox(7,1,1,w-2,h*2+1,color)
                draw.TextShadow({text=v.Name,pos={10,5},color=ColorAlpha(color_white,PLUGIN.alpha)},1,PLUGIN.alpha)
            end
            function DButton:DoClick()
                PLUGIN.active = k
                PLUGIN.ScrollPanel:Clear()
                PLUGIN.ScrollPanel.Messages = {}
                for _,msg in ipairs(v.Messages)do
                    PLUGIN.ScrollPanel:AddChatMessage(msg.args,msg.mdata)
                end
                if(#v.Messages>0)then
                    --I have no idea why, but for some reason scrolling immediately scrolls to the top and breaks
                    timer.Simple(0.01,function()
                        PLUGIN.ScrollPanel:ScrollToEnd()
                    end)
                end
            end
        end

        self.Settings = vgui.Create("DButton",self.Frame)
        self.Settings:SetSize(16,16)
        self.Settings:SetPos(self.Frame:GetWide()-22,6)
        self.Settings:SetText("")
        function self.Settings:Paint(w,h)
            surface.SetMaterial(PLUGIN.silkicons["gear"])
            surface.SetDrawColor(ColorAlpha(color_white,PLUGIN.alpha))
            surface.DrawTexturedRect(0,0,16,16)
            --surface.DrawRect(0,0,w,h)
        end
        function self.Settings:DoClick()
            PLUGIN:OpenChatSettings()
        end
    end
end

--called when the chat window should close
function PLUGIN:FinishChat()
    self.chatOpen = false
    if(PLUGIN.Frame)then
       self.alpha = self.alphaHide
       self.Frame:SetMouseInputEnabled(false)
       self.Frame:SetKeyboardInputEnabled(false)
       gui.EnableScreenClicker(false)
    end
    self.TextBox:SetText("")
    hook.Run("ChatTextChanged","")
end

--Chat Autocomplete
function PLUGIN:ChatTextChanged(str)
    self.suggestions = {}
    if( (string.Left(str,1)=="/") or (string.Left(str,1)=="!") or (string.Left(str,1)=="@") ) then
        local com = string.sub(str,2,(string.find(str," ") or (#str+1))-1)
        for _,v in pairs(autobox.plugins)do
            if(v.command and string.sub(v.command,0,#com)==string.lower(com) and #self.suggestions<4)then
                table.insert(self.suggestions,{command = string.sub(str,1,1)..v.command,usage = v.usage or ""})
            end
        end
        table.SortByMember(self.suggestions,"command",function(a,b)return a<b end)
    end
end
function PLUGIN:OnChatTab(str)
    if ( string.match( str, "^[/!][^ ]*$" ) and #self.suggestions > 0 ) then
		return self.suggestions[1].command .. " "
	end
end

--Rank Names
function PLUGIN:OnPlayerChat(ply,txt,team,dead)
    if(GAMEMODE.IsSandboxDerived)then
        local rankData = autobox:GetRankInfo(ply:AAT_GetRank())
        local tab = {}
        local temp = {}
        temp.Player = ply
        temp.Type = "Message"
        temp.Icon = rankData.Icon
        temp.IconTooltip = rankData.RankName
        table.insert(tab,temp)
        --table.insert(tab,color_white)
        --table.insert(tab,"("..autobox:GetRankInfo(ply:AAT_GetRank()).RankName..") ")
        if(IsValid(ply))then
            table.insert(tab,autobox:HexToColor(rankData.Color) or color_white)
            table.insert(tab,ply:Nick())
        else
            table.insert(tab,"Console")
        end
        table.insert(tab,color_white)
        table.insert(tab,": "..txt)
        chat.AddText(unpack(tab))
        return true
    end
end

--chat box settings window
function PLUGIN:OpenChatSettings()
    if(self.chatOpen)then
        self:FinishChat()
    end
    self.SettingsFrame = vgui.Create("DFrame")
    self.SettingsFrame:SetSize(600,400)
    self.SettingsFrame:MakePopup()
    self.SettingsFrame:Center()
    --self.SettingsFrame:ShowCloseButton(false)
    self.SettingsFrame:SetTitle("")
    function self.SettingsFrame:Paint(w,h)
        surface.SetDrawColor(autobox.colors.discord[4])
        surface.DrawRect(3,3,w-6,22)
        surface.SetDrawColor(autobox.colors.discord[1])
        surface.DrawRect(3,25,w-6,h-26)
        autobox.draw:DrawBorder(0,0,w,h,255)
        surface.SetDrawColor(autobox.colors.discord[2])
        surface.DrawRect(2,23,w-4,1)
        draw.TextShadow({pos={10,6},text="Settings"},1)
    end
    function self.SettingsFrame:OnFocusChanged(focus)
        if(!focus)then
      --      self:Remove()
        end
    end
    local temp = nil
    temp = autobox.draw:AddSlider(self.SettingsFrame,100,50,200,25,'alpha_show')
    temp:SetValue(self.alphaShow)
    function temp:OnValueChanged(value)
        PLUGIN.alphaShow = value
        if(PLUGIN.chatOpen)then
            PLUGIN.alpha = value
        end
    end
    temp = autobox.draw:AddSlider(self.SettingsFrame,100,75,200,25,'alpha_hide')
    temp:SetValue(self.alphaHide)
    function temp:OnValueChanged(value)
        PLUGIN.alphaHide = value
        if(!PLUGIN.chatOpen)then
            PLUGIN.alpha = value
        end
    end
end
function PLUGIN:HUDPaint()
    if(IsValid(self.SettingsFrame))then
        surface.SetDrawColor(autobox.colors.pink)
        surface.DrawRect(0,0,1920,1080)
    end
end

--reload cleanup
function PLUGIN:AAT_OnReload()
    if(CLIENT)then
        if(self.Frame)then
            self.Frame:Remove()
        end
        if(self.SettingsFrame)then
            self.SettingsFrame:Remove()
        end
    end
end

autobox:RegisterPlugin(PLUGIN)