--Framework File

--File Loading
function autobox:LoadCore()
    --Load in all core files. Core files are files that run once and setup functions/values.
    local path = "autobox/core/"
    local coreMods = file.Find(path.."*.lua","LUA")
    if(autobox.debug)then autobox.debugPrint = {} end
    for _,v in ipairs(coreMods) do
        include(path..v)
        AddCSLuaFile(path..v)
        if(autobox.debug)then table.insert(autobox.debugPrint,v) end
    end
    if(autobox.debug)then autobox:PrettyConsole("Core Files Loaded",unpack(autobox.debugPrint)) end       
end
