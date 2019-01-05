-----
--Change a player's nickname
-----
local PLUGIN = {}
PLUGIN.title = "Set Nickname"
PLUGIN.author = "Trist"
PLUGIN.description = "Changes a player's nickname"
PLUGIN.perm = "Set Nickname"
PLUGIN.command = "setnick"
PLUGIN.usage = "<player> [nickname]"

local META = debug.getregistry().Player
META.RealName = META.Nick
META.Nick = function(self) 
    if self != nil then
        if self:GetNWBool("IsNickNamed",false) then
             return self:GetNWString("NickName", self:RealName()) 
        else 
            return self:RealName()
        end 
    else 
        return "" 
    end 
end
META.Name = META.Nick
META.GetName = META.Nick

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({args[1],ply})
    if(!autobox:ValidateSingleTarget(ply,players))then return end
    local nick = table.concat(args," ",2)
    if(#nick>0)then
        autobox:Notify( autobox.colors.blue, ply:Nick(), autobox.colors.white, " set the name of ", autobox.colors.red, players[1]:Nick(), autobox.colors.white, " to ", autobox.colors.red, nick, autobox.colors.white, "." ) 
        players[1]:SetNWString("NickName",nick)
        players[1]:SetNWBool("IsNickNamed",true)
    else
        autobox:Notify( autobox.colors.blue, ply:Nick(), autobox.colors.white, " set the name of ", autobox.colors.red, players[1]:Nick(), autobox.colors.white, " back to ", autobox.colors.red, players[1]:RealName(), autobox.colors.white, "." ) 
        players[1]:SetNWString("NickName", ply:RealName())                    
        players[1]:SetNWBool("IsNickNamed",false)
    end
end

autobox:RegisterPlugin(PLUGIN)
