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
    local players = autobox:FindPlayers({args[1] or ply:SteamID()})
    if(!autobox:ValidateSingleTarget(ply,players))then return end
    if(#args<=1)then
        autobox:Notify(ply,autobox.colors.blue,players[1]:Nick(),autobox.colors.white," is ranked as ",autobox.colors.red,autobox:GetRankInfo(players[1]:AAT_GetRank()).RankName,autobox.colors.white,".")
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

autobox:RegisterPlugin(PLUGIN)