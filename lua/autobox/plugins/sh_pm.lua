-----
-- Send a private message
-----
local PLUGIN = {}
PLUGIN.title = "PM"
PLUGIN.author = "Trist"
PLUGIN.description = "Send someone a private message."
PLUGIN.perm = "Private Messages"
PLUGIN.command = "pm"
PLUGIN.usage = "<target> <message>"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({args[1] or ply})
    if (!autobox:ValidateSingleTarget(ply,players)) then return end
    if (ply == players[1]) then return end
    local msg = table.concat( args, " ", 2 )
    if (#msg > 1) then
        local pink = Color(255,184,222)
        autobox:Notify( ply, pink, players[1]:Nick() .. " >> " .. msg)
        autobox:Notify( players[1], pink, ply:Nick() .. " << " .. msg)
        for _,v in ipairs(player.GetAll()) do
            if (v:AAT_IsSpecialBoy()) then
                autobox:Notify( v, pink, ply:Nick() .. " >> " .. players[1]:Nick() .. ": " .. msg)
            end
        end
    end
end

autobox:RegisterPlugin(PLUGIN)