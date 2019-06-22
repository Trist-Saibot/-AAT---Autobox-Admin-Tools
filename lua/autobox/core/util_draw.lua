--various generic draw functions
if (SERVER) then
    for _,v in pairs(file.Find("materials/autobox/icon16/*.png","GAME")) do
        resource.AddFile( "materials/autobox/icon16/" .. v)
    end
    for _,v in pairs(file.Find("materials/autobox/ui/*.png","GAME")) do
        resource.AddFile( "materials/autobox/ui/" .. v)
    end
end
if (CLIENT) then
    autobox.draw = {}
    autobox.draw.borderMat = Material("autobox/ui/border.png")
    autobox.draw.gripMat = Material("autobox/ui/grip.png")
    function autobox.draw:DrawBorder(x,y,w,h,alpha)
        surface.SetAlphaMultiplier(alpha / 255)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(self.borderMat)
        surface.DrawTexturedRectUV(x,y,16,16,0,0,0.5,0.5) --top left
        surface.DrawTexturedRectUV(x,y + h - 16,16,16,0,0.5,0.5,1) --bottom left
        surface.DrawTexturedRectUV(x + w - 16,y,16,16,0.5,0,1,0.5) --top right
        surface.DrawTexturedRectUV(x + w - 16,y + h - 16,16,16,0.5,0.5,1,1) --bottom right

        surface.DrawTexturedRectUV(x + 16,y,w - 32,16,0.4375,0,0.5625,0.5) --top middle
        surface.DrawTexturedRectUV(x,y + 16,16,h - 32,0,0.4375,0.5,0.5625) --left middle
        surface.DrawTexturedRectUV(x + w - 16,y + 16,16,h - 32,0.5,0.4375,1,0.5625) --right middle
        surface.DrawTexturedRectUV(x + 16,y + h - 16,w - 32,16,0.4375,0.5,0.5625,1) --bottom middle
        surface.SetAlphaMultiplier(1)
    end
    function autobox.draw:DrawGrip(x,y,w,h,alpha)
        surface.SetAlphaMultiplier(alpha / 255)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(self.gripMat)
        local s = 8
        surface.DrawTexturedRectUV(x,y,s,s,0,0,0.5,0.5) --top left
        surface.DrawTexturedRectUV(x,y + h - s,s,s,0,0.5,0.5,1) --bottom left
        surface.DrawTexturedRectUV(x + w - s,y,s,s,0.5,0,1,0.5) --top right
        surface.DrawTexturedRectUV(x + w - s,y + h - s,s,s,0.5,0.5,1,1) --bottom right
        surface.DrawTexturedRectUV(x,y + s,s,h - s * 2,0,0.4375,0.5,0.5) --left middle
        surface.DrawTexturedRectUV(x + w - s,y + s,s,h - s * 2,0.5,0.4375,1,0.5) --right middle
        surface.SetAlphaMultiplier(1)
    end
    function autobox.draw:CustomVBar(panel)
        local vbar = panel:GetVBar()
        vbar:SetHideButtons(true)
        vbar:SetWide(16)
        function vbar:Paint(w,h)
            surface.SetDrawColor(ColorAlpha(autobox.colors.discord[4],panel:GetAlpha() or 255))
            surface.DrawRect(7,4,2,h - 8)
        end
        function vbar.btnGrip:Paint(w,h)
            autobox.draw:DrawGrip(0,0,w,h,panel:GetAlpha() or 255)
        end
    end
    function autobox.draw:AddSlider(parent,x,y,width,height,text,params)
        if (IsValid(parent)) then
            if (!params) then params = {} end
            local DSlider = vgui.Create("DNumSlider",parent)
            DSlider:SetPos(x,y)
            DSlider:SetSize(width,height)
            if (params.min) then DSlider:SetMin(params.min) else DSlider:SetMin(0) end
            if (params.max) then DSlider:SetMax(params.max) else DSlider:SetMax(255) end
            DSlider:SetDecimals(0)
            if (params.value) then DSlider:SetValue(params.value) end
            function DSlider:PerformLayout()
                self.Label:SetWide(0)
            end
            function DSlider.Slider.Knob:Paint(w,h)
                autobox.draw:DrawGrip(0,0,w,h,255)
            end
            function DSlider.Slider:Paint(w,h)
                surface.SetDrawColor(autobox.colors.discord[4])
                surface.DrawRect(8,h / 2,w - 16,1)
            end
            local DPanel = vgui.Create("DPanel",parent)
            DPanel:SetSize(width,height)
            DPanel:SetPos(DSlider:GetPos())
            DPanel:MoveLeftOf(DSlider)
            function DPanel:Paint(w,h)
                draw.TextShadow({text = text,pos = {w,h / 2.25},xalign = TEXT_ALIGN_RIGHT,yalign = TEXT_ALIGN_CENTER},1)
            end
            DSlider.Slider.Knob:NoClipping(false)
            return DSlider
        end
        return nil
    end
    autobox.draw.btn_on = Material("autobox/ui/btn_on.png")
    autobox.draw.btn_off = Material("autobox/ui/btn_off.png")
    function autobox.draw:RadioBox(parent,x,y,text,numoptions,default)
        if (IsValid(parent)) then
            local panel = vgui.Create("DPanel",parent)
            panel:SetPos(x,y)
            panel:SetSize((numoptions + 1) * 16,16)
            panel.buttons = {}
            panel.selected = tonumber(default) or - 1
            if (!numoptions or numoptions < 1) then numoptions = 1 end
            function panel:Paint(w,h) end
            function panel:OnChange() end
            for i = 1,numoptions do
                local btn = vgui.Create("DButton",panel)
                btn:SetPos((i - 1) * 16,0)
                btn:SetSize(16,16)
                btn:SetText("")
                panel.buttons[i] = btn
                function btn:Paint(w,h)
                    surface.SetDrawColor(color_white)
                    surface.SetMaterial((self:GetParent().selected ==  i) and autobox.draw.btn_on or autobox.draw.btn_off)
                    surface.DrawTexturedRect(0,0,w,h)
                end
                function btn:DoClick()
                    self:GetParent().selected = i
                    self:GetParent():OnChange()
                end
            end

            local DPanel = vgui.Create("DPanel",parent)
            surface.SetFont("default")
            local width, height = surface.GetTextSize(text)
            DPanel:SetSize(width * 1.25,height * 1.5)
            DPanel:SetPos(panel:GetPos())
            DPanel:MoveLeftOf(panel,5)
            function DPanel:Paint(w,h)
                draw.TextShadow({text = text,pos = {w,0},xalign = TEXT_ALIGN_RIGHT,yalign = TEXT_ALIGN_TOP},1)
            end
            return panel
        end
    end
end --end CLIENT