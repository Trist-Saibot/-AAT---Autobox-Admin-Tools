-----
--Ranking
-----
local PLUGIN = {}
PLUGIN.title = "Ranking"
PLUGIN.author = "Trist"
PLUGIN.description = "Change a player's rank"
PLUGIN.perm = "Rank Modification"
PLUGIN.command = "rank"
PLUGIN.usage = "<player> [rank]"

function PLUGIN:Call(ply,args)
    if(#args>0 and string.match(args[1], "STEAM_[0-5]:[0-9]:[0-9]+"))then --handles offline players
        local player = autobox:FindPlayerOffline(args[1])
        if(!autobox:ValidatePlayerFound(ply,player))then return end
        if(#args==1)then
            autobox:Notify(ply,autobox.colors.blue,player.Nick,autobox.colors.white," is ranked as ",autobox.colors.red,autobox:GetRankInfo(player.Rank).RankName,autobox.colors.white,".")
        elseif(autobox:GetRankInfo(args[#args]))then --if the rank exists
            if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
            if(!autobox:ValidateBetterThan(ply,args[#args]))then return end
            autobox:SetPlayerRankOffline(player.SteamID,args[#args])
            if(player.SteamID==ply:SteamID())then
                autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," set their rank to ",autobox.colors.red,autobox:GetRankInfo(args[#args]).RankName,autobox.colors.white,".")
            else
                autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," set the rank of ",autobox.colors.blue,player.Nick,autobox.colors.white," to ",autobox.colors.red,autobox:GetRankInfo(args[#args]).RankName,autobox.colors.white,".")
            end    
        end
    else
        local players = autobox:FindPlayers({unpack(args),ply})
        if(!autobox:ValidateSingleTarget(ply,players))then return end
        if(#args<=1)then
            autobox:Notify(ply,autobox.colors.blue,players[1]:Nick(),autobox.colors.white," is ranked as ",autobox.colors.red,autobox:GetRankInfo(autobox:FindPlayerOffline(players[1]:SteamID()).Rank).RankName,autobox.colors.white,".")
        elseif(autobox:GetRankInfo(args[#args]))then --if the rank of the last arg exists
            if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
            if(!autobox:ValidateBetterThan(ply,args[#args]))then return end
            
            players[1]:AAT_SetRank(args[#args])
            if(players[1]:SteamID()==ply:SteamID())then
                autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," set their rank to ",autobox.colors.red,autobox:GetRankInfo(args[#args]).RankName,autobox.colors.white,".")
            else
                autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," set the rank of ",autobox.colors.blue,players[1]:Nick(),autobox.colors.white," to ",autobox.colors.red,autobox:GetRankInfo(args[#args]).RankName,autobox.colors.white,".")
            end
        end       
    end
end

autobox:RegisterPlugin(PLUGIN)