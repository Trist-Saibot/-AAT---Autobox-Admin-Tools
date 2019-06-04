-----
--Display a player's profile
-----
local PLUGIN = {}
PLUGIN.title = "Profile"
PLUGIN.author = "Trist"
PLUGIN.description = "Display a player's profile"
PLUGIN.command = "profile"
PLUGIN.usage = "<player>"

if (SERVER) then
    util.AddNetworkString("AAT_OpenProfile")
end

function PLUGIN:Call(ply,args)
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateSingleTarget(ply,players)) then return end
    net.Start("AAT_OpenProfile")
        net.WriteEntity(players[1])
    net.Send(ply)
end

if (CLIENT) then
    net.Receive("AAT_OpenProfile",function()
        PLUGIN:OpenProfile(net.ReadEntity())
    end)
end

function PLUGIN:OpenProfile(player)
    PLUGIN:CloseProfile()
    PLUGIN.profile = vgui.Create("DFrame")
    PLUGIN.profile:SetSize(720,480)
    PLUGIN.profile:Center()
    PLUGIN.profile:SetTitle("")
    PLUGIN.profile:SetDraggable(true)
    PLUGIN.profile:MakePopup()
    function PLUGIN.profile:Paint(w,h)
        surface.SetDrawColor(autobox.colors.brown)
        surface.DrawRect(0,0,w,h)
    end
    function PLUGIN.profile:Think()
        if (!player:IsValid()) then PLUGIN:CloseProfile() end
    end

    local Frame = vgui.Create("DPanel",PLUGIN.profile)
    Frame:SetSize(PLUGIN.profile:GetWide(),PLUGIN.profile:GetTall() - 25)
    Frame:SetPos(0,25)
    function Frame:Paint(w,h)
        surface.SetDrawColor(autobox.colors.tan)
        surface.DrawRect(0,0,w,h)
    end

    local InfoBox = vgui.Create("DPanel",Frame)
    InfoBox:SetSize(300,128 + 8)
    InfoBox:SetPos(150,10)
    function InfoBox:Paint(w,h)
        if (!player:IsValid()) then return end
        surface.SetDrawColor(autobox.colors.brown)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(autobox.colors.tan2)
        surface.DrawRect(4,4,w-8,h-8)
        draw.DrawText(player:Nick(),"TristText_Bold",9,5,autobox.colors.brown,TEXT_ALIGN_LEFT)
        draw.DrawText(player:SteamID(),"TristText_Bold",9,25,autobox.colors.brown,TEXT_ALIGN_LEFT)
        draw.DrawText("[" .. autobox:GetRankInfo(player:AAT_GetRank()).RankName .. "]","TristText_Bold",9,45,autobox.colors.brown,TEXT_ALIGN_LEFT)
        draw.DrawText(autobox:FormatTime(player:AAT_GetPlaytime()),"TristText_Bold",9,65,autobox.colors.brown,TEXT_ALIGN_LEFT)

        draw.DrawText("right click to copy info","TristText_Bold",InfoBox:GetWide() - 9,InfoBox:GetTall() - 16 - 9,autobox.colors.brown,TEXT_ALIGN_RIGHT)

        InfoBox.count = 0
        for _,ent in ipairs(ents.GetAll()) do
            if (ent:GetNWString("AAT_Owner") == player:SteamID()) then
                InfoBox.count = InfoBox.count + 1
            end
        end
        draw.DrawText("Entities: " .. InfoBox.count,"TristText_Bold",9,85,autobox.colors.brown,TEXT_ALIGN_LEFT)
    end
    function InfoBox:OnMouseReleased(keyCode)
        if (keyCode == MOUSE_RIGHT) then
            PLUGIN:AAT_OpenDMenu(player)
        end
    end


    local BadgeBox = vgui.Create("DPanel",Frame)
    BadgeBox:SetSize(440,295)
    BadgeBox:SetPos(10,150)
    if (!player:IsBot()) then
        local badges = player:AAT_GetBadges()
        if (#badges > 0) then
            local c = 0
            for _,v in ipairs(badges) do
                local badge = vgui.Create("DPanel",BadgeBox)
                badge:SetPos(c * 42 + 8,8)
                badge:SetSize(32,32)
                function badge:Paint(w,h)
                    surface.SetDrawColor(autobox.colors.discord[4])
                    surface.DrawRect(2,2,w - 4,h - 4)
                    autobox.draw:DrawBorder(0,0,w,h,255)
                    surface.SetDrawColor(255,255,255,255)
                    surface.SetMaterial(autobox.badge:GetIcon(v,player))
                    surface.DrawTexturedRect(8,8,16,16)
                end
                badge:SetTooltip(autobox.badge:GetDesc(v,player))
                function badge:OnMouseReleased(keyCode)
                    if (keyCode == MOUSE_RIGHT) then
                        PLUGIN:AAT_OpenBMenu(v)
                    end
                end
                c = c + 1
            end
        end
    end
    function BadgeBox:Paint(w,h)
        surface.SetDrawColor(autobox.colors.brown)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor(autobox.colors.tan2)
        surface.DrawRect(4,4,w-8,h-8)
        --draw.DrawText("Badge Box Coming Soon™","TristText_Bold",w-9,h-25,autobox.colors.brown,TEXT_ALIGN_RIGHT)
    end

    local AvatarPanel = vgui.Create("DPanel",Frame)
    AvatarPanel:SetSize(128 + 8,128 + 8)
    AvatarPanel:SetPos(10,10)
    function AvatarPanel:Paint(w,h)
        surface.SetDrawColor(autobox.colors.brown)
        surface.DrawRect(0,0,w,h)
    end

    local Avatar = vgui.Create("AvatarImage",AvatarPanel)
    Avatar:SetSize(128,128)
    Avatar:SetPos(4,4)
    Avatar:SetPlayer(player,128)
    if (autobox:HasImmunity(LocalPlayer():AAT_GetRank(),"admin")) then
        local AdminBox = vgui.Create("DPanel",Frame)
        AdminBox:SetSize(200,98)
        AdminBox:SetPos(Frame:GetWide() - 210,10)
        function AdminBox:Paint(w,h)
            surface.SetDrawColor(autobox.colors.brown)
            surface.DrawRect(0,0,w,h)
            draw.DrawText("Admin Panel","TristText_Bold",w / 2,0,autobox.colors.white,TEXT_ALIGN_CENTER)
        end

        local DButton = vgui.Create("DButton",AdminBox)
        DButton:SetText("")
        DButton:SetPos(4,22)
        DButton:SetSize(AdminBox:GetWide() - 8,24)
        function DButton:Paint(w,h)
            if (self:IsHovered()) then
                surface.SetDrawColor(autobox.colors.tan2)
            else
                surface.SetDrawColor(autobox.colors.tan)
            end
            surface.DrawRect(0,0,w,h)
            draw.DrawText("Kick","TristText_Bold",w / 2,0,autobox.colors.brown,TEXT_ALIGN_CENTER)
        end
        function DButton:DoClick()
            if (player:IsValid()) then
                autobox:CallPlugin("kick",{player:SteamID()})
            end
        end

        DButton = vgui.Create("DButton",AdminBox)
        DButton:SetText("")
        DButton:SetPos(4,46)
        DButton:SetSize(AdminBox:GetWide() - 8,24)
        function DButton:Paint(w,h)
            if (self:IsHovered()) then
                surface.SetDrawColor(autobox.colors.tan2)
            else
                surface.SetDrawColor(autobox.colors.tan)
            end
            surface.DrawRect(0,0,w,h)
            draw.DrawText("Explode","TristText_Bold",w / 2,0,autobox.colors.brown,TEXT_ALIGN_CENTER)
        end
        function DButton:DoClick()
            autobox:CallPlugin("explode",{player:SteamID()})
        end

        DButton = vgui.Create("DButton",AdminBox)
        DButton:SetText("")
        DButton:SetPos(4,70)
        DButton:SetSize(AdminBox:GetWide() - 8,24)
        function DButton:Paint(w,h)
            if (self:IsHovered()) then
                surface.SetDrawColor(autobox.colors.tan2)
            else
                surface.SetDrawColor(autobox.colors.tan)
            end
            surface.DrawRect(0,0,w,h)
            draw.DrawText("Trainfuck","TristText_Bold",w / 2,0,autobox.colors.brown,TEXT_ALIGN_CENTER)
        end
        function DButton:DoClick()
            autobox:CallPlugin("trainfuck",{player:SteamID()})
        end
    end
end

function PLUGIN:AAT_OpenBMenu(BadID)
    local menu = DermaMenu()
    local isdisp = LocalPlayer():AAT_BadgeDisplayed(BadID)
    local text = "Display on scoreboard"
    if (isdisp) then text = "Remove from scoreboard" end
    local opt = menu:AddOption( text, function()
        autobox.badge:ToggleBadgeDisplay(BadID)
    end)
    if (isdisp) then
        opt:SetIcon("materials/icon16/cancel.png")
    else
        opt:SetIcon("materials/icon16/accept.png")
    end
    menu:Open()
end

function PLUGIN:AAT_OpenDMenu(ply)
    local menu = DermaMenu()
    menu:AddOption( "Copy SteamID", function()
        SetClipboardText(ply:SteamID())
        notification.AddLegacy("SteamID copied to clipboard!",3,2)
        surface.PlaySound( "ambient/levels/canals/drip" .. math.random(1,4) .. ".wav" )
    end)
    menu:Open()
end

function PLUGIN:CloseProfile()
    if (PLUGIN.profile) then
        PLUGIN.profile:Remove()
    end
end

function PLUGIN:AAT_OnReload()
    if (CLIENT) then self:CloseProfile() end
end

autobox:RegisterPlugin(PLUGIN)