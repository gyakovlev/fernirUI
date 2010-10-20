local module = {}
local settings = nil
local FBNLiteDB = nil
--
-- Feral by Night
-- An addon by Nightcrowler of Runetotem, with credits Yukizawa (creator of the original version of the Suggester frame -FaceMauler-) of Aggramar, Aytherine of Maelstrom

-- Our base array
FBNLite = {}
  
-- Feral by Night variables NOT SAVED

FBNLite.shreds_on_rips = {}
FBNLite.currentTime = GetTime()
FBNLite.cost = {}

FBNLite.L = {}

FBNLite.L["Rake"] = GetSpellInfo(48574)
FBNLite.L["Rake Debuff"] = GetSpellInfo(1822)
FBNLite.L["Rip"] = GetSpellInfo(49800)
FBNLite.L["Rip Debuff"] = GetSpellInfo(1079)
FBNLite.L["Mangle (Cat)"] = GetSpellInfo(48566)
FBNLite.L["Mangle (Cat) Debuff"] = GetSpellInfo(33983)
FBNLite.L["Mangle (Bear)"] = GetSpellInfo(48564)
FBNLite.L["Mangle (Bear) Debuff"] = GetSpellInfo(33987)
FBNLite.L["Trauma"] = GetSpellInfo(46854)
FBNLite.L["Faerie Fire"] = GetSpellInfo(770)
FBNLite.L["Clearcasting"] = GetSpellInfo(16870)
FBNLite.L["Savage Roar"] = GetSpellInfo(52610)
FBNLite.L["Tiger's Fury"] = GetSpellInfo(50213)
FBNLite.L["Berserk"] = GetSpellInfo(50334)
FBNLite.L["Shred"] = GetSpellInfo(48572)
FBNLite.L["Ferocious Bite"] = GetSpellInfo(48577)
FBNLite.L["Faerie Fire (Feral)"] = GetSpellInfo(16857)
FBNLite.L["Sting"] = GetSpellInfo(56631)
FBNLite.L["Lacerate"] = GetSpellInfo(48568)
FBNLite.L["Lacerate Debuff"] = GetSpellInfo(33745)
FBNLite.L["Maul"] = GetSpellInfo(48480)
FBNLite.L["Demoralizing Roar"] = GetSpellInfo(48560)
FBNLite.L["Demoralizing Roar Debuff"] = GetSpellInfo(99)
FBNLite.L["Demoralizing Shout"] = GetSpellInfo(25203)
FBNLite.L["Curse of Weakness"] = GetSpellInfo(50511)
FBNLite.L["Vindication"] = GetSpellInfo(26017)
FBNLite.L["Barkskin"] = GetSpellInfo(22812)
FBNLite.L["Survival Instincts"] = GetSpellInfo(61336)
FBNLite.L["Swipe (Bear)"] = GetSpellInfo(48562)
FBNLite.L["Growl"] = GetSpellInfo(6795)
FBNLite.L["Dire Bear Form"] = GetSpellInfo(9634)
FBNLite.L["Cat Form"] = GetSpellInfo(768)
FBNLite.L["Enrage"] = GetSpellInfo(5229)
FBNLite.L["Rend"] = GetSpellInfo(772)
FBNLite.L["Garrote"] = GetSpellInfo(703)
FBNLite.L["Rupture"] = GetSpellInfo(1943)
FBNLite.L["Pounce Bleed"] = GetSpellInfo(9007)
FBNLite.L["Savage Rend"] = GetSpellInfo(50498)
FBNLite.L["Rake (Pet)"] = GetSpellInfo(59881)
FBNLite.L["Deep Wounds"] = GetSpellInfo(12721)

FBNLite.timeSinceLastUpdate = 0
FBNLite.timeSinceLastUpdate_dps = 0

FBNLite.textureList = 
   {
      ["bottomleft"] = nil,
      ["middle"] = nil,
      ["bottomright"] = nil,
      ["topleft"] = nil,
      ["topright"] = nil,
   }
	
FBNLite.OoCtexture=nil;

