--Addon author: Allez

local module = {}
module.name = "ThreatMeter"
module.Init = function()
	if not fuiDB.modules[module.name] then return end

	settings = fuiDB
	local opts = settings[module.name]
	
	-- Config start
	local texture = settings["Main"].Texture
	local width, height = opts["Width"] or 120, opts["Height"] or 13
	local font_size = settings["Main"].FontSize
	local anchor = opts["Anchor"] or "CENTER"
	local pos_x, pos_y = opts["PosX"] or 0, opts["PosY"] or -185
	local spacing = opts["Spacing"] or 3
	local maxBars = opts["MaxBars"] or 3
	-- Config end

	local bar, tList, barList = {}, {}, {}
	local max = math.max
	local timer = 0
	local targeted = false

	RAID_CLASS_COLORS["PET"] = {r = 0, g = 0.7, b = 0,}

	local CreateFS = function(frame, fsize, fstyle)
		local fstring = frame:CreateFontString(nil, "OVERLAY")
		fstring:SetFont(settings["Main"].Font, fsize, fstyle)
		return fstring
	end

	local truncate = function(value)
		if value >= 1e6 then
			return string.format("%.2fm", value / 1e6)
		elseif value >= 1e4 then
			return string.format("%.1fk", value / 1e3)
		else
			return string.format("%.0f", value)
		end
	end

	local AddUnit = function(unit)
		local threatpct, rawpct, threatval = select(3, UnitDetailedThreatSituation(unit, "target"))
		if threatval and threatval < 0 then
			threatval = threatval + 410065408
		end
		local guid = UnitGUID(unit)
		if not tList[guid] then
			tinsert(barList, guid)
			tList[guid] = {
				name = UnitName(unit),
				class = UnitIsPlayer(unit) and select(2, UnitClass(unit)) or "PET",
			}
		end
		tList[guid].pct = threatpct or 0 
		tList[guid].val = threatval or 0
	end

	local CheckUnit = function(unit)
		if UnitExists(unit) and UnitIsVisible(unit) then
			AddUnit(unit)
			if UnitExists(unit.."pet") then
				AddUnit(unit.."pet")
			end
		end
	end

	local CreateBar = function()
		local bar = CreateFrame("Statusbar", nil, UIParent)
		bar:SetSize(width, height)
		bar:SetStatusBarTexture(texture)
		bar:SetMinMaxValues(0, 100)
		bar.bg = CreateFrame("Frame", nil, bar)
		bar.bg:SetPoint("TOPLEFT", bar, "TOPLEFT", -1, 1)
		bar.bg:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 1, -1)
		bar.bg:SetFrameStrata("LOW")
		SetTemplate(bar.bg)
		bar.left = CreateFS(bar, font_size)
		bar.left:SetPoint("LEFT", 2, 0)
		bar.left:SetJustifyH("LEFT")
		bar.right = CreateFS(bar, font_size)
		bar.right:SetPoint("RIGHT", -2, 0)
		bar.right:SetJustifyH("RIGHT")
		bar:Hide()
		return bar
	end

	local SortMethod = function(a, b)
		return tList[b].pct < tList[a].pct
	end

	local UpdateBars = function()
		for i, v in pairs(bar) do
			v:Hide()
		end
		table.sort(barList, SortMethod)
		for i = 1, #barList do
			cur = tList[barList[i]]
			max = tList[barList[1]]
			if i > maxBars or not cur then break end
			if not bar[i] then 
				bar[i] = CreateBar()
				bar[i]:SetPoint(anchor, pos_x, pos_y - (13 + spacing) * (i-1))
			end
			bar[i]:SetValue(100 * cur.pct / max.pct)
			local color = RAID_CLASS_COLORS[cur.class]
			bar[i]:SetStatusBarColor(color.r, color.g, color.b)
			bar[i].left:SetText(cur.name)
			bar[i].right:SetText(string.format("%s (%d%%)", truncate(cur.val/100), cur.pct))
			bar[i]:Show()
		end
	end

	local UpdateThreat = function()
		if targeted then
			if GetNumRaidMembers() > 0 then
				for i = 1, GetNumRaidMembers(), 1 do
					CheckUnit("raid"..i)
				end
			elseif GetNumPartyMembers() > 0 then
				for i = 1, GetNumPartyMembers(), 1 do
					CheckUnit("party"..i)
				end
			end
			CheckUnit("targettarget")
			CheckUnit("player")
			UpdateBars()
		end
	end

	local OnEvent = function(self, event, ...)
		if event == "PLAYER_TARGET_CHANGED" then
			if UnitExists("target") and not UnitIsDead("target") and not UnitIsPlayer("target") and UnitCanAttack("player", "target") then
				targeted = true
			else
				targeted = false
			end
			wipe(tList)
			wipe(barList)
			UpdateBars()
		elseif event == "UNIT_THREAT_LIST_UPDATE" then
			UpdateThreat()
		elseif event == "PLAYER_REGEN_ENABLED" then
			wipe(tList)
			wipe(barList)
			UpdateBars()
		end
	end

	local addon = CreateFrame("frame")
	addon:SetScript("OnEvent", OnEvent)
	addon:RegisterEvent("PLAYER_TARGET_CHANGED")
	addon:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
	addon:RegisterEvent("PLAYER_REGEN_ENABLED")

end
tinsert(fui.modules, module) -- finish him!