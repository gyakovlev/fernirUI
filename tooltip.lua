-------------------------------------------------------------------------------------
--Config
-------------------------------------------------------------------------------------
local settings = nil
local relpoint = "BOTTOMRIGHT"
local point = "BOTTOMRIGHT"
local xpoint = -100
local ypoint = 215
local cursor = false
local playerTitles = false
local colorStatusBar = true
local bdcRGB = {.05, .05, .05, 1} --Background color
local bdbcRGB = {.3, .3, .3, 1} --Border color
local gColorRGB = { 255/255, 20/255, 200/255, 1} --Guild Color
local TARGET = "|cfffed100"..TARGET..":|r "
local TARGETYOU = "<You>"
local worldBoss = "??"
local rareElite = "Rare+"
local rare = "Rare"
local ClassColors = {}
-------------------------------------------------------------------------------------
--End Config
-------------------------------------------------------------------------------------

local function GetHexColor(color)
	return ("|cff%.2x%.2x%.2x"):format(color.r * 255, color.g * 255, color.b * 255)
end

for class, color in pairs(RAID_CLASS_COLORS) do
	ClassColors[class] = GetHexColor(RAID_CLASS_COLORS[class])
end

local Reaction = {}
for i = 1, #FACTION_BAR_COLORS do
	Reaction[i] = GetHexColor(FACTION_BAR_COLORS[i])
end

local function getTargetLine(unit)
	if UnitIsUnit(unit, "player") then
		return ("|cffff0000%s|r"):format(TARGETYOU)
	elseif UnitIsPlayer(unit, "player")then
		return ClassColors[select(2, UnitClass(unit, "player"))]..UnitName(unit).."|r"
	elseif UnitReaction(unit, "player") then
		return ("%s%s|r"):format(Reaction[UnitReaction(unit, "player")], UnitName(unit))
	else
		return ("|cffffffff%s|r"):format(UnitName(unit))
	end
end

function GameTooltip_UnitColor(unit)
	local r, g, b
	local reaction = UnitReaction(unit, "player")
	if reaction then
		r = FACTION_BAR_COLORS[reaction].r
		g = FACTION_BAR_COLORS[reaction].g
		b = FACTION_BAR_COLORS[reaction].b
	else
		r = 1.0
		g = 1.0
		b = 1.0
	end
	if UnitPlayerControlled(unit) then
		if UnitCanAttack(unit, "player") then
			if not UnitCanAttack("player", unit) then
				r = 1.0
				g = 1.0
				b = 1.0
			else
				r = FACTION_BAR_COLORS[2].r
				g = FACTION_BAR_COLORS[2].g
				b = FACTION_BAR_COLORS[2].b
			end
		elseif UnitCanAttack("player", unit) then
			r = FACTION_BAR_COLORS[4].r
			g = FACTION_BAR_COLORS[4].g
			b = FACTION_BAR_COLORS[4].b
		elseif UnitIsPVP(unit) then
			r = FACTION_BAR_COLORS[6].r
			g = FACTION_BAR_COLORS[6].g
			b = FACTION_BAR_COLORS[6].b
		end
	end
	if UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit))
		if class then
			r = RAID_CLASS_COLORS[class].r
			g = RAID_CLASS_COLORS[class].g
			b = RAID_CLASS_COLORS[class].b
		end
	end
	return r, g, b
end