function FBNLite:InitializeGUI()
   -- Create GUI
   FBNLite:CreateGUI()
   FBNLite.displayFrame:SetScale(FBNLiteDB.scale)
   FBNLite.OoCFrame:SetScale(FBNLiteDB.OoCscale)

   if FBNLiteDB.LockedUI then
      FBNLite.displayFrame:SetScript("OnMouseDown", nil)
      FBNLite.displayFrame:SetScript("OnMouseUp", nil)
      FBNLite.displayFrame:SetScript("OnDragStop", nil)
      FBNLite.displayFrame:SetBackdropColor(0, 0, 0, 0)
      FBNLite.displayFrame:EnableMouse(false)
      
      FBNLite.OoCFrame:SetScript("OnMouseDown", nil)
      FBNLite.OoCFrame:SetScript("OnMouseUp", nil)
      FBNLite.OoCFrame:SetScript("OnDragStop", nil)
      FBNLite.OoCFrame:SetBackdropColor(0, 0, 0, 0)
      FBNLite.OoCFrame:EnableMouse(false)
   else
      FBNLite.displayFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
      FBNLite.displayFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
      FBNLite.displayFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
      FBNLite.displayFrame:SetBackdropColor(0, 0, 0, .4)
      FBNLite.displayFrame:EnableMouse(true)
      
      FBNLite.OoCFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
      FBNLite.OoCFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
      FBNLite.OoCFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
      FBNLite.OoCFrame:SetBackdropColor(0, 0, 0, .4)
      FBNLite.OoCFrame:EnableMouse(true)
   end
end

