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
        --game.CleanUpMap()

        -- https://github.com/Facepunch/garrysmod/blob/394ae745df8f8f353ea33c8780f012fc000f4f56/garrysmod/lua/includes/modules/cleanup.lua
        local cleanup_list = cleanup.GetList()
        for key, ply in pairs( cleanup_list ) do
            for key, type in pairs( ply ) do
                for key, ent in pairs( type ) do
                    if ( IsValid( ent ) ) then ent:Remove() end
                end
                table.Empty( type )
            end
        end
        game.CleanUpMap()

    else --cleanup specific players

        local players = autobox:FindPlayers(args)
        if (!autobox:ValidateHasTarget(ply,players)) then return end
        for _,pl in ipairs(players) do

            -- https://github.com/Facepunch/garrysmod/blob/394ae745df8f8f353ea33c8780f012fc000f4f56/garrysmod/lua/includes/modules/cleanup.lua
            local id = pl:UniqueID()
            local cleanup_list = cleanup.GetList()
            for key, val in pairs( cleanup_list[ id ] ) do
                for key, ent in pairs( val ) do
                    if ( IsValid( ent ) ) then ent:Remove() end
                end
                table.Empty( val )
            end

        end




        --[[
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
        ]]
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has cleaned up the entities of ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end

autobox:RegisterPlugin(PLUGIN)