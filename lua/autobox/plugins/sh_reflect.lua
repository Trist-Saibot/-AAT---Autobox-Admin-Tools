-----
--Reflect
-----
local PLUGIN = {}
PLUGIN.title = "Reflect"
PLUGIN.author = "Trist"
PLUGIN.description = "Reflects Damage"
PLUGIN.perm = "Reflect"
PLUGIN.command = "reflect"
PLUGIN.usage = "<players> [1/0]"

local sounds = { --prone to change in the future
    "friends/friend_join.wav"
}
local mat = Material("models/effects/portalrift_sheet") --mat of the shield

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    local enabled = (tonumber(args[#args]) or 1) > 0
    for _,v in ipairs(players) do
        v:SetNWBool("AAT_Shielded",enabled)
    end

    local plist = autobox:CreatePlayerList(players)
    if (#players == 1 and players[1] == ply) then plist = "themself" end

    if (enabled) then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has shielded ",autobox.colors.red,plist,autobox.colors.white," from harm.")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has unshielded ",autobox.colors.red,plist,autobox.colors.white," from harm.")
    end
end

function PLUGIN:EntityTakeDamage(ent,dmg)
    if (ent:IsPlayer() and ent:GetNWBool( "AAT_Shielded", false )) then
        if (IsEntity(dmg:GetInflictor())) then
            local inf = dmg:GetInflictor()
            ent:EmitSound(sounds[math.random(1,#sounds)],75,math.random(70,130))

            local dir = ent:GetPos() - inf:GetPos() --sends the direction vector of the damage
            if (dmg:GetDamageType() != DMG_FALL) then
                ent:SetNWVector("tri_shield",dir)
                ent:SetNWInt("tri_sh_hit",CurTime())
            end
            local attacker = dmg:GetAttacker()
            if (!attacker:GetNWBool( "AAT_Shielded", false )) then
                attacker:TakeDamageInfo(dmg)
            end
        end
        return true
    end
end

function PLUGIN:PostPlayerDraw(ply)
    if (!IsValid(ply) or !ply:GetNWBool( "AAT_Shielded", false )) then return end
    local perc = ply:GetNWInt("tri_sh_hit")
    perc = CurTime() - perc
    if (perc < 1) then
        local pos = ply:GetPos() + Vector(0,0,50)
        local dp = ply:GetNWVector("tri_shield",Vector(0,0,0))
        dp = dp:GetNormalized() * -20
        dp[3] = 0

        local ang = dp:Angle() + Angle(0,90,0)
        pos = pos + dp

        --local col = (1 - perc) * 255
        render.SetMaterial(mat)
        render.DrawBox(pos,ang,Vector(-25,0,-25),Vector(25,0,25),Color(255,255,255,col))
    end
end

autobox:RegisterPlugin(PLUGIN)