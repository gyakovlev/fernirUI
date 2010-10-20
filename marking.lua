local module = {}
module.name = "SimpleRaidTarget"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
   
    local settings = fuiDB.settings
    
    local srti = {}

    srti.frame = CreateFrame("button", "SRTIRadialMenu", UIParent)
    srti.frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    srti.frame:SetFrameStrata("DIALOG")
    srti.frame:SetWidth(100)
    srti.frame:SetHeight(100)
    srti.frame:Hide()

    srti.frame.origShow = srti.frame.Show
    function srti.frame:Show()
       srti.frame.p = srti.frame:CreateTexture("SRTIRadialMenuPortrait","BORDER")
       srti.frame.p:SetWidth(40)
       srti.frame.p:SetHeight(40)
       srti.frame.p:SetPoint("CENTER")
       srti.frame.b = srti.frame:CreateTexture("SRTIRadialMenuBorder", "BACKGROUND")
       srti.frame.b:SetTexture("Interface\\Minimap\\UI-TOD-Indicator")
       srti.frame.b:SetWidth(80)
       srti.frame.b:SetHeight(80)
       srti.frame.b:SetTexCoord(0.5,1,0,1)
       srti.frame.b:SetPoint("CENTER", srti.frame, "CENTER", 10, -10)
       for i=1, 8 do
          srti.frame[i] = srti.frame:CreateTexture("SRTIRadialMenu"..i,"OVERLAY")
       end

       srti.frame:origShow()
       srti.frame.Show = srti.frame.origShow
       srti.frame.origShow = nil

       srti.frame:SetScript("OnUpdate", function(self)
          local portrait = srti.frame.portrait
          srti.frame.portrait = nil
          local saved, index = self.index, GetRaidTargetIndex("target")
          self.index = nil
          local curtime = GetTime()
          if(not self.hiding) then
                if(not UnitExists("target") or (not UnitPlayerOrPetInRaid("target") and UnitIsDeadOrGhost("target"))) then
                if (portrait) then
                   self:Hide()
                   return
                else
                   self.hiding = curtime
                end
             elseif (portrait) then
                if(portrait==0 and not UnitIsUnit("target","mouseover")) then
                   self:Hide()
                   return
                end
                SetPortraitTexture(srti.frame.p, "target")
             end

                local x, y = GetCursorPosition()
             local s = srti.frame:GetEffectiveScale()
             local mx, my = srti.frame:GetCenter()
             x = x / s
             y = y / s

                local a, b = y - my, x - mx

                local dist = floor(math.sqrt( a*a + b*b ))

                if(dist > 60) then
                if(dist > 200) then
                   self.lingering = nil
                   self.hiding = curtime
                   self.showinghowing = nil
                elseif(not self.lingering) then
                   self.lingering = curtime
                end
             else
                self.lingering = nil

                    if(dist > 20 and dist < 50) then
                   local pos = math.deg(math.atan2(a, b)) + 27.5
                   self.index = mod(11-ceil(pos/45),8)+1
                end
             end

             for i=1, 8 do
                local t = self[i]
                if(index==i) then
                   t:SetTexCoord(0,1,0,1)
                   t:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
                else
                   t:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
                   SetRaidTargetIconTexture(t,i)
                end
             end
          end

            if(self.showing) then
             local status = curtime - self.showing
             if(status>0.1) then
                srti.frame.p:SetAlpha(1)
                srti.frame.b:SetAlpha(1)
                for i=1, 8 do
                   local t, radians = self[i], (0.375 - i/8) * 360
                   t:SetPoint("CENTER", self, "CENTER", 36*cos(radians), 36*sin(radians))
                   t:SetAlpha(0.5)
                   t:SetWidth(18)
                   t:SetHeight(18)
                end
                self.showing = nil
             else
                status = status / 0.1
                srti.frame.p:SetAlpha(status)
                srti.frame.b:SetAlpha(status)
                for i=1, 8 do
                   local t, radians = self[i], (0.375 - i/8) * 360
                   t:SetPoint("CENTER", self, "CENTER", (20*status + 16)*cos(radians), (20*status + 16)*sin(radians))
                   if(i==index) then
                      t:SetAlpha(status)
                   else
                      t:SetAlpha(0.5*status)
                   end
                   t:SetWidth(9*status + 9)
                   t:SetHeight(9*status + 9)
                end
             end
          elseif(self.hiding) then
             local status = curtime - self.hiding
             if(status >0.1) then
                self.hiding = nil
                self:Hide()
             else
                status = 1 - status / 0.1;
                srti.frame.p:SetAlpha(status)
                srti.frame.b:SetAlpha(status)
                for i=1, 8 do
                   local t, radians = self[i], (0.375 - i/8) * 360
                   if(self.index==i) then
                      t:SetWidth(36-18*status)
                      t:SetHeight(36-18*status)
                      t:SetAlpha(min(4*status,1))
                   else
                      t:SetPoint("CENTER", self, "CENTER", (20*status + 16)*cos(radians), (20*status + 16)*sin(radians))
                      t:SetAlpha(0.75*status)
                      t:SetWidth(18*status)
                      t:SetHeight(18*status)
                   end
                end
             end
          else
             for i=1, 8 do
                local t = self[i]
                if(i==index) then
                   t:SetAlpha(1)
                else
                   t:SetAlpha(0.75)
                end
                t:SetWidth(18)
                t:SetHeight(18)
             end
          end

            if(self.index) then
             local t = self[self.index]
             local alpha, width = t:GetAlpha(), t:GetWidth()

             if(not self.time or saved~=self.index) then
                self.time = curtime
             end
             local s = 1 + min( (curtime - self.time)/0.05, 1 )

             t:SetAlpha(min(alpha+0.125*s,1))
             t:SetWidth(width*s)
             t:SetHeight(width*s)
          end

          if(self.lingering) then
             local status = curtime - self.lingering
             if(status>0.75) then
                self.hiding = curtime
                self.lingering = nil
                self.showing = nil
                self.index = nil
             end
          end
       end)

       srti.frame:SetScript("OnClick", function(self,arg1)
          if(not self.hiding) then
             local index = GetRaidTargetIndex("target")
             if((arg1=="RightButton"and index and index>0) or (self.index and self.index>0 and self.index==index)) then
                self.index = index
                srti.SetRaidTarget(0)
             elseif(self.index) then
                srti.SetRaidTarget(self.index)
             end
             self.showing = nil
             self.hiding = GetTime()
          end
       end)
    end

    function srti.Show(frombinding)
       -- if(not IsPartyLeader()) then
          -- local num = GetNumRaidMembers()
          -- if(num==0) then
             -- return
          -- end

          -- local rank = select(2,GetRaidRosterInfo(num))
          -- if(rank == 0) then return end
       -- end

       srti.frame.showing = GetTime()
       srti.frame.hiding = nil
       srti.frame.index = nil
       srti.frame.lingering = nil
       if(UnitExists("target") and (frombinding or UnitIsUnit("target","mouseover"))) then
          srti.frame.exists = nil
       else
          srti.frame.exists = 1
       end
       srti.frame.portrait = frombinding or 0

       local x,y = GetCursorPosition()
       local s = srti.frame:GetEffectiveScale()
       srti.frame:SetPoint( "CENTER", UIParent, "BOTTOMLEFT", x/s, y/s )
       srti.frame:Show()
    end

    local origSetRaidTarget = SetRaidTarget
    function srti.SetRaidTarget(index, unit, fromBinding)
       index = index or 0
       if(srti.frame:IsVisible()) then
          srti.frame.i = index
          srti.frame:Click()
       end
       if(not fromBinding) then
          origSetRaidTarget("target", index)
       end
    end
    hooksecurefunc("SetRaidTarget", function(unit, index) srti.SetRaidTarget(index, unit, 1) end)

    local SRTI_MouseUp = function() 
        if(arg1=="LeftButton") then
          local curtime = GetTime()
          local x, y = GetCursorPosition()
          local double = (srti.click and curtime-srti.click<0.25 and abs(x-srti.clickX)<20 and abs(y-srti.clickY)<20)
          if(double) then
             srti.frame.hovering = nil
             srti.click = nil
             srti.Show()
          else
             srti.click = curtime
          end
          srti.clickX, srti.clickY = x, y
       end
    end

    WorldFrame:HookScript("OnMouseUp", SRTI_MouseUp)

end
tinsert(fui.modules, module) -- finish him!