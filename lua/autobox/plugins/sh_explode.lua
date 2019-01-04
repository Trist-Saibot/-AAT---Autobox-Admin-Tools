-----
--Explode a player
-----
local PLUGIN = {}
PLUGIN.title = "Explode"
PLUGIN.author = "Trist"
PLUGIN.description = "Explode a player"
PLUGIN.perm = "Explode"
PLUGIN.command = "explode"
PLUGIN.usage = "[players]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers(args)
    if(!autobox:ValidateHasTarget(ply,players))then return end
    for _, v in ipairs(players) do
        local explosive = ents.Create( "env_explosion" )
        explosive:SetPos( v:GetPos() )
        explosive:SetOwner( v )
        explosive:Spawn()
        explosive:SetKeyValue( "iMagnitude", "1" )
        explosive:Fire( "Explode", 0, 0 )
        explosive:EmitSound( "ambient/explosions/explode_4.wav", 500, 500 )
			
        v:SetVelocity( Vector( 0, 0, 400 ) )
        v:Kill()
        v:SetFrags(v:Frags()+1)
    end
    autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has exploded ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
end

autobox:RegisterPlugin(PLUGIN)