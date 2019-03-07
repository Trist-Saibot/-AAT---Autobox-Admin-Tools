-----
--Display the restriction menu
-----
local PLUGIN = {}
PLUGIN.title = "Restriction Menu"
PLUGIN.author = "Trist"
PLUGIN.description = "Display the restriction menu"
PLUGIN.perm = "Hide Physgun Beam"
PLUGIN.command = "rmenu"

if(SERVER)then
    util.AddNetworkString("AAT_OpenRMenu")
end

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    net.Start("AAT_OpenRMenu")
    net.Send(ply)
end

if(CLIENT)then
    net.Receive("AAT_OpenRMenu",function()
        if(!autobox:ValidatePerm(LocalPlayer(),PLUGIN.perm))then return end
        PLUGIN:OpenRMenu()
    end)
end

function PLUGIN:OpenRMenu()
    self:CloseRMenu()
    self.rmenu = vgui.Create("DFrame")
    self.rmenu:SetSize(800,500)
    self.rmenu:Center()
    self.rmenu:SetTitle("")
    self.rmenu:SetDraggable(true)
    self.rmenu:MakePopup()
    function self.rmenu:Paint(w,h)
        surface.SetDrawColor(autobox.colors.discord[4])
        surface.DrawRect(0,0,w,h)
    end

    local frame = vgui.Create("DScrollPanel",self.rmenu)
    frame:SetPos(0,100)
    frame:SetSize(self.rmenu:GetWide()/3,self.rmenu:GetTall()-frame:GetTall())
    function frame:Paint(w,h)
        surface.SetDrawColor(autobox.colors.discordAlt[2])
        surface.DrawRect(0,0,w,h)
    end
    autobox.draw:CustomVBar(frame)

    table.SortByMember(autobox.perms,"Permission",true)

    for i,v in ipairs(autobox.perms)do
        local rbox = autobox.draw:RadioBox(frame,frame:GetWide()-100,15*(i-1),v.Permission,5,v.Immunity)
        function rbox:OnChange()
            PLUGIN:UpdatePermission(v.Permission,self.selected)
        end
    end
end

if(SERVER)then
    util.AddNetworkString("AAT_rmenu_permUpdate")
    net.Receive("AAT_rmenu_permUpdate",function(len,ply)
        local perm = net.ReadString()
        local immunity = net.ReadString()
        PLUGIN:UpdatePermission(ply,perm,immunity)
    end)
    function PLUGIN:UpdatePermission(ply,perm,immunity)
        if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end --make sure the player isn't somehow cheating
    end
end
if(CLIENT)then
    function PLUGIN:UpdatePermission(perm,immunity)
        net.Start("AAT_rmenu_permUpdate")
            net.WriteString(perm)
            net.WriteString(immunity)
        net.SendToServer()
    end
end

function PLUGIN:CloseRMenu()
    if(PLUGIN.rmenu)then
        PLUGIN.rmenu:Remove()
    end
end

function PLUGIN:AAT_OnReload()
    if(CLIENT)then self:CloseRMenu() end
end

autobox:RegisterPlugin(PLUGIN)