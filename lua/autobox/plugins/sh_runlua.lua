-----
-- Run Lua on the server
-----
local PLUGIN = {}
PLUGIN.title = "Lua"
PLUGIN.author = "Trist"
PLUGIN.description = "Execute Lua on the server"
PLUGIN.perm = "Run Lua"
PLUGIN.command = "lua"
PLUGIN.usage = "<code>"

local mt, mt2 = {}, {}
EVERYONE, EVERYTHING = {}, {}

function mt.__index( t, k )
    return function( ply, ... )
        for _, pl in ipairs( player.GetAll() ) do
            pl[ k ]( pl, ... )
        end
    end
end

function mt2.__index( t, k )
    return function( ply, ... )
        for _, ent in ipairs( ents.GetAll() ) do
            if ( !ent:IsWorld() ) then ent[ k ]( ent, ... ) end
        end
    end
end

setmetatable( EVERYONE, mt )
setmetatable( EVERYTHING, mt2 )

function PLUGIN:Call(ply,args)
    if (!autobox:ValidatePerm(ply,PLUGIN.perm)) then return end
    local code = table.concat( args, " " )
    if (#code > 0) then
        ME = ply
        THIS = ply:GetEyeTrace().Entity
        --PLAYER = function( nick ) return evolve:FindPlayer( nick )[1] end

        local f, a, b = CompileString( code, "" )
        if ( !f ) then
            autobox:Notify( ply, autobox.colors.red, "Syntax error! Check your script!" )
            return
        end
        local status, err = pcall( f )
        if ( status ) then
            autobox:Notify( autobox.colors.blue, ply:Nick(), autobox.colors.white, " ran Lua code: ", autobox.colors.red, code )
        else
            autobox:Notify( ply, autobox.colors.red, string.sub( err, 5 ) )
        end

        THIS,ME,PLAYER = nil
    else
        autobox:Notify( ply, autobox.colors.red, "No code specified." )
    end
end

autobox:RegisterPlugin(PLUGIN)