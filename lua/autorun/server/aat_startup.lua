--Autobox Admin Tools
--By Trist Saibot (Tristan Sladek)

--Based off of Evolve, specifically the GMOD 13 update, which we've
--used on our GMOD server personally for nearly 5 years now
--https://github.com/Xandaros/evolve


--Setup mod table.
autobox = {}
autobox.version = 0.1
autobox.debug = true
autobox.debugPrint = {}
autobox.Link_Steam = "https://steamcommunity.com/groups/autobox"
autobox.Link_Discord = "https://discord.gg/0MDyYmYSbGz4V9RG"

--Utility
function autobox:PrettyConsole( ... )
    local length = 0
    local args = {}
    for _,v in ipairs({...}) do
        if(type(v)=="string")then
            if(string.len(v)>length)then length = string.len(v) end
            table.insert(args,v)
        end
    end
    print("+-"..string.rep("-",length).."-+")
    for _,v in ipairs(args) do
        print(string.format("| %-"..length.."s |",v))
    end
    print("+-"..string.rep("-",length).."-+")
end

--Print startup message.
autobox:PrettyConsole(
    "Autobox Administration Tools",
    "Version: "..autobox.version,
    "By Trist Saibot",
    "For use on the Autobox server",
    autobox.Link_Steam
)

--Send files to the client.
AddCSLuaFile( "autorun/client/aat_startup.lua" )
AddCSLuaFile("aat_framework.lua")

--Run file setup.
include("aat_framework.lua")

--Initialize
autobox:LoadCore()
autobox:SQL_SetupTables()
autobox:LoadPlugins()

