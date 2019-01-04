-----
--Ghost a player
-----
local PLUGIN = {}
PLUGIN.title = "Ghost"
PLUGIN.author = "Trist"
PLUGIN.description = "Ghost a player"
PLUGIN.perm = "Ghost"
PLUGIN.command = "ghost"
PLUGIN.usage = "<players> [1/0]"

function PLUGIN:Call(ply,args)
    if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
    local players
    if(#args>0 and !(#args==1 and tonumber(args[1])))then
        players = autobox:FindPlayers(args)
    else
        players = autobox:FindPlayers({ply:SteamID()})
    end
    if(!autobox:ValidateHasTarget(ply,players))then return end
    local enabled = (tonumber(args[#args]) or 1) > 0
    for _,v in ipairs(players) do
        if ( enabled ) then
            v:SetRenderMode( RENDERMODE_NONE )
            v:SetColor( Color(255, 255, 255, 0) )
            v:SetCollisionGroup( COLLISION_GROUP_WEAPON )

            for _, w in ipairs( v:GetWeapons() ) do
                w:SetRenderMode( RENDERMODE_NONE )
                w:SetColor( Color(255, 255, 255, 0) )
            end
        else
            v:SetRenderMode( RENDERMODE_NORMAL )
            v:SetColor( Color(255, 255, 255, 255) )
            v:SetCollisionGroup( COLLISION_GROUP_PLAYER )

            for _, w in ipairs( v:GetWeapons() ) do
                w:SetRenderMode( RENDERMODE_NORMAL )
                w:SetColor( Color(255, 255, 255, 255) )
            end
        end
        v:SetNWBool("AAT_Ghosted",enabled)
    end
    if(enabled)then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has ghosted ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has unghosted ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end

function PLUGIN:PlayerSpawn(ply)
    if(ply:GetNWBool("AAT_Ghosted",false))then
        ply:SetRenderMode( RENDERMODE_NONE )
		ply:SetColor( Color(255, 255, 255, 0) )
		ply:SetCollisionGroup( COLLISION_GROUP_WEAPON )

		for _, w in ipairs( ply:GetWeapons() ) do
			w:SetRenderMode( RENDERMODE_NONE )
			w:SetColor( Color(255, 255, 255, 0) )
		end
    end
end

function PLUGIN:PlayerCanPickupWeapon( ply, wep )
	if ( ply:GetNWBool( "AAT_Ghosted", false ) ) then
		wep:SetRenderMode( RENDERMODE_NONE )
		wep:SetColor( Color(255, 255, 255, 0) )
	end
end

autobox:RegisterPlugin(PLUGIN)