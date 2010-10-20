  -- config
local settings = nil
local opts = nil
  
local statusTexture = {
  notready = [=[Interface\RAIDFRAME\ReadyCheck-NotReady]=],
  ready = [=[Interface\RAIDFRAME\ReadyCheck-Ready]=],
  waiting = [=[Interface\RAIDFRAME\ReadyCheck-Waiting]=],
}
  
local PostIcon = function(button, ...)
  button.cd:SetAlpha(0)
  button.icon:SetTexCoord(.1, .9, .1, .9)
  button.overlay:SetTexture(0,0,0)
  button.overlay:SetPoint("TOPLEFT", -1, 1)   
  button.overlay:SetPoint("BOTTOMRIGHT", 1, -1)   
  button.overlay:SetDrawLayer("BACKGROUND")
  button.overlay.Hide = function(self) self:SetVertexColor(0,0,0) end
  button:SetScript("OnEnter", nil) 
end

local siValue = function(val)
  if val >= 10000000 then 
    return format("%.1fm", val / 1000000) 
  elseif val >= 1000000 then
    return format("%.2fm", val / 1000000) 
  elseif val >= 100000 then
    return format("%.0fk", val / 1000) 
  elseif val >= 10000 then
    return format("%.1fk", val / 1000) 
  else
    return val
  end
end

local SetUpAnimGroup = function(self)
    self.anim = self:CreateAnimationGroup("Flash")
    self.anim.fadein = self.anim:CreateAnimation("ALPHA", "FadeIn")
    self.anim.fadein:SetChange(1)
    self.anim.fadein:SetOrder(2)

    self.anim.fadeout = self.anim:CreateAnimation("ALPHA", "FadeOut")
    self.anim.fadeout:SetChange(-1)
    self.anim.fadeout:SetOrder(1)
end

local Flash = function(self, duration)
  if not self.anim then
    SetUpAnimGroup(self)
  end

  self.anim.fadein:SetDuration(duration)
  self.anim.fadeout:SetDuration(duration)
  self.anim:Play()
end

local StopFlash = function(self)
  if self.anim then
    self.anim:Finish()
  end
end

local function GetDebuffType(unit)
   if not UnitCanAssist("player", unit) then return nil end

  local CanDispel = {
    ["PRIEST"] = { ["Magic"] = true, ["Disease"] = true, },
    ["SHAMAN"] = { ["Poison"] = true, ["Disease"] = true, ["Curse"] = true, },
    ["PALADIN"] = { ["Magic"] = true, ["Poison"] = true, ["Disease"] = true, },
    ["MAGE"] = { ["Curse"] = true, },
    ["DRUID"] = { ["Curse"] = true, ["Poison"] = true, },
    ["WARLOCK"] = { ["Magic"] = true, },
  }

  local disList = CanDispel[select(2,UnitClass("player"))] or {}

  for i=1, 40 do
    local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable, shouldConsolidate, spellId = UnitAura(unit, i, "HARMFUL")
    if icon and disList[debuffType] then
      return debuffType, icon, spellId, count, duration, expirationTime
    end
  end
end
  
local function CheckDebuffs(self, event, unit)
  if self.unit ~= unit then return end
  local debuffType, texture, spellId, count, duration, expirationTime = GetDebuffType(unit)

  if debuffType then
    local color = DebuffTypeColor[debuffType] or {0,0,1}
    self:SetBackdropBorderColor(color.r, color.g, color.b,1)
    self.Icon.Icon:SetTexture(texture)
    self.Icon.Count:SetText((count~=0) and count)
    if duration then
      self.Icon.Cooldown:SetCooldown(GetTime(),  duration)
      self.Icon.Cooldown:SetReverse(true)
    else
      self.Icon.Cooldown:SetReverse(false)
    end
    self.Icon:Show()
  else
    self:SetBackdropBorderColor(0, 0, 0)
    self.Icon:Hide()
  end
end

