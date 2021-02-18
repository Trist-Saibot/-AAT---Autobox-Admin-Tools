--Player Management
function autobox:IsNameMatch(ply,str)
    if (str == "*") then --all players
        return true
    elseif (str == "@" and ply:IsAdmin()) then --only admins
        return true
    elseif (str == "!@" and !ply:IsAdmin()) then --non admins
        return true
    elseif (string.match(str, "STEAM_[0-5]:[0-9]:[0-9]+")) then --steamid
        return ply:SteamID() == str
    else --player name
        if (!tonumber(str)) then --can't pass number as arg
            return string.lower(ply:Nick()) == string.lower(str) or string.find(string.lower(ply:Nick()),string.lower(str),nil,true)
        end
    end
end
--Finds players with passed player names
function autobox:FindPlayers(...)
    --01/04/2019
    --Now supports passing the local player in, will
    --use the player if no args were found
    local matches = {}
    local args = unpack{...}
    for _, ply in ipairs(player.GetAll()) do
        for _,v in ipairs(args) do
            if (type(v) == "string" and autobox:IsNameMatch(ply,v)) then
                table.insert(matches,ply)
            end
        end
    end
    if (#matches < 1) then
        for _,v in pairs(args) do
            if (type(v) == "Player") then
                table.insert(matches,v)
                return matches
            end
        end
    end
    return matches
end
--Finds players with passed steamID.
--Searches SQL database rather than player list
function autobox:FindPlayerOffline(steamID)
    if (string.match(steamID, "STEAM_[0-5]:[0-9]:[0-9]+")) then
        return autobox:SQL_GetPlayerDataBySteamID(steamID)
    end
    return nil
end
function autobox:CreatePlayerList(players)
    local list = ""
    if (#players == 1) then
        list = players[1]:Nick()
    elseif (#players == #player.GetAll()) then
        list = "everyone"
    else
        for i = 1,#players do
            if (i == #players) then
                list = list .. " " .. "and" .. " " .. players[i]:Nick()
            elseif (i == 1) then
                list = players[i]:Nick()
            else
                list = list .. ", " .. players[i]:Nick()
            end
        end
    end
    return list
end
if (SERVER) then
    hook.Add("PlayerSpawn","AAT_SetupPlayer",function(ply)
        if (!ply.Initialized) then
            local data = autobox:SQL_GetPlayerData(ply)
            if (!data) then
                autobox:SQL_RegisterPlayer(ply)
                data = autobox:SQL_GetPlayerData(ply)
            end
            local time = autobox:SyncTime()
            ply.LastJoin = time
            ply.LastSave = time
            ply.Playtime = tonumber(autobox:SQL_GetPlayerData(ply).Playtime) or 0
            autobox:SQL_UpdateLastJoin(ply,time)
            if (data.LastJoin != "NULL") then
                if (ply:Nick() != data.Nick and !ply:IsBot()) then
                    autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," last joined ",autobox.colors.red,autobox:FormatTime(time-tonumber(data.LastJoin)),autobox.colors.white," ago as ",autobox.colors.red,data.Nick,autobox.colors.white,".")
                    autobox:SQL_UpdatePlayerName(ply:SteamID(),ply:Nick())
                else
                    autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," last joined ",autobox.colors.red,autobox:FormatTime(time-tonumber(data.LastJoin)),autobox.colors.white," ago.")
                end
            else
                autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has joined for the first time.")
            end
            timer.Create("AAT_TimeSync_" .. time,1,1,function()
                autobox:SyncPlaytime()
                timer.Remove("AAT_TimeSync_" .. time)
            end)

            ply:SetNWString("AAT_Rank",data.Rank)
            ply:AAT_FixUserGroup()
            autobox:SyncRanks(ply)
            autobox:SyncPerms(ply)

            --2/18/2021 I have NO IDEA why I did not give this priority when setting up AAT players, but now it does have it
            --I think I meant this to be temporary originally
            autobox.badge:LoadPlayer(ply)
            autobox.badge:SyncProgress()

            hook.Run("AAT_InitializePlayer",ply)
            ply.Initialized = true
        end
    end)

    hook.Add("PlayerDisconnected", "AAT_DisconnectMessage", function(ply)
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has disconnected.")
    end)


    gameevent.Listen("player_changename")
    hook.Add("player_changename","AAT_OnNameChange",function(data)
        local ply = Player(data.userid)
        local oldname = data.oldname
        local newname = data.newname
        autobox:Notify(autobox.colors.blue,oldname,autobox.colors.white," changed their name to ",autobox.colors.red,newname,autobox.colors.white,".")
        autobox:SQL_UpdatePlayerName(ply:SteamID(),newname)
    end)
end

--overwrite player connection
if (CLIENT) then
    hook.Add( "ChatText", "hide_joinleave", function( index, name, text, typ )
        if ( typ == "joinleave" ) then return true end
    end )
end