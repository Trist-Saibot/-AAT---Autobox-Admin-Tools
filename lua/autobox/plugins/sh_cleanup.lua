-----
--Clean up the map
-----
local PLUGIN = {}
PLUGIN.title = "Cleanup"
PLUGIN.author = "Trist"
PLUGIN.description = "Clean up the map"
PLUGIN.perm = "Cleanup"
PLUGIN.command = "cleanup"
PLUGIN.usage = "[player]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    if (#args == 0) then --cleanup all
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has cleaned up the map.")
        game.CleanUpMap()
    else --cleanup specific players
        local players = autobox:FindPlayers(args)
        if (!autobox:ValidateHasTarget(ply,players)) then return end
        for _,ent in ipairs(ents.GetAll()) do
            for _,v in ipairs(players) do
                if (ent:GetNWString("AAT_Owner") == v:SteamID()) then
                    ent:Remove()
                    break
                end
            end
        end
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has cleaned up the entities of ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end

autobox:RegisterPlugin(PLUGIN)