local function createAuraWatch(self, unit)
  local corners = fuiDB.corners

  local auras = CreateFrame("Frame", nil, self)
  auras:SetAllPoints(self.Health)

  auras.presentAlpha = 1
  auras.missingAlpha = 0
  auras.icons = {}


  for i, corner in pairs(corners) do
    local icon = CreateFrame("Frame", nil, auras)
    icon.spellID = corner.spellID

    if corner.action == "HARMFUL" then
      icon.anyUnit = true
      icon:SetWidth(20)
      icon:SetHeight(20)
      icon:SetPoint("CENTER",0,0)
      --icon.Auras.PostCreateIcon = PostIcon
    else
      local tex = icon:CreateTexture(nil, "BACKGROUND")
      tex:SetAllPoints(icon)

      local cd = CreateFrame("Cooldown", nil, icon)
      cd:SetAllPoints(icon)
      cd:SetReverse()
      icon.cd = cd

      icon:SetWidth(corner.width)
      icon:SetHeight(corner.height)
      icon:SetPoint(corner.point, self.Health, 0, 0)
      tex:SetTexture(settings["Main"].Indicator)
      tex:SetVertexColor(unpack(corner.color))

      if corner.count == true then
        local count = icon:CreateFontString(nil, "OVERLAY")
        count:SetFont(settings["Main"].Font, 9, "THINOUTLINE")
        count:SetPoint(corner.point, -7, 0)
        icon.count = count
      end

      icon.icon = tex
    end
    auras.icons[corner.spellID] = icon
    auras.icons[corner.spellID]:Hide()
  end
  self.AuraWatch = auras
end

local function check_threat(self,event,unit)
  if unit then
    if self.unit ~= unit then
      return
    end
    if self.Aggro then
      local threat = UnitThreatSituation(unit)
      if threat == 3 then
        self.Aggro:SetText("|cffFF0000AGGRO")
      elseif threat == 2 then
        self.Aggro:SetText("|cffFFAA00THREAT")
      else
        self.Aggro:SetText("")
      end
    end
  end
end

local function updateHealth(self, unit, min, max)
  if (self.unit ~= unit) and unit then 
    return 
  end
  if UnitName(unit) then
    self:GetParent().Name:SetText(UnitName(unit):sub(1, 8))
  else
    self:GetParent().Name:SetText("oO")
  end

  if (UnitIsDead(unit) or UnitIsGhost(unit) or not UnitIsConnected(unit)) then
    self.value:SetText((UnitIsDead(unit) and "Dead") or (UnitIsGhost(unit) and "Ghost") or (not UnitIsConnected(unit) and "Offline"))
    self.value:SetTextColor(0.5, 0.5, 0.5)
    self:GetParent().Health:SetStatusBarColor(0.5, 0.5, 0.5)
  else
    self.value:SetText("")
    local color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
    if (color) then
      local r,g,b = color.r, color.g, color.b
      if string.find(string.lower(self.unit), "raidpet") then
        self.bg:SetVertexColor(0.2, 0.4, 0.4)
        self.bg:SetVertexColor(0.1, 0.2, 0.2)
      else
        if(max~=0 and min~= nil and max ~= nil) then
            r, g, b = oUF.ColorGradient(tonumber(min)/tonumber(max), 1, 0, 0, r, g, b, r, g, b) -- we color percent hp by color gradient from green to red
        end
        self:SetStatusBarColor(r*0.6, g*0.6, b*0.6)
        self.bg:SetVertexColor(r*0.2, g*0.2, b*0.2)
      end
    end
  end
end

local PostUpdatePower = function(bar, unit, min, max)
  local r, g, b = 1, 1, 1 -- manabar coloring
  if(opts.PowerColorByType==true) then
    local _, ptype = UnitPowerType(unit)
    if(opts["Power colors"][ptype]) then
      r, g, b = unpack(opts["Power colors"][ptype])
    end
  else
    r, g, b = unpack(opts.OwnPowerColor)
  end

  bar:SetStatusBarColor(r, g, b)
  bar.bg:SetVertexColor(r, g, b, .2)
end

