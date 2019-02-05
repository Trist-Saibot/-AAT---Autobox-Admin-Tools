-----
--Provides Chat Commands
-----

local PLUGIN = {}
PLUGIN.title = "Chat Commands"
PLUGIN.description = "Provides chat commands to run plugins."
PLUGIN.author = "Trist"
--this plugin was MAJORITY copied from Overv's in Evolve
--It's pretty much a direct port into the new system

--Thank you http://lua-users.org/lists/lua-l/2009-07/msg00461.html
function PLUGIN:Levenshtein( s, t )
	local d, sn, tn = {}, #s, #t
	local byte, min = string.byte, math.min
	for i = 0, sn do d[i * tn] = i end
	for j = 0, tn do d[j] = j end
	for i = 1, sn do
		local si = byte(s, i)
		for j = 1, tn do
			d[i*tn+j] = min(d[(i-1)*tn+j]+1, d[i*tn+j-1]+1, d[(i-1)*tn+j-1]+(si == byte(t,j) and 0 or 1))
		end
	end
	return d[#d]
end

function PLUGIN:GetCommand( msg )
	return ( string.match( msg, "%w+" ) or "" ):lower()
end

function PLUGIN:GetArguments( msg )
	local args = {}
	local first = true

	for match in string.gmatch( msg, "[^ ]+" ) do
		if ( first ) then first = false else
			table.insert( args, match )
		end
	end

	return args
end

function PLUGIN:PlayerSay( ply, msg )
    if ( ( GAMEMODE.IsSandboxDerived and string.Left( msg, 1 ) == "/" ) or string.Left( msg, 1 ) == "!" or string.Left( msg, 1 ) == "@" ) then
		local command = self:GetCommand( msg )
		local args = self:GetArguments( msg )
		local closest = { dist = 99, plugin = "" }

        if ( #command > 0 ) then
			for _, plugin in ipairs( autobox.plugins ) do
				if ( plugin.command == command or ( type( plugin.command ) == "table" and table.HasValue( plugin.command, command ) ) ) then
                    autobox.silentNotify = string.Left( msg, 1 ) == "@"
                        local res, ret = pcall( plugin.Call, plugin, ply, args, string.sub( msg, #command + 3 ), command )
                    autobox.silentNotify = false

					if ( !res ) then
						autobox:Notify( autobox.colors.red, "Plugin '" .. plugin.title .. "' failed with error:" )
						autobox:Notify( autobox.colors.red, ret )
					end
					return ""
				elseif ( plugin.command ) then
					local dist = self:Levenshtein( command, type( plugin.command ) == "table" and plugin.command[1] or plugin.command )
					if ( dist < closest.dist ) then
						closest.dist = dist
						closest.plugin = plugin
					end
                end
            end

			if ( closest.dist <= 0.25 * #closest.plugin.command ) then
				local res, ret = pcall( closest.plugin.Call, closest.plugin, ply, args )

				if ( !res ) then
					autobox:Notify( autobox.colors.red, "Plugin '" .. closest.plugin.title .. "' failed with error:" )
					autobox:Notify( autobox.colors.red, ret )
				end
				return ""
			end
		end
	end
end

autobox:RegisterPlugin(PLUGIN)