local settings = nil
local _, class = UnitClass("player")
    
local spells =  {
  -- WARRIOR
  [GetSpellInfo(47486)]	= "Arms",			-- Mortal Strike
  [GetSpellInfo(46924)]	= "Arms",			-- Bladestorm
  [GetSpellInfo(23881)]	= "Fury",			-- Bloodthirst
  [GetSpellInfo(12809)]	= "Protection",		-- Concussion Blow
  [GetSpellInfo(47498)]	= "Protection",		-- Devastate
  -- PALADIN
  [GetSpellInfo(48827)]	= "Protection",		-- Avenger's Shield
  [GetSpellInfo(48825)]	= "Holy",			-- Holy Shock
  [GetSpellInfo(35395)]	= "Retribution",	-- Crusader Strike
  [GetSpellInfo(53385)]	= "Retribution",	-- Divine Storm
  [GetSpellInfo(20066)]	= "Retribution",	-- Repentance
  -- ROGUE
  [GetSpellInfo(48666)]	= "Assassination",	-- Mutilate
  [GetSpellInfo(51690)]	= "Combat",			-- Killing Spree
  [GetSpellInfo(13877)]	= "Combat",			-- Blade Flurry
  [GetSpellInfo(13750)]	= "Combat",			-- Adrenaline Rush
  [GetSpellInfo(48660)]	= "Subtlety",		-- Hemorrhage
  -- PRIEST
  [GetSpellInfo(53007)]	= "Discipline",		-- Penance
  [GetSpellInfo(10060)]	= "Discipline",		-- Power Infusion
  [GetSpellInfo(33206)]	= "Discipline",		-- Pain Suppression
  [GetSpellInfo(34861)]	= "Holy",			-- Circle of Healing
  [GetSpellInfo(15487)]	= "Shadow",			-- Silence
  [GetSpellInfo(48160)]	= "Shadow",			-- Vampiric Touch
  -- DEATHKNIGHT
  [GetSpellInfo(55262)]	= "Blood",			-- Heart Strike
  [GetSpellInfo(49203)]	= "Frost",			-- Hungering Cold
  [GetSpellInfo(55268)]	= "Frost",			-- Frost Strike
  [GetSpellInfo(51411)]	= "Frost",			-- Howling Blast
  [GetSpellInfo(55271)]	= "Unholy",			-- Scourge Strike
  -- MAGE
  [GetSpellInfo(44781)]	= "Arcane",			-- Arcane Barrage
  [GetSpellInfo(55360)]	= "Fire",			-- Living Bomb
  [GetSpellInfo(42950)]	= "Fire",			-- Dragon's Breath
  [GetSpellInfo(42945)]	= "Fire",			-- Blast Wave
  [GetSpellInfo(44572)]	= "Frost",			-- Deep Freeze
  -- WARLOCK
  [GetSpellInfo(59164)]	= "Affliction",		-- Haunt
  [GetSpellInfo(47843)]	= "Affliction",		-- Unstable Affliction
  [GetSpellInfo(59672)]	= "Demonology",		-- Metamorphosis
  [GetSpellInfo(59172)]	= "Destruction",	-- Chaos Bolt
  [GetSpellInfo(47847)]	= "Destruction",	-- Shadowfury
  -- SHAMAN
  [GetSpellInfo(59159)]	= "Elemental",		-- Thunderstorm
  [GetSpellInfo(16166)]	= "Elemental",		-- Elemental Mastery
  [GetSpellInfo(51533)]	= "Enhancement",	-- Feral Spirit
  [GetSpellInfo(30823)]	= "Enhancement",	-- Shamanistic Rage
  [GetSpellInfo(17364)]	= "Enhancement",	-- Stormstrike
  [GetSpellInfo(61301)]	= "Restoration",	-- Riptide
  [GetSpellInfo(51886)]	= "Restoration",	-- Cleanse Spirit
  -- HUNTER
  [GetSpellInfo(19577)]	= "Beast Mastery",	-- Intimidation
  [GetSpellInfo(34490)]	= "Marksmanship",	-- Silencing Shot
  [GetSpellInfo(53209)]	= "Marksmanship",	-- Chimera Shot
  [GetSpellInfo(60053)]	= "Survival",		-- Explosive Shot
  [GetSpellInfo(49012)]	= "Survival",		-- Wyvern Sting
  -- DRUID
  [GetSpellInfo(53201)]	= "Balance",		-- Starfall
  [GetSpellInfo(61384)]	= "Balance",		-- Typhoon
  [GetSpellInfo(48566)]	= "Feral",			-- Mangle (Cat)
  [GetSpellInfo(48564)]	= "Feral",			-- Mangle (Bear)
  [GetSpellInfo(18562)]	= "Restoration",		-- Swiftmend
}

local buffs = { -- credits Proditor, Rinu
  -- WARRIOR
  [GetSpellInfo(56638)]	= "Arms",			-- Taste for Blood
  [GetSpellInfo(64976)]	= "Arms",			-- Juggernaut
  [GetSpellInfo(29801)]	= "Fury",			-- Rampage
  [GetSpellInfo(50227)]	= "Protection",		-- Sword and Board
  -- PALADIN
  [GetSpellInfo(20375)]	= "Retribution",	-- If you are using Seal of Command, I hate you so much
  [GetSpellInfo(31836)]	= "Holy",			-- Light's Grace
  -- ROGUE
  [GetSpellInfo(36554)]	= "Subtlety",		-- Shadowstep
  [GetSpellInfo(31223)]	= "Subtlety",		-- Master of Subtlety
  -- PRIEST
  [GetSpellInfo(47788)]	= "Holy",			-- Guardian Spirit
  [GetSpellInfo(52800)]	= "Discipline",		-- Borrowed Time
  [GetSpellInfo(15473)]	= "Shadow",			-- Shadowform
  [GetSpellInfo(15286)]	= "Shadow",			-- Vampiric Embrace
  -- DEATHKNIGHT
  [GetSpellInfo(49222)]	= "Unholy",			-- Bone Shield
  [GetSpellInfo(49016)]	= "Blood",			-- Hysteria
  [GetSpellInfo(53138)]	= "Blood",			-- Abomination's Might
  [GetSpellInfo(55610)]	= "Frost",			-- Imp. Icy Talons
  -- MAGE
  [GetSpellInfo(43039)]	= "Frost",			-- Ice Barrier
  [GetSpellInfo(11129)]	= "Fire",			-- Combustion
  [GetSpellInfo(31583)]	= "Arcane",			-- Arcane Empowerment
  -- WARLOCK
  [GetSpellInfo(30302)]	= "Destruction",	-- Nether Protection
  -- SHAMAN
  [GetSpellInfo(57663)]	= "Elemental",		-- Totem of Wrath
  [GetSpellInfo(49284)]	= "Restoration",	-- Earth Shield
  [GetSpellInfo(51470)]	= "Elemental",		-- Elemental Oath
  [GetSpellInfo(30809)]	= "Enhancement",	-- Unleashed Rage
  -- HUNTER
  [GetSpellInfo(20895)]	= "Beast Mastery",	-- Spirit Bond
  [GetSpellInfo(19506)]	= "Marksmanship",	-- Trueshot Aura
  -- DRUID
  [GetSpellInfo(24932)]	= "Feral",			-- Leader of the Pack
  [GetSpellInfo(34123)]	= "Restoration",	-- Tree of Life
  [GetSpellInfo(24907)]	= "Balance",		-- Moonkin Aura
  [GetSpellInfo(53251)]	= "Restoration",	-- Wild Growth
}