local powerbar = function(self)
  local pp = CreateFrame("StatusBar")
  pp:SetStatusBarTexture(settings["Main"].Texture)
  pp:GetStatusBarTexture():SetHorizTile(true)
  pp:SetOrientation("VERTICAL")
  pp.colorPower = true
  
  pp.colorTapping = true
  pp.colorDisconnected = true
  pp.colorClass = true
  pp.frequentUpdates = true
  
  pp:SetParent(self)
  pp:SetPoint("TOPRIGHT", self,"TOPRIGHT", -1, -1)
  pp:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", -opts["raid"].ManaBarHeight, 1)

  local ppbg = pp:CreateTexture(nil, "BORDER")
  ppbg:SetAllPoints(pp)
  ppbg:SetTexture(settings["Main"].Texture)
  ppbg:SetVertexColor(.1,.1,.1)
  ppbg.multiplier = .2
  pp.bg = ppbg
  
  self.Power = pp
  self.Power.PostUpdate = PostUpdatePower
end

--[[------------------------------------------------]]

local stylefunc = function(self, unit)

  self:SetScript("OnEnter", UnitFrame_OnEnter)
  self:SetScript("OnLeave", UnitFrame_OnLeave)
  
  self:SetAttribute("initial-height", opts["raid"].Height)
  self:SetAttribute("initial-width", opts["raid"].Width)

  self.Health = CreateFrame("StatusBar",nil,self)
  self.Health:SetPoint("TOPLEFT",self,"TOPLEFT",1,-1)
  self.Health:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",-opts["raid"].ManaBarHeight-1 or -1,1)
  self.Health:SetStatusBarTexture(settings["Main"].Texture)
  self.Health:GetStatusBarTexture():SetHorizTile(true)
  self.Health:SetOrientation("VERTICAL")

  self:SetBackdrop{
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = false,
    tileSize = 0,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
  }
  
  self:SetBackdropColor(0, 0, 0)
  self:SetBackdropBorderColor(0, 0, 0)
  
  self.DebuffHighlight = self:CreateTexture(nil, "OVERLAY")
  self.DebuffHighlight:SetAllPoints(self)
  self.DebuffHighlight:SetTexture(fuiDB["Main"].Texture)
  self.DebuffHighlight:SetBlendMode("ADD")
  self.DebuffHighlight:SetVertexColor(1, 0, 0, 0) -- set alpha to 0 to hide the texture
  self.DebuffHighlightAlpha = 1
  self.DebuffHighlightFilter = false

  self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
  self.Health.bg:SetAllPoints(self.Health)
  self.Health.bg:SetTexture(settings["Main"].Texture)

  self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
  self.Health.value:SetPoint("BOTTOM", 0, 5)
  self.Health.value:SetFont(settings["Main"].Font, 10)
  self.Health.value:SetShadowOffset(1, -1)
  
  self.Name = self.Health:CreateFontString(nil, "OVERLEY")
  self.Name:SetPoint("LEFT", 2, 0)
  self.Name:SetPoint("RIGHT", -2, 0)
  self.Name:SetFont(settings["Main"].Font, settings["Main"].FontSize)
  self.Name:SetShadowColor(0,0,0)
  self.Name:SetShadowOffset(1.25, -1.25)
  self.Name:SetTextColor(1, 1, 1)

  self.Aggro = self.Health:CreateFontString(nil, "OVERLAY")
  self.Aggro:SetPoint("CENTER", self, "TOP")
  self.Aggro:SetFont(settings["Main"].Font, 8, "THINOUTLINE")
  self.Aggro:SetShadowColor(0, 0, 0)
  self.Aggro:SetShadowOffset(1.25, -1.25)
  self.Aggro:SetTextColor(1, 1, 1)
  
  -- debuff icons
  
  self.Icon = CreateFrame("Frame", nil, self.Health)
  self.Icon:SetPoint("CENTER")
  self.Icon:SetHeight(24)
  self.Icon:SetWidth(24)
  self.Icon:SetFrameStrata("MEDIUM")
  self.Icon:SetBackdrop{
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    tile = false,
    tileSize = 0,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 },
  }
  
  self.Icon.Icon = self.Icon:CreateTexture(nil, "OVERLAY")
  self.Icon.Icon:SetAllPoints(self.Icon)
  self.Icon.Icon:SetTexCoord(.1, .9, .1, .9)

  self.Icon.Count = self.Icon:CreateFontString(nil, "OVERLAY")
  self.Icon.Count:SetPoint("BOTTOMRIGHT", self.Icon, 1, 0)
  self.Icon.Count:SetFont(settings["Main"].Font, 10, "THINOUTLINE")
  self.Icon.Count:SetShadowColor(0, 0, 0, 0)
  self.Icon.Count:SetTextColor(1, 1, 1)

  self.Icon.Cooldown = CreateFrame("Cooldown",nil, self.Icon, "CooldownFrameTemplate")
  self.Icon.Cooldown:SetAllPoints(self.Icon)
  self.Icon.Cooldown:SetReverse(false)
  
  self.Icon:Hide()
  
  self.ReadyCheck = self.Health:CreateTexture(nil, "OVERLAY")
  self.ReadyCheck:SetPoint("CENTER", 0, 5)
  self.ReadyCheck:SetWidth(20)
  self.ReadyCheck:SetHeight(20)
  
  powerbar(self)
  
  self:RegisterEvent("UNIT_AURA", CheckDebuffs)
  self:RegisterEvent("UNIT_DEAD", CheckDebuffs)
  
  self:RegisterEvent("UNIT_DEAD", check_threat)
  self:RegisterEvent("PLAYER_TARGET_CHANGED", check_threat)
  self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", check_threat)
  self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", check_threat)

  local function update(self)
     if(not IsRaidLeader() and not IsRaidOfficer() and not IsPartyLeader()) then return end

     local status = GetReadyCheckStatus(self.unit)
     if(status) then
        self.ReadyCheck:SetTexture(statusTexture[status])
        self.ReadyCheck:SetAlpha(1)
        self.ReadyCheck:Show()
     end
  end
  
  local function prepare(self)
     local dummy = self.ReadyCheck.dummy

     dummy.unit = self.unit
     dummy.finish = 10
     dummy.fade = 1.5
    
     dummy:SetScript("OnUpdate", function(self, elapsed)
           if(self.finish) then
              self.finish = self.finish - elapsed
              if(self.finish <= 0) then
                 self.finish = nil
              end
           else
              self.fade = self.fade - elapsed
              if(self.fade <= 0) then
                 self.fade = nil
                 self:SetScript("OnUpdate", nil)

                 for _, v in next, oUF.objects do
                    if(v.ReadyCheck and v.unit == self.unit) then
                       v.ReadyCheck:Hide()
                    end
                 end
              else
                 for _, v in next, oUF.objects do
                    if(v.ReadyCheck and v.unit == self.unit) then
                       v.ReadyCheck:SetAlpha(self.fade / 1.5)
                    end
                 end
              end
           end
        end)
  end
  
  self:RegisterEvent("READY_CHECK", update)
  self:RegisterEvent("READY_CHECK_CONFIRM", update)
  self:RegisterEvent("READY_CHECK_FINISHED", prepare)

  self.ReadyCheck.dummy = CreateFrame("Frame", nil, self)

  if opts["Corner points"] == true then
    createAuraWatch(self,unit)
  end

  local ricon = self.Health:CreateTexture(nil, "OVERLAY")
  ricon:SetHeight(10)
  ricon:SetWidth(10)
  ricon:SetPoint("BOTTOM", self.Name, "TOP", 0, -1)
  ricon:SetTexture"Interface\\TargetingFrame\\UI-RaidTargetingIcons"
  self.RaidIcon = ricon

  self.Range = {
    insideAlpha = 1,
    outsideAlpha = 0.5,
  }

  self.Health.PostUpdate = updateHealth
  self.Health.Smooth = opts.Smooth
  
  -- self.DebuffHighlight = self.Health:CreateTexture(nil, "ARTWORK")
  -- self.DebuffHighlight:SetAllPoints(self.Health)
  -- self.DebuffHighlight:SetTexture(fuiDB["Main"].Texture)
  -- self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
  -- self.DebuffHighlight:SetBlendMode("ADD")
  -- self.DebuffHighlightAlpha = .5
  -- self.DebuffHighlightFilter = false

  return self
