-----
--Changes the default hp bar
-----
local PLUGIN = {}
PLUGIN.title = "HPBox"
PLUGIN.author = "Trist"
PLUGIN.description = "Changes the default hp bar"

function PLUGIN:HUDShouldDraw(name)
    if (name == "CHudHealth" or name == "CHudBattery") then
        return false
    end
end

function PLUGIN:HUDPaint()

    --debugging
    --surface.SetDrawColor(autobox.colors.pink)
    --surface.DrawRect(0,0,1920,1080)


    local p = 10 --padding
    local h = 100 --height
    local w = 400 --width
    local x = 2 * p + 10
    surface.SetDrawColor(autobox.colors.discord[4])
    surface.DrawRect(2 * p + 2, ScrH() - h - p + 2, w - 4, h - 4)
    autobox.draw:DrawBorder(2 * p, ScrH() - h - p, w, h,255)
    self:DrawBar(x + 130, ScrH() - 63 - p ,250 ,12, autobox.colors.db32[12], 100 , 100) --placeholder
    self:DrawBar(x, ScrH() - 48 - p ,380,12, autobox.colors.db32[20], LocalPlayer():Armor() , 100)
    self:DrawBar(x, ScrH() - 33 - p ,380,24, autobox.colors.db32[28], LocalPlayer():Health() , 100)
    draw.TextShadow({font = "CloseCaption_Normal",text = LocalPlayer():Health(),pos = {x + 10,ScrH() - 33 - p - 2}}, 1)

    draw.TextShadow({font = "TargetID",text = "LVL 1",pos = {x ,ScrH() - h -2}}, 1)
    draw.TextShadow({font = "TargetID",text = "Squire",pos = {x ,ScrH() - h + 16 -2}}, 1)


    --super inefficient, find way to cache in future
    local c = 0
    for _,ent in ipairs(ents.GetAll()) do
        if (ent:GetNWString("AAT_Owner") == LocalPlayer():SteamID()) then
            c = c + 1
        end
    end

    draw.TextShadow({xalign = TEXT_ALIGN_RIGHT,font = "TargetID",text = c .. " Props",pos = {w ,ScrH() - h -2}}, 1) --prop count
end



function PLUGIN:DrawBar(x,y,w,h,color,value,max)
    if (value > max) then value = max end
    surface.SetDrawColor(color_white)
    surface.DrawRect(x, y, w, h)
    surface.SetDrawColor(color_black)
    surface.DrawOutlinedRect(x+1, y+1, w-2, h-2)
    surface.SetDrawColor(autobox.colors.discordAlt[2])
    surface.DrawRect(x+2, y+2, w-4, h-4)
    surface.SetDrawColor(color)
    surface.DrawRect(x+2, y+2, (w-4)*(value/max), h-4)
end

autobox:RegisterPlugin(PLUGIN)