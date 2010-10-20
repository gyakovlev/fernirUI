if not oUF then return end

local TalentsUpdate = function(self, elapsed)
	if ( self.endTime < GetTime() ) then
		usedTalentss[self.guid] = false
		local unit = arenaGUID[self.guid]
		if ( unit and arenaFrame[unit] ) then
			if ( arenaFrame[unit].Talents.TalentsUpAnnounce ) then
				SendChatMessage("Talents ready: "..UnitName(unit).." "..UnitClass(unit), "PARTY")
			end
		end
		self:SetScript("OnUpdate", nil)
	end
end

local Update = function(self, event, ...)
	if ( event == "COMBAT_LOG_EVENT_UNFILTERED" ) then
		local timestamp, eventType, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID, spellName = ...
		if ( eventType == "SPELL_CAST_SUCCESS" ) then
			-- enemy Talents usage
			if ( spellID == 59752 or spellID == 42292 ) then
				TalentsUsed(sourceGUID, 120)
			end
			-- WotF
			if ( spellID == 7744 ) then
				TalentsUsed(sourceGUID, 45)
			end
		end
	elseif ( event == "ARENA_OPPONENT_UPDATE" ) then
		local unit, type = ...
		if ( type == "seen" ) then
			if ( UnitExists(unit) and UnitIsPlayer(unit) and arenaFrame[unit] ) then
				arenaGUID[UnitGUID(unit)] = unit
				arenaFrame[unit].Talents.Icon:SetTexture(GetTalentsIcon(unit))
			end
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		for k, v in pairs(TalentsFrame) do
			v:SetScript("OnUpdate", nil)
		end
		for k, v in pairs(arenaFrame) do
			CooldownFrame_SetTimer(v.Talents.cooldownFrame, 1, 1, 1)
		end
		arenaGUID  = {}
		usedTalentss = {}
		TalentsFrame = {}
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
frame:RegisterEvent("ARENA_OPPONENT_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", Update)

oUF.Tags['[talents]'] = function(unit)
	return string.format("|T%s:20:20:0:0|t", "")
end

local Enable = function(self)
	if (self.Talents) then
		self.Talents.cooldownFrame = CreateFrame("Cooldown", nil, self.Talents)
		self.Talents.cooldownFrame:SetAllPoints(self.Talents)
		self.Talents.Icon = self.Talents:CreateTexture(nil, "BORDER")
		self.Talents.Icon:SetAllPoints(self.Talents)
		self.Talents.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
		arenaFrame[self.unit] = self
	end
end
 
local Disable = function(self)
	if ( self.Talents ) then
		arenaFrame[self.unit] = nil
	end
end
 
oUF:AddElement('Talents', function() return end, Enable, Disable)