--LUA functions that return some AAT table data

e2function string entity:aatGetRank() --extend entity class
    if (IsValid(this) and this:IsPlayer() and !this:IsBot()) then --make sure entity is player
        return this:AAT_GetRank() --run ABX lua function
    end
end
e2function string entity:aatGetRankName()
    if (IsValid(this) and this:IsPlayer() and !this:IsBot()) then
        return autobox:GetRankInfo(this:AAT_GetRank()).RankName
    end
end
e2function number entity:aatGetImmunity()
    if (IsValid(this) and this:IsPlayer() and !this:IsBot()) then
        return autobox:GetRankInfo(this:AAT_GetRank()).Immunity
    end
end
e2function number entity:aatGetBadgeProgress(string BadID)
    if (IsValid(this) and this:IsPlayer() and !this:IsBot()) then
        return this:AAT_GetBadgeProgress(BadID)
    end
end
e2function number entity:aatHasBadge(string BadID)
    if (IsValid(this) and this:IsPlayer() and !this:IsBot()) then
        if ( this:AAT_HasBadge(BadID) ) then return 1 else return 0 end
    end
end
e2function number entity:aatHasMaxBadge(string BadID)
    if (IsValid(this) and this:IsPlayer() and !this:IsBot()) then
        if ( this:AAT_HasMaxBadge(BadID) ) then return 1 else return 0 end
    end
end



