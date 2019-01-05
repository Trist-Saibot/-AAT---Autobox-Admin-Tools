-----
--Play a sound
-----
local PLUGIN = {}
PLUGIN.title = "Play"
PLUGIN.author = "Trist"
PLUGIN.description = "Play a sound"
PLUGIN.perm = "Play Sound"
PLUGIN.command = "play"
PLUGIN.usage = "<path to sound>"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local sound = args[1]
    if(sound and file.Exists("sound/"..sound,"GAME"))then
        for _,v in ipairs(player.GetAll())do
            v:ConCommand("play "..sound)
        end
    else
        autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"Sound file not found!") 
    end
end

autobox:RegisterPlugin(PLUGIN)