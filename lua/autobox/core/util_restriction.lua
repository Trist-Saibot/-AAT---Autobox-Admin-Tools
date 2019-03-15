--General Restrictions

if (SERVER) then
    if !autobox.restrictions then autobox.restrictions = {} end --initialize the module
    local AAT_Player = FindMetaTable("Player")
    function AAT_Player:AAT_CanUse(ptype,perm)
        if (ptype == "weapon" or ptype == "entity" or ptype == "tool") then
            local r = autobox.restrictions[ptype][perm]
            if (r and tonumber(autobox:GetRankInfo(self:AAT_GetRank()).Immunity) >= r) then
                return true
            end
        end
        return false
    end
    hook.Add("Initialize","ABX_Restriction_Initialization",function()
        autobox:SetupRestrictionTable()
    end)
    function autobox:SetupRestrictionTable()
        autobox.restrictions.weapon = {}
        for _,v in pairs({
            "weapon_crowbar",
            "weapon_pistol",
            "weapon_smg1",
            "weapon_frag",
            "weapon_physcannon",
            "weapon_crossbow",
            "weapon_shotgun",
            "weapon_357",
            "weapon_rpg",
            "weapon_ar2",
            "weapon_physgun"
        }) do --really ugly way of initializing these
            autobox.restrictions.weapon[v] = 5
        end
        for _,v in ipairs(weapons.GetList()) do
            autobox.restrictions.weapon[v.ClassName] = 5
        end
        for k,v in pairs(autobox.restrictions.weapon) do
            autobox.restrictions.weapon[k] = tonumber(autobox:SQL_Restriction_CheckPerm("weapon",k)) --set the immunity to any stored immunity, or create the perm if it doesn't exist.
        end

        autobox.restrictions.entity = {}
        for c,v in ipairs(scripted_ents.GetSpawnable()) do
            autobox.restrictions.entity[v.ClassName or c] = 5
        end
        for k,v in pairs(autobox.restrictions.entity) do
            autobox.restrictions.entity[k] = tonumber(autobox:SQL_Restriction_CheckPerm("entity",k))
        end
        autobox.restrictions.tool = {}
        if (GAMEMODE.IsSandboxDerived) then
            for _,v in ipairs(file.Find("weapons/gmod_tool/stools/*.lua","LUA")) do
                local _,_,c = string.find(v,"([%w_]*).lua")
                autobox.restrictions.tool[c] = 5
            end
            for k,v in pairs(autobox.restrictions.tool) do
                autobox.restrictions.tool[k] = tonumber(autobox:SQL_Restriction_CheckPerm("tool",k)) --set the immunity to any stored immunity, or create the perm if it doesn't exist.
            end
        end
    end
    util.AddNetworkString("AAT_RestrictionUpdate")
    net.Receive("AAT_RestrictionUpdate",function(len,ply)
        local ptype = net.ReadString()
        local perm = net.ReadString()
        local immunity = net.ReadInt(5)
        if (ply:AAT_BetterThanOrEqual("superadmin")) then
            autobox:SQL_Restriction_UpdatePerm(ptype,perm,immunity)
            autobox:SyncRestrictions()
        end
    end)
    function autobox:SyncRestrictions()
        autobox:SetupRestrictionTable()
        for _,v in ipairs(player.GetAll()) do
            autobox:SendRestrictions(v)
        end
    end
    function autobox:SendRestrictions(ply)
        net.Start("AAT_RestrictionUpdate")
            net.WriteTable(autobox.restrictions)
        net.Send(ply)
    end
    hook.Add("AAT_InitializePlayer","AAT_Restriction_Setup",function(ply)
        autobox:SendRestrictions(ply)
    end)
end

if (CLIENT) then
    if !autobox.restrictions then autobox.restrictions = {} end --initialize the module
    net.Receive("AAT_RestrictionUpdate",function()
        autobox.restrictions = net.ReadTable()
    end)
    function autobox:UpdateRestriction(ptype,perm,immunity)
        net.Start("AAT_RestrictionUpdate")
            net.WriteString(ptype)
            net.WriteString(perm)
            net.WriteInt(immunity,5)
        net.SendToServer()
    end
end