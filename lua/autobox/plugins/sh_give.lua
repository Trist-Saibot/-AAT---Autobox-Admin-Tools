-----
--Give a weapon to a player
-----
local PLUGIN = {}
PLUGIN.title = "Give Weapon"
PLUGIN.author = "Trist"
PLUGIN.description = "Give a weapon to a player"
PLUGIN.perm = "Give Weapon"
PLUGIN.command = "give"
PLUGIN.usage = "<players> <weapon>"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers(args)
    if(!autobox:ValidateHasTarget(ply,players))then return end
    local wep = args[#args]
    if(#args<2)then
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"No weapon specified!")
    --TODO return to this when weapon restrictions are a thing
    elseif(string.Left(wep,7)!="weapon_")then
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"The specified item isn't a weapon!")
    else
        for _,p in ipairs(players)do
            p:Give(wep)
        end
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has given ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white," a ",autobox.colors.red,wep,autobox.colors.white,".")
    end
end

autobox:RegisterPlugin(PLUGIN)