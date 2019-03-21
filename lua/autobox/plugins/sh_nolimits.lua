-----
--Disable limits on a player
-----
local PLUGIN = {}
PLUGIN.title = "No Limits"
PLUGIN.author = "Trist"
PLUGIN.description = "Disable limits on a player"
PLUGIN.perm = "No Limits"
PLUGIN.command = "nolimits"
PLUGIN.usage = "<player> [1/0]"

function PLUGIN:Call( ply, args )
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    local enabled = tonumber(args[#args]) or 1
    for _,v in ipairs(players) do
        v.AAT_NoLimits = tobool(enabled)
    end
    local stateString = "enabled"
    if (tobool(enabled)) then
        stateString = "disabled"
    end
    if (#players == 1 and players[1] == ply) then

        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has " .. stateString .. " limits for themselves.")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has " .. stateString .. " limits for ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end

if (SERVER) then
    local AAT_Player = FindMetaTable("Player")
    function PLUGIN:AAT_PostStartup() --run right after the plugin initializes
        timer.Simple(5,function()
            PLUGIN.GetCount = AAT_Player.GetCount
            function AAT_Player:GetCount(limit,minus)
                if (self.AAT_NoLimits or self:AAT_HasPerm(PLUGIN.perm)) then
                    return -1
                else
                    return PLUGIN.GetCount(self,limit,minus)
                end
            end
        end)
    end
    function PLUGIN:AAT_OnReload() --run if the plugin is reloaded to avoid one HUGE stack of functions calling themselves
        if (PLUGIN.GetCount) then
            AAT_Player.GetCount = PLUGIN.GetCount
        end
    end
end

autobox:RegisterPlugin( PLUGIN )