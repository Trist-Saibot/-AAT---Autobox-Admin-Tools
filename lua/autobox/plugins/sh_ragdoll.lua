-----
--Ragdoll a player
-----
local PLUGIN = {}
PLUGIN.title = "Ragdoll"
PLUGIN.author = "Trist"
PLUGIN.description = "Ragdoll a player"
PLUGIN.perm = "Ragdoll"
PLUGIN.command = "ragdoll"
PLUGIN.usage = "<players> [1/0]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if(!autobox:ValidateHasTarget(ply,players))then return end
    local enabled = (tonumber(args[#args]) or 1) > 0
    for _,v in ipairs(players) do
        if(enabled)then
            if(!v:GetNWBool("AAT_Ragdolled",false) and v:Alive())then
                v:DrawViewModel(false)
                v:StripWeapons()

                local doll = ents.Create("prop_Ragdoll")
                doll:CallOnRemove("Clean up prop",function()
                    v:SetNWBool("AAT_Ragdolled",false)
                    v:SetNoTarget(false)
                    v:SetParent()
                    v:Spawn()
                end)
                doll:SetModel(v:GetModel())
                doll:SetPos(v:GetPos())
                doll:SetAngles(v:GetAngles())
                doll:Spawn()
                doll:Activate()


                v:Spectate(OBS_MODE_CHASE)
                v:SpectateEntity(doll)
                v:SetParent(doll)

                v:SetNWEntity("AAT_Ragdoll",doll)
            end
        else
            v:SetNoTarget(false)
            v:SetParent()
            v:Spawn()
        end
        v:SetNWBool("AAT_Ragdolled",enabled)
    end
    if(enabled)then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has ragdolled ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has unragdolled ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end
function PLUGIN:CanProperty(ply,property,ent)
    if(ply:GetNWBool("AAT_Ragdolled") and !ply:AAT_HasPerm(PLUGIN.perm))then return false end
end
function PLUGIN:CanPlayerSuicide(ply)
    if(ply:GetNWBool("AAT_Ragdolled",false))then return false end
end
function PLUGIN:PlayerDisconnect(ply)
    if(IsValid(ply:GetNWEntity("AAT_Ragdoll",nil)))then ply:GetNWEntity("AAT_Ragdoll",nil):Remove() end
end
function PLUGIN:PlayerDeath(ply)
    ply:SetNoTarget(false)
    ply:SetParent()
    ply:SetNWBool("AAT_Ragdolled",false)
end
function PLUGIN:PlayerSpawn(ply)
    local ragdoll = ply:GetNWEntity("AAT_Ragdoll",nil)
    if(IsValid(ragdoll))then
        ply:SetPos(ragdoll:GetPos()+Vector(0,0,10))
        ragdoll:Remove()
        ply:SetNWEntity("AAT_Ragdoll",nil)
    end
end

autobox:RegisterPlugin(PLUGIN)