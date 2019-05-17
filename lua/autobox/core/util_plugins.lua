--Functions managing Plugins

if (!autobox.plugins) then autobox.plugins = {} end--this table stores plugin titles and file names, used for reloading

local currentPlugin --this allows us to store the plugin's file name for later reloading

function autobox:LoadPlugins()
    autobox.plugins = {}
    local path = "autobox/plugins/"
    local plugins = file.Find(path .. "*.lua","LUA")
    if (autobox.debug) then autobox.debugPrint = {} end
    for _,v in ipairs(plugins) do
        local prefix = string.Left(v,string.find(v,"_") - 1)
        currentPlugin = v
        if (CLIENT and (prefix == "sh")) then
            include(path .. v)
            if (autobox.debug) then table.insert(autobox.debugPrint,v) end
        elseif (SERVER) then
            if (prefix != "cl") then
                include(path .. v)
                if (autobox.debug) then table.insert(autobox.debugPrint,v) end
            end
            if (prefix == "sh") then
                AddCSLuaFile(path .. v)
            end
        end
    end
    if (autobox.debug) then autobox:PrettyConsole("Plugins Loaded",unpack(autobox.debugPrint)) end
end

--this works because the logic of loading plugins will call RegisterPlugin inside, and refer back to this function

function autobox:RegisterPlugin(plugin)
    for k,v in pairs(autobox.plugins) do --avoids adding duplicate plugins
        if (v.title == plugin.title) then
            return
        end
    end
    if (plugin.perm and SERVER) then
        autobox:SQL_AddPerm(plugin.perm)
    end
    if (!plugin.title) then plugin.title = "" end
    if (!plugin.author) then plugin.author = "" end
    if (!plugin.description) then plugin.description = "" end
    plugin.file = currentPlugin
    table.insert(autobox.plugins,plugin)
    if (plugin.AAT_PostStartup) then plugin:AAT_PostStartup() end --if this plugin has stuff it wants called after being loaded in
end

function autobox:FindPlugin(str)
    for _,v in ipairs(autobox.plugins) do
        if (string.lower(str) == string.lower(v.title)) then
            return v
        end
    end
    return nil
end

if (SERVER) then
    util.AddNetworkString("AAT_ReloadPlugin")
    util.AddNetworkString("AAT_CallPlugin")
end

function autobox:ReloadPlugin(plugin)
    if (plugin) then
        if (plugin.AAT_OnReload) then
            plugin:AAT_OnReload()
        end
        local path = "autobox/plugins/"
        local prefix = string.Left(plugin.file,string.find(plugin.file,"_") - 1)
        currentPlugin = plugin.file
        for k,v in pairs(autobox.plugins) do --remove the previous addon from the table
            if (v.title == plugin.title) then
                table.remove(autobox.plugins,k)
                break
            end
        end
        if (CLIENT and (prefix == "sh")) then
            include(path .. plugin.file)
        elseif (SERVER) then
            if (prefix != "cl") then
                include(path .. plugin.file)
            end
            if (prefix == "sh") then
                AddCSLuaFile(path .. plugin.file)
                net.Start("AAT_ReloadPlugin")
                    net.WriteTable({T = plugin.title,P = path,F = plugin.file})
                net.Broadcast()
            end
        end
    end
end

if (SERVER) then
    function autobox:HotloadPlugins()
        local path = "autobox/plugins/"
        local plugins = {}
        for _,v in ipairs(file.Find(path .. "*.lua","LUA")) do
            local found = false
            for _,p in ipairs(autobox.plugins) do
                if (v == p.file) then
                    found = true
                    break
                end
            end
            if (!found) then
                table.insert(plugins,v)
            end
        end
        for _,v in ipairs(plugins) do
            local prefix = string.Left(v,string.find(v,"_") - 1)
            currentPlugin = v
            if (CLIENT and (prefix == "sh")) then
                include(path .. v)
            elseif (SERVER) then
                if (prefix != "cl") then
                    include(path .. v)
                end
                if (prefix != "sv") then
                    AddCSLuaFile(path .. v)
                    net.Start("AAT_ReloadPlugin")
                        net.WriteTable({P = path,F = v})
                    net.Broadcast()
                end
            end
            autobox:Notify(autobox.colors.white,"The plugin ",autobox.colors.red,v,autobox.colors.white," was Hotloaded.")
        end
    end
    function autobox:CallPlugin(plug,ply,...)
        local plugin = autobox:FindPlugin(plug)
        local args = {...}
        if (plugin and plugin.Call) then
            plugin:Call(ply,args)
        else
            autobox:DebugPrint( plug .. " not found.")
        end
    end
    net.Receive("AAT_CallPlugin",function(len,ply)
        local plugin = net.ReadString(plugin)
        local args = net.ReadTable() or nil
        autobox:CallPlugin(plugin,ply,args)
    end)
end

if (CLIENT) then
    net.Receive("AAT_ReloadPlugin",function()
        local data = net.ReadTable()
        currentPlugin = data.F
        if (data.T) then
            for k,v in pairs(autobox.plugins) do --remove the previous addon from the table
                if (v.title == data.T) then
                    if (v.AAT_OnReload) then
                        v:AAT_OnReload()
                    end
                    table.remove(autobox.plugins,k)
                    break
                end
            end
        end
        include(data.P .. data.F)
    end)
    function autobox:CallPlugin(plugin,args)
        net.Start("AAT_CallPlugin")
        net.WriteString(plugin)
        net.WriteTable(args)
        net.SendToServer()
    end
end

--This allows plugins that have hook calls to run their hooks
if (!ABX_HookCall) then ABX_HookCall = hook.Call end
hook.Call = function(name,gm,...)
    --ABX plugin logic to run before each plugin logic
    for _,v in ipairs(autobox.plugins) do
        if (v[name]) then --if the plugin has this hook call
            local returnValues = { pcall( v[name], v, ... ) } --run the hook inside of the plugin, collect return values

            if ( returnValues[1] and returnValues[2] != nil ) then -- if it returned anything (and should have) pass those normally
                table.remove( returnValues, 1 )
                return unpack( returnValues )
            elseif ( !returnValues[1] ) then --if it didn't your plugin failed
                autobox:Notify( autobox.colors.red, "Hook '" .. name .. "' in plugin '" .. v.title .. "' failed with error:" )
                autobox:Notify( autobox.colors.red, returnValues[2] )
            end
        end
    end
    --Running the actual hook logic
    return ABX_HookCall(name,gm,...)
end