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
        surface.SetDrawColor(autobox.colors.brown)
        surface.DrawRect(0,0,w,h)
    end

    local frame = vgui.Create("DPanel",self.rmenu)
    frame:SetSize(self.rmenu:GetWide(),self.rmenu:GetTall()-25)
    frame:SetPos(0,25)
    function frame:Paint(w,h)
        surface.SetDrawColor(autobox.colors.tan)
        surface.DrawRect(0,0,w,h)
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