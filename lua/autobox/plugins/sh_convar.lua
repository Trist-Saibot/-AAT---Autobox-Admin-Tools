-----
--Change a convar
-----
local PLUGIN = {}
PLUGIN.title = "Change Convar"
PLUGIN.author = "Trist"
PLUGIN.description = "Change a convar"
PLUGIN.perm = "Change Convar"
PLUGIN.command = "convar"
PLUGIN.usage = "<limit> <value>"
PLUGIN.allowedConvars = {
    "sbox_",
    "g_",
    "mp_",
    "aat_"
}

function PLUGIN:Call(ply,args)
	if(!autobox:ValidatePerm(ply,PLUGIN.perm))then return end
	if(!autobox:ValidateNumber(ply,args[2]))then return end

	if(!GetConVar(args[1])) then
		autobox:Notify( ply, autobox.colors.red, "Unknown convar!" )
	elseif(GetConVar(args[1]):GetInt() == tonumber(args[2])) then
		autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"That convar is already set to that value.")
	else
		local allowed = false
		for _, v in ipairs( self.allowedConvars ) do
			if(string.Left(args[1],#v)==v) then
				allowed = true
				break
			end
		end
		if (allowed) then
			RunConsoleCommand(args[1], args[2])
			autobox:Notify(autobox.colors.blue,ply:Nick(),autobox.colors.white," has changed ",autobox.colors.red,args[1],autobox.colors.white," to " ..math.Round(args[2])..".")
		else
			autobox:Notify(ply,autobox.chatConst.err,autobox.colors.red,"You are not allowed to change that convar!")
		end
	end

end

autobox:RegisterPlugin(PLUGIN)