-----
--Displays player names above heads.
-----
local PLUGIN = {}
PLUGIN.title = "Player Names"
PLUGIN.author = "Trist"
PLUGIN.description = "Displays player names above heads."
PLUGIN.perm = "See Player Names"

function PLUGIN:HUDPaint()
    if (!LocalPlayer():AAT_HasPerm(PLUGIN.perm)) then return end
    for _,v in ipairs(player.GetAll()) do
        if ((v != LocalPlayer() and v:Alive()) or LocalPlayer():GetNWBool("AAT_Ragdolled",false)) then
            local target = v
            if (v:GetNWBool("AAT_Ragdolled",false) and IsValid(v:GetNWEntity("AAT_Ragdoll",nil))) then
                target = v:GetNWEntity("AAT_Ragdoll",nil)
            end


            local bone = target:LookupBone("ValveBiped.Bip01_Head1")
            local pos = nil
            if (!bone) then
                pos = target:GetPos() + Vector(0,0,90)
            else
                pos = target:GetBonePosition( bone )
            end
            if (type(target) == "Player") then
                pos = target:GetShootPos()
            end

            local td = {}
            td.start = LocalPlayer():GetShootPos()
            td.endpos = pos
            local trace = util.TraceLine(td)

            if (!trace.HitWorld) then
                surface.SetFont( "DermaDefaultBold" )
                local w = surface.GetTextSize(v:Nick()) + 32
                local h = 24

                local drawPos = pos:ToScreen()
                local distance = LocalPlayer():GetShootPos():Distance(pos)
                drawPos.x = drawPos.x - w / 2
                drawPos.y = drawPos.y - h - 25

                local alpha = 255
                if ( distance > 512 ) then
                    alpha = 255 - math.Clamp( ( distance - 512 ) / ( 2048 - 512 ) * 255, 0, 255 )
                end

                surface.SetDrawColor( 62, 62, 62, alpha )
                surface.DrawRect( drawPos.x, drawPos.y, w, h )
                surface.SetDrawColor( 129, 129, 129, alpha )
                surface.DrawOutlinedRect( drawPos.x, drawPos.y, w, h )

                surface.SetMaterial(autobox:GetRankInfo(v:AAT_GetRank()).IconTexture)
                surface.SetDrawColor( 255, 255, 255, math.Clamp( alpha * 2, 0, 255 ) )
                surface.DrawTexturedRect( drawPos.x + 5, drawPos.y + 5, 14, 14 )

                local col = autobox:HexToColor(autobox:GetRankInfo(v:AAT_GetRank()).Color) or team.GetColor( pl:Team() )
                col.a = math.Clamp( alpha * 2, 0, 255 )
                draw.DrawText( v:Nick(), "DermaDefaultBold", drawPos.x + 28, drawPos.y + 5, col, 0 )
            end
        end
    end
end

autobox:RegisterPlugin(PLUGIN)