
local module = {}
module.name = "SpellAlerter"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
	local settings = fuiDB
	local opts = settings[module.name]
	
	local ncSpellalert = CreateFrame("Frame", "ncSpellalert")
	local band, bor = bit.band, bit.bor
	local enemy = bor(COMBATLOG_OBJECT_REACTION_HOSTILE, COMBATLOG_OBJECT_TYPE_PLAYER)
	local deathcoil = GetSpellInfo(62904)
	local owncolor = opts["Color"] or {1, .2, .2, 1}
	local special = {
		[GetSpellInfo(59752)] = 1, -- horde pvp trink
		[GetSpellInfo(42292)] = 1, -- ally
		[GetSpellInfo(7744)] = 2, -- wotf
		[GetSpellInfo(57073)] = 3, -- drink
		[GetSpellInfo(8129)] = 4, -- Mana burn
	}
	local function isenemy(flags) return band(flags, enemy)==enemy end
	local function tohex(val) return string.format("%.2x", val) end
	local function colortostr(color) if not color then return "ffffff" end return tohex(color[1]*255)..tohex(color[2]*255)..tohex(color[3]*255) end
	local function getclasscolor(class) local color = RAID_CLASS_COLORS[class] if not color then return "ffffff" end return tohex(color.r*255)..tohex(color.g*255)..tohex(color.b*255) end
	local function colorize(name) if name then return "|cff"..getclasscolor(select(2,UnitClass(name)))..name.."|r" else return nil end end
	local function createmessageframe(name)
		local f = CreateFrame("MessageFrame", name, UIParent)
		f:SetPoint("LEFT", UIParent)
		f:SetPoint("RIGHT", UIParent)
		f:SetHeight(25)
		f:SetInsertMode("TOP")
		f:SetFrameStrata("HIGH")
		f:SetTimeVisible(1)
		f:SetFadeDuration(3)
		f:SetFont(settings["Main"].Font, 23, "OUTLINE")
		return f
	end

	local spell = createmessageframe()
	spell:SetPoint("TOP", 0, -200)
	local buff = createmessageframe()
	buff:SetPoint("BOTTOM", spell, "TOP", 0, 2)

	function ncSpellalert:PLAYER_LOGIN()
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self:ZONE_CHANGED_NEW_AREA()
		self:UnregisterEvent("PLAYER_LOGIN")
	end

	function ncSpellalert:ZONE_CHANGED_NEW_AREA()
		local pvp = GetZonePVPInfo()
		if not pvp or pvp ~= "sanctuary" then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		else
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		end
	end

	function ncSpellalert:COMBAT_LOG_EVENT_UNFILTERED(event, timestamp, eventType, sourceGUID, sourcename, sourceFlags, destGUID, destname, destFlags, spellid, spellname)
		if (spellname==deathcoil and select(2, UnitClass(sourceGUID))=="DEATHKNIGHT") or spellid == 59752 or spellid == 42292 or spellid == 7744 then return end -- ignores
		if eventType == "SPELL_AURA_APPLIED" and special[spellname] and isenemy(destFlags) then
			buff:AddMessage(format(ACTION_SPELL_AURA_APPLIED_BUFF_FULL_TEXT_NO_SOURCE, nil, "|cff"..colortostr(owncolor)..spellname.."|r", nil, colorize(destname)))
		elseif eventType == "SPELL_CAST_START" and special[spellname] and isenemy(sourceFlags) then
			local color = "ff0000"
			if color then
				local template
				if sourcename and destname then
					template = ACTION_SPELL_CAST_START_FULL_TEXT_NO_SOURCE
				elseif sourcename then
					template = ACTION_SPELL_CAST_START_FULL_TEXT_NO_DEST
				elseif destname then
					template = ACTION_SPELL_CAST_START_FULL_TEXT
				end
				spell:AddMessage(format(template, colorize(sourcename), "|cff"..color..spellname.."|r", nil, colorize(destname)))
			end
		end
	end

	function ncSpellalert:UNIT_SPELLCAST_SUCCEEDED(event, unit, spell, rank)
		event = special[spell]
		if event and UnitIsEnemy("player", unit) then
			if event == 1 and opts["PVP trinket"] then
				buff:AddMessage(format("%s использовал |cff"..colortostr(owncolor).."PvP тринку|r.", colorize(UnitName(unit))))
			elseif event == 2 and opts["WOTF using"] then
				buff:AddMessage(format("%s заюзал |cff"..colortostr(owncolor).."ВОТФ|r.", colorize(UnitName(unit))))
			elseif event == 3 and opts["Watch drinking"] then
				buff:AddMessage(format("%s пьет!", colorize(UnitName(unit))))
			elseif event == 4 and opts["Watch manaburn"] then
				buff:AddMessage(format("%s жжет ману!", colorize(UnitName(unit))))
			end
		end
	end

	ncSpellalert:RegisterEvent("PLAYER_LOGIN")
	ncSpellalert:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)

end
tinsert(fui.modules, module) -- finish him!