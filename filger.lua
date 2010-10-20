local module = {}
module.name = "Filger"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
	settings = fuiDB
   if not settings[module.name] then settings[module.name] = {} end
	local opts = settings[module.name]
   
   --[[ Filger, Copyright (c) 2009, Nils Ruesch, All rights reserved. ]]
   --[[ some changes, Fernir ]]
   
   local spells = {
      ["ROGUE"] = {
         {
            Name = "Proc",
            Growth = "UP",
            Mode = "BAR",
            
            -- OCC
            { spellID = 408, unit = "target", caster = 1, filter = "DEBUFF", },
            { spellID = 6774, unit = "player", caster = 1, filter = "BUFF", },
            { spellID = 51662, unit = "player", caster = 1, filter = "BUFF", },
            { spellID = 57969, unit = "player", caster = 1, filter = "BUFF", },
         },
      },
      ["DRUID"] = {
         {
            Name = "Proc",
            Growth = "UP",
            Mode = "ICON",
            
            -- OCC
            { spellID = 12536, unit = "player", caster = 1, filter = "BUFF", },
            { spellID = 69369, unit = "player", caster = 1, filter = "BUFF", },
            { spellID = 52610, unit = "player", caster = 1, filter = "BUFF", },
            { spellID = 52610, unit = "player", caster = 1, filter = "BUFF", },
         },
      },
      ["WARLOCK"] = {
         {
            Name = "CD",
            Growth = "UP",
            Mode = "ICON",
            
            -- Death Coil
            { spellID = 47860, unit = "player", caster = 1, filter = "CD", },
         },
         {
            Name = "Proc",
            Growth = "UP",
            Mode = "ICON",
            
            -- Nightfall and Eradication
            { spellID = 64371, unit = "player", caster = 1, filter = "BUFF", },
            { spellID = 17941, unit = "player", caster = 1, filter = "BUFF", },
         },
      },
   }

   if not opts["Bar Width"] then opts["Bar Width"] = 200 end
   if not opts["Bar Spacing"] then opts["Bar Spacing"] = 1 end
   if not opts["Bar Size"] then opts["Bar Size"] = 18 end
   if not opts["Icon Size"] then opts["Icon Size"] = 32 end

   local configmode = false
   local barSize = opts["Bar Size"] or 18
   local iconSize = opts["Icon Size"] or 32
   local barWidth = opts["Bar Width"] or 200
   local barSpace = opts["Bar Spacing"] or 1
   
   
   local class = select(2, UnitClass("player"))
   local active, bars = {}, {}
   local MyUnits = { player = true, vehicle = true, pet = true, }
   local timer, Update

   local createFs = function(parent, justify, ownfsize, fstyle)
       local f = parent:CreateFontString(nil, "OVERLAY")
       f:SetFont(fuiDB["Main"].Font, ownfsize or fuiDB["Main"].FontSize, fstyle)
       if(justify) then f:SetJustifyH(justify) end
       f:SetShadowOffset(.5, -.5)
       return f
   end

   local OnUpdate = function(self, elapsed)
      timer = self.filter == "CD" and self.expirationTime+self.duration-GetTime() or self.expirationTime-GetTime()
      if ( self:GetParent().Mode == "BAR" ) then
         self.statusbar:SetValue(timer)
         self.timer:SetFormattedText(SecondsToTimeAbbrev(timer))
      end
      if ( timer < 0 and self.filter == "CD" ) then
         local id = self:GetParent().id
         for index, value in ipairs(active[id]) do
            if ( self.spellID == value.data.spellID ) then
               tremove(active[id], index)
               break
            end
         end
         self:SetScript("OnUpdate", nil)
         Update(self:GetParent())
      end
   end

   local Update = function(self)
      local id = self.id
      if ( not bars[id] ) then
         bars[id] = {}
      end
      for index, value in ipairs(bars[id]) do
         value:Hide()
      end
      local bar
      for index, value in ipairs(active[id]) do
         local mname = "FilgerAnker"..id.."Frame"..index
         bar = bars[id][index]
         if ( _G[mname] == nil ) then
            bar = CreateFrame("Frame", mname, self)
            if ( self.Mode == "ICON" ) then
               bar:SetWidth(iconSize)
               bar:SetHeight(iconSize)
            else
               bar:SetWidth(barSize)
               bar:SetHeight(barSize)
            end
            if ( index == 1 ) then
               if ( self.Growth == "UP" ) then
                  bar:SetPoint("BOTTOM", self)
               elseif ( self.Growth == "RIGHT" ) then
                  bar:SetPoint("LEFT", self)
               elseif ( self.Growth == "LEFT" ) then
                  bar:SetPoint("RIGHT", self)
               else
                  bar:SetPoint("TOP", self)
               end
            else
               if ( self.Growth == "UP" ) then
                  bar:SetPoint("BOTTOM", bars[id][index-1], "TOP", 0, barSpace)
               elseif ( self.Growth == "RIGHT" ) then
                  bar:SetPoint("LEFT", bars[id][index-1], "RIGHT", self.Mode == "ICON" and barSpace or barWidth+barSpace, 0)
               elseif ( self.Growth == "LEFT" ) then
                  bar:SetPoint("RIGHT", bars[id][index-1], "LEFT", self.Mode == "ICON" and -barSpace or -(barWidth+barSpace), 0)
               else
                  bar:SetPoint("TOP", bars[id][index-1], "BOTTOM", 0, -barSpace)
               end
            end
            if ( self.Mode == "ICON" ) then
               bar.icon = bar:CreateTexture("$parentIcon", "OVERLAY")
               bar.icon:SetAllPoints()
               bar.icon:SetTexCoord(.1, .9, .1, .9)
               
               bar.count = createFs(bar)
               bar.count:SetPoint("BOTTOMRIGHT", -2, 2)
               bar.count:SetJustifyH("RIGHT")
               
               bar.cooldown = _G[mname.."Cooldown"] or CreateFrame("Cooldown", "$parentCooldown", bar, "CooldownFrameTemplate")
               bar.cooldown:SetAllPoints()
               bar.cooldown:SetReverse()
               
               bar.overlay = bar:CreateTexture(nil, "OVERLEY")
               bar.overlay:SetTexture(fuiDB["Main"].Texture)
               bar.overlay:SetPoint("TOPLEFT", -2, 2)
               bar.overlay:SetPoint("BOTTOMRIGHT", 2, -2)
               bar.overlay:SetVertexColor(0, 0, 0)
            else
               bar.icon = bar:CreateTexture(nil, "OVERLEY")
               bar.icon:SetAllPoints()
               bar.icon:SetTexCoord(.1, .9, .1, .9)
               
               bar.count = createFs(bar)
               bar.count:SetPoint("BOTTOMRIGHT")
               bar.count:SetJustifyH("RIGHT")
               
               bar.statusbar = _G[mname.."StatusBar"] or CreateFrame("StatusBar", "$parentStatusBar", bar)
               
               SetTemplate(bar.statusbar)
               bar.statusbar:SetWidth(barWidth or 200)
               bar.statusbar:SetHeight(barSize)
               bar.statusbar:SetStatusBarTexture(fuiDB["Main"].Texture)
               bar.statusbar:SetStatusBarColor(0.4, 0.4, 0.4, 1)
               bar.statusbar:SetPoint("LEFT", bar, "RIGHT")
               bar.statusbar:SetMinMaxValues(0, 1)
               bar.statusbar:SetValue(0)
               bar.statusbar.background = bar.statusbar:CreateTexture(nil, "BACKGROUND")
               bar.statusbar.background:SetAllPoints()
               bar.statusbar.background:SetTexture(fuiDB["Main"].Texture)
               bar.statusbar.background:SetVertexColor(.1, .1, .1, 0.7)
               
               bar.timer = createFs(bar.statusbar)
               bar.timer:SetPoint("RIGHT", bar.statusbar, -2, 1)
               
               bar.spellname = createFs(bar.statusbar)
               bar.spellname:SetPoint("LEFT", bar.statusbar, 2, 1)
               bar.spellname:SetPoint("RIGHT", bar.timer, "LEFT")
               bar.spellname:SetJustifyH("CENTER")
            end
            
            tinsert(bars[id], bar)
         end
         
         bar.spellID = value.data.spellID
         
         bar.icon:SetTexture(value.icon)
         bar.count:SetText(value.count > 1 and value.count or "")
         if ( self.Mode == "BAR" ) then
            bar.spellname:SetText(value.data.displayName)
         end
         if ( value.duration > 0 ) then
            if ( self.Mode == "ICON" ) then
               CooldownFrame_SetTimer(bar.cooldown, value.data.filter == "CD" and value.expirationTime or value.expirationTime-value.duration, value.duration, 1)
               if ( value.data.filter == "CD" ) then
                  bar.expirationTime = value.expirationTime
                  bar.duration = value.duration
                  bar.filter = value.data.filter
                  bar:SetScript("OnUpdate", OnUpdate)
               end
            else
               bar.statusbar:SetMinMaxValues(0, value.duration)
               bar.expirationTime = value.expirationTime
               bar.duration = value.duration
               bar.filter = value.data.filter
               bar:SetScript("OnUpdate", OnUpdate)
            end
         else
            if ( self.Mode == "ICON" ) then
               bar.cooldown:Hide()
            else
               bar.statusbar:SetMinMaxValues(0, 1)
               bar.statusbar:SetValue(1)
               bar.timer:SetText("")
               bar:SetScript("OnUpdate", nil)
            end
         end
         
         bar:Show()
      end
   end

   local function OnEvent(self, event, ...)
      local unit = ...
      if ( ( unit == "target" or unit == "player" ) or event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_ENTERING_WORLD" or event == "SPELL_UPDATE_COOLDOWN" ) then
         local data, name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, start, enabled, slotLink
         local id = self.id
   
         for i=1, #spells[class][id], 1 do
            data = spells[class][id][i]
            local spn = GetSpellInfo(data.spellID)
               
            if ( data.filter == "BUFF" ) then
               name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitBuff(data.unit, spn)
               data.displayName = name
            elseif ( data.filter == "DEBUFF" ) then
               name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable = UnitDebuff(data.unit, spn)
               data.displayName = name
            else
               if ( type(data.spellID) == "string" or type(data.spellID) == "number" ) then
                  start, duration, enabled = GetSpellCooldown(GetSpellInfo(data.spellID))
                  icon = GetSpellTexture(data.spellID)
               else
                  slotLink = GetInventoryItemLink("player", GetSpellInfo(data.spellID))
                  if ( slotLink ) then
                     name, _, _, _, _, _, _, _, _, icon = GetItemInfo(slotLink)
                     if ( not data.displayName ) then
                        data.displayName = name
                     end
                     start, duration, enabled = GetInventoryItemCooldown("player", data.spellID)
                  end
               end
               count = 0
               caster = "all"
            end
            if ( not active[id] ) then
               active[id] = {}
            end
            for index, value in ipairs(active[id]) do
               if ( data.spellID == value.data.spellID ) then
                  tremove(active[id], index)
                  break
               end
            end
            if ( ( name and ( data.caster ~= 1 and ( caster == data.caster or data.caster == "all" ) or MyUnits[caster] )) or ( ( enabled or 0 ) > 0 and ( duration or 0 ) > 1.5 ) ) then
               table.insert(active[id], { data = data, icon = icon, count = count, duration = duration, expirationTime = expirationTime or start })
            end
         end
         Update(self)
      end
   end


   local init = function(self)

   local data, mainframe

      for i=1, #spells[class], 1 do
         data = spells[class][i]
         
         if ( _G["FilgerAnker"..i] == nil ) then
            mainframe = CreateFrame("Frame", "FilgerAnker"..i, UIParent)
            mainframe.id = i
            mainframe.Growth = data.Growth or "DOWN"
            mainframe.Mode = data.Mode or "ICON"
            mainframe.text = createFs(mainframe)
            mainframe.text:SetPoint("CENTER")
            mainframe:SetWidth(100)
            mainframe:SetHeight(20)
           
            fuiDB[mainframe:GetName()] = fuiDB[mainframe:GetName()] or {}
            local x = fuiDB[mainframe:GetName()].posX or 400
            local y = fuiDB[mainframe:GetName()].posY or 400
            
            mainframe:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
            mainframe:SetMovable(true)
         else
            mainframe = _G["FilgerAnker"..i]
         end

         if ( configmode ) then
            mainframe:UnregisterAllEvents()
            mainframe:SetFrameStrata("DIALOG")
            mainframe:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile = "", insets = { left = 0, right = 0, top = 0, bottom = 0 }})
            mainframe:EnableMouse(true)
            mainframe:RegisterForDrag("LeftButton")
            mainframe:SetScript("OnDragStart", function(mainframe) mainframe:StartMoving() end)
            mainframe:SetScript("OnDragStop", function(mainframe) 
               mainframe:StopMovingOrSizing()
               mainframe:SetUserPlaced(true)
               local x, y = mainframe:GetLeft(), mainframe:GetBottom()
               fuiDB[mainframe:GetName()].posX = x
               fuiDB[mainframe:GetName()].posY = y
            end)
            mainframe.text:SetText(data.Name and data.Name or "FilgerAnker"..i)         
         else
            mainframe:SetFrameStrata("LOW")
            mainframe:SetBackdrop(nil)
            mainframe:EnableMouse(false)
            mainframe:RegisterForDrag(nil)
            mainframe:SetScript("OnDragStart", nil)
            mainframe:SetScript("OnDragStop", nil)         
            mainframe.text:SetText("")
         
            for j=1, #spells[class][i], 1 do
               data = spells[class][i][j]
               if ( data.filter == "CD" ) then
                  mainframe:RegisterEvent("SPELL_UPDATE_COOLDOWN")
                  break
               end
            end
            mainframe:RegisterEvent("UNIT_AURA")
            mainframe:RegisterEvent("PLAYER_TARGET_CHANGED")
            mainframe:RegisterEvent("PLAYER_ENTERING_WORLD")
            mainframe:SetScript("OnEvent", OnEvent)
         end
      end
   end
   
   FILGERTOGGLELOCKED = function()
      configmode = not configmode
      init()
   end

   if ( spells and spells[class] ) then
      for index in pairs(spells) do
         if ( index ~= class ) then
            spells[index] = nil
         end
      end
      init()
   end

   opts.ToggleLocked = "functionFILGERTOGGLELOCKED()"

   SlashCmdList.FILGER = function() FILGERTOGGLELOCKED() end
   SLASH_FILGER1 = "/filger"
   SLASH_FILGER2 = "/fr"
   
end
tinsert(fui.modules, module) -- finish him!