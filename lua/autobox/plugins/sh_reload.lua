-----
--Reload the map
-----
local PLUGIN = {}
PLUGIN.title = "Reload"
PLUGIN.author = "Trist"
PLUGIN.description = "Reload the map"
PLUGIN.perm = "Map Reload"
PLUGIN.command = "reload"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has reloaded the map.")
    for _, v in ipairs( player.GetAll() ) do
        autobox:SQL_UpdateLastJoin(v,math.floor(os.time()))
        autobox:SQL_UpdatePlaytime(v,v:AAT_GetPlaytime())
    end
    RunConsoleCommand("gamemode",GAMEMODE.FolderName)
    RunConsoleCommand("changelevel",tostring(game.GetMap()))
end

autobox:RegisterPlugin(PLUGIN)