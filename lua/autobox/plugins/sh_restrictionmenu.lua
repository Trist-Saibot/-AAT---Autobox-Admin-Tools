resource.AddFile( "materials/autobox/icon64/mitch.png")
-----
--Display the restriction menu
-----
local PLUGIN = {}
PLUGIN.title = "Restriction Menu"
PLUGIN.author = "Trist"
PLUGIN.description = "Display the restriction menu"
PLUGIN.perm = "Display Restriction Menu"

if (CLIENT) then
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
            local rbox = autobox.draw:RadioBox(container,container:GetWide() - (#autobox.ranks) * 16,0,v.Permission,#autobox.ranks-1,v.Immunity + 1,{"guest","regular","respected","homie","admin","superadmin"})
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


        --https://github.com/Facepunch/garrysmod/blob/master/garrysmod/gamemodes/sandbox/gamemode/spawnmenu/creationmenu/content/contenttypes/weapons.lua
        --Example taken from GMOD lua
        local Weapons = list.Get("Weapon")
        local Categories = {}
        for k,weapon in pairs(Weapons) do
            if (!weapon.Spawnable) then continue end
            Categories[weapon.Category] = Categories[weapon.Category] or {} --create table if empty
            table.insert(Categories[ weapon.Category ], weapon)
        end
        Weapons = nil

        if (true) then
            local lastadd = nil
            for Category, v in SortedPairs(Categories) do --every category
                local header = vgui.Create("DPanel",frame)
                header:SetSize(frame:GetWide(),16)
                if (lastadd) then header:MoveBelow(lastadd) else header:SetPos(0,0) end
                function header:Paint(w,h)
                    surface.SetDrawColor(0,0,0)
                    surface.DrawRect(0,0,w,h)
                    draw.TextShadow({text = Category,pos = {5,0},xalign = TEXT_ALIGN_LEFT,yalign = TEXT_ALIGN_TOP},1)
                end
                local i = 0
                lastadd = header

                for k,wep in SortedPairsByMemberValue(v,"PrintName") do --weapon in category
                    local name  = wep.PrintName or wep.ClassName
                    local class = wep.ClassName
                    local swep  = weapons.Get(class)
                    local mat   = nil
                    if (swep and file.Exists("materials/vgui/entities/" .. class .. ".vmt", "GAME")) then
                        mat = Material("vgui/entities/" .. class)
                    elseif (swep and file.Exists("materials/weapons/" .. class .. ".vmt","GAME")) then
                        mat = Material("weapons/" .. class)
                    elseif (file.Exists("materials/entities/" .. class .. ".png","GAME")) then
                        mat = Material("entities/" .. class .. ".png")
                    end


                    local immunity = autobox.restrictions.weapon[class]
                    if (!immunity) then continue end --bail if we missed one




                    local container = vgui.Create("DPanel",frame)
                    container:SetSize(frame:GetWide(),16)
                    container:MoveBelow(lastadd)
                    container.colind = (i % 2) + 1
                    function container:Paint(w,h)
                        surface.SetDrawColor(colors[self.colind])
                        surface.DrawRect(0,0,w,h)
                    end

                    local mousecatch = vgui.Create("DPanel",container) --invisible panel to detect mouse on part of this panel
                    mousecatch:SetSize((#autobox.ranks) * 16,16)
                    function mousecatch:Paint(w,h)

                    end
                    function mousecatch:OnCursorEntered()
                        if (PLUGIN.iframe and PLUGIN.iframe:IsValid()) then PLUGIN.iframe:Remove() end
                        local iframe = vgui.Create("DPanel")
                        local cx, cy = self:GetParent():LocalToScreen(self:GetPos())
                        cy = cy - 128
                        iframe:SetPos(cx,cy)
                        iframe:SetSize(128,128)
                        iframe:MakePopup()
                        function iframe:Think()
                            if (!mousecatch or !mousecatch:IsValid()) then self:Remove() end
                        end
                        function iframe:Paint(w,h)
                            if (!mat) then return end
                            surface.SetMaterial(mat)
                            surface.SetDrawColor(color_white)
                            surface.DrawTexturedRect(0,0,w,h)
                        end
                        function mousecatch:OnCursorExited()
                            PLUGIN.iframe:Remove()
                        end
                        function iframe:OnCursorEntered()
                            self:Remove()
                        end
                        PLUGIN.iframe = iframe
                    end

                    local rbox = autobox.draw:RadioBox(container,container:GetWide() - (#autobox.ranks) * 16,0,name,#autobox.ranks-1,immunity + 1,{"guest","regular","respected","homie","admin","superadmin"})
                    --container:SetTooltip(v.Permission)
                    function rbox:OnChange()
                        autobox:UpdateRestriction("weapon",class,self.selected-1)
                        PLUGIN:UpdatePermission(class,self.selected)
                    end

                    lastadd = container

                    i = i + 1
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
                local rbox = autobox.draw:RadioBox(container,container:GetWide() - (#autobox.ranks) * 16,0,entname,#autobox.ranks-1,v.Immunity + 1,{"guest","regular","respected","homie","admin","superadmin"})
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

                local rbox = autobox.draw:RadioBox(container,container:GetWide() - (#autobox.ranks) * 16,0,v.Permission,#autobox.ranks-1,v.Immunity + 1,{"guest","regular","respected","homie","admin","superadmin"})
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
    function PLUGIN:InitPostEntity()
        if (LocalPlayer():AAT_IsSpecialBoy()) then
        list.Set("DesktopWindows","AAT_RMenu",{
            title = "Restriction Menu",
            icon = "autobox/icon64/mitch.png",
            init = function(icon,window)
                window:Remove()
                if (!autobox:ValidatePerm(LocalPlayer(),PLUGIN.perm)) then return end
                PLUGIN:OpenRMenu()
            end
        })
        CreateContextMenu()
        end
    end



end
if (SERVER) then
    util.AddNetworkString("AAT_RMenu_PermUpdate")
    net.Receive("AAT_RMenu_PermUpdate",function(len,ply)
        local perm = net.ReadString()
        local immunity = net.ReadString()
        PLUGIN:UpdatePermission(ply,perm,immunity)
    end)
    function PLUGIN:UpdatePermission(ply,perm,immunity)
        if (!IsValid(ply)) then return end
        if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end --make sure the player isn't somehow cheating
        autobox:SQL_UpdatePerm(perm,immunity)
        for _,v in ipairs(player.GetAll()) do
            autobox:SyncPerms(v)
        end
    end

    --Restriction Block
    function PLUGIN:PlayerGiveSWEP(ply,wep)
        if (!IsValid(ply)) then return end
        if (!ply:AAT_CanUse("weapon",wep)) then
            autobox:Notify(ply,autobox.colors.red,"You are not allowed to spawn this weapon!")
            return false
        end
    end
    function PLUGIN:PlayerSpawnSWEP(ply,wep)
        if (!IsValid(ply)) then return end
        if (!ply:AAT_CanUse("weapon",wep)) then
            autobox:Notify(ply,autobox.colors.red,"You are not allowed to spawn this weapon!")
            return false
        end
    end
    function PLUGIN:PlayerSpawnSENT(ply,class)
        if (!IsValid(ply)) then return end
        if (!ply:AAT_CanUse("entity",class)) then
            autobox:Notify(ply,autobox.colors.red,"You are not allowed to spawn this entity!")
            return false
        end
    end
    function PLUGIN:PlayerCanPickupWeapon(ply,wep)
        if (!IsValid(ply)) then return end
        if (!ply:AAT_CanUse("weapon",wep:GetClass())) then
            return false
        end
    end
    function PLUGIN:PlayerSpawnNPC(ply,npc,wep)
        if (!IsValid(ply)) then return end
        if (!ply:AAT_CanUse("weapon",wep)) then
            autobox:Notify(ply,autobox.colors.red,"You are not allowed to spawn an NPC with this weapon!")
            return false
        end
    end
    function PLUGIN:CanTool(ply,tr,tool)
        if (!IsValid(ply)) then return end
        if (!ply:AAT_CanUse("tool",tool)) then
            autobox:Notify(ply,autobox.colors.red,"You are not allowed to use this tool!")
            return false
        end
    end
end

autobox:RegisterPlugin(PLUGIN)