local module = {}
module.name = "Tooltips"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
	
	settings = fuiDB
	local opts = settings[module.name]
	
	point = opts["Point"] or "BOTTOMRIGHT"
	xpoint = opts["XPoint"] or -100
	ypoint = opts["YPoint"] or 215
	cursor = opts["Pivot to cursor"] or false
	playerTitles = opts["Player titles"] or false
	colorStatusBar = opts["Colorized status bar"] or true
	bdcRGB = opts["Background color"] or {.05, .05, .05, 1} --Background color
	bdbcRGB = opts["Border color"] or {.3, .3, .3, 1} --Border color
	gColorRGB = opts["Guild color"] or { 255/255, 20/255, 200/255, 1} --Guild Color
	TARGETYOU = opts["Text target you"] or "<You>"
	worldBoss = opts["World boss"] or "??"
	rareElite = opts["Rare and elite mob"] or "Rare+"
	rare = opts["Rare mob"] or "Rare"

	GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	local unit = select(2, self:GetUnit())
	  if unit then
		local level = UnitLevel(unit)
		local color = GetQuestDifficultyColor(level)
		local textLevel = ("%s%d|r"):format(GetHexColor(color), level)
		local unitPvP = ""
		local pattern = "%s"
		if level == "??" or level == -1 then
			textLevel = "|cffff0000??|r"
		end
		
		if UnitIsPlayer(unit) then
				local unitRace = UnitRace(unit)
				local unitClass = UnitClass(unit)
				
				if UnitIsAFK(unit) then
					self:AppendText((" |cff00cc00%s|r"):format(CHAT_FLAG_AFK))
				elseif UnitIsDND(unit) then 
					self:AppendText((" |cff00cc00%s|r"):format(CHAT_FLAG_DND))
				end
				
				for i = 2, GameTooltip:NumLines() do
					if _G["GameTooltipTextLeft"..i]:GetText():find(LEVEL) then
						pattern = pattern.." %s %s %s"
						_G["GameTooltipTextLeft"..i]:SetText((pattern):format(unitPvP, textLevel, unitRace, unitClass):trim())
						break
					end
				end
				
				local unitGuild = GetGuildInfo(unit)
				local text = GameTooltipTextLeft2:GetText()
				if unitGuild and text and text:find("^"..unitGuild) then	
					GameTooltipTextLeft2:SetTextColor(unpack(gColorRGB))
				end
		else
				local text = GameTooltipTextLeft2:GetText()
				local reaction = UnitReaction(unit, "player")
				if reaction and text and not text:find(LEVEL) then
					GameTooltipTextLeft2:SetTextColor(FACTION_BAR_COLORS[reaction].r, FACTION_BAR_COLORS[reaction].g, FACTION_BAR_COLORS[reaction].b)
				end
				if level ~= 0 then
					
						local class = UnitClassification(unit)
						if class == "worldboss" then
							textLevel = ("|cffff0000%s|r"):format(worldBoss)
						elseif class == "rareelite" then
							if level == -1 then
								textLevel = ("|cffff0000??+|r %s"):format(rareElite)
							else
								textLevel = ("%s%d+|r %s"):format(GetHexColor(color), level, rareElite)
							end
						elseif class == "elite" then
							if level == -1 then
								textLevel = "|cffff0000??+|r"
							else
								textLevel = ("%s%d+|r"):format(GetHexColor(color), level)
							end
						elseif class == "rare" then
							if level == -1 then
								textLevel = ("|cffff0000??|r %s"):format(rare)
							else
								textLevel = ("%s%d|r %s"):format(GetHexColor(color), level, rare)
							end
						end
					
					local creatureType = UnitCreatureType(unit)
					for i = 2, GameTooltip:NumLines() do
						if _G["GameTooltipTextLeft"..i]:GetText():find(LEVEL) then
							pattern = pattern.." %s %s"
							_G["GameTooltipTextLeft"..i]:SetText((pattern):format(unitPvP, textLevel, creatureType or ""):trim())
							break
						end
					end
				end
		end

		if UnitIsPVP(unit) then
				for i = 2, GameTooltip:NumLines() do
					if _G["GameTooltipTextLeft"..i]:GetText():find(PVP) then
						_G["GameTooltipTextLeft"..i]:SetText(nil)
						break
					end
				end
		end

		if (UnitExists(unit .. "target")) then
			local text = ("%s%s"):format(TARGET, getTargetLine(unit.."target"))
			GameTooltip:AddLine(text)	
		end

		if colorStatusBar then
			local r, g, b = GameTooltip_UnitColor(unit)
			GameTooltipStatusBar:SetStatusBarColor(r, g, b)
		end
		
		if (UnitIsDead(unit) or UnitIsGhost(unit)) then
					GameTooltipStatusBar:Hide()
		  else
				self:AddLine(" ")
				GameTooltipStatusBar:Show()
				GameTooltipStatusBar:ClearAllPoints()
				GameTooltipStatusBar:SetPoint("LEFT", self:GetName().."TextLeft"..self:NumLines(), "LEFT", 0, -1)
				GameTooltipStatusBar:SetPoint("RIGHT", self, "RIGHT", -10, -1)
		end
	  end
	end)

	GameTooltipStatusBar:SetStatusBarTexture(settings["Main"].Texture)
	GameTooltipStatusBar:GetStatusBarTexture():SetHorizTile(false)
	GameTooltipStatusBar:SetHeight(10)
	-- Statusbar
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:SetPoint("TOPLEFT", GameTooltip, 4, -4)
	GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip, -4, 4)
	GameTooltipStatusBar:SetAlpha(1)
	GameTooltipStatusBar:SetFrameLevel(1)
	GameTooltipStatusBar:SetStatusBarColor(0, 0, 0)

	local bg = GameTooltipStatusBar:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints(GameTooltipStatusBar)
	bg:SetTexture(settings["Main"].Texture)
	bg:SetVertexColor(0.5, 0.5, 0.5, 0.5)

	local function ShortValue(value)
		if value >= 1e7 then
			return ('%.1fm'):format(value / 1e6):gsub('%.?0+([km])$', '%1')
		elseif value >= 1e6 then
			return ('%.2fm'):format(value / 1e6):gsub('%.?0+([km])$', '%1')
		elseif value >= 1e5 then
			return ('%.0fk'):format(value / 1e3)
		elseif value >= 1e3 then
			return ('%.1fk'):format(value / 1e3):gsub('%.?0+([km])$', '%1')
		else
			return value
		end
	end

	GameTooltipStatusBar:SetScript("OnValueChanged", function(self, value)
		if not value then
			return
		end
		local min, max = self:GetMinMaxValues()
		if (value < min) or (value > max) then
			return
		end
		local unit  = select(2, GameTooltip:GetUnit())
		if unit then
			min, max = UnitHealth(unit), UnitHealthMax(unit)
			if not self.text then
				self.text = self:CreateFontString(nil, "OVERLAY")
				self.text:SetPoint("CENTER", GameTooltipStatusBar)
				self.text:SetFont(settings["Main"].Font, GameTooltipStatusBar:GetHeight(), "THINOUTLINE")
				self.text:SetJustifyV("MIDDLE")
			end
			self.text:Show()
			local hp = ShortValue(min).." / "..ShortValue(max)
			self.text:SetText(hp)
		end
	end)

	local Tooltips = {GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3}
	for i, v in ipairs(Tooltips) do
		SetTemplate(v)
		for i = 1, select('#', v:GetRegions()) do
		  local obj = select(i, v:GetRegions())
		  if (obj and obj:GetObjectType() == 'FontString') then
				obj:SetFont(settings["Main"].Font, settings["Main"].FontSize, "THINOUTLINE")
				obj:GetParent():SetScale(1)
		  end
		end

		v:SetScript("OnShow", function(self)
			self:SetBackdropColor(unpack(bdcRGB))
			local name, item = self:GetItem()
			if(item) then
				local quality = select(3, GetItemInfo(item))
				if(quality) then
					local r, g, b = GetItemQualityColor(quality)
					self:SetBackdropBorderColor(r, g, b)
				end
			else
				self:SetBackdropBorderColor(unpack(bdbcRGB))
			end
		end)
	end

	hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
		local frame = GetMouseFocus()
		if cursor and frame == WorldFrame then
			tooltip:SetOwner(parent, "ANCHOR_CURSOR")
		else
			tooltip:SetOwner(parent, "ANCHOR_NONE")
			tooltip:SetPoint(point, UIParent, relpoint, xpoint, ypoint)
		end
		tooltip.default = 1
	end)

	if playerTitles then return end
	GameTooltip:HookScript("OnTooltipSetUnit", function(self)
		local unitName, unit = self:GetUnit()
		if unit and UnitIsPlayer(unit) then
			local title = UnitPVPName(unit)
			if title then
				title = title:gsub(unitName, "")
				name = GameTooltipTextLeft1:GetText()
				name = name:gsub(title, "")
				if name then GameTooltipTextLeft1:SetText(name) end
			end
		end
	end)

	--[[
		Shadow, Mal'Ganis (US)
	]]

	hooksecurefunc("SetItemRef", function(link, text, button)
		local icon
		local type, id = string.match(link, "^([a-z]+):(%d+)")
		if( type == "item" ) then
			icon = select(10, GetItemInfo(link))
		elseif( type == "spell" or type == "enchant" ) then
			icon = select(3, GetSpellInfo(id))
		elseif( type == "achievement" ) then
			icon = select(10, GetAchievementInfo(id))
		end	
		
		if( not icon ) then
			ItemRefTooltipTexture10:Hide()

			ItemRefTooltipTextLeft1:ClearAllPoints()
			ItemRefTooltipTextLeft1:SetPoint("TOPLEFT", ItemRefTooltip, "TOPLEFT", 8, -10)

			ItemRefTooltipTextLeft2:ClearAllPoints()
			ItemRefTooltipTextLeft2:SetPoint("TOPLEFT", ItemRefTooltipTextLeft1, "BOTTOMLEFT", 0, -2)
			return
		end

		ItemRefTooltipTexture10:ClearAllPoints()
		ItemRefTooltipTexture10:SetPoint("TOPLEFT", ItemRefTooltip, "TOPLEFT", 8, -7)
		ItemRefTooltipTexture10:SetTexture(icon)
		ItemRefTooltipTexture10:SetHeight(20)
		ItemRefTooltipTexture10:SetWidth(20)
		ItemRefTooltipTexture10:Show()
		ItemRefTooltipTexture10:SetTexCoord(.1,.9,.1,.9)
		
		ItemRefTooltipTextLeft1:ClearAllPoints()
		ItemRefTooltipTextLeft1:SetPoint("TOPLEFT", ItemRefTooltipTexture10, "TOPLEFT", 24, -2)

		ItemRefTooltipTextLeft2:ClearAllPoints()
		ItemRefTooltipTextLeft2:SetPoint("TOPLEFT", ItemRefTooltip, "TOPLEFT", 8, -28)
		
		local textRight = ItemRefTooltipTextLeft1:GetRight()
		local closeLeft = ItemRefCloseButton:GetLeft()
		
		if( closeLeft <= textRight ) then
			ItemRefTooltip:SetWidth(ItemRefTooltip:GetWidth() + (textRight - closeLeft))
		end
	end)

end
tinsert(fui.modules, module) -- finish him!