oUF.TagEvents["talents"] = "UNIT_AURA UNIT_SPELLCAST_START"
if (not oUF.Tags["talents"]) then
    oUF.Tags["talents"] = function(unit, ...)
        for index=1, 40 do
          local name, rank, icon, count, debuffType, duration, expirationTime, unitCaster, isStealable = UnitAura(unit, index, "HELPFUL")
          if name ~= nil and unitCaster==unit then
             if buffs[name] then
                return "|cffff0000"..buffs[name].."|r"
             end
          end
        end
        
        local spell = select(1, UnitCastingInfo(unit))
        if spell then
            if spells[spell] then
                return "|cffff0000"..spells[spell].."|r"
            end
        end
    end
end

local CreateBG = function(parent)
  local bg = CreateFrame("Frame", nil, parent)
  bg:SetPoint("TOPLEFT", parent, "TOPLEFT", -2, 2)
  bg:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 2, -2)
  bg:SetFrameStrata("LOW")
  SetTemplate(bg)
  return bg
end

local createFs = function(parent, justify, ownfsize, fstyle)
    local f = parent:CreateFontString(nil, "OVERLAY")
    f:SetFont(fuiDB["Main"].Font, ownfsize or fuiDB["Main"].FontSize, fstyle)
    if(justify) then f:SetJustifyH(justify) end
    f:SetShadowOffset(.5, -.5)
    return f
end

SecondsToTimeAbbrev = function(time)
    local hr, m, s, text
    if time <= 0 then text = ""
    elseif(time < 3600 and time > 60) then
      hr = floor(time / 3600)
      m = floor(mod(time, 3600) / 60 + 1)
      s = mod(time, 60)
      text = format("%dм", m)
    elseif time < 60 then
      m = floor(time / 60)
      s = mod(time, 60)
      text = (m == 0 and format("%dс", s))
    else
      hr = floor(time / 3600 + 1)
      text = format("%dч", hr)
    end
    return text
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


--[[ Right click menu ]]
local menu = function(self)
	local unit = self.unit:sub(1, -2)
	local cunit = self.unit:gsub("(.)", string.upper, 1)
   
	if(unit=="party" or unit=="partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor")
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor")
	end
end

--[[ Short numbarz! ]]
local format = string.format

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

--[[ Health update ]]
local ColorGradient = oUF.ColorGradient -- we need it for hp and druid power coloring
local unpack = unpack


local postUpdateHealth = function(bar, unit, min, max) -- this func replaces standart health update func
    if not bar then return end
    local r, g, b, a = 1, 1, 1, 1

    if(max~=0 and min~= nil and max ~= nil) then
        r, g, b = ColorGradient(tonumber(min)/tonumber(max), 1, 0, 0, 1, 1, 0, 0, 1, 0) -- we color percent hp by color gradient from green to red
    end

    if(not UnitIsConnected(unit)) then
        bar:SetValue(0)
        bar.value:SetText("Off")
    elseif(UnitIsDead(unit)) then
        bar:SetValue(0)
        bar.value:SetText("Dead")
    elseif(UnitIsGhost(unit)) then
        bar:SetValue(0)
        bar.value:SetText("Ghost")
    else
        bar.value:SetTextColor(1, 1, 0)
        if(unit=="player") then
            bar.value:SetFormattedText("|cff%02x%02x%02x%s|r/%s", r*255, g*255, b*255, siValue(min), siValue(max))    -- text for player: "curhp percenthp"
        elseif(unit=="pet") then
            bar.value:SetFormattedText("%s", siValue(min))  -- text for pet: "shortcurhp"
        elseif(unit=="target") then
            bar.value:SetFormattedText("%s/|cff%02x%02x%02x%d|r", siValue(min), r*255, g*255, b*255, (min/max)*100)   -- text for target: "shortcurhp percenthp"
        elseif(unit=="targettarget" or unit=="focus" or unit=="focustarget" or unit:find("boss%d") or unit:find("arena%d") or unit:find("arena%dtarget")) then
            bar.value:SetFormattedText(siValue(max))    -- text for player: "curhp percenthp"
        else
            bar.value:SetText() -- no hp text for others. Feel free to add other units. Info about SetFormattedText can be found on wowwiki.com
        end
    end

    if(settings.ClassColor==true) then   -- determine what color to use
        if(UnitIsPlayer(unit)) then
            local _, engclass = UnitClass(unit)

            if(bar:GetParent().colors.class[engclass]) then
                r, g, b = unpack(bar:GetParent().colors.class[engclass])
            end
        else
            r, g, b = UnitSelectionColor(unit)
        end
    else
        r, g, b, a = unpack(fuiDB["Main"]["OwnBackColor"])
    end
    
    if(UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit)) then  -- grey color for tapped mobs
        r, g, b = .6, .6, .6
    end

    if(unit=="pet" and GetPetHappiness()) then  -- petframe is colored by happiness
        r, g, b = unpack(bar:GetParent().colors.happiness[GetPetHappiness()])
    end

    if(max~=0 and min~= nil and max ~= nil) then
        r, g, b = ColorGradient(tonumber(min)/tonumber(max), 1, 0, 0, r, g, b, r, g, b) -- we color percent hp by color gradient from green to red
    end

    bar:SetStatusBarColor(r*.8, g*.8, b*.8, a)          -- hp bar coloring
    bar.bg:SetVertexColor(r, g, b, .2)      -- hp background - same color but 20% opacity
    if(bar:GetParent().Castbar) then                   -- same with castbar
        bar:GetParent().Castbar:SetStatusBarColor(r, g, b)
        bar:GetParent().Castbar.bg:SetVertexColor(r, g, b, .2)
    end
