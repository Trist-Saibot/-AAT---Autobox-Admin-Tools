-----
--Fake an achievement
-----
local PLUGIN = {}
PLUGIN.title = "Set Badge"
PLUGIN.author = "Trist"
PLUGIN.description = "Set the badge progress of a player"
PLUGIN.perm = "Set Badge"
PLUGIN.command = "setbadge"
PLUGIN.usage = "<player> <badgeID> <progress>"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    if (#args > 0 and string.match(args[1], "STEAM_[0-5]:[0-9]:[0-9]+")) then --handles offline players
        local pl = autobox:FindPlayerOffline(args[1])
        if (!autobox:ValidatePlayerFound(ply,pl)) then return end
        if (!args[2] or !autobox.badge:Exists(args[2])) then return end
        if (!args[3] or !tonumber(args[3])) then return end
        local steamID = pl.SteamID
        local badgeID = args[2]
        local prog = tonumber(args[3])
        if (player.GetBySteamID(steamID)) then
            player.GetBySteamID(steamID):AAT_SetBadgeProgress(args[2],tonumber(args[3]))
        else
            sql.Query("REPLACE INTO AAT_Badges(`Progress`,`SteamID`,`BadgeID`) VALUES" ..
            "( " .. prog .. "," ..
            sql.SQLStr(steamID) .. "," ..
            sql.SQLStr(badgeID) .. ")"
            )
        end
    elseif (#args == 3) then
        local players = autobox:FindPlayers({unpack(args),ply})
        if (!autobox:ValidateSingleTarget(ply,players)) then return end
        if (!args[2] or !autobox.badge:Exists(args[2])) then return end
        if (!args[3] or !tonumber(args[3])) then return end
        players[1]:AAT_SetBadgeProgress(args[2],tonumber(args[3]))
    end
end

autobox:RegisterPlugin( PLUGIN )