end


  
local module = {}
module.name = "Raid"
module.Init = function()
  if not fuiDB.modules[module.name] then return end
  settings = fuiDB
  opts = settings["UnitFrames"] or DefaultSettings["UnitFrames"]
  
  oUF:RegisterStyle("ouf_raid", stylefunc)
  oUF:SetActiveStyle("ouf_raid")

  local function make_me_movable(f)
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton","RightButton")
    f:SetScript("OnDragStart", function(self) 
      self:StartMoving() 
    end)
    f:SetScript("OnDragStop", function(self) 
      self:StopMovingOrSizing() 
      self:SetUserPlaced(true)
      local x, y = self:GetCenter()
      fuiDB[UnitName("player")].RaidposX = x
      fuiDB[UnitName("player")].RaidposY = y
    end)
  end

  local RaidDragFrame = CreateFrame("button","RaidDragFrame",UIParent)
  make_me_movable(RaidDragFrame)
  fuiDB[UnitName("player")] = fuiDB[UnitName("player")] or {}
  local x = fuiDB[UnitName("player")].RaidposX or 200
  local y = fuiDB[UnitName("player")].RaidposY or 500
  RaidDragFrame:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x, y)

  RaidDragFrame:SetWidth(10)
  RaidDragFrame:SetHeight(10)
  RaidDragFrame:SetAlpha(0)
  local t = RaidDragFrame:CreateTexture()
  t:SetTexture(settings["Main"].Indicator)
  t:SetAllPoints(RaidDragFrame)
  t:SetVertexColor(0,.9,.1)
  RaidDragFrame:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
  RaidDragFrame:SetScript("OnLeave", function(self) self:SetAlpha(0) end)
  
  RaidDragFrame:SetScript("OnDoubleClick", function(self) 
    if(oUF_Raid:IsShown()) then 
      oUF_Raid:Hide() 
      oUF_Pet:Hide() 
      RaidDragFrame:SetScript("OnEnter", nil)
      RaidDragFrame:SetScript("OnLeave", nil)
      RaidDragFrame:SetAlpha(1)
    else 
      oUF_Raid:Show() 
      oUF_Pet:Show() 
      RaidDragFrame:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
      RaidDragFrame:SetScript("OnLeave", function(self) self:SetAlpha(0) end)
    end 
  end)
  
  RaidDragFrame:Show()

  local raid = oUF:SpawnHeader("oUF_Raid", nil, nil,
    "showPlayer", true,
    "showSolo", opts["Show raid when solo"] or true,
    "showParty", true,
    "showRaid", true,
    "xoffset", 0,
    "yOffset", 0,
    "point", "TOP",
    "groupFilter", "1,2,3,4,5,6,7,8",
    "groupingOrder", "1,2,3,4,5,6,7,8",
    "groupBy", "GROUP",
    "maxColumns", opts["MaxGroups"] or 8,
    "unitsPerColumn", 5,
    "columnSpacing", 0,
    "columnAnchorPoint", "LEFT"
  )
  raid:SetPoint("TOPLEFT", RaidDragFrame, "TOPRIGHT", 0, 0)
  raid:SetClampedToScreen(true)
  raid:Show()
  
  if opts["Show raid when solo"] then
    local pets = oUF:SpawnHeader("oUF_Pet", "SecureGroupPetHeaderTemplate", nil,
      "showSolo", opts["Show raid when solo"],
      "showParty", true,
      "showRaid", true,
      "xoffset", 0,
      "yOffset", 0,
      "point", "TOP",
      "maxColumns", opts["MaxGroups"] or 8,
      "unitsPerColumn", 5,
      "columnSpacing", 0,
      "columnAnchorPoint", "LEFT"
    )
    pets:SetPoint("TOPLEFT", oUF_Raid, "TOPRIGHT", 0, 0)
    pets:SetClampedToScreen(true)
    pets:Show()
  end

end
tinsert(fui.modules, module) -- finish him!