function FBNLite:CreateGUI()
   local displayFrame = CreateFrame("Frame","FBNLiteDisplayFrame",UIParent)
   displayFrame:SetFrameStrata("LOW")
   displayFrame:SetWidth(250)
   displayFrame:SetHeight(90)
   displayFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32 })
  
   displayFrame:SetBackdropColor(0, 0, 0, .4)
   displayFrame:EnableMouse(true)
   displayFrame:SetMovable(true)
   displayFrame:SetClampedToScreen(true)
   displayFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
   displayFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
   displayFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
   
   local OoCFrame = CreateFrame("Frame","FBNLiteOoCFrame",UIParent)
   OoCFrame:SetFrameStrata("LOW")
   OoCFrame:SetWidth(128)
   OoCFrame:SetHeight(128)
   OoCFrame:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 32})

   OoCFrame:SetBackdropColor(0, 0, 0, .4)
   OoCFrame:EnableMouse(true)
   OoCFrame:SetMovable(true)
   OoCFrame:SetClampedToScreen(true)
   OoCFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
   OoCFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
   OoCFrame:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
   OoCFrame:SetPoint("CENTER",0,0)
 
   local displayFrame_last = CreateFrame("Frame","$parent_last", FBNLiteDisplayFrame)
   local displayFrame_current = CreateFrame("Frame","$parent_current", FBNLiteDisplayFrame)
   local displayFrame_next = CreateFrame("Frame","$parent_next", FBNLiteDisplayFrame)
   local displayFrame_misc = CreateFrame("Frame","$parent_misc", FBNLiteDisplayFrame)
   local displayFrame_int = CreateFrame("Frame","$parent_int", FBNLiteDisplayFrame)
   
   local t = OoCFrame:CreateTexture(nil,"LOW")
   t:SetTexture(nil)
   t:SetAllPoints(OoCFrame)
   t:SetAlpha(0.5)
   OoCFrame.texture = t
   FBNLite.OoCtexture = t

   displayFrame_last:SetWidth(45)
   displayFrame_current:SetWidth(70)
   displayFrame_next:SetWidth(45)
   displayFrame_misc:SetWidth(45)
   displayFrame_int:SetWidth(45)
   
   displayFrame_last:SetHeight(45)
   displayFrame_current:SetHeight(70)
   displayFrame_next:SetHeight(45)
   displayFrame_misc:SetHeight(45)
   displayFrame_int:SetHeight(45)

   displayFrame_last:SetPoint("TOPLEFT", 0, -48)
   displayFrame_current:SetPoint("TOPLEFT", 92, -10)
   displayFrame_next:SetPoint("TOPLEFT", 200, -48)
   displayFrame_misc:SetPoint("TOPLEFT", 0, 0)
   displayFrame_int:SetPoint("TOPLEFT", 200, 0)
   
   local t = displayFrame_last:CreateTexture(nil,"LOW")
   t:SetTexture(nil)
   t:SetAllPoints(displayFrame_last)
   t:SetAlpha(.8)
   displayFrame_last.texture = t
   FBNLite.textureList["bottomleft"] = t
   FBNLite.textureList["bottomleft"].back = displayFrame_last:CreateTexture(nil,"BACKGROUND")
   FBNLite.textureList["bottomleft"].back:SetPoint("TOPLEFT", t, "TOPLEFT", -1, 1)
   FBNLite.textureList["bottomleft"].back:SetPoint("BOTTOMRIGHT", t, "BOTTOMRIGHT", 1, -1)
   FBNLite.textureList["bottomleft"].back:SetTexture(0,0,0)
   
   t = displayFrame_current:CreateTexture(nil,"LOW")
   t:SetTexture(nil)
   t:ClearAllPoints()
   t:SetAllPoints(displayFrame_current)
   displayFrame_current.texture = t
   FBNLite.textureList["middle"] = t
   FBNLite.textureList["middle"].back = displayFrame_current:CreateTexture(nil,"BACKGROUND")
   FBNLite.textureList["middle"].back:SetPoint("TOPLEFT", t, "TOPLEFT", -1, 1)
   FBNLite.textureList["middle"].back:SetPoint("BOTTOMRIGHT", t, "BOTTOMRIGHT", 1, -1)
   FBNLite.textureList["middle"].back:SetTexture(0,0,0)

   t = displayFrame_next:CreateTexture(nil,"LOW")
   t:SetTexture(nil)
   t:SetAllPoints(displayFrame_next)
   t:SetAlpha(.8)
   displayFrame_next.texture = t
   FBNLite.textureList["bottomright"] = t
   FBNLite.textureList["bottomright"].back = displayFrame_next:CreateTexture(nil,"BACKGROUND")
   FBNLite.textureList["bottomright"].back:SetPoint("TOPLEFT", t, "TOPLEFT", -1, 1)
   FBNLite.textureList["bottomright"].back:SetPoint("BOTTOMRIGHT", t, "BOTTOMRIGHT", 1, -1)
   FBNLite.textureList["bottomright"].back:SetTexture(0,0,0)
   
   t = displayFrame_misc:CreateTexture(nil,"LOW")
   t:SetTexture(nil)
   t:SetAllPoints(displayFrame_misc)
   t:SetAlpha(.8)
   displayFrame_misc.texture = t
   FBNLite.textureList["topleft"] = t
   FBNLite.textureList["topleft"].back = displayFrame_misc:CreateTexture(nil,"BACKGROUND")
   FBNLite.textureList["topleft"].back:SetPoint("TOPLEFT", t, "TOPLEFT", -1, 1)
   FBNLite.textureList["topleft"].back:SetPoint("BOTTOMRIGHT", t, "BOTTOMRIGHT", 1, -1)
   FBNLite.textureList["topleft"].back:SetTexture(0,0,0)
   
   t = displayFrame_int:CreateTexture(nil,"LOW")
   t:SetTexture(nil)
   t:SetAllPoints(displayFrame_int)
   t:SetAlpha(.8)
   displayFrame_int.texture = t
   FBNLite.textureList["topright"] = t
   FBNLite.textureList["topright"].back = displayFrame_int:CreateTexture(nil,"BACKGROUND")
   FBNLite.textureList["topright"].back:SetPoint("TOPLEFT", t, "TOPLEFT", -1, 1)
   FBNLite.textureList["topright"].back:SetPoint("BOTTOMRIGHT", t, "BOTTOMRIGHT", 1, -1)
   FBNLite.textureList["topright"].back:SetTexture(0,0,0)



   displayFrame:SetScript(
      "OnUpdate", 
      function(this, elapsed)
         FBNLite:OnUpdate(elapsed)
      end)

   FBNLite.displayFrame = displayFrame
   
   FBNLite.displayFrame_last = displayFrame_last
   FBNLite.displayFrame_current = displayFrame_current
   FBNLite.displayFrame_next = displayFrame_next
   FBNLite.displayFrame_misc =  displayFrame_misc
   FBNLite.displayFrame_int =  displayFrame_int
   FBNLite.OoCFrame = OoCFrame

   if FBNLiteDB.OoCframeshow == false then
      FBNLite.OoCFrame:Hide()
   else
      FBNLite.OoCFrame:Show()
   end
   
   SuggestionFrameSetVisibility(FBNLiteDB.SuggesterFrameShow)
end

function SuggestionFrameHide() 
   FBNLite.displayFrame_last:Hide()
   FBNLite.displayFrame_current:Hide()
   FBNLite.displayFrame_next:Hide()
   FBNLite.displayFrame_misc:Hide()
   FBNLite.displayFrame_int:Hide()
end

function SuggestionFrameShow()
   FBNLite.displayFrame_last:Show()
   FBNLite.displayFrame_current:Show()
   FBNLite.displayFrame_next:Show()
   FBNLite.displayFrame_misc:Show()
   FBNLite.displayFrame_int:Show()
end

function SuggestionFrameSetVisibility(visible)
   if visible then
      SuggestionFrameShow()
   else
      SuggestionFrameHide()
   end
end 

function OoCFrameSetVisibility(visible)
   if visible then
      FBNLite.OoCFrame:Show()
   else
      FBNLite.OoCFrame:Hide()
   end