end

local PostUpdatePower = function(bar, unit, min, max)
    if(not UnitIsConnected(unit) or min==0) then    -- no unit - no mana!
        bar.value:SetText()
    elseif(UnitIsDead(unit) or UnitIsGhost(unit)) then  -- dead unit - no mana!
        bar:SetValue(0)
        bar.value:SetText()
    elseif(unit=="player" or unit=="target" or unit=="pet" or unit:find("arena%d") or unit:find("boss%d")) then
        if min < max/100*20 then
            Flash(bar, 0.3)
        else
            StopFlash(bar)
        end
        bar.value:SetFormattedText("%s", siValue(min))  -- text for player, pet, target: "shortcurrentmana"
    else
        bar.value:SetText() -- no text for other units
    end

    local r, g, b = 1, 1, 1 -- manabar coloring
    if(settings.PowerColorByType==true) then
        local _, ptype = UnitPowerType(unit)
        if(settings["Power colors"][ptype]) then
            r, g, b = unpack(settings["Power colors"][ptype])
        end
    else
        r, g, b = unpack(settings.OwnPowerColor)
    end

    if(max~=0 and min~= nil and max ~= nil) then
        r, g, b = ColorGradient(tonumber(min)/tonumber(max), 1, 0, 0, r, g, b, r, g, b) -- we color percent hp by color gradient from green to red
    end

    bar:SetStatusBarColor(r, g, b)
    bar.value:SetTextColor(1, 1, 1)     -- power text colored with same color as power bar
    bar.bg:SetVertexColor(r, g, b, .2)
end

--[[ Castbar time styling ]]
local CustomTimeText = function(self, duration)
    self.Time:SetFormattedText("%.1f", duration)   -- text for casts: "elapsed / casttime"
end

local _G = getfenv(0) -- speed up getting globals

local CancelBuff = function(self, button) -- cancel buffs on right click
    if(button=="RightButton") then
        CancelUnitBuff("player", self:GetID())
    end
end

local PostCreateAuraIcon = function(self, button, icon, index, isDebuff)
    button.cd:SetReverse()
    
    button.count:ClearAllPoints()
    button.count:SetPoint("TOPLEFT")    -- Stacks text will be on top of icon
    button.count:SetFont(fuiDB["Main"].Font, fuiDB["Main"].FontSize, "THINOUTLINE")
    button.count:SetTextColor(.8, .8, .8)   -- Color for stacks text
    button.icon:SetPoint("TOPLEFT", 2, -2)
    button.icon:SetPoint("BOTTOMRIGHT", -2, 2)
    button.icon:SetTexCoord(.1,.9,.1,.9)
    button.icon:SetDrawLayer("OVERLAY")
    button.cd:SetAllPoints(button.icon)
    button.overlay:Hide()
    button.overlay.Show = function() end
        
    SetTemplate(button)
    
    if(not isDebuff and self.unit=="player") then     -- Cancel buffs on right click
        button:SetScript("OnMouseUp", CancelBuff)
    end
end


local PostUpdateAuraIcon = function(self, unit, icon, index, offset)
    local MyUnits = { -- true to show cooldown for debuffs from that units, false to hide
        player = true,
        pet = true,
        vehicle = true
    }
    
    if icon.debuff then
        local r,g,b = icon.overlay:GetVertexColor()
        icon:SetBackdropBorderColor(r, g, b)
    else
        SetTemplate(icon)
    end
    
    if(icon.cd:IsShown() and unit=="target" and icon.debuff and not MyUnits[icon.owner]) then
        icon.cd:Hide()
    end
    
	if(icon.debuff and unit == 'target') then
		if(not UnitIsFriend('player', unit) and icon.owner ~= 'player' and icon.owner ~= 'vehicle') then
			icon.icon:SetDesaturated(true)
		else
			icon.icon:SetDesaturated(false)
		end
	end
end


