-----
--draws a radar minimap
-----
if (SERVER) then
    resource.AddFile("materials/autobox/maps/gm_bigcity.png")
end
local PLUGIN = {}
PLUGIN.title = "radar"
PLUGIN.author = "Trist"
PLUGIN.description = "draws a radar minimap"
PLUGIN.mat = Material("autobox/maps/gm_bigcity.png")
PLUGIN.player = Material("autobox/ui/player.png")

function PLUGIN:HUDPaint()

    surface.SetDrawColor(color_white)
    surface.SetMaterial(self.mat)
    local s = 256
    local o = 512 * 13
    local pos = LocalPlayer():GetPos()
    local x = -pos.x
    local y = pos.y
    local ms = 13250
    local ux1 = (x+ms-o)/26500
    local uy1 = (y+ms-o)/26500
    local ux2 = (x+ms+o)/26500
    local uy2 = (y+ms+o)/26500
    surface.DrawTexturedRectUV(ScrW() - 20 - s,ScrH() - 20 - s,s,s,ux1,uy1,ux2,uy2)

    local h = 25
    surface.SetDrawColor(color_black)
    surface.DrawRect(ScrW() - 20 - s ,ScrH() - 20 - s - h, s, h)

    autobox.draw:DrawBorder(ScrW() - 20 - s - 2,ScrH() - 20 - s - 2 - h,s + 4,s + 4 + h,255)


    local sec1 = A
    local sex = {"A","B","C","D","E"}
    local sec2 = 1
    if (pos.x < -ms or pos.x > ms) then sec1 = "?" else sec1 = sex[6 - math.ceil((pos.x + ms) * 5 / (ms * 2))] end
    if (pos.y < -ms or pos.y > ms) then sec2 = "?" else sec2 = math.ceil((pos.y + ms) * 5 / (ms * 2)) end
    draw.TextShadow({xalign = TEXT_ALIGN_CENTER,font = "TargetID",text = "Sector " .. sec1 .. sec2,pos = {ScrW() - 20 - s - 2 + s / 2,ScrH() - 20 - s - 2 - h + 4}}, 1)

    surface.SetDrawColor(Color(255,0,0,255))
    surface.SetMaterial(self.player)
    surface.DrawTexturedRectRotated( ScrW() - 20 - s/2 ,ScrH() - 20 - s / 2 , 8,8, LocalPlayer():GetAimVector():Angle().yaw + 90)
end

autobox:RegisterPlugin(PLUGIN)