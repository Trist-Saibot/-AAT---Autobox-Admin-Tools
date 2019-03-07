--Functions refering to the internal SQL database
if (SERVER) then
    function autobox:SQL_SetupTables()
        if (!sql.TableExists("AAT_Ranks")) then
            sql.Query("CREATE TABLE AAT_Ranks (`Rank` TEXT,`RankName` TEXT,`Color` TEXT,`Immunity` INTEGER,`Icon` TEXT,CONSTRAINT `PK_Ranks` PRIMARY KEY (`Rank`))")
            sql.Query("INSERT INTO AAT_Ranks(`Rank`,`RankName`,`Immunity`,`Color`,`Icon`) VALUES ('guest','Guest',0,'#80FFFF','user_add'),('regular','Regular',1,'#80FFA1','user'),('respected','Respected',2,'#80A1FF','user'),('admin','Admin',3,'#464646','shield'),('superadmin','System Admin',4,'#000000','shield_add'),('owner','Owner',5,'#00ABBD','key')")
        end
        if (!sql.TableExists("AAT_Permissions")) then
            sql.Query("CREATE TABLE AAT_Permissions(`Permission` TEXT,`Immunity` INTEGER DEFAULT 5,CONSTRAINT `PK_Permissions` PRIMARY KEY (`Permission`))")
        end
        if (!sql.TableExists("AAT_Players")) then
            sql.Query("CREATE TABLE AAT_Players (`SteamID` TEXT,`Nick` TEXT,`Rank` TEXT,`Playtime` INTEGER,`LastJoin` INTEGER,CONSTRAINT `PK_Players` PRIMARY KEY (`SteamID`),CONSTRAINT `FK_P_Rank` FOREIGN KEY (`Rank`) REFERENCES AAT_Ranks(`Rank`))")
        end
        if (!sql.TableExists("AAT_Restrictions")) then
            sql.Query("CREATE TABLE AAT_Restrictions(`Type` TEXT,`Permission` TEXT,`Immunity` INTEGER DEFAULT 5,CONSTRAINT `PK_Restrictions` PRIMARY KEY (`Type`,`Permission`))")
        end
    end
    function autobox:SQL_CheckPerm(rank,perm)
        if (perm and rank and type(perm) == "string" and type(rank) == "string") then
            if (rank == "owner") then --owner has every permission
                return true
            else
                local data = sql.QueryRow("SELECT * from AAT_Permissions WHERE Permission = " .. sql.SQLStr(perm),1)
                if (data) then return autobox:SQL_FindRank(rank).Immunity >= data.Immunity else return nil end
            end
        end
        return nil
    end
    function autobox:SQL_AddPerm(perm)
        if (perm and type(perm) == "string") then
            local data = sql.Query("SELECT Permission FROM AAT_Permissions WHERE Permission = " .. sql.SQLStr(perm))
            if (!data) then -- if the permission isn't already in the table
                sql.Query("INSERT INTO AAT_Permissions(Permission) VALUES (" .. sql.SQLStr(perm) .. ")")
            end
        end
    end
    function autobox:SQL_GetPlayerData(ply)
        if (ply and ply:IsValid() and ply:IsPlayer()) then
                return sql.QueryRow("SELECT * FROM AAT_Players WHERE SteamID = " .. sql.SQLStr(ply:SteamID()),1)
        end
        return nil
    end
    function autobox:SQL_GetPlayerDataBySteamID(steamid)
        if (steamid and type(steamid) == "string") then
                return sql.QueryRow("SELECT * FROM AAT_Players WHERE SteamID = " .. sql.SQLStr(steamid),1)
        end
        return nil
    end
    function autobox:SQL_GetAllOnlinePlayerData()
        local players = {}
        for _,v in ipairs(player.GetAll()) do
            table.insert(players,autobox:SQL_GetPlayerData(v))
        end
        return players
    end
    function autobox:SQL_GetAllPlayerData()
        return sql.Query("SELECT * FROM AAT_Players")
    end
    function autobox:SQL_GetRanks()
        return sql.Query("SELECT * from AAT_Ranks")
    end
    function autobox:SQL_GetPerms()
        return sql.Query("SELECT * from AAT_Permissions")
    end
    function autobox:SQL_FindRank(rank)
        if (rank and type(rank) == "string") then
            return sql.QueryRow("SELECT * from AAT_Ranks where Rank = " .. sql.SQLStr(rank),1)
        end
        return nil
    end
    function autobox:SQL_UpdatePlayerRank(ply,rank)
        if (ply and rank and ply:IsValid() and ply:IsPlayer() and type(rank) == "string") then
            sql.Query("UPDATE AAT_Players SET " ..
            "Rank = " .. sql.SQLStr(rank) .. " " ..
            "WHERE SteamID = " .. sql.SQLStr(ply:SteamID())
            )
        end
    end
    function autobox:SQL_UpdatePlayerRankOffline(steamID,rank)
        if (steamID and rank and type(steamID) == "string" and string.match(steamID,"STEAM_[0-5]:[0-9]:[0-9]+") and type(rank) == "string") then
            sql.Query("UPDATE AAT_Players SET " ..
            "Rank = " .. sql.SQLStr(rank) .. " " ..
            "WHERE SteamID = " .. sql.SQLStr(steamID)
            )
        end
    end
    function autobox:SQL_UpdatePlayerName(steamID,name)
        if (steamID and name and type(steamID) == "string" and string.match(steamID,"STEAM_[0-5]:[0-9]:[0-9]+") and type(name) == "string") then
            sql.Query("UPDATE AAT_Players SET " ..
            "Nick = " .. sql.SQLStr(name) .. " " ..
            "WHERE SteamID = " .. sql.SQLStr(steamID)
            )
        end
    end
    function autobox:SQL_RegisterPlayer(ply)
        if (ply and ply:IsValid() and ply:IsPlayer()) then
            sql.Query("INSERT INTO AAT_Players(SteamID,Nick,Rank,Playtime)" ..
            " VALUES(" ..
            sql.SQLStr(ply:SteamID()) .. "," ..
            sql.SQLStr(ply:Nick()) .. "," ..
            sql.SQLStr(ply:AAT_GetRank() or "guest") ..
            ",0)"
            )
        end
    end
    function autobox:SQL_UpdatePlaytime(ply,playtime)
        if (ply and playtime and ply:IsValid() and ply:IsPlayer() and tonumber(playtime)) then
            sql.Query("UPDATE AAT_Players SET " ..
            "Playtime = " .. tonumber(playtime) .. " " ..
            "WHERE SteamID = " .. sql.SQLStr(ply:SteamID())
            )
        end
    end
    function autobox:SQL_UpdateLastJoin(ply,lastjoin)
        if (ply and lastjoin and ply:IsValid() and ply:IsPlayer() and tonumber(lastjoin)) then
            sql.Query("UPDATE AAT_Players SET " ..
            "LastJoin = " .. tonumber(lastjoin) .. " " ..
            "WHERE SteamID = " .. sql.SQLStr(ply:SteamID())
            )
        end
    end
    function autobox:SQL_SaveTimeOnDisconnect(steamid,playtime,lastjoin)
        if (steamid and playtime and lastjoin and type(steamid) == "string" and tonumber(playtime) and tonumber(lastjoin)) then
            sql.Query("UPDATE AAT_Players SET " ..
            "Playtime = " .. tonumber(playtime) .. "," ..
            "LastJoin = " .. tonumber(lastjoin) .. " " ..
            "WHERE SteamID = " .. sql.SQLStr(steamid)
            )
        end
    end
    function autobox:SQL_Restriction_CheckPerm(ptype,perm)
        if (type and perm and type(ptype) == "string" and type(perm) == "string") then
            local data = sql.QueryRow("SELECT * from AAT_Restrictions where Type = " .. sql.SQLStr(ptype) .. "and Permission = " .. sql.SQLStr(perm),1)
            if (!data) then --instead, create the row if it cannot be found. Give it the default Immunity.
                sql.Query("INSERT INTO AAT_Restrictions VALUES (" .. sql.SQLStr(ptype) .. "," .. sql.SQLStr(perm) .. ",5)")
                return 5
            else
                return data.Immunity
            end
        end
        return nil
    end
end

