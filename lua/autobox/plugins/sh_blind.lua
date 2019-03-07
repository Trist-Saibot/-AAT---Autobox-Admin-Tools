-----
--Blind a player
-----
local PLUGIN = {}
PLUGIN.title = "Blind"
PLUGIN.author = "Trist"
PLUGIN.description = "Blind a player"
PLUGIN.perm = "Blind"
PLUGIN.command = "blind"
PLUGIN.usage = "<players> [1/0]"

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local players = autobox:FindPlayers({unpack(args),ply})
    if (!autobox:ValidateHasTarget(ply,players)) then return end
    local enabled = (tonumber(args[#args]) or 1) > 0
    for _,v in ipairs(players) do
        v:SetNWBool("AAT_Blinded",enabled)
    end
    if (enabled) then
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has blinded ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    else
        autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has unblinded ",autobox.colors.red,autobox:CreatePlayerList(players),autobox.colors.white,".")
    end
end

function PLUGIN:HUDPaint()
    if ( LocalPlayer():GetNWBool( "AAT_Blinded", false ) ) then
        surface.SetDrawColor( 0, 0, 0, 255 )
        surface.DrawRect( 0, 0, ScrW(), ScrH() )
    end
end

autobox:RegisterPlugin(PLUGIN)