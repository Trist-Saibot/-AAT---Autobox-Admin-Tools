resource.AddFile( "materials/autobox/scoreboard/gear.vtf")
resource.AddFile( "materials/autobox/scoreboard/gear.vmt")
resource.AddFile( "materials/autobox/scoreboard/logo.vtf")
resource.AddFile( "materials/autobox/scoreboard/logo.vmt")
--[[
resource.AddFile( "materials/autobox/scoreboard/icons/steam.vtf")
resource.AddFile( "materials/autobox/scoreboard/icons/steam.vmt")
resource.AddFile( "materials/autobox/scoreboard/icons/discord.vtf")
resource.AddFile( "materials/autobox/scoreboard/icons/discord.vmt")
]]
resource.AddFile( "materials/autobox/scoreboard/icons/steam.png")
resource.AddFile( "materials/autobox/scoreboard/icons/discord.png")
resource.AddFile( "materials/autobox/scoreboard/icons/patreon.png")

-----
--Display a custom scoreboard
-----
local PLUGIN = {}
PLUGIN.title = "Scoreboard"
PLUGIN.author = "Trist"
PLUGIN.description = "Display a custom scoreboard"

function PLUGIN:GrabPlayerData()
    local DATA = {}
    DATA.onlineRanks = {}
    for _,v in pairs(player.GetAll()) do
        if (!table.HasValue(DATA.onlineRanks,autobox:GetRankInfo(v:AAT_GetRank()))) then
            table.insert(DATA.onlineRanks,autobox:GetRankInfo(v:AAT_GetRank()))
        end
    end
    table.SortByMember(DATA.onlineRanks,"Immunity",false)
    return DATA
end

