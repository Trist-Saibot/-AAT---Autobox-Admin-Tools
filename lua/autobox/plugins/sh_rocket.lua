-----
--Rocket a player
-----
local PLUGIN = {}
PLUGIN.title = "Rocket"
PLUGIN.author = "Trist"
PLUGIN.description = "Rocket a player"
PLUGIN.perm = "Rocket"
PLUGIN.command = "rocket"
PLUGIN.usage = "[players]"

game.AddParticles( "particles/rockettrail.pcf" )
PrecacheParticleSystem( "rockettrail" )

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if(!autobox:ValidateHasTarget(ply,players))then return end
    for _, v in ipairs(players) do
        v:SetMoveType(MOVETYPE_WALK)
        v:SetVelocity(Vector(0,0,4000))
        ParticleEffectAttach( "rockettrail", PATTACH_ABSORIGIN_FOLLOW, v, 0 )
        timer.Simple(1,function()
            local e = ents.Create("env_explosion")
            e:SetPos(v:GetPos())
            e:SetOwner(v)
            e:Spawn()
            e:SetKeyValue("iMagnitude","1")
            e:Fire("Explode",0,0)
            e:EmitSound("ambient/explosions/explode_4.wav",500,500)

            v:StopParticles()
            v:Kill()
            v:SetFrags(v:Frags()+1)
        end)
    end
    autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has rocketed ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
end

autobox:RegisterPlugin(PLUGIN)