end

function OoCFrameSetTexture(active)
   if (active) then
      FBNLite.OoCtexture:SetTexture("Interface\\AddOns\\FBNLite\\clearcast.tga")
   else
      FBNLite.OoCtexture:SetTexture(nil)
   end
end


-- Our sneaky frame to watch for events ... checks FBNLite.events[] for the function.  Passes all args.
FBNLite.eventFrame = CreateFrame("Frame")
FBNLite.eventFrame:SetScript(
   "OnEvent", 
   function(this, event, ...)
      FBNLite.events[event](...)
   end)

-- To check if we are on 80 lvl druid and disable the addon otherwise. 
--[[ 
   To monitor Shred and Rip casts in order to correctly deduce if another 
   Shred can extend Rip. Yes, this seems like an overkill, but you cannot 
   deduce it from the Rip bleed duration as it is calculated really weirdly :-/
--]]
FBNLite.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

-- Define our Event Handlers here
FBNLite.events = {}


function FBNLite.events.COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName)
   if sourceGUID ~= UnitGUID("player") then 
      return 
   end
   if event == "SPELL_AURA_APPLIED" and spellName == FBNLite.L["Rip"] then
      -- set the number of shreds on this rip to 0
      FBNLite.shreds_on_rips[destGUID] = 0   
   elseif event == "SPELL_AURA_REMOVED" and spellName == FBNLite.L["Rip"] then 
      -- delete table key with this guid
      FBNLite.shreds_on_rips[destGUID] = nil
   elseif event == "SPELL_DAMAGE" and spellName == FBNLite.L["Shred"] and FBNLite.shreds_on_rips[destGUID] then
      FBNLite.shreds_on_rips[destGUID] = FBNLite.shreds_on_rips[destGUID] + 1      
   end  

--   print(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags) 
end

function FBNLite:InitializeDB()
  -- Default saved variables
   if not FBNLiteDB then
      if not fuiDB["Feral by Night"] then fuiDB["Feral by Night"] = {} end
   	FBNLiteDB = fuiDB["Feral by Night"] -- fresh start
   end
 
   if FBNLiteDB.anchor == nil then FBNLiteDB.anchor = true end
   if FBNLiteDB.badspec == nil then FBNLiteDB.spec1 = true end
   if FBNLiteDB.spec1 == nil then FBNLiteDB.spec1 = true end
   if FBNLiteDB.spec2 == nil then FBNLiteDB.spec2 = true end
   if not FBNLiteDB.scale then FBNLiteDB.scale = 0.70 end
   if not FBNLiteDB.LagCorrection then FBNLiteDB.LagCorrection = true end
   
   if not FBNLiteDB.OoCscale then FBNLiteDB.OoCscale = 2 end
   if FBNLiteDB.LockedUI == nil then FBNLiteDB.LockedUI = true end
   if FBNLiteDB.showPrediction == nil then FBNLiteDB.showPrediction = true end
   
   if FBNLiteDB.SuggesterFrameShow == nil then FBNLiteDB.SuggesterFrameShow = true end
   if FBNLiteDB.OoCFrameShow == nil then FBNLiteDB.OoCFrameShow = true end
end

function FBNLite:OnUpdate(elapsed)
   if FBNLiteDB.anchor then
      FBNLite.displayFrame:SetPoint("BOTTOM", oUF_player, "TOP", 0, 32)
   else
      FBNLite.displayFrame:SetPoint("BOTTOM",0,260)
   end
   
   local spec = GetActiveTalentGroup(isInspect);
   local showForThisSpec = (FBNLiteDB.spec1 and spec == 1) or (FBNLiteDB.spec2 and spec == 2) 

   if not showForThisSpec then
      SuggestionFrameHide()
      OoCFrameSetVisibility(false)
      return
   end 

   local	name = UnitAura("player", FBNLite.L["Clearcasting"]); 
   OoCFrameSetTexture(name ~= nil)
   
   local catform = UnitAura("player", FBNLite.L["Cat Form"]); 
   local bearform = UnitAura("player", FBNLite.L["Dire Bear Form"]);
   local showSuggestionFrame = (UnitName("target") ~= nil and UnitIsFriend("player","target") == nil and UnitHealth("target") > 0 and ((catform ~= nil) or (bearform ~= nil)))
   
   SuggestionFrameSetVisibility(showSuggestionFrame or not FBNLiteDB.LockedUI)
   OoCFrameSetVisibility(FBNLiteDB.OoCFrameShow or not FBNLiteDB.LockedUI)

   if showSuggestionFrame then
      FBNLite:DecideSpells()
   end

   if not FBNLiteDB.LockedUI then
      OoCFrameSetTexture(true)
      FBNLite:SetTexture("middle", "Mangle (Cat)", true)
      FBNLite:SetTexture("topleft", "Tiger's Fury", true)
      FBNLite:SetTexture("bottomleft", "Berserk", true)
      FBNLite:SetTexture("topright", "Mangle (Cat)", true)
      FBNLite:SetTexture("bottomright", "Mangle (Cat)", true)
   end      
