-----
--Grant a player Unlimited Ammo
-----
local PLUGIN = {}
PLUGIN.title = "Unlimited Ammo"
PLUGIN.author = "Trist"
PLUGIN.description = "Grant a player Unlimited Ammo"
PLUGIN.perm = "Unlimited Ammo"
PLUGIN.command = "uammo"
PLUGIN.usage = "<players> [1/0]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if(!autobox:ValidateHasTarget(ply,players))then return end
    local enabled = (tonumber(args[#args]) or 1) > 0
    for _,v in ipairs(players) do
        v.AAT_UnlimitedAmmo = enabled
        if(enabled)then
            for _,w in ipairs(v:GetWeapons())do
                self:FillClips(v,w)
            end
        end
    end
    if(enabled)then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has enabled unlimited ammo for ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has disabled unlimited ammo for ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end

function PLUGIN:FillClips(ply,wep)
    --taken straight from evolve's uammo
    if(wep:Clip1()<250)then wep:SetClip1(250) end
    if(wep:Clip2()<250)then wep:SetClip2(250) end

    if wep:GetPrimaryAmmoType() == 10 or wep:GetPrimaryAmmoType() == 8 then
		ply:GiveAmmo( 9 - ply:GetAmmoCount( wep:GetPrimaryAmmoType() ), wep:GetPrimaryAmmoType() )
	elseif wep:GetSecondaryAmmoType() == 9 or wep:GetSecondaryAmmoType() == 2 then
		ply:GiveAmmo( 9 - ply:GetAmmoCount( wep:GetSecondaryAmmoType() ), wep:GetSecondaryAmmoType() )
	end
end

function PLUGIN:Tick()
    for _,v in ipairs(player.GetAll())do
        if(v.AAT_UnlimitedAmmo and v:Alive() and v:GetActiveWeapon())then
            self:FillClips(v,v:GetActiveWeapon())
        end
    end
end

autobox:RegisterPlugin(PLUGIN)