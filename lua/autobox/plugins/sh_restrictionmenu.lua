-----
--Display the restriction menu
-----
local PLUGIN = {}
PLUGIN.title = "Restriction Menu"
PLUGIN.author = "Trist"
PLUGIN.description = "Display the restriction menu"
PLUGIN.perm = "Display Restriction Menu"
PLUGIN.command = "rmenu"

if (CLIENT) then
    net.Receive("AAT_OpenRMenu",function()
        if (!autobox:ValidatePerm(LocalPlayer(),PLUGIN.perm)) then return end
        PLUGIN:OpenRMenu()
    end)
    function PLUGIN:OpenRMenu()

        self:CloseRMenu()
        self.rmenu = vgui.Create("DFrame")
        self.rmenu:SetSize(1200,500)
        self.rmenu:Center()
        self.rmenu:SetTitle("")
        self.rmenu:SetDraggable(true)
        self.rmenu:MakePopup()
        function self.rmenu:Paint(w,h)
            surface.SetDrawColor(autobox.colors.discord[4])
            surface.DrawRect(0,0,w,h)
        end

        local scale = (self.rmenu:GetWide() - 50) / 4
        local colors = {
            autobox.colors.discord[3],
            autobox.colors.discordAlt[2]
        }

        --Permissions
        table.SortByMember(autobox.perms,"Permission",true)
        local frame = vgui.Create("DScrollPanel",self.rmenu)
        frame:SetPos(10,100)
        frame:SetSize(scale,self.rmenu:GetTall() - 110)
        function frame:Paint(w,h)
            surface.SetDrawColor(autobox.colors.discordAlt[2])
            surface.DrawRect(0,0,w,h)
        end
        autobox.draw:CustomVBar(frame)
        for i,v in ipairs(autobox.perms) do
            local container = vgui.Create("DPanel",frame)
            container:SetSize(frame:GetWide(),16)
            container:SetPos(0,15 * (i-1))
            container.colind = (i % 2) + 1
            function container:Paint(w,h)
                surface.SetDrawColor(colors[self.colind])
                surface.DrawRect(0,0,w,h)
            end
            local rbox = autobox.draw:RadioBox(container,container:GetWide() - (#autobox.ranks) * 16,0,v.Permission,#autobox.ranks-1,v.Immunity + 1)
            function rbox:OnChange()
                PLUGIN:UpdatePermission(v.Permission,self.selected - 1)
            end
        end

        --Weapons
        frame = vgui.Create("DScrollPanel",self.rmenu)
        frame:SetPos(20 + scale,100)
        frame:SetSize(scale,self.rmenu:GetTall() - 110)
        function frame:Paint(w,h)
            surface.SetDrawColor(autobox.colors.discordAlt[2])
            surface.DrawRect(0,0,w,h)
        end
        autobox.draw:CustomVBar(frame)
        if (true) then
            for i,v in ipairs(PLUGIN:SortRestrictionTable(autobox.restrictions.weapon)) do
                local container = vgui.Create("DPanel",frame)
                container:SetSize(frame:GetWide(),16)
                container:SetPos(0,15 * (i-1))
                container.colind = (i % 2) + 1
                function container:Paint(w,h)
                    surface.SetDrawColor(colors[self.colind])
                    surface.DrawRect(0,0,w,h)
                end
                local wepname
                if (weapons.Get(v.Permission)) then
                    wepname = weapons.Get(v.Permission or "").PrintName
                else
                    wepname = v.Permission
                end
                local rbox = autobox.draw:RadioBox(container,container:GetWide() - (#autobox.ranks) * 16,0,wepname,#autobox.ranks-1,v.Immunity + 1)
                container:SetTooltip(v.Permission)
                function rbox:OnChange()
                    autobox:UpdateRestriction("weapon",v.Permission,self.selected-1)
                    --PLUGIN:UpdatePermission(v.Permission,self.selected)
                end
            end
        end

        --Ents
        frame = vgui.Create("DScrollPanel",self.rmenu)
        frame:SetPos(10 + 2 * (10 + scale),100)
        frame:SetSize(scale,self.rmenu:GetTall() - 110)
        function frame:Paint(w,h)
            surface.SetDrawColor(autobox.colors.discordAlt[2])
            surface.DrawRect(0,0,w,h)
        end
        autobox.draw:CustomVBar(frame)
        if (true) then
            for i,v in ipairs(PLUGIN:SortRestrictionTable(autobox.restrictions.entity)) do
                local container = vgui.Create("DPanel",frame)
                container:SetSize(frame:GetWide(),16)
                container:SetPos(0,15 * (i-1))
                container.colind = (i % 2) + 1
                function container:Paint(w,h)
                    surface.SetDrawColor(colors[self.colind])
                    surface.DrawRect(0,0,w,h)
                end
                local entname
                if (scripted_ents.Get(v.Permission)) then
                    entname = scripted_ents.Get(v.Permission or "").PrintName
                else
                    entname = v.Permission
                end
                local rbox = autobox.draw:RadioBox(container,container:GetWide() - (#autobox.ranks) * 16,0,entname,#autobox.ranks-1,v.Immunity + 1)
                container:SetTooltip(v.Permission)
                function rbox:OnChange()
                    autobox:UpdateRestriction("entity",v.Permission,self.selected-1)
                    --PLUGIN:UpdatePermission(v.Permission,self.selected - 1)
                end
            end
        end

        --Tools
        frame = vgui.Create("DScrollPanel",self.rmenu)
        frame:SetPos(10 + 3 * (10 + scale),100)
        frame:SetSize(scale,self.rmenu:GetTall() - 110)
        function frame:Paint(w,h)
            surface.SetDrawColor(autobox.colors.discordAlt[2])
            surface.DrawRect(0,0,w,h)
        end
        autobox.draw:CustomVBar(frame)
        if (true) then
            for i,v in ipairs(PLUGIN:SortRestrictionTable(autobox.restrictions.tool)) do
                local container = vgui.Create("DPanel",frame)
                container:SetSize(frame:GetWide(),16)
                container:SetPos(0,15 * (i-1))
                container.colind = (i % 2) + 1
                function container:Paint(w,h)
                    surface.SetDrawColor(colors[self.colind])
                    surface.DrawRect(0,0,w,h)
                end

                local rbox = autobox.draw:RadioBox(container,container:GetWide() - (#autobox.ranks) * 16,0,v.Permission,#autobox.ranks-1,v.Immunity + 1)
                function rbox:OnChange()
                    autobox:UpdateRestriction("tool",v.Permission,self.selected-1)
                    --PLUGIN:UpdatePermission(v.Permission,self.selected - 1)
                end
            end
        end
    end
    function PLUGIN:SortRestrictionTable(tab)
        local temp = {}
        local i = 1
        for k,v in pairs(tab) do
            temp[i] = {}
            temp[i].Permission = k
            temp[i].Immunity = v
            i = i + 1
        end
        table.SortByMember(temp, "Permission", true)
        return temp
    end

    function PLUGIN:UpdatePermission(perm,immunity)
        net.Start("AAT_RMenu_PermUpdate")
            net.WriteString(perm)
            net.WriteString(immunity)
        net.SendToServer()
    end
    function PLUGIN:CloseRMenu()
        if (PLUGIN.rmenu) then
            PLUGIN.rmenu:Remove()
        end
    end

    function PLUGIN:AAT_OnReload()
        self:CloseRMenu()
    end
end
if (SERVER) then
    util.AddNetworkString("AAT_RMenu_PermUpdate")
    util.AddNetworkString("AAT_OpenRMenu")
    function PLUGIN:Call(ply,args)
        if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
        net.Start("AAT_OpenRMenu")
        net.Send(ply)
    end
    net.Receive("AAT_RMenu_PermUpdate",function(len,ply)
        local perm = net.ReadString()
        local immunity = net.ReadString()
        PLUGIN:UpdatePermission(ply,perm,immunity)
    end)
    function PLUGIN:UpdatePermission(ply,perm,immunity)
        if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end --make sure the player isn't somehow cheating
        autobox:SQL_UpdatePerm(perm,immunity)
        for _,v in ipairs(player.GetAll()) do
            autobox:SyncPerms(v)
        end
    end

    --Restriction Block
    function PLUGIN:PlayerGiveSWEP(ply,wep)
        if (!ply:AAT_CanUse("weapon",wep)) then
            autobox:Notify(ply,autobox.colors.red,"You are not allowed to spawn this weapon!")
            return false
        end
    end
    function PLUGIN:PlayerSpawnSWEP(ply,wep)
        if (!ply:AAT_CanUse("weapon",wep)) then
            autobox:Notify(ply,autobox.colors.red,"You are not allowed to spawn this weapon!")
            return false
        end
    end
    function PLUGIN:PlayerSpawnSENT(ply,class)
        if (!ply:AAT_CanUse("entity",class)) then
            autobox:Notify(ply,autobox.colors.red,"You are not allowed to spawn this entity!")
            return false
        end
    end
    function PLUGIN:PlayerCanPickupWeapon(ply,wep)
        if (!ply:AAT_CanUse("weapon",wep:GetClass())) then
            return false
        end
    end
    function PLUGIN:PlayerSpawnNPC(ply,npc,wep)
        if (!ply:AAT_CanUse("weapon",wep)) then
            autobox:Notify(ply,autobox.colors.red,"You are not allowed to spawn an NPC with this weapon!")
            return false
        end
    end
    function PLUGIN:CanTool(ply,tr,tool)
        if (!ply:AAT_CanUse("tool",tool)) then
            autobox:Notify(ply,autobox.colors.red,"You are not allowed to use this tool!")
            return false
        end
    end
end

autobox:RegisterPlugin(PLUGIN)