if (CLIENT) then
    PLUGIN.icon_gear     = surface.GetTextureID("autobox/scoreboard/gear")
    PLUGIN.icon_logo     = surface.GetTextureID("autobox/scoreboard/logo")
    PLUGIN.icon_steam    = Material("autobox/scoreboard/icons/steam.png")
    PLUGIN.icon_discord  = Material("autobox/scoreboard/icons/discord.png")
    PLUGIN.icon_patreon  = Material("autobox/scoreboard/icons/patreon.png")
    PLUGIN.cachecount = 0
    PLUGIN.open = false
    function PLUGIN:Think()
        if (self.open and self.cachecount != #player.GetAll()) then
            PLUGIN:ScoreboardShow()
        end
    end
end

function PLUGIN:ScoreboardShow()
    if (self.open) then
        PLUGIN:ScoreboardHide()
    end
    gui.EnableScreenClicker(true)
    self.open = true
    self.cachecount = #player.GetAll()

    --Vars
    local DATA = self:GrabPlayerData()
    local TopH = 150
    local Margin = 5
    local Length = 720 + Margin * 2 + 16 * 8
    local Height = 20 + TopH + (#DATA.onlineRanks * 32) + (self.cachecount * 24) + Margin * 2



    --Draw Board
    PLUGIN.scoreboard = vgui.Create("DPanel")
    PLUGIN.scoreboard:SetPos((ScrW() - Length) / 2,(ScrH() - Height) / 2)
    PLUGIN.scoreboard:SetSize(Length,Height)
    function PLUGIN.scoreboard:Paint(w,h)
        surface.SetDrawColor(autobox.colors.tan)
        surface.DrawRect(0,0,w,h)
    end
    --PLUGIN.scoreboard:MakePopup()


    local TopPanel = vgui.Create("DPanel",PLUGIN.scoreboard)
    TopPanel:SetPos(Margin,Margin)
    TopPanel:SetSize(Length-Margin * 2,TopH)
    function TopPanel:Paint(w,h)
        surface.SetDrawColor(autobox.colors.brown)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetTexture(PLUGIN.icon_gear)
        surface.DrawTexturedRectRotated( 64, 64, 128, 128 , (CurTime() % 360) * 10 )
        surface.SetTexture(PLUGIN.icon_logo)
        surface.DrawTexturedRectRotated( 64, 64, 128, 128 , 0 )

        draw.DrawText(os.date("%I:%M %p"),"TristText_Bold",w-5,5,autobox.colors.white,TEXT_ALIGN_RIGHT)
        local text = "Currently playing " .. engine.ActiveGamemode() .. " on " .. game.GetMap() .. " with " .. #player.GetAll()
        if (#player.GetAll() != 1) then
            text = text .. " players."
        else
            text = text .. " player."
        end
        draw.DrawText(text,"TristText_Default",w / 2,h-25,autobox.colors.white,TEXT_ALIGN_CENTER)
        surface.SetDrawColor(autobox.colors.white)
    end

    local DiscordButton = vgui.Create("DButton",TopPanel)
    DiscordButton:SetPos(TopPanel:GetWide() - 21,TopPanel:GetTall() - 21)
    DiscordButton:SetSize(16,16)
    DiscordButton:SetText("")
    DiscordButton:SetTooltip("Copy our Discord link")
    function DiscordButton:DoClick()
        SetClipboardText(autobox.Link_Discord)
        notification.AddLegacy("Discord link copied to clipboard!",3,2)
        surface.PlaySound( "ambient/levels/canals/drip" .. math.random(1,4) .. ".wav" )
    end
    function DiscordButton:Paint(w,h)
        surface.SetMaterial(PLUGIN.icon_discord)
        surface.DrawTexturedRect(0,0,w,h)
    end

    local SteamButton = vgui.Create("DButton",TopPanel)
    SteamButton:SetPos(TopPanel:GetWide() - 40,TopPanel:GetTall() - 21)
    SteamButton:SetSize(16,16)
    SteamButton:SetText("")
    SteamButton:SetTooltip("Copy our Steam group link")
    function SteamButton:DoClick()
        SetClipboardText(autobox.Link_Steam)
        notification.AddLegacy("Steam group link copied to clipboard!",3,2)
        surface.PlaySound( "ambient/levels/canals/drip" .. math.random(1,4) .. ".wav" )
    end
    function SteamButton:Paint(w,h)
        surface.SetMaterial(PLUGIN.icon_steam)
        surface.DrawTexturedRect(0,0,w,h)
    end

    local PatreonButton = vgui.Create("DButton",TopPanel)
    PatreonButton:SetPos(TopPanel:GetWide() - 59,TopPanel:GetTall() - 21)
    PatreonButton:SetSize(16,16)
    PatreonButton:SetText("")
    PatreonButton:SetTooltip("Copy our Patreon link")
    function PatreonButton:DoClick()
        SetClipboardText(autobox.Link_Patreon)
        notification.AddLegacy("Patreon link copied to clipboard!",3,2)
        surface.PlaySound( "ambient/levels/canals/drip" .. math.random(1,4) .. ".wav" )
    end
    function PatreonButton:Paint(w,h)
        surface.SetMaterial(PLUGIN.icon_patreon)
        surface.DrawTexturedRect(0,0,w,h)
    end

    --determine where our players should sit for later
    local offsets = PLUGIN:DetermineOffsets(DATA)

    --Panel containing players and their ranks
    local RankPanel = vgui.Create("DPanel",PLUGIN.scoreboard)
    RankPanel:SetPos(Margin,TopPanel:GetTall() + Margin + 20)
    RankPanel:SetSize(Length-Margin * 2,((#DATA.onlineRanks) * 32) + (#player.GetAll() * 24))
    function RankPanel:Paint(w,h)
        local y = 0
        for _,v in pairs(DATA.onlineRanks) do
            --draw the rank bar at the top
            surface.SetDrawColor(autobox.colors.brown)
            surface.DrawRect(0,y,w,24)

            surface.SetDrawColor(autobox.colors.white)
            surface.SetMaterial(v.IconTexture)
            surface.DrawTexturedRect(4,y + 4,16,16)
            draw.DrawText(v.RankName,"TristText_Bold",30,y + 1,autobox.colors.white,TEXT_ALIGN_LEFT)

            draw.DrawText("Ping","TristText_Bold",Length-80,y + 1,autobox.colors.white,TEXT_ALIGN_CENTER)
            draw.DrawText("Playtime","TristText_Bold",Length-150,y + 1,autobox.colors.white,TEXT_ALIGN_CENTER)
            draw.DrawText("Frags","TristText_Bold",Length-220,y + 1,autobox.colors.white,TEXT_ALIGN_CENTER)
            draw.DrawText("Deaths","TristText_Bold",Length-290,y + 1,autobox.colors.white,TEXT_ALIGN_CENTER)
            draw.DrawText("Props","TristText_Bold",Length-360,y + 1,autobox.colors.white,TEXT_ALIGN_CENTER)

            y = y + 24
            local swap = false
            for k,p in pairs(player.GetAll()) do
                if (p:AAT_GetRank() == v.Rank) then
                    --draw each player line
                    if (!swap) then
                        surface.SetDrawColor(autobox.colors.tan2)
                    else
                        surface.SetDrawColor(autobox.colors.tan)
                    end
                    swap = !swap
                    if (k > #offsets) then
                        DATA = PLUGIN:GrabPlayerData()
                        offsets = PLUGIN:DetermineOffsets(DATA)
                        return
                    end --fix players joining in and causing an error
                    surface.DrawRect(0,offsets[k],w,24)
                    draw.DrawText(p:Nick(),"TristText_Bold",30,offsets[k],autobox.colors.brown,TEXT_ALIGN_LEFT)
                    surface.SetDrawColor(autobox.colors.black)
                    surface.DrawRect(2,offsets[k] + 2,20,20)

                    draw.DrawText(p:Ping(),"TristText_Bold",Length-80,offsets[k],autobox.colors.brown,TEXT_ALIGN_CENTER)
                    draw.DrawText(autobox:FormatTime(p:AAT_GetPlaytime()),"TristText_Bold",Length-150,offsets[k],autobox.colors.brown,TEXT_ALIGN_CENTER)
                    draw.DrawText(p:Frags(),"TristText_Bold",Length-220,offsets[k],autobox.colors.brown,TEXT_ALIGN_CENTER)
                    draw.DrawText(p:Deaths(),"TristText_Bold",Length-290,offsets[k],autobox.colors.brown,TEXT_ALIGN_CENTER)
                    local c = 0
                    for _,ent in ipairs(ents.GetAll()) do
                        if (ent:GetNWString("AAT_Owner") == p:SteamID()) then
                            c = c + 1
                        end
                    end
                    draw.DrawText(c,"TristText_Bold",Length-360,offsets[k],autobox.colors.brown,TEXT_ALIGN_CENTER)
                    y = y + 24
                end
            end
            y = y + 8
        end
    end


    for k,v in pairs(player.GetAll()) do
        local x,y = RankPanel:GetPos()

        local PlayerBar = vgui.Create("DPanel",PLUGIN.scoreboard)
        PlayerBar:SetPos(x,y + offsets[k])
        PlayerBar:SetSize(RankPanel:GetWide(),24)
        function PlayerBar:Paint(w,h) end
        function PlayerBar:OnMouseReleased(keyCode)
            if (keyCode == MOUSE_RIGHT) then
                local menu = DermaMenu()
                menu:AddOption( "Copy SteamID", function()
                    SetClipboardText(v:SteamID())
                    notification.AddLegacy("SteamID copied to clipboard!",3,2)
                    surface.PlaySound( "ambient/levels/canals/drip" .. math.random(1,4) .. ".wav" )
                end)
                if (autobox:HasImmunity(LocalPlayer():AAT_GetRank(),"admin")) then
                    local submenu = menu:AddSubMenu("Admin Panel")
                    local ki = submenu:AddOption( "Kick", function()
                        autobox:CallPlugin("kick",{v:SteamID()})
                    end)
                    ki:SetIcon("materials/icon16/cancel.png")
                    local e = submenu:AddOption( "Explode", function()
                        autobox:CallPlugin("explode",{v:SteamID()})
                    end)
                    e:SetIcon("materials/icon16/bomb.png")
                    local t = submenu:AddOption( "Trainfuck", function()
                        autobox:CallPlugin("trainfuck",{v:SteamID()})
                    end)
                    t:SetIcon("materials/icon16/car.png")
                end
                menu:Open()
            end
        end


        local Avatar = vgui.Create("AvatarImage",PlayerBar)
        Avatar:SetSize(16,16)
        Avatar:SetPos(4,4)
        Avatar:SetPlayer(v,32)

        local AvatarButton = vgui.Create("DButton",Avatar)
        AvatarButton:SetSize(Avatar:GetSize())
        AvatarButton:SetText("")
        function AvatarButton:Paint(w,h)
        end
        AvatarButton:SetTooltip("Open this player's profile")
        function AvatarButton:DoClick()
            autobox:FindPlugin("Profile"):OpenProfile(v)
            surface.PlaySound("buttons/lightswitch2.wav")
            PLUGIN:ScoreboardHide()
        end
        local Mute = vgui.Create("DImageButton",PlayerBar)
        Mute:SetSize(16,16)
        Mute:SetPos(Length-40,4)
        if (v:IsMuted()) then
            Mute:SetImage( "icon32/muted.png" )
            Mute:SetTooltip("Unmute this player")
        else
            Mute:SetImage( "icon32/unmuted.png" )
            Mute:SetTooltip("Mute this player")
        end
        function Mute:DoClick()
            v:SetMuted(!v:IsMuted())
            if (v:IsMuted()) then
                Mute:SetImage( "icon32/muted.png" )
                Mute:SetTooltip("Unmute this player")
            else
                Mute:SetImage( "icon32/unmuted.png" )
                Mute:SetTooltip("Mute this player")
            end
            ChangeTooltip(Mute)
            surface.PlaySound("buttons/lightswitch2.wav")
        end

        if (v:IsValid() and !v:IsBot()) then
            local BadgeBox = vgui.Create("DPanel",PlayerBar)
            BadgeBox:SetSize(16 * 7,24)
            BadgeBox:SetPos(Length-384 - 16 * 7,0)
            function BadgeBox:Paint(w,h) end
            local badges = v:AAT_GetDisplayedBadges()
            local c = 0
            for key,value in ipairs(badges) do
                local badge = vgui.Create("DPanel",BadgeBox)
                badge:SetSize(16,16)
                badge:SetPos(c * 16,4)
                function badge:Paint(w,h)
                    surface.SetMaterial(autobox.badge:GetIcon(value,v))
                    surface.DrawTexturedRect(0,0,16,16)
                end
                badge:SetTooltip(autobox.badge:GetDesc(value,v))
                badge:SetMouseInputEnabled( true )
                c = c + 1
            end
            BadgeBox:SetMouseInputEnabled( false )
        end
    end

    return true
end
function PLUGIN:DetermineOffsets(DATA)
    local offsets = {}
    local oy = 0
    for _,v in pairs(DATA.onlineRanks) do
        oy = oy + 24
        for k,p in pairs(player.GetAll()) do
            if (p:AAT_GetRank() == v.Rank) then
                offsets[k] = oy
                oy = oy + 24
            end
        end
        oy = oy + 8
    end
    return offsets
end
function PLUGIN:ScoreboardHide()
    self.open = false
    gui.EnableScreenClicker(false)
    PLUGIN.scoreboard:Remove()
end
if (CLIENT) then
    function PLUGIN:Think()
        if (self.open and self.cachecount != #player.GetAll() ) then
            self:ScoreboardHide()
            timer.Simple(0.1,function()
                self:ScoreboardShow()
            end)
        end
    end
end
autobox:RegisterPlugin(PLUGIN)