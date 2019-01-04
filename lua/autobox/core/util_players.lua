--Player Management
function autobox:IsNameMatch(ply,str)
    if(str=="*")then --all players
        return true
    elseif(str=="@" and ply:IsAdmin())then --only admins
        return true
    elseif(str=="!@" and !ply:IsAdmin())then --non admins
        return true
    elseif(string.match(str, "STEAM_[0-5]:[0-9]:[0-9]+"))then --steamid
        return ply:SteamID() == str
    else --player name
        if(!tonumber(str))then --can't pass number as arg
            return(string.lower(ply:Nick())==string.lower(str) or string.find(string.lower(ply:Nick()),string.lower(str),nil,true))
        end
    end
end
function autobox:FindPlayers(...)
    local matches = {}
    local args = unpack{...}
    for _, ply in ipairs(player.GetAll())do
        for _,v in ipairs(args) do
            if(type(v)=="string")then
                if(autobox:IsNameMatch(ply,v)) then table.insert(matches,ply) end
            end
        end        
    end
    return matches
end
function autobox:CreatePlayerList(players)
    local list = ""
    if(#players == 1) then
        list = players[1]:Nick()
    elseif(#players==#player.GetAll()) then
        list = "everyone"
    else
        for i=1,#players do
            if(i==#players)then
                list = list.." ".."and".." "..players[i]:Nick()
            elseif(i==1)then
                list = players[i]:Nick()
            else
                list = list..", "..players[i]:Nick()
            end
        end        
    end
    return list
end
if(SERVER)then
    hook.Add("PlayerSpawn","AAT_SetupPlayer",function(ply)
        if(!ply.Initialized)then
            local data = autobox:SQL_GetPlayerData(ply)
            if(!data)then
                autobox:SQL_RegisterPlayer(ply)
                data = autobox:SQL_GetPlayerData(ply)
            end
            local time = autobox:SyncTime()
            ply.LastJoin = time
            ply.LastSave = time            
            ply.Playtime = tonumber(autobox:SQL_GetPlayerData(ply).Playtime) or 0
            autobox:SQL_UpdateLastJoin(ply,time)
            if(data.LastJoin != "NULL")then
                autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," last joined ",autobox.colors.red,autobox:FormatTime(time-tonumber(data.LastJoin)),autobox.colors.white," ago.")            
            else
                autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has joined for the first time.")            
            end 
            timer.Create("AAT_TimeSync_"..time,1,1,function()
                autobox:SyncPlaytime()
                timer.Remove("AAT_TimeSync_"..time)
            end)
            if(ply:GetNWString("AAT_Rank",nil)!=nil)then
                ply:SetNWString("AAT_Rank",data.Rank)
                autobox:SyncRanks(ply)
            end
            hook.Run("AAT_InitializePlayer",ply)
            ply.Initialized = true            
        end        
    end)
end