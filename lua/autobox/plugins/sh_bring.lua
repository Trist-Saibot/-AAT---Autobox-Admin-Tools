-----
--Bring a player to you
-----
local PLUGIN = {}
PLUGIN.title = "Bring"
PLUGIN.author = "Trist"
PLUGIN.description = "Bring a player to you"
PLUGIN.perm = "Bring"
PLUGIN.command = "bring"
PLUGIN.usage = "<players>"

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
        local unfilteredPlayers = autobox:FindPlayers(args)
        local players = {}
        for k,v in ipairs(unfilteredPlayers)do
            if(ply:AAT_BetterThan(v:AAT_GetRank()))then
                table.insert(players,v)
            end
        end
        if(!autobox:ValidateHasTarget(ply,players))then return end
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has brought ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
        for i,pl in ipairs(players)do
        if(pl:InVehicle())then pl:ExitVehicle() end
        
        if(pl:GetMoveType()==MOVETYPE_NOCLIP)then
            pl:SetPos(ply:GetPos()+ply:GetForward()*45)
        else
            local pos = self:FindPosition(ply)
            if(pos)then
                pl:SetPos(pos)
            else
                pl:SetPos(ply:GetPos()+Vector(0,0,72*i))
            end
            pl:GodEnable()
            timer.Create("Bring_Ungod_Timer",5,1,function() pl:GodDisable() end)
        end
    end
end

autobox:RegisterPlugin(PLUGIN)