--[[ Let's start! ]]
local func = function(self, unit)
    if not unit then unit = "player" end
    if not self.unit then self.unit = "player" end

    self.menu = menu
    self:EnableMouse(true)
    self:RegisterForClicks("AnyUp")
    self:SetAttribute("type2", "menu")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    if not self.shadow then
        self.shadow = CreateFrame("frame", nil, self)
        self.shadow:SetBackdrop({
            bgFile = "",
            edgeFile = fuiDB["Main"]["Glow texture"],
            edgeSize = 4,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        self.shadow:SetBackdropBorderColor(0,0,0, .4)
        self.shadow:SetPoint("TOPLEFT", self, -6, 6)
        self.shadow:SetPoint("BOTTOMRIGHT", self, 6, -6)
        self.shadow:SetFrameStrata("LOW")
    end

    
    self.disallowVehicleSwap = true
    
    local s = nil

    if (unit and unit:find("arena%d") and not unit:find("arena%dtarget")) then
        s = settings["arena"]
    elseif (unit and unit:find("arena%dtarget")) then
        s = settings["arenatarget"]
    elseif (unit and unit:find("boss%d")) then
        s = settings["boss"]
    else
        s = settings[unit]
    end
    
    --[[ Frame sizes ]]
    self:SetAttribute("initial-width", s.Width)
    self:SetAttribute("initial-height", s.Height)

    --[[ Healthbar ]]
    local hp = CreateFrame("StatusBar", nil, self)
    hp:SetStatusBarTexture(fuiDB["Main"].Texture)
    hp:GetStatusBarTexture():SetHorizTile(false)
    hp.frequentUpdates = true
    hp:SetPoint("TOPRIGHT")
    hp:SetPoint("TOPLEFT")
    hp:SetHeight((s.Height*2)/3-3)
    
    local hpbg = hp:CreateTexture(nil, "BACKGROUND")
    hpbg:SetTexture(fuiDB["Main"].Texture)
    hpbg:SetAllPoints(hp)

    local hpp = createFs(hp)
    hpp:SetPoint("RIGHT", hp, "RIGHT", -5, 0)   -- health text for player - on right side
    
    hp.bg = hpbg
    hp.value = hpp
    self.Health = hp
    self.Health.PostUpdate = postUpdateHealth
    
    --[[ Manabar ]]
    local pp = CreateFrame("StatusBar", nil, self)
    pp:SetStatusBarTexture(fuiDB["Main"].Texture)
    pp:GetStatusBarTexture():SetHorizTile(false)
    pp.frequentUpdates = true
    pp:SetPoint("BOTTOMLEFT")
    pp:SetPoint("BOTTOMRIGHT")
    pp:SetHeight(s.Height/3)

    local ppbg = pp:CreateTexture(nil, "BACKGROUND")
    ppbg:SetTexture(fuiDB["Main"].Texture)
    ppbg:SetAllPoints(pp)

    local ppp = createFs(pp)
    ppp:SetPoint("RIGHT", pp, "RIGHT", -2, 0)

    hp.Smooth = settings.Smooth
    pp.Smooth = settings.Smooth
    
    self.MoveableFrames = true
    
    pp.bg = ppbg
    pp.value = ppp
    self.Power = pp
    self.Power.PostUpdate = PostUpdatePower
        
    --[[ Info text ]]
    self.info = createFs(self.Health)
    if(unit=="player") then
        self.info:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 3)
        if (UnitLevel(unit) < 80) then
            self:Tag(self.info, "[smartlevel] [name]")    -- look into \Interface\AddOns\oUF\elements\tags.lua for more tags
        else
            self:Tag(self.info, "[name]")
        end
    elseif(unit=="target") then
        self.info:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 3)
        if (UnitLevel(unit) ~= 80) then
            self:Tag(self.info, "[talents] [name]|r [difficulty][smartlevel]")    -- look into \Interface\AddOns\oUF\elements\tags.lua for more tags
        else
            self:Tag(self.info, "[talents] [name]|r [difficulty]")    -- look into \Interface\AddOns\oUF\elements\tags.lua for more tags
        end
        self.info:SetWidth(s.Width)
        self.info:SetJustifyH("RIGHT")
    elseif(unit=="targettarget" or unit=="focus" or unit=="focustarget" or unit:find("boss%d") or unit:find("arena%d") or unit:find("arena%dtarget")) then
        self.info:SetPoint("LEFT", 2, 0)
        self.info:SetPoint("RIGHT", self.Health.value, "LEFT", 0, 0)
        self:Tag(self.info, "[talents] [name]")
    elseif(not unit) then
        self.info:SetPoint("BOTTOM", self, "TOP", 0, 3)
        self.info:SetJustifyH("CENTER")
        self:Tag(self.info, "[name]")
    end

    --[[ Castbar ]]
    if(unit=="player" or unit=="target" or unit=="pet" or unit=="focus" or unit:find("boss%d") or unit:find("arena%d") or unit:find("arena%dtarget")) then
        local space = 0
        if  class == "DEATHKNIGHT" or class=="SHAMAN" then
            space = 12
        end
        
        local cb = CreateFrame("StatusBar", nil, self)
        --SetTemplate(cb)
        cb:SetStatusBarTexture(fuiDB["Main"].Texture)
        cb:GetStatusBarTexture():SetHorizTile(false)
        cb:GetStatusBarTexture():SetVertTile(false)
        cb:SetHeight(s.Height/3) -- Castbar will be as big as healthbar
        cb:SetWidth(s.Width-cb:GetHeight())
        cb:SetPoint("TOPLEFT", self, "BOTTOMLEFT", cb:GetHeight(), -4-space)
        
        local cbblackbg = cb:CreateTexture(nil, "BACKGROUND")   -- that's the black thingie like global background
        cbblackbg:SetPoint("TOPLEFT", -1-cb:GetHeight(), 1)
        cbblackbg:SetPoint("BOTTOMRIGHT", 1, -1)
        cbblackbg:SetTexture(0, 0, 0)

        local cbbg = cb:CreateTexture(nil, "BORDER")
        cbbg:SetTexture(fuiDB["Main"].Texture)
        cbbg:SetAllPoints(cb)

        local cbtime = createFs(cb, "RIGHT")
        cbtime:SetPoint("RIGHT", cb, "RIGHT", -4, 0)

        local text = createFs(cb, "LEFT")
        text:SetPoint("LEFT", cb, "LEFT", 4, 0)
        text:SetPoint("RIGHT", cbtime, "LEFT")

        local spark = cb:CreateTexture(nil, "OVERLAY")
        spark:SetVertexColor(1, 1, 1)
        spark:SetBlendMode("ADD")
        spark:SetHeight(cb:GetHeight()*2.5)
        spark:SetWidth(20)
        
        cbicon = cb:CreateTexture(nil, "OVERLAY")
        cbicon:SetTexCoord(.1,.9,.1,.9)
        cbicon:SetWidth(cb:GetHeight())
        cbicon:SetHeight(cb:GetHeight())
        cbicon:SetPoint("RIGHT", cb, "LEFT", 0, 0)

        if(unit=="player") then
            local sz = cb:CreateTexture(nil, "ARTWORK")
            sz:SetTexture(fuiDB["Main"].Texture)
            sz:SetVertexColor(1, 0.3, 0.3)
            sz:SetPoint("BOTTOMRIGHT")
            sz:SetPoint("TOPRIGHT")
            cb.SafeZone = sz

            local lag = createFs(cb, "RIGHT", 9,"OUTLINE")
            lag:SetPoint("TOPRIGHT", cb, "BOTTOMRIGHT", 0, -2)
            lag:SetJustifyH("RIGHT")
            cb.Latency = lag

            local PostCastStart = function(Castbar, unit, name, rank, text, castid)
                Castbar.channeling = false
                if unit == "vehicle" then unit = "player" end

                if unit == "player" then
                    local latency = GetTime() - Castbar.castSent
                    latency = latency > Castbar.max and Castbar.max or latency
                    Castbar.Latency:SetText(("%dms"):format(latency * 1e3))
                    Castbar.SafeZone:SetWidth(Castbar:GetWidth() * latency / Castbar.max)
                    Castbar.SafeZone:ClearAllPoints()
                    Castbar.SafeZone:SetPoint("TOPRIGHT")
                    Castbar.SafeZone:SetPoint("BOTTOMRIGHT")
                end

                if Castbar.interrupt and UnitCanAttack("player", unit) then
                    Castbar:SetStatusBarColor(0.69, 0.31, 0.31, 1)
                else
                    Castbar:SetStatusBarColor(0.4, 0.4, 0.5, 1)
                end
            end

            local PostChannelStart = function(Castbar, unit, name, rank, text)
                Castbar.channeling = true
                if unit == "vehicle" then unit = "player" end

                if unit == "player" then
                    local latency = GetTime() - Castbar.castSent
                    latency = latency > Castbar.max and Castbar.max or latency
                    Castbar.Latency:SetText(("%dms"):format(latency * 1e3))
                    Castbar.SafeZone:SetWidth(Castbar:GetWidth() * latency / Castbar.max)
                    Castbar.SafeZone:ClearAllPoints()
                    Castbar.SafeZone:SetPoint("TOPLEFT")
                    Castbar.SafeZone:SetPoint("BOTTOMLEFT")
                end

                if Castbar.interrupt and UnitCanAttack("player", unit) then
                    Castbar:SetStatusBarColor(0.69, 0.31, 0.31, 0.3)
                else
                    Castbar:SetStatusBarColor(0.4, 0.4, 0.5, 0.3)
                end
            end 
            
            local SpellCastInterruptable = function(self, event, unit)
                if event == "UNIT_SPELLCAST_NOT_INTERRUPTABLE" then
                    self:SetStatusBarColor(1, 0, 0, 0.5)
                else
                    self:SetStatusBarColor(0,31, 0.45, 0.63, 0.5)
                end
            end
            
            cb:RegisterEvent("UNIT_SPELLCAST_INTERRUPTABLE", SpellCastInterruptable)
            cb:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTABLE", SpellCastInterruptable)
            
            self:RegisterEvent("UNIT_SPELLCAST_SENT", function(self, event, caster)
                if caster == "player" or caster == "vehicle" then
                    self.Castbar.castSent = GetTime()
                end
            end)
            
            cb.PostChannelStart = PostChannelStart
            cb.PostCastStart = PostCastStart
            
            cb.CustomDelayText = function(self, duration)
                self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(self.channeling and duration or self.max - duration, self.channeling and "- " or "+", self.delay))
            end
        end

        cb.bg = cbbg
        cb.Time = cbtime
        cb.Text = text
        cb.Spark = spark
        cb.CustomTimeText = CustomTimeText
        cb.Icon = cbicon
        self.Castbar = cb
    end
    
    if (unit:find("arena%d") and not unit:find("arena%dtarget")) then
        self.Trinketbg = CreateFrame("Frame", nil, self)
        self.Trinketbg:SetHeight(26)
        self.Trinketbg:SetWidth(26)
        self.Trinketbg:SetPoint("RIGHT", self, "LEFT", -6, 0)
        self.Trinketbg:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                tile = true,
                tileSize = 16,
                edgeSize = 16,
                insets = {left = 3, right = 3, top = 3, bottom = 3},
            })
        self.Trinketbg:SetBackdropColor(.05, .05, .05)
        self.Trinketbg:SetBackdropBorderColor(.3, .3, .3)
        self.Trinketbg:SetFrameLevel(0)

        self.Trinket = CreateFrame("Frame", nil, self.Trinketbg)
        self.Trinket:SetAllPoints(self.Trinketbg)
        self.Trinket:SetPoint("TOPLEFT", self.Trinketbg, 2, -2)
        self.Trinket:SetPoint("BOTTOMRIGHT", self.Trinketbg, -2, 2)
        self.Trinket:SetFrameLevel(1)
        self.Trinket.trinketUseAnnounce = true
    end
    
    if unit=="player" and class == "DEATHKNIGHT" then
        local rune = CreateFrame("Frame", nil, self)
        rune:SetPoint("TOP", self, "BOTTOM", 0, -1)
        rune:SetWidth(s.Width)
        rune:SetHeight(8)
        for i = 1, 6 do
            rune[i] = CreateFrame("StatusBar", nil, runes)
            rune[i]:SetParent(rune)
            rune[i]:SetWidth(rune:GetWidth()/6-1)
            rune[i]:SetHeight(rune:GetHeight())
            rune[i]:SetStatusBarTexture(fuiDB["Main"].Texture)
            rune[i]:GetStatusBarTexture():SetHorizTile(false)
            rune[i]:GetStatusBarTexture():SetVertTile(false)
            rune[i]:SetStatusBarColor(unpack(settings["Rune colors"][i]))
            rune[i].bg = rune[i]:CreateTexture(nil, "BACKGROUND")   -- that's the black thingie like global background
            rune[i].bg:SetPoint("TOPLEFT", -1, 1)
            rune[i].bg:SetPoint("BOTTOMRIGHT", 1, -1)
            rune[i].bg:SetTexture(0, 0, 0)
            if i == 1 then 
                rune[i]:SetWidth(rune:GetWidth()/6)
                rune[i]:SetPoint('TOPLEFT', rune, 'TOPLEFT', 0, 0)
            else
               rune[i]:SetPoint('LEFT', rune[i-1], 'RIGHT', 1, 0)
            end
        end
        self.Runes = rune
    end

    if unit == "player" or unit == "target" then
        self.CombatFeedbackText = createFs(self.Health, nil, 16)
        self.CombatFeedbackText:SetPoint("CENTER", 0, 1)
        self.CombatFeedbackText.colors = {
            DAMAGE = {0.69, 0.31, 0.31},
            CRUSHING = {0.69, 0.31, 0.31},
            CRITICAL = {0.69, 0.31, 0.31},
            GLANCING = {0.69, 0.31, 0.31},
            STANDARD = {0.84, 0.75, 0.65},
            IMMUNE = {0.84, 0.75, 0.65},
            ABSORB = {0.84, 0.75, 0.65},
            BLOCK = {0.84, 0.75, 0.65},
            RESIST = {0.84, 0.75, 0.65},
            MISS = {0.84, 0.75, 0.65},
            HEAL = {0.33, 0.59, 0.33},
            CRITHEAL = {0.33, 0.59, 0.33},
            ENERGIZE = {0.31, 0.45, 0.63},
            CRITENERGIZE = {0.31, 0.45, 0.63},
        }
    end
    
    if settings.Portraits and (unit and unit=="player" or unit == "target") then
        self.Portrait = CreateFrame("PlayerModel", nil, self)
        self.Portrait:SetWidth(s.Height)
        self.Portrait:SetHeight(s.Height)
        if unit == "target" then
            self.Portrait:SetPoint("LEFT", self, "RIGHT", 4, 0)
        else
            self.Portrait:SetPoint("RIGHT", self, "LEFT", -4, 0)
        end
        CreateBG(self.Portrait)
    end
    
    
    if(unit=="player") then
    
        -- [[ Temporary enchants icons ]] --
        local ench = {}
        
        for i = 1,2 do
            ench[i] = _G["TempEnchant"..i]
             _G["TempEnchant"..i.."Border"]:Hide()
            
            ench[i]:ClearAllPoints()
            
            if (i==1) then
                ench[i]:SetPoint("TOPLEFT", self.Castbar.Icon, "BOTTOMLEFT", 0, -4)
            else
                ench[i]:SetPoint("LEFT", ench[i-1], "RIGHT", 4, 0)
            end
            
            local icon = _G["TempEnchant"..i.."Icon"]
            icon:SetTexCoord(.1,.9,.1,.9)
            icon:SetDrawLayer("OVERLAY")
            ench[i]:SetWidth(oUF.units.player.Health:GetHeight())
            ench[i]:SetHeight(oUF.units.player.Health:GetHeight())
            icon:SetPoint("TOPLEFT", 2, -2)
            icon:SetPoint("BOTTOMRIGHT", -2, 2)

            ench[i]:Show()
            
            SetTemplate(ench[i])
            
            ench[i].dur = _G["TempEnchant"..i.."Duration"]
            ench[i].dur:ClearAllPoints()
            ench[i].dur:SetPoint("BOTTOM", ench[i])
            ench[i].dur:SetFont(fuiDB["Main"].Font, 10, "THINOUTLINE")
            ench[i].dur:SetVertexColor(1, 1, 1)
            ench[i].dur.SetVertexColor = function() end
            ench[i].dur:SetDrawLayer("OVERLAY")
        end
         
        -- Hide old buffs
        _G["BuffFrame"]:Hide()
        _G["BuffFrame"]:UnregisterAllEvents()
        _G["BuffFrame"]:SetScript("OnUpdate", nil)
    
        local buffs = CreateFrame("Frame", nill, self)
        buffs:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -5, -(_G["aFrame"]:GetHeight()+5) or -20)
        buffs.initialAnchor = "TOPRIGHT"
        buffs["growth-y"] = "DOWN"
        buffs["growth-x"] = "LEFT"
        buffs:SetHeight(500)
        buffs:SetWidth(250)
        buffs.spacing = 3
        buffs.size = 28
        buffs.gap = false
        self.Buffs = buffs
        self.Buffs.PostCreateIcon = PostCreateAuraIcon
        self.Buffs.PostUpdateIcon = PostUpdateAuraIcon
		
        local debuffs = CreateFrame("Frame", nill, self)
        debuffs:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -5, -150)
        debuffs.initialAnchor = "TOPRIGHT"
        debuffs["growth-x"] = "LEFT"
        debuffs["growth-y"] = "DOWN"
        debuffs:SetHeight(500)
        debuffs:SetWidth(220)
        debuffs.spacing = 3
        debuffs.size = 32
        debuffs.showDebuffType = true
        self.Debuffs = debuffs
        self.Debuffs.PostCreateIcon = PostCreateAuraIcon
        self.Debuffs.PostUpdateIcon = PostUpdateAuraIcon
    end
    
    if(unit=="target") then     -- For target we make one frame. Buffs first, then debuffs
        local auras = CreateFrame("Frame", nill, self)
        auras:SetPoint("BOTTOMLEFT", self.info, "TOPLEFT", 0, 2)
        auras.initialAnchor = "BOTTOMLEFT"
        auras["growth-x"] = "RIGHT"
        auras["growth-y"] = "UP"
        auras.numDebuffs = 16   -- Max amount of debuffs to show
        auras:SetHeight(373)
        auras:SetWidth(s.Width)
        auras.spacing = 1
        auras.size = s.Width/6 - (auras.spacing*6)
        auras.gap = false        -- A gap between buffs and debuffs
        auras.showType = true
        
        self.Auras = auras
        self.Auras.PostCreateIcon = PostCreateAuraIcon
        self.Auras.PostUpdateIcon = PostUpdateAuraIcon
    end

    if(unit=="focus" or unit=="targettarget") then
        local debuffs = CreateFrame("Frame", nill, self)    -- Debuffs for focus
        debuffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
        debuffs.initialAnchor = "TOPLEFT"
        debuffs["growth-x"] = "RIGHT"
        debuffs["growth-y"] = "DOWN"
        debuffs:SetHeight(300)
        debuffs:SetWidth(s.Width)
        debuffs.spacing = 2
        debuffs.size = s.Width/6 - debuffs.spacing
        debuffs.gap = false        -- A gap between buffs and debuffs

        self.Debuffs = debuffs
    end
    
    --[[ Druid mana ]]
    if(unit=="player" and class=="DRUID") then
        local druid = CreateFrame("StatusBar", nil, self)
        druid.value = createFs(druid, "LEFT")
        druid.value:SetAllPoints(self.Power)
        druid.value:SetTextColor(0.31, 0.45, 0.63)
        druid.n = 0
        self.DruidPower = druid

        self.DruidPower:RegisterEvent("UNIT_MANA")
        self.DruidPower:RegisterEvent("UNIT_ENERGY")
        self.DruidPower:RegisterEvent("UNIT_MAXENERGY")
        self.DruidPower:RegisterEvent("PLAYER_LOGIN")
        self.DruidPower:SetScript("OnEvent", function(self)
            local num, str = UnitPowerType("player")
            if num ~= 0 then
                local min = UnitPower("player", 0)
                local max = UnitPowerMax("player", 0)
                if min~=max then
                    self.value:SetText(siValue(min))
                    self:SetAlpha(1)
                end
            else
                self:SetAlpha(0)
            end
        end)
        
    end

    --[[ Raid Target Icon ]]
    if(unit=="player" or unit=="target") then
        local ricon = self.Health:CreateTexture(nil, "OVERLAY")
        ricon:SetHeight(16)
        ricon:SetWidth(16)
        ricon:SetPoint("CENTER")

        self.RaidIcon = ricon
    end

    --[[ Resting icon ]]
    if(unit=="player") then
        local rest = self.Health:CreateTexture(nil, "OVERLAY")
        rest:SetHeight(20)
        rest:SetWidth(20)
        rest:SetPoint("LEFT")

        self.Resting = rest
    end

    --[[ Combat icon ]]
    if(unit=="player") then
        local combat = self.Health:CreateTexture(nil, "OVERLAY")
        combat:SetHeight(18)
        combat:SetWidth(18)
        combat:SetPoint("LEFT")

        self.Combat = combat
    end

    --[[ Leader icon ]]
    if(not unit) then   -- only for party frames
        local leader = self:CreateTexture(nil, "OVERLAY")
        leader:SetHeight(16)
        leader:SetWidth(16)
        leader:SetPoint("RIGHT", hp, "LEFT", -2, 0)

        self.Leader = leader
    end

    --[[ Combo Points ]]
    if(unit=="target") then -- this is for Malygos. Text will be shown on right of target healthbar
        local UpdateCPoints = function(self, event, unit)
           if unit == PlayerFrame.unit and unit ~= self.CPoints.unit then
              self.CPoints.unit = unit
           end
        end
    
        self.cpFrame = self.cpFrame or CreateFrame("Frame", nil, self)
        self.cpFrame:SetPoint("TOPLEFT",self,"BOTTOMLEFT",0,0)
        self.cpFrame:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",0,-12)
        self.cpFrame:CreateTexture(nil):SetTexture(0,0,0)
        self.cpFrame:Show()
        self.CPoints = {}
        self.CPoints.unit = PlayerFrame.unit
        for i = 1, 5 do
				self.CPoints[i] = self.cpFrame:CreateTexture(nil, "OVERLAY")
				self.CPoints[i]:SetHeight(12)
				self.CPoints[i]:SetWidth(12)
				self.CPoints[i]:SetTexture(fuiDB["Main"].Indicator)
				if i == 1 then
					self.CPoints[i]:SetPoint("LEFT")
					self.CPoints[i]:SetVertexColor(0.69, 0.31, 0.31)
				else
					self.CPoints[i]:SetPoint("LEFT", self.CPoints[i-1], "RIGHT", 2, 0)
				end
			end
			self.CPoints[2]:SetVertexColor(0.69, 0.31, 0.31)
			self.CPoints[3]:SetVertexColor(0.65, 0.63, 0.35)
			self.CPoints[4]:SetVertexColor(0.65, 0.63, 0.35)
			self.CPoints[5]:SetVertexColor(0.33, 0.59, 0.33)
			self:RegisterEvent("UNIT_COMBO_POINTS", UpdateCPoints)
    end
    
    --[[ Totems ]]--
    if unit=="player" and class == "SHAMAN" then
        local GetTotemInfo, SetValue, GetTime = GetTotemInfo, SetValue, GetTime
        
        local Abbrev = function(name)
           return (string.len(name) > 10) and string.gsub(name, "%s*(.)%S*%s*", "%1. ") or name
        end
        
        self.TotemBar = {}
        self.TotemBar.colors = settings["TotemBar colors"]
        
        local total = 0
        local delay = 1
        
        self.TotemBarFrame = CreateFrame("frame", "oUF_TotemBarFrame",self)
        self.TotemBarFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -1, 0)
        self.TotemBarFrame:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 1, -settings.player.Height/3+1)
        local tfbg = self.TotemBarFrame:CreateTexture(nil, "BACKGROUND")
        tfbg:SetAllPoints(self.TotemBarFrame)
        tfbg:SetTexture(fuiDB["Main"].Texture)
        tfbg:SetVertexColor(0,0,0)
        self.TotemBarFrame:Show()
            
        for i = 1, 4 do
            self.TotemBar[i] = CreateFrame("StatusBar", self:GetName().."_TotemBar"..i, self)
            self.TotemBar[i]:SetHeight(settings.player.Height/3-3)
            self.TotemBar[i]:SetWidth(s.Width/4-1)
            if (i==1) then
               self.TotemBar[i]:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -1)
            else
               self.TotemBar[i]:SetPoint("LEFT", self.TotemBar[i-1], "RIGHT", 1, 0)
            end
            self.TotemBar[i]:SetStatusBarTexture(fuiDB["Main"].Texture)
            self.TotemBar[i]:GetStatusBarTexture():SetHorizTile(false)
            self.TotemBar[i]:SetMinMaxValues(0, 1)

            self.TotemBar[i].bg = self.TotemBar[i]:CreateTexture(nil, "BORDER")
            self.TotemBar[i].bg:SetAllPoints(self.TotemBar[i])
            self.TotemBar[i].bg:SetTexture(fuiDB["Main"].Texture)
            self.TotemBar[i].bg:SetVertexColor(.2,.2,.2)
            
            self.TotemBar[i].fs = createFs(self.TotemBar[i], nil, 8)
            self.TotemBar[i].fs:SetAllPoints(self.TotemBar[i])
            
            self.TotemBar[i].bg:Hide()
            self.TotemBar[i]:Hide()
        end
        
        local function TotemOnClick(self,...)
           local id = self.ID
           local mouse = ...
              if IsShiftKeyDown() then
                 for j = 1,4 do 
                   DestroyTotem(j)
                 end 
              else 
                 DestroyTotem(id)
              end
        end
        self.TotemBar.Destroy = true

        local function InitDestroy(self)
           local totem = self.TotemBar
           for i = 1 , 4 do
              local Destroy = CreateFrame("Button",nil, totem[i])
              Destroy:SetAllPoints(totem[i])
              Destroy:RegisterForClicks("LeftButtonUp", "RightButtonUp")
              Destroy.ID = i
              Destroy:SetScript("OnClick", TotemOnClick)
           end
        end

        local function UpdateSlot(self, slot)
           local totem = self.TotemBar
           self.TotemBar[slot]:Show()
           if(totem) then
              if totem.Destroy then
                 InitDestroy(self)
              end
           end
   
           haveTotem, name, startTime, duration, totemIcon = GetTotemInfo(slot)
           
           totem[slot]:SetStatusBarColor(unpack(totem.colors[slot]))
           totem[slot]:SetValue(0)
           
           totem[slot].ID = slot
           
           -- If we have a totem then set his value 
           if(haveTotem) then
              if totem[slot].Name then
                 totem[slot].Name:SetText(Abbrev(name))
              end
              if(duration >= 0) then
                 totem[slot]:SetValue(1 - ((GetTime() - startTime) / duration))
                 -- Status bar update
                 totem[slot]:SetScript("OnUpdate",function(self,elapsed)
                       total = total + elapsed
                       if total >= delay then
                          total = 0
                          haveTotem, name, startTime, duration, totemIcon = GetTotemInfo(self.ID)
                             if ((GetTime() - startTime) == 0) then
                                self:SetValue(0)
                                self.fs:SetText("")
                             else
                                self:SetValue(1 - ((GetTime() - startTime) / duration))
                                self.fs:SetText(SecondsToTimeAbbrev(floor(duration - (GetTime() - startTime))))
                             end
                       end
                    end)
              else
                 -- There's no need to update because it doesn't have any duration
                 totem[slot]:SetScript("OnUpdate",nil)
                 totem[slot]:SetValue(0)
                 totem[slot]:Hide()
                 totem[slot].bg:Hide()
              end 
           else
              -- No totem = no time 
              if totem[slot].Name then
                 totem[slot].Name:SetText(" ")
              end
              totem[slot]:SetValue(0)
              totem[slot]:Hide()
              totem[slot].bg:Hide()
           end

        end
        
        local function Event(self,event,...)
           if event == "PLAYER_TOTEM_UPDATE" then
              UpdateSlot(self, ...)
           end
        end
        
        self:RegisterEvent("PLAYER_TOTEM_UPDATE", Event)
    end

    if unit=="target" or unit=="focus" or unit:find("arena%d") then
        self.AuraTracker = CreateFrame("Frame", nil, self or self.Trinket)
        self.AuraTracker:SetWidth(s.Height)
        self.AuraTracker:SetHeight(s.Height)
        if settings.Portraits then
            self.AuraTracker:SetPoint("RIGHT", self.Portrait, "LEFT", -4, 0)
        else
            self.AuraTracker:SetPoint("RIGHT", self, "LEFT", -4, 0)
        end
    elseif unit == "player" then
        self.AuraTracker = CreateFrame("Frame", nil, self or self.Trinket)
        self.AuraTracker:SetWidth(s.Height)
        self.AuraTracker:SetHeight(s.Height)
        self.AuraTracker:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    end

    --[[ Fading for party ]]
    if(not unit) then
        self.Range = {
            insideAlpha = 1,
            outsideAlpha = 0.5,
        }
    end
    
    self.DebuffHighlight = self.Health:CreateTexture(nil, "ARTWORK")
    self.DebuffHighlight:SetAllPoints(self.Health)
    self.DebuffHighlight:SetTexture(fuiDB["Main"].Texture)
    self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
    self.DebuffHighlight:SetBlendMode("ADD")
    self.DebuffHighlightAlpha = 1
    self.DebuffHighlightFilter = false
    

    --self.DebuffHighlightUseTexture = true
    
    CreateBG(self.Health)
    CreateBG(self.Power)
    
    return self
