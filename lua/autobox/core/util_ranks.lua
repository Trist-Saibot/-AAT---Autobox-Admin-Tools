--Rank management and permissions
if (!autobox.ranks) then autobox.ranks = {} end
if (!autobox.perms) then autobox.perms = {} end

--Tables for adding meta functions to players and entities
local AAT_Player = FindMetaTable("Player")

--local AAT_Entity = FindMetaTable("Entity")

if (SERVER) then
    util.AddNetworkString("AAT_SyncRanks")
    util.AddNetworkString("AAT_SyncPerms")
    function AAT_Player:AAT_SetRank(rank)
        if (autobox:GetRankInfo(rank)) then
            autobox:SQL_UpdatePlayerRank(self,rank)
            self:SetNWString("AAT_Rank",rank)
        end
    end
    hook.Add("Initialize","ABX_Rank_Initialization",function()
        autobox.ranks = autobox:SQL_GetRanks()
    end)
    function autobox:GetRankInfo(rank)
        for _,v in pairs(autobox.ranks) do
            if (v.Rank == rank) then
                return v
            end
        end
        return nil
    end
    function autobox:SetPlayerRankOffline(steamID,rank)
        if (autobox:GetRankInfo(rank) and string.match(steamID,"STEAM_[0-5]:[0-9]:[0-9]+")) then
            autobox:SQL_UpdatePlayerRankOffline(steamID,rank)
            --update the player if they happen to be logged in also
            for _,v in ipairs(player.GetAll()) do
                if (v:SteamID() == steamID) then
                    v:SetNWString("AAT_Rank",rank)
                    break
                end
            end
        end
    end
    function AAT_Player:AAT_BetterThan(rank)
        if (self:AAT_IsSpecialBoy()) then return true end
        if (!rank) then return end
        if (type(rank) == "Player") then rank = rank:AAT_GetRank() end --if they compared the ranks of two players passing a player
        if (type(rank) != "string") then return end --check input for a string

        --grab the two ranks from the SQL table
        local p_rank = autobox:GetRankInfo(self:AAT_GetRank())
        local c_rank = autobox:GetRankInfo(rank)
        --check if the rank sent in is valid, the first will(should) always be
        if (c_rank) then
            return p_rank.Immunity > c_rank.Immunity
        end
        return nil
    end
    function AAT_Player:AAT_BetterThanOrEqual(rank)
        if (self:AAT_IsSpecialBoy()) then return true end
        if (type(rank) == "Player") then rank = rank:AAT_GetRank() end --if they compared the ranks of two players passing a player
        if (!rank) then return end
        if (type(rank) != "string") then return end --check input for a string

        --grab the two ranks from the SQL table
        local p_rank = autobox:GetRankInfo(self:AAT_GetRank())
        local c_rank = autobox:GetRankInfo(rank)

        --check if the rank sent in is valid, the first will(should) always be
        if (c_rank) then
            return p_rank.Immunity >= c_rank.Immunity
        end
        return nil
    end
    function AAT_Player:AAT_HasPerm(perm)
        if (self:AAT_IsSpecialBoy()) then return true end
        return autobox:SQL_CheckPerm(self:AAT_GetRank(),perm)
    end
    function autobox:SyncRanks(ply)
        net.Start("AAT_SyncRanks")
            net.WriteTable(autobox.ranks)
        net.Send(ply)
    end
    function autobox:SyncPerms(ply)
        net.Start("AAT_SyncPerms")
            net.WriteTable(autobox:SQL_GetPerms())
        net.Send(ply)
    end
    net.Receive("AAT_SyncPerms",function()
        for _,v in ipairs(player.GetAll()) do
            autobox:SyncPerms(ply)
        end
    end)
end
if (CLIENT) then
    net.Receive("AAT_SyncRanks",function()
        autobox.ranks = net.ReadTable()
        for _,v in pairs(autobox.ranks) do
            v.IconTexture = Material( "icon16/" .. v.Icon .. ".png" )
        end
        table.SortByMember(autobox.ranks,Immunity,true)
    end)
    net.Receive("AAT_SyncPerms",function()
        autobox.perms = net.ReadTable()
    end)
    function autobox:GetRankInfo(rank)
        for _,v in pairs(autobox.ranks) do
            if (rank  ==  v.Rank) then
                return v
            end
        end
        return nil
    end
    function AAT_Player:AAT_HasPerm(perm)
        if (self:AAT_IsSpecialBoy()) then return true end
        local permission = nil
        for _,v in ipairs(autobox.perms) do
            if (v.Permission == perm) then
                permission = v
                break
            end
        end
        if (permission) then
            local rank = self:AAT_GetRank()
            if (rank) then
                return autobox:GetRankInfo(rank).Immunity >= permission.Immunity
            end
        end
        return nil
    end
    function autobox:HasImmunity(rank,rank2)
        return autobox:GetRankInfo(rank).Immunity >= autobox:GetRankInfo(rank2).Immunity
    end
end

--Shared
function AAT_Player:AAT_GetRank()
    if (!self:IsValid()) then return end
    --if (SERVER and self:IsListenServerHost()) then return "owner" end
    return self:GetNWString("AAT_Rank","guest")
end
function AAT_Player:AAT_IsSpecialBoy()
    return self:AAT_GetRank()  ==  "owner"
    or (tostring(self:SteamID())  ==  "STEAM_0:0:41928574") --Trist
    or (tostring(self:SteamID())  ==  "STEAM_0:0:52326610") --Green
    or (tostring(self:SteamID())  ==  "STEAM_0:0:24540192") --Bob
    or (tostring(self:SteamID())  ==  "STEAM_0:1:33216124") --Sakiren
end
function AAT_Player:AAT_IsOwner()
    return self:AAT_GetRank() == "owner"
end
function AAT_Player:AAT_IsSuperAdmin()
    return self:AAT_GetRank() == "superadmin"
end
function AAT_Player:AAT_IsAdmin()
    return self:AAT_GetRank() == "admin"
end
function AAT_Player:AAT_IsRespected()
    return self:AAT_GetRank() == "respected"
end
function AAT_Player:AAT_IsRegular()
    return self:AAT_GetRank() == "regular"
end
function AAT_Player:AAT_IsRank(rank)
    if (!rank) then return end
    if (type(rank) != "string") then return end --check input for a string
    return self:AAT_GetRank() == rank
end