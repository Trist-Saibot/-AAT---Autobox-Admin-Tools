--General Restrictions

if(SERVER)then
    if !autobox.restrictions then autobox.restrictions = {} end --initialize the module
    hook.Add("Initialize","ABX_Restriction_Initialization",function()
        autobox.restrictions.weapons = {}
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
            autobox.restrictions.weapons[v] = 5
        end
        for _,v in ipairs(weapons.GetList())do
            autobox.restrictions.weapons[v.ClassName] = 5
        end
        for k,v in pairs(autobox.restrictions.weapons)do
            v = autobox:SQL_Restriction_CheckPerm("weapon",k) --set the immunity to any stored immunity, or create the perm if it doesn't exist.
        end

        autobox.restrictions.entities = {}
        for c,v in ipairs(scripted_ents.GetSpawnable())do
            autobox.restrictions.entities[v.ClassName or c] = 5
        end
        for k,v in pairs(autobox.restrictions.entities)do
            v = autobox:SQL_Restriction_CheckPerm("entity",k)
        end

        autobox.restrictions.tools = {}
        if(GAMEMODE.IsSandboxDerived)then
            for _,v in ipairs(file.Find("weapons/gmod_tool/stools/*.lua","LUA"))do
                local _,_,c = string.find(v,"([%w_]*).lua")
                autobox.restrictions.tools[c] = 5
            end
            for k,v in pairs(autobox.restrictions.tools)do
                v = autobox:SQL_Restriction_CheckPerm("tool",k) --set the immunity to any stored immunity, or create the perm if it doesn't exist.
            end
        end
    end)
    PrintTable(autobox.restrictions)
end