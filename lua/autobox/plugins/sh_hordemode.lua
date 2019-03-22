-----
--Toggle Horde Mode
-----
local PLUGIN = {}
PLUGIN.title = "Horde Mode"
PLUGIN.author = "Trist"
PLUGIN.description = "Toggle Horde Mode"
PLUGIN.perm = "Horde Mode"
PLUGIN.command = "horde"
PLUGIN.usage = "[1/0]"

PLUGIN.hordemode = false
PLUGIN.trackedZ = {}
PLUGIN.ZMax = 50
PLUGIN.RMin = 750 --min range
PLUGIN.RMax = 2000 --min range

function PLUGIN:Call( ply, args )
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    PLUGIN.hordemode = (tonumber(args[#args]) or 1) > 0
    if (!self.hordemode) then
        self:CleanupZ()
    end
end

function PLUGIN:CleanupZ()
    for k,z in pairs(self.trackedZ) do
        if (z:IsValid()) then z:Remove() end
    end
    self.trackedZ = {}
end

function PLUGIN:Think()
    for k,z in pairs(self.trackedZ) do
        if (!z:IsValid() or !self:NearPlayer(z)) then
            table.remove(self.trackedZ,k)
            if (z:IsValid()) then z:Remove() end
        end
    end
    if (self.hordemode and table.Count(self.trackedZ) < self.ZMax) then
        self:FindZPos(table.Random(player.GetAll()))
    end
end

function PLUGIN:NearPlayer(zombie)
    for _, v in ipairs(player.GetAll()) do
        if (zombie:GetPos():Distance(v:GetPos()) < self.RMax * 1.5 ) then return true end
    end
    return false
end

function PLUGIN:FindZPos( ply )
    local vec = ply:GetForward()
    for i = 1,10 do --try 10 times then give up
        vec:Rotate(Angle(0,math.random(0,360),0))
        local pos = ply:GetPos() + Vector(0,0,50) + vec * math.random(self.RMin, self.RMax)
        if (util.IsInWorld(pos)) then
            self:SpawnZ(pos)
        end
    end
end

function PLUGIN:SpawnZ(pos)
    local ZType = {
        "npc_zombie",
        "npc_zombie_torso",
        "npc_poisonzombie",
        "npc_fastzombie",
        "npc_fastzombie_torso"
    }
    local z = ents.Create(ZType[math.random(1,#ZType)])
    z:SetPos(pos)
    z:Spawn()
    z:DropToFloor()
    --z:SetSequence("canal5await")
    table.insert(self.trackedZ,#self.trackedZ,z)
end

autobox:RegisterPlugin( PLUGIN )