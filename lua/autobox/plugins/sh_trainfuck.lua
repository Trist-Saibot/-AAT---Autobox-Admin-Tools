-----
--Trainfuck a player
-----
local train_models = {
"models/props_trainstation/train001.mdl",
"models/props_trainstation/train002.mdl",
"models/props_trainstation/train003.mdl"
}

local PLUGIN = {}
PLUGIN.title = "Trainfuck"
PLUGIN.author = "Trist"
PLUGIN.description = "Trainfuck a player"
PLUGIN.perm = "Trainfuck"
PLUGIN.command = "trainfuck"
PLUGIN.usage = "[players]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    for _, v in ipairs(players) do
        local tPos,tDir = v:GetPos() + v:GetForward() * 2000 + Vector(0,0,100),v:GetForward() * -1
        local tModel = train_models[math.random(1,#train_models)]
        local train = ents.Create("prop_physics")
        train:SetModel(tModel)
        train:SetAngles(tDir:Angle() + Angle(0,270,0))
        train:SetPos(tPos)
        train:Spawn()
        train:Activate()
        v:EmitSound("ambient/alarms/train_horn2.wav", 511, 100)
        local obj = train:GetPhysicsObject()
        if (IsValid(obj)) then
            obj:EnableGravity(false)
            obj:EnableCollisions(false)
            obj:SetVelocity(tDir * 100000)
        end
        timer.Simple(0.6,function()
            local dmg = DamageInfo()
            dmg:AddDamage(2^31-1)
            dmg:SetDamageForce(tDir * 500000)
            dmg:SetInflictor(train)
            dmg:SetAttacker(train)
            if (v:HasGodMode() or v:Health() == 0) then
                v:TakeDamageInfo(dmg)
                v:Kill()
            end
            v:TakeDamageInfo(dmg)
            v:SetFrags(v:Frags() + 1)
        end)
        timer.Simple(3,function()
            train:Remove()
        end)
    end
    autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has trainfucked ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
end

autobox:RegisterPlugin(PLUGIN)