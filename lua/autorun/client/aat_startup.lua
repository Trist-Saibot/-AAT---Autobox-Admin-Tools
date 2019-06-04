--Setup mod table.
autobox = {}
autobox.version = 0.1
autobox.debug = true
autobox.debugPrint = {}
autobox.Link_Steam = "https://steamcommunity.com/groups/autobox"
autobox.Link_Discord = "https://discord.gg/0MDyYmYSbGz4V9RG"
autobox.Link_Patreon = "https://www.patreon.com/autobox"

--Utility
function autobox:PrettyConsole( ... )
    local length = 0
    local args = {}
    for _,v in ipairs({...}) do
        if (type(v) == "string") then
            if (string.len(v) > length) then length = string.len(v) end
            table.insert(args,v)
        end
    end
    print("+-" .. string.rep("-",length) .. "-+")
    for _,v in ipairs(args) do
        print(string.format("| %-" .. length .. "s |",v))
    end
    print("+-" .. string.rep("-",length) .. "-+")
end

surface.CreateFont( "TristText_Default", {
    font = "Trebuchet MS",
    extended = false,
    size = 20,
    weight = 500,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )
surface.CreateFont( "TristText_Bold", {
    font = "Trebuchet MS",
    extended = false,
    size = 20,
    weight = 1000,
    blursize = 0,
    scanlines = 0,
    antialias = true,
    underline = false,
    italic = false,
    strikeout = false,
    symbol = false,
    rotary = false,
    shadow = false,
    additive = false,
    outline = false,
} )

--Print startup message.
autobox:PrettyConsole(
    "Autobox Administration Tools",
    "Version: " .. autobox.version,
    "By Trist Saibot",
    "For use on the Autobox server",
    autobox.Link_Steam
)

--Run file setup.
include("aat_framework.lua")

--Initialize
autobox:LoadCore()
autobox:LoadPlugins()
hook.Run("AAT_LoadOthers")
