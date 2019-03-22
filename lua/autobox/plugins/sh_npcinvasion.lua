-----
--Handles NPC Attacks
-----

local PLUGIN = {}
PLUGIN.title = "Npc Invasions"
PLUGIN.author = "Trist"
PLUGIN.description = "Handles NPC Invasions"
PLUGIN.perm = "Npc Invasions"
PLUGIN.command = "attack"
PLUGIN.usage = "[Sector]"

local hash = {}
hash["a"] = 1
hash["b"] = 2
hash["c"] = 3
hash["d"] = 4
hash["e"] = 5

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local sec1 = math.random(1,5)
    local sec2 = math.random(1,5)
    if (#args == 1 and string.match(string.lower(args[1]),"^[a-e]%w")) then
        sec1 = hash[string.lower(string.sub(args[1],1,1))]
        sec2 = tonumber(string.sub(args[1],2,2)) or sec2
    end

    local sex = {"A","B","C","D","E"}
    local SectorString = sex[sec1] .. sec2

    autobox:Notify({Override = true,Icon = "warning",IconTooltip = "Invasion"},autobox.colors.white,"An attack has started at Sector " ,autobox.colors.red , SectorString)
    self:StageAttack(sec1,sec2)
end

function PLUGIN:CleanupAttack()
    for _,v in ipairs(ents.GetAll()) do
        if (v:IsValid() and v.AAT_Tracked_NPC) then
            v:Remove()
        end
    end
end

function PLUGIN:StageAttack(sec1,sec2)
    self:CleanupAttack()

    local section = 13250 * 2 / 5
    local x = section * (5-sec1) - 13250
    local y = section * (sec2-1) - 13250
    local x2 = x + section
    local y2 = y + section
    local z = -11100

    for i = 0,math.random(20,50) do
        local pos = self:FindSpawnPos(x,y,x2,y2,z)

        local v = ents.Create("npc_combine_s")
        v:SetPos(pos)
        v:Spawn()
        v:DropToFloor()
        v:Give("weapon_smg1")
        v.AAT_Tracked_NPC = true

        timer.Simple(0.1,function()
            local ed = EffectData()
            ed:SetOrigin(v:GetPos() + Vector(0,0,50))
            ed:SetEntity(v)
            util.Effect("cball_explode",ed)
            util.Effect("explode",ed)
        end)
    end
end

function PLUGIN:FindSpawnPos(x,y,x2,y2,z)
    for i = 0, 100 do --try 100 times
        local pos = Vector(math.random(x,x2),math.random(y,y2),z)
        if (util.IsInWorld(pos)) then print(pos) return pos end
    end
    return nil
end

autobox:RegisterPlugin(PLUGIN)