end

function FBNLite:GetPowerCost(SpellName)
    local _, _, _, powerCost = GetSpellInfo(FBNLite.L[SpellName])
    return powerCost
end

--[[ 
   Function to obtain remaining time on debuff and number of its stacks.
   If more than one debuff is specified, only the longest one is returned.
   Also includes an optional check to only permitt debuffs cast by you.
   
   You gotta love refactoring code with lot of repetitions :)
--]]
function FBNLite:GetRemainingDebuffTimeAndStacks(onlyMine, ...)
   local longest = 0
   local stacks = 0
   local argc = select('#', ...)
        
   for i = 1, argc do
      local name, _, _, stackCount, _, _, expirationTime, caster = UnitDebuff("target", FBNLite.L[select(i, ...)]); 
      if name ~= nil and (not onlyMine or caster == "player") then
         local rt = expirationTime - FBNLite.currentTime
         if rt > longest then
            longest = rt
            stacks = stackCount
         end
      end
   end
   return longest, stacks
end

-- Function to obtain cooldown of a spell.
function FBNLite:GetSpellCD(spellName)
   local start, duration = GetSpellCooldown(FBNLite.L[spellName]);
   local cd = 0
   if duration ~= nil then
      cd = duration + start - FBNLite.currentTime	
   end
   return cd   
end

-- Function to obtain remaining time on a self buff
function FBNLite:GetRemainingBuffTime(spellName)
   local rt = 0
   local name, _, _, _, _, _, expirationTime = UnitAura("player", FBNLite.L[spellName]);
   if name ~= nil then
   	rt = expirationTime - FBNLite.currentTime
   end
   return rt
end

-- Realtime ability cost update.
function FBNLite:UpdateAbilityCost()
   FBNLite.cost.mangle        = FBNLite:GetPowerCost("Mangle (Cat)")
   FBNLite.cost.shred         = FBNLite:GetPowerCost("Shred")
   FBNLite.cost.rake          = FBNLite:GetPowerCost("Rake")
   FBNLite.cost.rip           = FBNLite:GetPowerCost("Rip")
   FBNLite.cost.sr            = FBNLite:GetPowerCost("Savage Roar")
   FBNLite.cost.fb            = FBNLite:GetPowerCost("Ferocious Bite")
   FBNLite.cost.mangle_bear   = FBNLite:GetPowerCost("Mangle (Bear)")
   FBNLite.cost.lacerate      = FBNLite:GetPowerCost("Lacerate")
   FBNLite.cost.demoshout     = FBNLite:GetPowerCost("Demoralizing Roar")
   FBNLite.cost.swipe         = FBNLite:GetPowerCost("Swipe (Bear)")
end

-- Set texture of a frame to particular spell or nil based on a condition.
function FBNLite:SetTexture(frame, spell, condition)
   if (condition) then 
      FBNLite.textureList[frame]:SetTexture(GetSpellTexture(FBNLite.L[spell]))
      FBNLite.textureList[frame]:SetTexCoord(.1,.9,.1,.9)
   else
      FBNLite.textureList[frame]:SetTexture(nil)
   end         
end

-- Adjusts all keys in table tb by specified adjustment
function FBNLite:AdjustKeys(tb, adjustment, ...)
   for i = 1, select('#', ...) do
      local key = select(i, ...)
      tb[key] = tb[key] + adjustment
   end
end

