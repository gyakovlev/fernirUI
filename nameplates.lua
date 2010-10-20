local settings = nil


local module = {}
module.name = "Nameplates"
module.Init = function()
	if not fuiDB.modules[module.name] then return end

	settings = fuiDB
	local opts = settings[module.name]
	
	local ownNP = CreateFrame("Frame", nil, UIParent)
	ownNP:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

	local data = {
		totemList = {
			2484,--Earthbind Totem
			8143,--Tremor Totem
			8177,--Grounding Totem
			8512,--Windfury Totem
			6495,--Sentry Totem
			8170,--Cleansing Totem
			3738,--Wrath of Air Totem
			2062,--Earth Elemental Totem
			2894,--Fire Elemental Totem
			58734,--Magma Totem
			58582,--Stoneclaw Totem
			58753,--Stoneskin Totem
			58739,--Fire Resistance Totem
			58656,--Flametongue Totem
			58745,--Frost Resistance Totem
			58757,--Healing Stream Totem
			58774,--Mana Spring Totem
			58749,--Nature Resistance Totem
			58704,--Searing Totem
			58643,--Strength of Earth Totem
			57722,--Totem of Wrath

			71278,--chokingGas --"Interface\\Icons\\Ability_Creature_Cursed_01"
		},
		classIcon = {
			["WARRIOR"] = { 0.00, 0.25, 0.00, 0.25 },
			["MAGE"] = { 0.25, 0.50, 0.00, 0.25 },
			["ROGUE"] = { 0.50, 0.75, 0.00, 0.25 },
			["DRUID"] = { 0.75, 1.00, 0.00, 0.25 },
			["HUNTER"] = { 0.00, 0.25, 0.25, 0.50 },
			["SHAMAN"] = { 0.25, 0.50, 0.25, 0.50 },
			["PRIEST"] = { 0.50, 0.75, 0.25, 0.50 },
			["WARLOCK"] = { 0.75, 1.00, 0.25, 0.50 },
			["PALADIN"] = { 0.00, 0.25, 0.50, 0.75 },
			["DEATHKNIGHT"] = { 0.25, 0.50, 0.50, 0.75 },
		},
		totems = {},
	}
	for i=1,#data.totemList do
		 temp, _, temp2 = GetSpellInfo(data.totemList[i])
		 data.totems[i] = { name = temp, texture = temp2 }
	end
	tinsert( data.totems, { name = "Initiate's Training Dummy", texture = temp2 } )

	--[[ Get the class ]]
	local function colorToString(r,g,b)
		 return "C"..math.floor((100*r) + 0.5)..math.floor((100*g) + 0.5)..math.floor((100*b) + 0.5)
	end
	local classByColor = {}
	for classname, color in pairs( RAID_CLASS_COLORS ) do 
		 classByColor[colorToString(color.r, color.g, color.b)] = classname
	end
		
	local barTexture = settings["Main"].Texture
	local overlayTexture = [=[Interface\Tooltips\Nameplate-Border]=]
	local glowTexture = settings["Main"]["Glow texture"]
	local font, fontSize, fontOutline = settings["Main"].Font, 10, "THINOUTLINE"
	local backdrop = {
			edgeFile = glowTexture, edgeSize = 5,
			insets = {left = 3, right = 3, top = 3, bottom = 3}
		}
	local select = select

	local function getTotem(name)
		for i=1,#data.totems do
			if strfind(name, data.totems[i].name) then
				return data.totems[i].texture
			end
		end
		return nil
	end


	local IsValidFrame = function(frame)
		if frame:GetName() then
			return
		end

		overlayRegion = select(2, frame:GetRegions())

		return overlayRegion and overlayRegion:GetObjectType() == "Texture" and overlayRegion:GetTexture() == overlayTexture
	end

	local UpdateTime = function(self, curValue)
		local minValue, maxValue = self:GetMinMaxValues()
		if self.channeling then
			self.time:SetFormattedText("%.1f ", curValue)
		else
			self.time:SetFormattedText("%.1f ", maxValue - curValue)
		end
	end

	local ThreatUpdate = function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed >= 0.2 then
			if not self.oldglow:IsShown() then
				self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
			else
				self.healthBar.hpGlow:SetBackdropBorderColor(self.oldglow:GetVertexColor())
			end

			self.healthBar:SetStatusBarColor(self.r, self.g, self.b)

			self.elapsed = 0
		end
	end

	local UpdateFrame = function(self)
		local r, g, b = self.healthBar:GetStatusBarColor()
			
		
		local newr, newg, newb
		if g + b == 0 then
			newr, newg, newb = 0.69, 0.31, 0.31
			self.healthBar:SetStatusBarColor(0.69, 0.31, 0.31)
		elseif r + b == 0 then
			newr, newg, newb = 0.33, 0.59, 0.33
			self.healthBar:SetStatusBarColor(0.33, 0.59, 0.33)
		elseif r + g == 0 then
			newr, newg, newb = 0.31, 0.45, 0.63
			self.healthBar:SetStatusBarColor(0.31, 0.45, 0.63)
		elseif 2 - (r + g) < 0.05 and b == 0 then
			newr, newg, newb = 0.65, 0.63, 0.35
			self.healthBar:SetStatusBarColor(0.65, 0.63, 0.35)
		else
			newr, newg, newb = r, g, b
		end
		
		self.r, self.g, self.b = newr, newg, newb
		
		self.healthBar:ClearAllPoints()
		self.healthBar:SetPoint("CENTER", self.healthBar:GetParent())
		self.healthBar:SetHeight(opts["Height"] or  10)
		self.healthBar:SetWidth(opts["Width"] or 80)

		self.castBar:ClearAllPoints()
		self.castBar:SetPoint("TOP", self.healthBar, "BOTTOM", 0, -4)
		self.castBar:SetHeight(opts["Height"] or 10)
		self.castBar:SetWidth(opts["Width"] or 80)

		self.highlight:ClearAllPoints()
		self.highlight:SetAllPoints(self.healthBar)

		self.name:SetText(self.oldname:GetText())

		local level, elite, mylevel = tonumber(self.level:GetText()), self.elite:IsShown(), UnitLevel("player")
		self.level:ClearAllPoints()
		self.level:SetPoint("RIGHT", self.healthBar, "LEFT", -2, 1)
		if self.boss:IsShown() then
			self.level:SetText("B")
			self.level:SetTextColor(0.8, 0.05, 0)
			self.level:Show()
		elseif not elite and level == mylevel then
			self.level:Hide()
		else
			self.level:SetText(level..(elite and "+" or ""))
		end
		
		self.totem:SetTexture(nil)
		
		local isTotem = getTotem(self.name:GetText())
		
		local class = classByColor[colorToString(self.r, self.g, self.b)]
		
		if isTotem then
			if opts["Totem icons"] then
				self.totem:SetTexture(isTotem)
			end
		end
		if class and not isTotem then
			if opts["Class icon"] then
				self.totem:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
				self.totem:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
			end
		end
	end

	local FixCastbar = function(self)
		self.castbarOverlay:Hide()
		self:SetHeight(10)
		self:ClearAllPoints()
		self:SetPoint("TOP", self.healthBar, "BOTTOM", 0, -4)
	end

	local ColorCastBar = function(self, shielded)
		if shielded then
			self:SetStatusBarColor(0.8, 0.05, 0)
			self.cbGlow:SetBackdropBorderColor(0.75, 0.75, 0.75)
		else
			self.cbGlow:SetBackdropBorderColor(0, 0, 0)
		end
	end

	local OnSizeChanged = function(self)
		self.needFix = true
	end

	local OnValueChanged = function(self, curValue)
		UpdateTime(self, curValue)
		if self.needFix then
			FixCastbar(self)
			self.needFix = nil
		end
	end

	local OnShow = function(self)
		self.channeling  = UnitChannelInfo("target") 
		FixCastbar(self)
		ColorCastBar(self, self.shieldedRegion:IsShown())
	end

	local OnHide = function(self)
		self.highlight:Hide()
		self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
	end

	local OnEvent = function(self, event, unit)
		if unit == "target" then
			if self:IsShown() then
				ColorCastBar(self, event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
			end
		end
	end

	local CreateFrame = function(frame)
		if frame.done then
			return
		end

		frame.nameplate = true

		frame.healthBar, frame.castBar = frame:GetChildren()
		local healthBar, castBar = frame.healthBar, frame.castBar
		local glowRegion, overlayRegion, castbarOverlay, shieldedRegion, spellIconRegion, highlightRegion, nameTextRegion, levelTextRegion, bossIconRegion, raidIconRegion, stateIconRegion = frame:GetRegions()

		frame.oldname = nameTextRegion
		nameTextRegion:Hide()

		local newNameRegion = frame:CreateFontString()
		newNameRegion:SetPoint("BOTTOM", healthBar, "TOP", 0, 1)
		newNameRegion:SetWidth(healthBar:GetWidth()-20)
		newNameRegion:SetHeight(fontSize+4)
		newNameRegion:SetFont(font, fontSize, fontOutline)
		newNameRegion:SetTextColor(0.84, 0.75, 0.65)
		newNameRegion:SetShadowOffset(1.25, -1.25)
		frame.name = newNameRegion

		frame.level = levelTextRegion
		levelTextRegion:SetFont(font, fontSize, fontOutline)
		levelTextRegion:SetShadowOffset(1.25, -1.25)

		healthBar:SetStatusBarTexture(barTexture)

		healthBar.hpBackground = healthBar:CreateTexture(nil, "BORDER")
		healthBar.hpBackground:SetAllPoints(healthBar)
		healthBar.hpBackground:SetTexture(barTexture)
		healthBar.hpBackground:SetVertexColor(0.15, 0.15, 0.15)

		healthBar.hpGlow = CreateFrame("Frame", nil, healthBar)
		healthBar.hpGlow:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -4.5, 4)
		healthBar.hpGlow:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 4.5, -4.5)
		healthBar.hpGlow:SetBackdrop(backdrop)
		healthBar.hpGlow:SetBackdropColor(0, 0, 0)
		healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)

		castBar.castbarOverlay = castbarOverlay
		castBar.healthBar = healthBar
		castBar.shieldedRegion = shieldedRegion
		castBar:SetStatusBarTexture(barTexture)

		castBar:HookScript("OnShow", OnShow)
		castBar:HookScript("OnSizeChanged", OnSizeChanged)
		castBar:HookScript("OnValueChanged", OnValueChanged)
		castBar:HookScript("OnEvent", OnEvent)
		castBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
		castBar:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")

		castBar.time = castBar:CreateFontString(nil, "ARTWORK")
		castBar.time:SetPoint("RIGHT", castBar, "LEFT", -2, 1)
		castBar.time:SetFont(font, fontSize, fontOutline)
		castBar.time:SetTextColor(0.84, 0.75, 0.65)
		castBar.time:SetShadowOffset(1.25, -1.25)

		castBar.cbBackground = castBar:CreateTexture(nil, "BORDER")
		castBar.cbBackground:SetAllPoints(castBar)
		castBar.cbBackground:SetTexture(barTexture)
		castBar.cbBackground:SetVertexColor(0.15, 0.15, 0.15)

		castBar.cbGlow = CreateFrame("Frame", nil, castBar)
		castBar.cbGlow:SetPoint("TOPLEFT", castBar, "TOPLEFT", -4.5, 4)
		castBar.cbGlow:SetPoint("BOTTOMRIGHT", castBar, "BOTTOMRIGHT", 4.5, -4.5)
		castBar.cbGlow:SetBackdrop(backdrop)
		castBar.cbGlow:SetBackdropColor(0, 0, 0)
		castBar.cbGlow:SetBackdropBorderColor(0, 0, 0)

		spellIconRegion:SetHeight(20)
		spellIconRegion:SetWidth(20)
		spellIconRegion:SetTexCoord(.1,.9,.1,.9)
		spellIconRegion:SetPoint("RIGHT", castBar.time, "LEFT", -2, 0)
		
		highlightRegion:SetTexture(barTexture)
		highlightRegion:SetVertexColor(0.25, 0.25, 0.25)
		frame.highlight = highlightRegion

		raidIconRegion:ClearAllPoints()
		raidIconRegion:SetPoint("LEFT", healthBar, "RIGHT", 2, 0)
		raidIconRegion:SetHeight(15)
		raidIconRegion:SetWidth(15)

		frame.oldglow = glowRegion
		frame.elite = stateIconRegion
		frame.boss = bossIconRegion
		
		frame.totem = frame:CreateTexture(nil, "OVERLAY")
		frame.totem:SetWidth(opts["Icon size"] or 30)
		frame.totem:SetHeight(opts["Icon size"] or 30)
		frame.totem:SetPoint("BOTTOM", frame, "TOP", 0, 4)

		frame.done = true

		glowRegion:SetTexture(nil)
		overlayRegion:SetTexture(nil)
		shieldedRegion:SetTexture(nil)
		castbarOverlay:SetTexture(nil)
		stateIconRegion:SetTexture(nil)
		bossIconRegion:SetTexture(nil)

		UpdateFrame(frame)
		frame:SetScript("OnShow", UpdateFrame)
		frame:SetScript("OnHide", OnHide)

		frame.elapsed = 0
		frame:SetScript("OnUpdate", ThreatUpdate)
	end

	local numKids = 0
	local lastUpdate = 0
	local OnUpdate = function(self, elapsed)
		lastUpdate = lastUpdate + elapsed

		if lastUpdate > 0.1 then
			lastUpdate = 0

			if WorldFrame:GetNumChildren() ~= numKids then
				numKids = WorldFrame:GetNumChildren()
				for i = 1, select("#", WorldFrame:GetChildren()) do
					frame = select(i, WorldFrame:GetChildren())

					if IsValidFrame(frame) then
						CreateFrame(frame)
					end
				end
			end
		end
	end

	ownNP:SetScript("OnUpdate", OnUpdate)

	--ownNP:RegisterEvent("PLAYER_REGEN_ENABLED")
	function ownNP:PLAYER_REGEN_ENABLED()
		SetCVar("nameplateShowEnemies", 0)
	end

	ownNP:RegisterEvent("PLAYER_REGEN_DISABLED")
	function ownNP.PLAYER_REGEN_DISABLED()
		SetCVar("nameplateShowEnemies", 1)
		SetCVar("ShowClassColorInNameplate", 1)
		SetCVar("UnitNameEnemyTotemName", 1)
		SetCVar("nameplateShowEnemyTotems", 1)
	end

end
tinsert(fui.modules, module) -- finish him!