end

local module = {}
module.name = "UnitFrames"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
   
    settings = fuiDB[module.name] or DefaultSettings[module.name]

    oUF:RegisterStyle("style", func)
    oUF:SetActiveStyle("style")

    --[[ Positions ]]
    oUF:Spawn("player", "oUF_player"):SetPoint("TOPRIGHT", UIParent, "BOTTOM", -100, 220)
    oUF:Spawn("target", "oUF_target"):SetPoint("TOPLEFT", UIParent, "BOTTOM", 100, 220)
    oUF:Spawn("targettarget", "oUF_targettarget"):SetPoint("TOP", UIParent, "BOTTOM", 0, 220)
    oUF:Spawn("focus", "oUF_focus"):SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 32, 220)
    oUF:Spawn("focustarget", "oUF_focustarget"):SetPoint("LEFT", oUF.units.focus, "RIGHT", 5, 0)
    if settings.Portraits then
        oUF:Spawn("pet", "oUF_pet"):SetPoint("TOPRIGHT", oUF.units.player.Portrait, "TOPLEFT", -5, 0)
    else
        oUF:Spawn("pet", "oUF_pet"):SetPoint("TOPRIGHT", oUF.units.player, "TOPLEFT", -5, 0)
    end

    local boss = {}
    for i = 1, MAX_BOSS_FRAMES do
       boss[i] = oUF:Spawn("boss"..i, "oUF_Boss"..i)
       boss[i].MoveableFrames = true

       if i == 1 then
          boss[i]:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -200, -250)
       else
          boss[i]:SetPoint("TOP", boss[i-1], "BOTTOM", 0, -settings["boss"].ManaBarHeight or 20)
       end
    end
    for i, v in ipairs(boss) do v:Show() end


    if not IsAddOnLoaded("Gladius") then
        local arena = {}
        for i = 1, 5 do
          arena[i] = oUF:Spawn("arena"..i, "oUF_Arena"..i)
          arena[i].MoveableFrames = true
          if i == 1 then
             arena[i]:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -200, -250)
          else
             arena[i]:SetPoint("TOP", arena[i-1], "BOTTOM", 0, -settings["arena"].ManaBarHeight or 20)
          end
        end

        local arenatarget = {}
        for i = 1, 5 do
          arenatarget[i] = oUF:Spawn("arena"..i.."target", "oUF_Arena"..i.."target")
          if i == 1 then
             arenatarget[i]:SetPoint("TOPLEFT", arena[i], "TOPRIGHT", 20, 0)
          else
             arenatarget[i]:SetPoint("TOP", arenatarget[i-1], "BOTTOM", 0, -settings["arena"].ManaBarHeight or 20)
          end
        end
        for i, v in ipairs(arena) do v:Show() end
    end
    
--[[ testmode ]]
SlashCmdList.TestUI = function() 
    if(oUF) then
        for i, v in pairs(oUF.units) do
            if not v.fff then
                v.fff = CreateFrame("frame")
                v.fffs = v.fff:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                v.fffs:SetAllPoints(v.fff)
                v.fffs:SetText(v:GetName())
            end
            v.fff:SetAllPoints(v)
            SetTemplate(v.fff)
            if v.fff:IsVisible() then 
                v.fff:Hide()
            else
                v.fff:Show()
            end
        end
    end
end
SLASH_TestUI1 = "/tu"
    
end
tinsert(fui.modules, module) -- finish him!