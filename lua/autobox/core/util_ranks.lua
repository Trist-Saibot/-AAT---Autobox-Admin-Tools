--Rank management and permissions
if(!autobox.ranks)then autobox.ranks = {} end

--Tables for adding meta functions to players and entities
local AAT_Player = FindMetaTable("Player")
local AAT_Entity = FindMetaTable("Entity")

if(SERVER)then        
    util.AddNetworkString("AAT_SyncRanks")
    function AAT_Player:AAT_SetRank(rank)  
        if(autobox:SQL_FindRank(rank))then
            autobox:SQL_UpdatePlayerRank(self,rank)
            self:SetNWString("AAT_Rank",rank)
        end
    end
    function AAT_Player:AAT_BetterThan(rank)
        if(self:AAT_IsSpecialBoy())then return true end
        if(!rank)then return end
        if(type(rank)=="Player")then rank = rank:AAT_GetRank() end --if they compared the ranks of two players passing a player
        if(type(rank)!="string")then return end --check input for a string

        --grab the two ranks from the SQL table
        local p_rank = autobox:SQL_FindRank(self:AAT_GetRank())
        local c_rank = autobox:SQL_FindRank(rank)
        --check if the rank sent in is valid, the first will(should) always be
        if(c_rank)then
            return(p_rank.Immunity > c_rank.Immunity)
        end
        return nil
    end
    function AAT_Player:AAT_BetterThanOrEqual(rank)
        if(self:AAT_IsSpecialBoy())then return true end
        if(type(rank)=="Player")then rank = rank:AAT_GetRank() end --if they compared the ranks of two players passing a player
        if(!rank)then return end
        if(type(rank)!="string")then return end --check input for a string

        --grab the two ranks from the SQL table
        local p_rank = autobox:SQL_FindRank(self:AAT_GetRank())
        local c_rank = autobox:SQL_FindRank(rank)
        
        --check if the rank sent in is valid, the first will(should) always be
        if(c_rank)then
            return(p_rank.Immunity >= c_rank.Immunity)
        end
        return nil
    end
    function AAT_Player:AAT_HasPerm(perm)
        if(self:AAT_IsSpecialBoy())then return true end
        return autobox:SQL_CheckPerm(self:AAT_GetRank(),perm)
    end 
    function autobox:SyncRanks(ply)
        net.Start("AAT_SyncRanks")
            net.WriteTable(autobox:SQL_GetRanks())
        net.Send(ply)
    end
    function autobox:GetRankInfo(rank)
        return autobox:SQL_FindRank(rank)
    end
end
if(CLIENT)then
    net.Receive("AAT_SyncRanks",function()
        autobox.ranks = net.ReadTable()
        for _,v in pairs(autobox.ranks) do
            v.IconTexture = Material( "icon16/" .. v.Icon ..".png" )
        end
        table.SortByMember(autobox.ranks,Immunity,true)
    end)
    function autobox:GetRankInfo(rank)
        for _,v in pairs(autobox.ranks)do
            if(rank == v.Rank)then
                return v
            end
        end
        return nil
    end
    function autobox:HasImmunity(rank,rank2)
        return autobox:GetRankInfo(rank).Immunity >= autobox:GetRankInfo(rank2).Immunity
    end
end
function AAT_Player:AAT_GetRank()
    if(!self:IsValid())then return end
    if(SERVER and self:IsListenServerHost())then return "owner" end
    return self:GetNWString("AAT_Rank","guest")        
end
function AAT_Player:AAT_IsSpecialBoy()
    return self:AAT_GetRank() == "owner"
    or (tostring(self:SteamID()) == "STEAM_0:0:41928574") --Trist 
    or (tostring(self:SteamID()) == "STEAM_0:0:52326610") --Green
    or (tostring(self:SteamID()) == "STEAM_0:0:24540192") --Bob
    or (tostring(self:SteamID()) == "STEAM_0:1:33216124") --Sakiren
end
function AAT_Player:AAT_IsOwner()
    return self:AAT_GetRank()=="owner"
end
function AAT_Player:AAT_IsSuperAdmin()
    return self:AAT_GetRank()=="superadmin"
end
function AAT_Player:AAT_IsAdmin()
    return self:AAT_GetRank()=="admin"
end
function AAT_Player:AAT_IsRespected()
    return self:AAT_GetRank()=="respected"
end
function AAT_Player:AAT_IsRegular()
    return self:AAT_GetRank()=="regular"
end
function AAT_Player:AAT_IsRank(rank)
    if(!rank)then return end
    if(type(rank)!="string")then return end --check input for a string
    return (self:AAT_GetRank()==rank)        
end