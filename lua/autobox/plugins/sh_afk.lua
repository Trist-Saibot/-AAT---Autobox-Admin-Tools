-----
--AFK stuff
-----
local PLUGIN = {}
PLUGIN.title = "AFK"
PLUGIN.author = "Trist"
PLUGIN.description = "Show your status as AFK"
PLUGIN.command = "afk"

PLUGIN.afkTime = 600 --15 seconds, bob told me to

function PLUGIN:Call(ply)
    ply.AAT_AFKTimer = CurTime() - self.afkTime
    self:checkAFK()
end
function PLUGIN:PlayerUse(ply) self:setBack(ply) end
function PLUGIN:KeyPress(ply) self:setBack(ply) end
function PLUGIN:KeyRelease(ply) self:setBack(ply) end
function PLUGIN:PlayerSay(ply) self:setBack(ply) end
function PLUGIN:Think()
    if (self.nextCheck or 0 > CurTime()) then return end
    self.nextCheck = CurTime() + 0.1
    self:checkAFK()
end
function PLUGIN:checkAFK()
    for _,v in ipairs(player.GetAll()) do
        if (v:EyeAngles() != v.AAT_AFKAngles) then
            v.AAT_AFKTimer = CurTime()
            v.AAT_AFKAngles = v:EyeAngles()
        end
        if (!v.AAT_AFK and v.AAT_AFKTimer + self.afkTime < CurTime()) then
            autobox:Notify(autobox.colors.blue,v:Nick(),autobox.colors.white," is now AFK.")
            v.AAT_AFK = true
        elseif (v.AAT_AFK and v.AAT_AFKTimer + self.afkTime > CurTime()) then
            autobox:Notify(autobox.colors.blue,v:Nick(),autobox.colors.white," is now back.")
            v.AAT_AFK = false
        end
    end
end
function PLUGIN:setBack(ply)
    ply.AAT_AFKTimer = CurTime()
    self:checkAFK()
end
autobox:RegisterPlugin(PLUGIN)