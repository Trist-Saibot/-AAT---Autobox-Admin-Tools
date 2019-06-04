autobox.badge = autobox.badge or {} --meta table containing badge functions
autobox.badge.badges = autobox.badge.badges or {} --table containing badge information by BadgeID
autobox.badge.progress = autobox.badge.progress or {} --table containing all badge progress of currently logged in players

function autobox.badge:GetName(BadID,ply)
    --return the name of a badge
    local badge = self:GetBadge(BadID)
    if (ply and badge.Prog) then
        return badge.GetProg(ply).Name
    else
        return badge.Name
    end
end

function autobox.badge:GetDesc(BadID,ply)
    --return the description of a badge
    local badge = self:GetBadge(BadID)
    if (ply and badge.Prog) then
        return badge.GetProg(ply).Desc
    else
        return badge.Desc
    end
end

function autobox.badge:GetGoal(BadID,ply)
    --return the goal required to have a badge
    local badge = self:GetBadge(BadID)
    if (ply and badge.Prog) then
        return badge.GetProg(ply).Goal
    else
        return badge.Goal
    end
end

function autobox.badge:GetIcon(BadID,ply)
    --returns the badge icon of the selected badge
    local badge = self:GetBadge(BadID)
    if (ply and badge.Prog) then
        return badge.GetProg(ply).Icon
    else
        return badge.Icon
    end
end

function autobox.badge:GetBadge(BadID)
    --returns a badge table, empty if nil
    if (!self:Exists(BadID)) then return {} end
    return self.badges[BadID]
end

function autobox.badge:Exists(BadID)
    --returns whether a badge exists for a given BadgeID
    if (self.badges[BadID]) then return true end
end

hook.Add("AAT_LoadOthers","AAT_LoadBadges",function() --initializes this at startup
    autobox.badge.badges = {}
    local path = "autobox/badges/"
    local badges = file.Find(path .. "*.lua","LUA")
    for _,v in ipairs(badges) do
        include(path .. v)
        if (SERVER) then
            AddCSLuaFile(path .. v)
        end
    end
end)

