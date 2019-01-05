-----
--Go to a player
-----
local PLUGIN = {}
PLUGIN.title = "Goto"
PLUGIN.author = "Trist"
PLUGIN.description = "Go to a player"
PLUGIN.perm = "Goto"
PLUGIN.command = "goto"
PLUGIN.usage = "<player>"

PLUGIN.Positions = {}
for i=0,360,45 do table.insert( PLUGIN.Positions, Vector(math.cos(i),math.sin(i),0) ) end -- Around
table.insert( PLUGIN.Positions, Vector(0,0,1) ) -- Above

function PLUGIN:FindPosition( ply )
    local size = Vector( 32, 32, 72 )
    local StartPos = ply:GetPos() + Vector(0,0,size.z/2)
    for _,v in ipairs( self.Positions ) do
        local Pos = StartPos + v * size * 1.5
        local tr = {}
        tr.start = Pos
        tr.endpos = Pos
        tr.mins = size / 2 * -1
        tr.maxs = size / 2
        local trace = util.TraceHull( tr )
        if (!trace.Hit) then
            return Pos - Vector(0,0,size.z/2)
        end
    end
    return false
end

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({args[1]})
    if(!autobox:ValidateSingleTarget(ply,players))then return end
    if(!autobox:ValidateBetterThanOrEqual(ply,players[1]))then return end    
    autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has gone to ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    if ( ply:InVehicle() ) then ply:ExitVehicle() end
    if ( ply:GetMoveType() == MOVETYPE_NOCLIP) then
        ply:SetPos( players[1]:GetPos() + players[1]:GetForward() * 45 )
    else
        local pos = self:FindPosition( players[1] )
        if (pos) then
            ply:SetPos(pos)
        else
            ply:SetPos( players[1]:GetPos() + Vector(0,0,72) )
        end
    end
end

autobox:RegisterPlugin(PLUGIN)