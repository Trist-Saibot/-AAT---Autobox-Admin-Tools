-----
--Pre Init
-----
local PLUGIN = {}
PLUGIN.title = "Pre Init"
PLUGIN.author = "Trist"
PLUGIN.description = "Runs Before Initialization"

local maps = {
    "gm_new_worlds_wc",
    "sb_new_worlds_2_wc",
    "gm_galactic_rc1"
}

function PLUGIN:Initialize()
    local map = game.GetMap()
    if (table.HasValue(maps,map)) then
        daynight_enabled = {}
        function daynight_enabled:GetInt()
            return 0
        end
    end
end

autobox:RegisterPlugin(PLUGIN)