function FBNLite:DecideSpells()
   local guid = UnitGUID("target")
   local catform = UnitAura("player", FBNLite.L["Cat Form"]); 
   local bearform = UnitAura("player", FBNLite.L["Dire Bear Form"]);

   -- We are not in bearform or catform or we are not targeting anything. Clear textures.
   if (guid == nil or (catform == nil and bearform == nil)) then
      FBNLite:SetTexture("bottomleft", nil, false)
      FBNLite:SetTexture("bottomright", nil, false)
      FBNLite:SetTexture("topleft", nil, false)
      FBNLite:SetTexture("topright", nil, false)
      FBNLite:SetTexture("middle", nil, false)
      return
   end
   
   FBNLite.currentTime = GetTime()
   FBNLite:UpdateAbilityCost()
   
   -- State variables common for bear and cat:
   local state = {}
   state.boss_target = (UnitLevel("target") == -1) 
   state.fffdur = FBNLite:GetRemainingDebuffTimeAndStacks(false, "Faerie Fire (Feral)", "Sting", "Faerie Fire", "Curse of Weakness")
   state.fff = FBNLite:GetSpellCD("Faerie Fire (Feral)")
   state.OoC = FBNLite:GetRemainingBuffTime("Clearcasting")
	state.berserk = FBNLite:GetSpellCD("Berserk")
   state.GCD =  math.max(0, FBNLite:GetSpellCD("Faerie Fire"))
	

   if FBNLiteDB.LagCorrection then
      local _, _, latency = GetNetStats();
      -- max lag is 500ms, lag granularity is 50ms (so that it doesn't fluctuate much...)
      state.lag = math.ceil( math.min(latency / 1000, 0.5) / 0.05) * 0.05
   else
      state.lag = 0
   end
   
   -- call apropriate decide spell function 
   if (catform ~= nil) then
      FBNLite:DecideCatformSpells(state)
   elseif (bearform ~= nil) then
      FBNLite:DecideBearformSpells(state)
   end
end

function FBNLite:DecideBearformSpells(state)
   -- set state variables
   state.rage = UnitPower("player", 1)
	state.lacerate, state.lacerate_stack =  FBNLite:GetRemainingDebuffTimeAndStacks(true, "Lacerate Debuff")
	state.demoshout =  FBNLite:GetRemainingDebuffTimeAndStacks(false, "Demoralizing Roar Debuff", "Demoralizing Shout", "Curse of Weakness", "Vindication")
--	state.growl = FBNLite:GetSpellCD("Growl")
   _, state.tanking_status = UnitDetailedThreatSituation("player","target")
	state.mangle_bear = FBNLite:GetSpellCD("Mangle (Bear)")
   
   -- get suggested spell
   local spell = FBNLite:NextBearformSpell(state)
   
   -- set textures
   FBNLite:SetTexture("middle", spell, spell ~= "empty")
   FBNLite:SetTexture("bottomleft", "Berserk", FBNLite:GetSpellCD("Berserk") < 1)
   FBNLite:SetTexture("bottomright", "Survival Instincts", FBNLite:GetSpellCD("Survival Instincts") < 1)
   FBNLite:SetTexture("topright", "Barkskin", FBNLite:GetSpellCD("Barkskin") < 1)
   FBNLite:SetTexture("topleft", "Enrage", FBNLite:GetSpellCD("Enrage") < 1)
end

function FBNLite:NextBearformSpell(st)
   -- We are targeting boss while not tanking him, suggest growl. 
   -- This can be bogus if you are an offtank and you need to generate as much threat as possible
   -- without actually taunting the boss (Lady Deathwhisper HC). Comment this section in that case. 
--   if (not st.is_tanking and st.boss_target and st.growl < st.lag) then   
--      return "Growl"
   -- We are targeting (tanking) boss and demoshout is not on. Apply it as it significantly reduces the boss' damage.
   if (st.demoshout < 3 + st.GCD and st.boss_target and st.tanking_status == 3) then
      return "Demoralizing Roar"
   -- Mangle is ready after this GCD.
   elseif (st.mangle_bear < st.lag + st.GCD) then
      return "Mangle (Bear)"
   -- Faerie Fire is ready after this GCD. 
   elseif (st.fff < st.lag + st.GCD) then
      return "Faerie Fire (Feral)"
   -- Lacerate has not 5 stacks or is about to fall off in this or next Mangle-FF cycle. Refresh it.
   elseif (st.lacerate <= 7.5 or st.lacerate_stack < 5) then
      return "Lacerate"
   elseif (st.demoshout < 3 + st.GCD and st_boss_target) then
      return "Demoralizing Roar"
   else   -- Filler attack.
      return "Swipe (Bear)"
   end
end

-- Just an utility function to copy a table by value. 
function table.copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function FBNLite:DecideCatformSpells(state)    
   local shreds_on_rip = FBNLite.shreds_on_rips[UnitGUID("target")]
  
   state.energy = UnitPower("player", 3)
   state.cp = GetComboPoints("player")
   state.rake = FBNLite:GetRemainingDebuffTimeAndStacks(true, "Rake Debuff")
   state.rip = FBNLite:GetRemainingDebuffTimeAndStacks(true, "Rip Debuff")
   state.mangle = FBNLite:GetRemainingDebuffTimeAndStacks(false, "Mangle (Cat) Debuff", "Mangle (Bear) Debuff", "Trauma")
   state.sr = FBNLite:GetRemainingBuffTime("Savage Roar")      
   state.tf = FBNLite:GetSpellCD("Tiger's Fury")
   state.can_extend_rip = 0
  
   if shreds_on_rip then 
      state.can_extend_rip = 3 - shreds_on_rip
   end

   -- get suggested spell
   spell = FBNLite:NextCatformSpell(state)
   
   -- get +1 move prediction 
   if FBNLiteDB.showPrediction then
      -- a special case for TF since it is off GCD and adds energy
      if spell == "Tiger's Fury" then
         -- Add energy and adjust timers by a reaction time (well, by a lag since that is bigger factor...)
         FBNLite:AdjustKeys(state, 60, "energy")
         FBNLite:AdjustKeys(state, -state.lag, "mangle", "sr", "rip", "rake", "fff", "fffdur", "berserk", "OoC")
         nextSpell1CP = FBNLite:NextCatformSpell(state)
         nextSpell2CP = nextSpell1CP
      else 
         -- compute energy discount coefficient
         local OoC = 1 
         if (state.OoC > 0) then OoC = 0 end
      
         -- We are 1 second (= 1 GCD) ahead, decrease remaining time on buffs, 
         -- debuffs and CDs by 1 second and increase available energy by 10.
         FBNLite:AdjustKeys(state, -1, "mangle", "sr", "rip", "rake", "fff", "fffdur", "berserk", "OoC")
         FBNLite:AdjustKeys(state, 10, "energy")
         FBNLite:AdjustKeys(state, -state.OoC, "OoC")
         -- cp generators
         if spell == "Mangle (Cat)" or spell == "Shred" or spell == "Rake" then 
            if spell == "Mangle (Cat)" then
               FBNLite:AdjustKeys(state, 60, "mangle")
               FBNLite:AdjustKeys(state, -FBNLite.cost.mangle * OoC, "energy")
            elseif spell == "Shred" then
               FBNLite:AdjustKeys(state, -1, "can_extend_rip")
               FBNLite:AdjustKeys(state, -FBNLite.cost.shred * OoC, "energy")
            elseif spell == "Rake" then
               FBNLite:AdjustKeys(state, 9, "rake")
               FBNLite:AdjustKeys(state, -FBNLite.cost.rake * OoC, "energy")
            end
            -- 1 cp
            FBNLite:AdjustKeys(state, 1, "cp")
            nextSpell1CP = FBNLite:NextCatformSpell(state)
            -- 2 cps
            FBNLite:AdjustKeys(state, 1, "cp")
            nextSpell2CP = FBNLite:NextCatformSpell(state)
         -- non-cp generating abilities: finishers, energy pooling and faerie fire
         else
            if spell == "Faerie Fire (Feral)" then
               FBNLite:AdjustKeys(state, 300, "fffdur")
               FBNLite:AdjustKeys(state, 6, "fff")
            -- finishers, no need to do anything special for energy pooling ("empty")
            elseif spell ~= "empty" then
               -- Set cp to 0 or < 0 if we did sr with less than 5cps.
               FBNLite:AdjustKeys(state, -5, "cp")
               if spell == "Rip" then
                  FBNLite:AdjustKeys(state, 12, "rip")
                  FBNLite:AdjustKeys(state, -FBNLite.cost.rip * OoC, "energy")
               elseif spell == "Savage Roar" then
                  FBNLite:AdjustKeys(state, 9 + state.cp * 5, "sr")
                  -- no OoC discount since Savage Roar ignores OoC!
                  FBNLite:AdjustKeys(state, -FBNLite.cost.sr, "energy")
               else -- spell == "Ferocious Bite"
                  FBNLite:AdjustKeys(state, -(FBNLite.cost.fb * OoC + math.min(30, state.energy - FBNLite.cost.fb * OoC)), "energy")
               end
            end
            -- Get next ability. Maybe it would look better if the second was empty? 
            nextSpell1CP = FBNLite:NextCatformSpell(state)
            nextSpell2CP = nextSpell1CP                
         end
      end
   end
   
   -- update textures
   FBNLite:SetTexture("middle", spell, spell ~= "empty")
   FBNLite:SetTexture("topleft", "Tiger's Fury", state.tf < state.lag + state.GCD)
   FBNLite:SetTexture("bottomleft", "Berserk", state.berserk < state.lag + state.GCD)
   FBNLite:SetTexture("topright", nextSpell1CP, nextSpell1CP ~= "empty")
   FBNLite:SetTexture("bottomright", nextSpell2CP, nextSpell2CP ~= "empty")
end

--[[
Based on this adjusted priority list (removed time_to_death conditions)

actions+=/faerie_fire_feral,debuff_only=1
actions+=/tigers_fury,energy<=40,berserk=0
actions+=/savage_roar,cp>=1,savage_roar<=1
actions+=/savage_roar,if=buff.combo_points.stack>=3&buff.savage_roar.remains-dot.rip.remains<=3&buff.savage_roar.remains<=9
actions+=/shred,cp<=4,extend_rip=1,rip<=3
actions+=/rip,cp>=5
actions+=/ferocious_bite,cp>=5,rip>=8,savage_roar>=11
actions+=/mangle_cat,mangle<=1
actions+=/rake 
actions+=/shred,if=(energy>=80|buff.omen_of_clarity.up|buff.berserk.up|cooldown.tigers_fury.remains<=3)
actions+=/shred,cp<=0,savage_roar<=2
--]]
function FBNLite:NextCatformSpell(st)
   local cost = FBNLite.cost
   local OoC = 0;
   local lgcd = st.lag + st.GCD

   if (st.OoC > lgcd) then OoC = 1 end
   -- keep Faerie Fire up, maximum priority since it boosts damage of every melee/hunter and tank threat generation
   if (st.boss_target and st.fff < lgcd and st.fffdur < 2 + lgcd) then 
      return "Faerie Fire (Feral)"
   elseif (st.tf < st.lag and st.energy < (40 - 10 * (OoC + lgcd)) and st.berserk < 165) then
      return "Tiger's Fury"
   elseif ((st.sr < 1 + lgcd and st.cp > 0) or (st.cp > 2 and (st.sr - st.rip) < 3 and (st.sr < 9 + lgcd))) then
      return FBNLite:HaveEnoughEnergyFor("Savage Roar", st, cost.sr)
   elseif (st.cp < 5 and st.can_extend_rip > 0 and st.rip < 4 + lgcd) then
      return FBNLite:HaveEnoughEnergyFor("Shred", st, cost.shred)
   elseif (st.rip < lgcd and st.cp == 5) then
      return FBNLite:HaveEnoughEnergyFor("Rip", st, cost.rip)
   elseif (st.cp == 5 and st.rip > 8 and st.sr > 11 and st.berserk < 165) then -- FB when not berserking
      return FBNLite:HaveEnoughEnergyFor("Ferocious Bite", st, cost.fb)
   elseif (st.cp == 5 and st.rip > 8 and st.sr > 11 and st.berserk < 167) then
      return FBNLite:HaveEnoughEnergyFor("Ferocious Bite", st, cost.fb) 
   elseif (st.cp == 5 and st.rip > 4 and st.sr > 7 and (st.berserk - 165) * 10 + st.energy > (st.berserk - 165) * cost.shred + 30) then
      return FBNLite:HaveEnoughEnergyFor("Ferocious Bite", st, cost.fb) 
   elseif (st.mangle < 1 + lgcd) then
      return FBNLite:HaveEnoughEnergyFor("Mangle (Cat)", st, cost.mangle)
   elseif (st.rake < lgcd) then
      return FBNLite:HaveEnoughEnergyFor("Rake", st, cost.rake)
   elseif (st.energy > 80 - 10 * lgcd or OoC == 1 or st.berserk > 165 or st.tf < 3 + lgcd) then -- filler attack, but try to pool energy if necessary
      return FBNLite:HaveEnoughEnergyFor("Shred", st, cost.shred)
   else
      return "empty"
   end
end

function FBNLite:HaveEnoughEnergyFor(spell, st, needEnergy)
   local lgcd = st.lag + st.GCD
   if (st.energy + lgcd >= needEnergy or (needEnergy == 0 and (st.OoC > lgcd))) then 
      return spell
   else 
      return "empty"
   end
end

module.name = "Feral by Night"
module.Init = function()

   FBNLite:InitializeDB()
	
	if not fuiDB.modules[module.name] then return end

   settings = fuiDB.settings
   
   local _,playerClass = UnitClass("player")
   local playerlevel = UnitLevel("player")
   
   if (playerClass ~= "DRUID" or playerlevel < 80) then
      print("FBNLite: You have to be a level 80 druid to be able to use this addon.")
      FBNLite.eventFrame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
      return 
   end

   FBNLite:InitializeGUI()
   
   -- Register for Slash Commands
   SlashCmdList["FBNLite"] = FBNLite.Options
   SLASH_FBNLite1 = "/fbnlite"
   SLASH_FBNLite2 = "/fbn"
   
   print("FBNLite succesfully loaded. /fbn or /fbnlite for options.")

end
tinsert(fui.modules, module) -- finish him!