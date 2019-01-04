resource.AddFile( "materials/autobox/scoreboard/gear.vtf")
resource.AddFile( "materials/autobox/scoreboard/gear.vmt")
resource.AddFile( "materials/autobox/scoreboard/logo.vtf")
resource.AddFile( "materials/autobox/scoreboard/logo.vmt")
resource.AddFile( "materials/autobox/scoreboard/icons/steam.vtf")
resource.AddFile( "materials/autobox/scoreboard/icons/steam.vmt")
resource.AddFile( "materials/autobox/scoreboard/icons/discord.vtf")
resource.AddFile( "materials/autobox/scoreboard/icons/discord.vmt")
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
    for _,v in pairs(player.GetAll())do
        if(!table.HasValue(DATA.onlineRanks,autobox:GetRankInfo(v:AAT_GetRank())))then
            table.insert(DATA.onlineRanks,autobox:GetRankInfo(v:AAT_GetRank()))
        end
    end 
    table.SortByMember(DATA.onlineRanks,"Immunity",false)
    return DATA
end

if(CLIENT)then
    PLUGIN.icon_gear     = surface.GetTextureID("autobox/scoreboard/gear")
    PLUGIN.icon_logo     = surface.GetTextureID("autobox/scoreboard/logo")
    PLUGIN.icon_steam    = surface.GetTextureID("autobox/scoreboard/icons/steam")
    PLUGIN.icon_discord    = surface.GetTextureID("autobox/scoreboard/icons/discord")
    PLUGIN.cachecount = 0
    PLUGIN.open = false
    function PLUGIN:Think()
        if(self.open)then
            if(self.cachecount != #player.GetAll())then
                PLUGIN:ScoreboardShow()
            end    
        end
    end
end

function PLUGIN:ScoreboardShow()
    if(self.open)then
        PLUGIN:ScoreboardHide()
    end
    gui.EnableScreenClicker(true)    
    self.open = true
    self.cachecount = #player.GetAll()

    --Vars
    local DATA = self:GrabPlayerData()
    local TopH = 150    
    local Margin = 5
    local Length = 720+Margin*2    
    local Height = 20+TopH+(#DATA.onlineRanks*32)+(self.cachecount*24)+Margin*2
    


    --Draw Board
    PLUGIN.scoreboard = vgui.Create("DPanel")
    PLUGIN.scoreboard:SetPos((ScrW()-Length)/2,(ScrH()-Height)/2)
    PLUGIN.scoreboard:SetSize(Length,Height)
    function PLUGIN.scoreboard:Paint(w,h)
        surface.SetDrawColor(autobox.colors.tan)
        surface.DrawRect(0,0,w,h)        
    end
    --PLUGIN.scoreboard:MakePopup()


    local TopPanel = vgui.Create("DPanel",PLUGIN.scoreboard)
    TopPanel:SetPos(Margin,Margin)
    TopPanel:SetSize(Length-Margin*2,TopH)
    function TopPanel:Paint(w,h)
        surface.SetDrawColor(autobox.colors.brown)
        surface.DrawRect(0,0,w,h)
        surface.SetDrawColor( 255, 255, 255, 255 )
        surface.SetTexture(PLUGIN.icon_gear)
        surface.DrawTexturedRectRotated( 64, 64, 128, 128 , (CurTime()%360)*10 )
        surface.SetTexture(PLUGIN.icon_logo)
        surface.DrawTexturedRectRotated( 64, 64, 128, 128 , 0 )
        
        draw.DrawText(os.date("%I:%M %p"),"TristText_Bold",w-5,5,autobox.colors.white,TEXT_ALIGN_RIGHT)
        local text = "Currently playing "..engine.ActiveGamemode().." on "..game.GetMap().." with "..#player.GetAll()
        if(#player.GetAll()~= 1)then
            text=text.." players."
        else
            text=text.." player."
        end
        draw.DrawText(text,"TristText_Default",w/2,h-25,autobox.colors.white,TEXT_ALIGN_CENTER)
        surface.SetDrawColor(autobox.colors.white)
    end
    
    local DiscordButton = vgui.Create("DButton",TopPanel)
    DiscordButton:SetPos(TopPanel:GetWide()-21,TopPanel:GetTall()-21)
    DiscordButton:SetSize(16,16)
    DiscordButton:SetText("")
    DiscordButton:SetTooltip("Copy our Discord link")
    function DiscordButton:DoClick()
        SetClipboardText(autobox.Link_Discord)
        notification.AddLegacy("Discord link copied to clipboard!",3,2)
        surface.PlaySound( "ambient/levels/canals/drip"..math.random(1,4)..".wav" )
    end
    function DiscordButton:Paint(w,h)
        surface.SetTexture(PLUGIN.icon_discord)
        surface.DrawTexturedRect(0,0,w,h)
    end
    
    local SteamButton = vgui.Create("DButton",TopPanel)
    SteamButton:SetPos(TopPanel:GetWide()-40,TopPanel:GetTall()-21)
    SteamButton:SetSize(16,16)
    SteamButton:SetText("")
    SteamButton:SetTooltip("Copy our Steam group link")
    function SteamButton:DoClick()
        SetClipboardText(autobox.Link_Steam)
        notification.AddLegacy("Steam group link copied to clipboard!",3,2)
        surface.PlaySound( "ambient/levels/canals/drip"..math.random(1,4)..".wav" )
    end
    function SteamButton:Paint(w,h)
        surface.SetTexture(PLUGIN.icon_steam)
        surface.DrawTexturedRect(0,0,w,h)
    end

    --determine where our players should sit for later
    local offsets = {}
    local oy = 0
    for _,v in pairs(DATA.onlineRanks)do
        oy=oy+24
        for k,p in pairs(player.GetAll())do
            if(p:AAT_GetRank()==v.Rank)then
                offsets[k]=oy
                oy=oy+24
            end
        end
        oy=oy+8
    end

    --Panel containing players and their ranks
    local RankPanel = vgui.Create("DPanel",PLUGIN.scoreboard)
    RankPanel:SetPos(Margin,TopPanel:GetTall()+Margin+20)
    RankPanel:SetSize(Length-Margin*2,((#DATA.onlineRanks)*32)+(#player.GetAll()*24))
    function RankPanel:Paint(w,h)        
        local y = 0
        for _,v in pairs(DATA.onlineRanks)do
            --draw the rank bar at the top
            surface.SetDrawColor(autobox.colors.brown)
            surface.DrawRect(0,y,w,24)
            
            surface.SetDrawColor(autobox.colors.white)
            surface.SetMaterial(v.IconTexture)
            surface.DrawTexturedRect(4,y+4,16,16)
            draw.DrawText(v.RankName,"TristText_Bold",30,y+1,autobox.colors.white,TEXT_ALIGN_LEFT)

            draw.DrawText("Ping","TristText_Bold",Length-80,y+1,autobox.colors.white,TEXT_ALIGN_CENTER)
            draw.DrawText("Playtime","TristText_Bold",Length-150,y+1,autobox.colors.white,TEXT_ALIGN_CENTER)
            draw.DrawText("Frags","TristText_Bold",Length-220,y+1,autobox.colors.white,TEXT_ALIGN_CENTER)
            draw.DrawText("Deaths","TristText_Bold",Length-290,y+1,autobox.colors.white,TEXT_ALIGN_CENTER)
            draw.DrawText("Props","TristText_Bold",Length-360,y+1,autobox.colors.white,TEXT_ALIGN_CENTER)

            y=y+24
            local swap = false            
            for k,p in pairs(player.GetAll())do
                if(p:AAT_GetRank()==v.Rank)then
                    --draw each player line
                    if(!swap)then
                        surface.SetDrawColor(autobox.colors.tan2)                        
                    else
                        surface.SetDrawColor(autobox.colors.tan)
                    end
                    swap = !swap
                    surface.DrawRect(0,offsets[k],w,24)
                    draw.DrawText(p:Nick(),"TristText_Bold",30,offsets[k],autobox.colors.brown,TEXT_ALIGN_LEFT)                    
                    surface.SetDrawColor(autobox.colors.black)
                    surface.DrawRect(2,offsets[k]+2,20,20)
                    
                    draw.DrawText(p:Ping(),"TristText_Bold",Length-80,offsets[k],autobox.colors.brown,TEXT_ALIGN_CENTER)
                    draw.DrawText(autobox:FormatTime(p:AAT_GetPlaytime()),"TristText_Bold",Length-150,offsets[k],autobox.colors.brown,TEXT_ALIGN_CENTER)
                    draw.DrawText(p:Frags(),"TristText_Bold",Length-220,offsets[k],autobox.colors.brown,TEXT_ALIGN_CENTER)
                    draw.DrawText(p:Deaths(),"TristText_Bold",Length-290,offsets[k],autobox.colors.brown,TEXT_ALIGN_CENTER)
                    local c = 0
                    for _,ent in ipairs(ents.GetAll())do
                        if(ent:GetNWString("AAT_Owner") == p:SteamID())then
                            c=c+1
                        end
                    end                    
                    draw.DrawText(c,"TristText_Bold",Length-360,offsets[k],autobox.colors.brown,TEXT_ALIGN_CENTER)
                    y=y+24
                end
            end  
            y=y+8
        end
    end


    for k,v in pairs(player.GetAll())do
        local Avatar = vgui.Create("AvatarImage",PLUGIN.scoreboard)
        Avatar:SetSize(16,16)
        local x,y = RankPanel:GetPos()
        Avatar:SetPos(x+4,y+offsets[k]+4)
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

        local Mute = vgui.Create("DImageButton",PLUGIN.scoreboard)
        Mute:SetSize(16,16)
        Mute:SetPos(Length-36,y+offsets[k]+4)
        if(v:IsMuted())then
            Mute:SetImage( "icon32/muted.png" )
            Mute:SetTooltip("Unmute this player")
        else
            Mute:SetImage( "icon32/unmuted.png" )
            Mute:SetTooltip("Mute this player")
        end
        function Mute:DoClick()
            v:SetMuted(!v:IsMuted())
            if(v:IsMuted())then
                Mute:SetImage( "icon32/muted.png" )
                Mute:SetTooltip("Unmute this player")                
            else
                Mute:SetImage( "icon32/unmuted.png" )
                Mute:SetTooltip("Mute this player")
            end
            ChangeTooltip(Mute)
            surface.PlaySound("buttons/lightswitch2.wav")
        end
    end

    return true
end

function PLUGIN:ScoreboardHide()
    self.open = false
    gui.EnableScreenClicker(false)
    PLUGIN.scoreboard:Remove()
end












autobox:RegisterPlugin(PLUGIN)