function autobox.badge:RegisterBadge(BadID,Name,Desc,Goal,Icon,Prog,GetProg)
    --takes information sent in and registers a badge in the badge table
    --disallows duplicate BadgeIDs from existing, first in gets it
    if (!BadID or self:Exists(BadID) or !Name or #string.Trim(Name) == 0) then return false end
    local badge = {}
    badge.Name = Name
    badge.Desc = Desc or ""
    badge.Goal = Goal or 1
    badge.Icon = Icon or "materials/icon16/help.png" --this icon should be 16x16
    badge.Prog = Prog or false
    badge.GetProg = GetProg or nil
    if (CLIENT) then badge.Icon = Material(badge.Icon,"nocull") end
    self.badges[BadID] = badge
end

local AAT_Player = FindMetaTable("Player")
function AAT_Player:AAT_HasBadge(BadID)
    --return true/false if they have Prog/Goal == 100%
    local badge = autobox.badge:GetBadge(BadID)
    if (badge.Prog) then
        return badge.GetProg(self).Has
    else
        local goal = autobox.badge:GetGoal(BadID,self)
        local prog = self:AAT_GetBadgeProgress(BadID)
        if prog >= goal then return true else return false end
    end
end
function AAT_Player:AAT_HasMaxBadge(BadID)
    --return true/false if they have Prog/Goal == 100%
    local badge = autobox.badge:GetBadge(BadID)
    if (badge.Prog) then
        return badge.GetProg(self).HasMax
    else
        return self:AAT_HasBadge(BadID)
    end
end

function AAT_Player:AAT_GetBadges()
    local badges = {}
    for k,_ in pairs(autobox.badge.progress[self:SteamID()]) do
        if (self:AAT_HasBadge(k,self)) then badges[#badges + 1] = k end
    end
    return badges
end

function AAT_Player:AAT_GetDisplayedBadges()
    local badges = {}
    for k,_ in pairs(autobox.badge.progress[self:SteamID()]) do
        if (self:AAT_HasBadge(k,self) and self:AAT_BadgeDisplayed(k)) then badges[#badges + 1] = k end
    end
    return badges
end

function AAT_Player:AAT_GetBadgeProgress(BadID)
    --return the progress of a badge
    --0 by default, 1 if boolean has/hasnot
    --number if any other progress
    if (!autobox.badge.progress[self:SteamID()] or !autobox.badge.progress[self:SteamID()][BadID] or !autobox.badge.progress[self:SteamID()][BadID].Progress) then return 0 end
    return autobox.badge.progress[self:SteamID()][BadID].Progress
end

function AAT_Player:AAT_BadgeDisplayed(BadID)
    return autobox.badge.progress[self:SteamID()][BadID].Displayed
end


if (SERVER) then
    function AAT_Player:AAT_AddBadgeProgress(BadID,prog)
        --increments the progress number on their badge by prog number
        if (!self:AAT_HasMaxBadge(BadID)) then
            if (!autobox.badge.progress[self:SteamID()][BadID]) then autobox.badge.progress[self:SteamID()][BadID] = {} end
            autobox.badge.progress[self:SteamID()][BadID].Progress = self:AAT_GetBadgeProgress(BadID) + prog
            autobox.badge:CheckProgress(self,BadID)
            autobox.badge:WriteChange(self,BadID)
            autobox.badge:SyncProgress()
        end
    end

    function AAT_Player:AAT_SetBadgeProgress(BadID,prog)
        --sets the progress on their badge to prog number
        if (!autobox.badge.progress[self:SteamID()][BadID]) then autobox.badge.progress[self:SteamID()][BadID] = {} end
        autobox.badge.progress[self:SteamID()][BadID].Progress = prog
        autobox.badge:CheckProgress(self,BadID)
        autobox.badge:WriteChange(self,BadID)
        autobox.badge:SyncProgress()
    end

    function autobox.badge:CheckProgress(ply,BadID)
        local badge = self:GetBadge(BadID)
        if (badge.Prog and table.HasValue(badge.GetProg(ply).GetVals,ply:AAT_GetBadgeProgress(BadID))) then
            local name = self:GetName(BadID)
            if (self:GetBadge(BadID).Prog) then
                name = self:GetBadge(BadID).GetProg(ply).ProgName
            end
            autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," just earned the badge ",autobox.colors.red,name,autobox.colors.white,".")
            autobox:CallPlugin("play",ents.Create(""),"garrysmod/save_load1.wav")
        elseif (self:GetGoal(BadID,ply) == ply:AAT_GetBadgeProgress(BadID)) then
            autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," just earned the badge ",autobox.colors.red,self:GetName(BadID),autobox.colors.white,".")
            autobox:CallPlugin("play",ents.Create(""),"garrysmod/save_load1.wav")
        end
    end

    hook.Add("AAT_SetupSQLTables", "AAT_Badge_SQL", function()
        --setup the badge information table
        --this table stores PROGRESS information for all players
        --badge descriptions and goals should be stored in memory
        if (!sql.TableExists("AAT_Badges")) then
            sql.Query("CREATE TABLE AAT_Badges(`BadgeID` TEXT,`SteamID` TEXT,`Progress` INTEGER DEFAULT 0,`Displayed` INTEGER DEFAULT 0,CONSTRAINT `PK_Badges` PRIMARY KEY (`BadgeID`,`SteamID`))")
        end
    end)

    function autobox.badge:LoadPlayer(ply)
        if (!ply:IsValid()) then return end
        local SteamID = ply:SteamID()
        local data = sql.Query("SELECT * from AAT_Badges WHERE `SteamID` = " .. sql.SQLStr(SteamID))
        local pdata = {} --player data table
        if (data) then
            for _,v in pairs(data) do
                if (self.badges[v.BadgeID]) then --only load valid badge data
                    pdata[v.BadgeID] = {}
                    pdata[v.BadgeID].Progress = tonumber(v.Progress)
                    pdata[v.BadgeID].Displayed = tobool(v.Displayed)
                end
            end
        end
        self.progress[SteamID] = pdata --store this table in the collection of player data
    end

    hook.Add("PlayerInitialSpawn", "AAT_LoadBadges", function(ply)
        autobox.badge:LoadPlayer(ply)
        autobox.badge:SyncProgress()
    end)

    util.AddNetworkString("AAT_SyncBadgeData")
    function autobox.badge:SyncProgress()
        --send player progress data to all players
        net.Start("AAT_SyncBadgeData")
        net.WriteTable(self.progress)
        net.Broadcast()
    end

    function autobox.badge:WriteChange(ply,BadID)
        --called to save badge progress in the database
        if (!self.progress[ply:SteamID()]) then return end --if you crashed upon getting an achievement, you're probably SOL
        local prog = ply:AAT_GetBadgeProgress(BadID)
        if (!prog) then return end -- don't write bad data
        local disp = 0
        if (autobox.badge.progress[ply:SteamID()][BadID].Displayed) then disp = 1 end
        sql.Query("REPLACE INTO AAT_Badges(`Progress`,`SteamID`,`BadgeID`,`Displayed`) VALUES" ..
            "( " .. prog .. "," ..
            sql.SQLStr(ply:SteamID()) .. "," ..
            sql.SQLStr(BadID) .. "," ..
            disp .. ")"
            )
    end

    hook.Add("PlayerDisconnect","AAT_Clean_Badges",function(ply) --keeps memory clean of disconnected players
        if (!ply:IsBot()) then
            table.remove(autobox.badges.progress,ply:SteamID())
        end
    end)

    util.AddNetworkString("AAT_ToggleBadgeDisplay")
    net.Receive("AAT_ToggleBadgeDisplay", function(len,ply) --changes the display variable of a badge
        local badgeID = net.ReadString()
        local disp = net.ReadBool()
        if (disp == true) then disp = 1 else disp = 0 end
        if (autobox.badge:Exists(badgeID)) then
            sql.Query("UPDATE AAT_Badges SET " ..
            "Displayed = " .. disp .. " " ..
            "WHERE BadgeID = " .. sql.SQLStr(badgeID) .. " " ..
            "and SteamID = " .. sql.SQLStr(ply:SteamID())
            )
        end
        autobox.badge.progress[ply:SteamID()][badgeID].Displayed = tobool(disp)
        autobox.badge:SyncProgress()
    end)
    util.AddNetworkString("AAT_ShowBadgeNotif")
    function autobox.badge:ShowNotice(ply,BadID)
        net.Start("AAT_ShowBadgeNotif")
        net.WriteString(BadID)
        net.Send(ply)
    end
end

if (CLIENT) then
    net.Receive("AAT_SyncBadgeData",function()
        autobox.badge.progress = net.ReadTable()
    end)
    function autobox.badge:ToggleBadgeDisplay(BadID)
        if (#LocalPlayer():AAT_GetDisplayedBadges() <= 5) then --5 displayed cap
            net.Start("AAT_ToggleBadgeDisplay")
            net.WriteString(BadID)
            net.WriteBool(!LocalPlayer():AAT_BadgeDisplayed(BadID))
            net.SendToServer()
        else
            notification.AddLegacy("You can only display 5 badges!",3,2)
            surface.PlaySound( "ambient/levels/canals/drip" .. math.random(1,4) .. ".wav" )
        end
    end

    hook.Add("HUDPaint","AAT_BadgeNotification",function()
        autobox.badge.NPanel = vgui.Create("DNotify")
        autobox.badge.NPanel:SetPos(ScrW() - 225,ScrH() - 200)
        autobox.badge.NPanel:SetSize(200,200)
        hook.Remove("HUDPaint", "AAT_BadgeNotification")
    end)
    net.Receive("AAT_ShowBadgeNotif",function()
        local BadID = net.ReadString()
        autobox.badge:ShowNotice(BadID)
    end)
    function autobox.badge:ShowNotice(BadID)
        local bg = vgui.Create("DPanel",autobox.badge.NPanel)
        bg:SetSize(200,20)
        bg:SetBackgroundColor(autobox.colors.discord[4])

        local lbl = vgui.Create( "DLabel", bg )
        lbl:SetPos( 5, 0 )
        lbl:SetSize( 200, 20 )
        lbl:SetText( self:GetName(BadID,LocalPlayer()) .. " " .. LocalPlayer():AAT_GetBadgeProgress(BadID) .. "/" .. self:GetGoal(BadID,LocalPlayer()) )
        lbl:SetTextColor( Color( 255, 200, 0 ) )
        lbl:SetFont( "GModNotify" )
        lbl:SetWrap( true )

        autobox.badge.NPanel:AddItem(bg)
    end
end