autobox.badge:RegisterBadge("kills","Kills","",1,"materials/icon16/user_delete.png",true,function(ply)
    local badge = {}
    badge.Has = false
    badge.HasMax = false
    badge.GetVals = {100,1000,10000,20000}
    local prog = ply:AAT_GetBadgeProgress("kills")
    if (prog >= 20000) then
        badge.Goal = 20000
        badge.Desc = "Get 20000 kills"
        badge.Icon = "materials/icon16/user_red.png"
        badge.Name = "Kills"
        badge.ProgName = "20000 Kills"
        badge.Has = true
        badge.HasMax = true
    elseif (prog >= 10000) then
        badge.Goal = 10000
        badge.Desc = "Get 10000 kills"
        badge.Icon = "materials/icon16/user_red.png"
        badge.Name = "Kills"
        badge.ProgName = "10000 Kills"
        badge.Has = true
        badge.HasMax = false
    elseif (prog >= 1000) then
        badge.Goal = 10000
        badge.Desc = "Get 1000 kills"
        badge.Icon = "materials/icon16/user_delete.png"
        badge.Name = "Kills"
        badge.ProgName = "1000 Kills"
        badge.Has = true
        badge.HasMax = false
    elseif (prog >= 100) then
        badge.Goal = 1000
        badge.Desc = "Get 100 kills"
        badge.Icon = "materials/icon16/user_delete.png"
        badge.Name = "Kills"
        badge.ProgName = "100 Kills"
        badge.Has = true
        badge.HasMax = false
    else
        badge.Goal = 100
        badge.Desc = "Get 100 kills"
        badge.Icon = "materials/icon16/user_delete.png"
        badge.Name = "Kills"
        badge.ProgName = "100 Kills"
        badge.Has = false
        badge.HasMax = false
    end
    if (CLIENT) then badge.Icon = Material(badge.Icon) end
    return badge
end)
hook.Add("PlayerDeath","AAT_Track_Deaths",function(victim,inflictor,attacker)
    if (victim != attacker and attacker:IsPlayer() and !attacker:IsBot()) then
        attacker:AAT_AddBadgeProgress("kills",1)
        if (!attacker:AAT_HasMaxBadge("kills",attacker)) then
            autobox.badge:ShowNotice(attacker,"kills")
        end
    end
end)