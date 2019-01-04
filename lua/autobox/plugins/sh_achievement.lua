-----
--Fake an achievement
-----
local PLUGIN = {}
PLUGIN.title = "Achievement"
PLUGIN.author = "Trist"
PLUGIN.description = "Fake someone earning an achievement."
PLUGIN.perm = "Achievement"
PLUGIN.command = "ach"
PLUGIN.usage = "<player> <achievement>"

function PLUGIN:Call( ply, args )
	if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
	local players = autobox:FindPlayers({args[1]})
	if(!autobox:ValidateHasTarget(ply,players))then return end
	local achievement = table.concat(args," ",2)
	if ( #achievement > 0 ) then
		for _, pl in ipairs( players ) do
			autobox:Notify( team.GetColor( pl:Team() ), pl:Nick(), color_white, " earned the achievement ", Color( 255, 201, 0, 255 ), achievement )
		end
	else
		autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"No achievement specified.")
	end
end

autobox:RegisterPlugin( PLUGIN )