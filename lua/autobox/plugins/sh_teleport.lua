-----
--Teleport a player
-----
local PLUGIN = {}
PLUGIN.title = "Teleport"
PLUGIN.author = "Trist"
PLUGIN.description = "Teleport a player"
PLUGIN.perm = "Teleport"
PLUGIN.command = "tp"
PLUGIN.usage = "[player]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local unfilteredPlayers = autobox:FindPlayers({unpack(args),ply})
    local players = {}
    for k,v in ipairs(unfilteredPlayers) do
        if (ply:AAT_BetterThanOrEqual(v:AAT_GetRank())) then
            table.insert(players,v)
        end
    end
    if (!autobox:ValidateHasTarget(ply,players)) then return end


    local size = Vector(32,32,72)
    local tr = {}
    tr.start = ply:GetShootPos()
    tr.endpos = ply:GetShootPos() + ply:GetAimVector() * 100000000
    tr.filter = ply
    local trace = util.TraceEntity(tr,ply)
    local EyeTrace = ply:GetEyeTraceNoCursor()
    if (trace.HitPos:Distance(EyeTrace.HitPos) > size:Length()) then
        trace = EyeTrace
        trace.HitPos = trace.HitPos + trace.HitNormal * size * 1.2
    end
    size = size * 1.5
    for i,v in ipairs(players) do
        if (v:InVehicle()) then v:ExitVehicle() end
        v:SetPos(trace.HitPos + trace.HitNormal * (i-1) * size)
        v:SetLocalVelocity(Vector(0,0,0))
    end
    autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has teleported ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
end

autobox:RegisterPlugin(PLUGIN)