-----
--Crash a player
-----
local PLUGIN = {}
PLUGIN.title = "Crash"
PLUGIN.author = "Trist"
PLUGIN.description = "nword a player"
PLUGIN.perm = "Crash"
PLUGIN.command = "nword"
PLUGIN.usage = "[players]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    for _, v in ipairs(players) do
        v:SendLua("cam.End()")
        file.Append("MEME_crashLog.txt", "\n" .. os.date("[%m-%d-%y %H:%M] ",os.time()) .. ply:Nick() .. " crashed " .. v:Nick() .. " - " .. v:SteamID())
    end
end

autobox:RegisterPlugin(PLUGIN)