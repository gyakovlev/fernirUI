local settings = nil

local module = {}
module.name = "OmniCC"
module.Init = function()
	if not fuiDB.modules[module.name] then return end

	settings = fuiDB
	local opts = settings[module.name]
	
	local OmniCC_Settings = {
		FontSize = opts["Font size"] or 13,                         -- Font size for frames of NormalizedSize, will be scaled for other sizes
		NormalizedSize = opts["Normalized size"] or 31,                   -- At this frame width font will have 100% size
		ChangeColorTime = opts["Change color time"] or 5,                   -- Time in seconds when text color will be changed
		longRGB = opts["Long color"] or {.8, .8, .8}, -- Color for cooldowns longer than ChangeColorTime. More info: http://www.wowwiki.com/API_FontString_SetTextColor
		shortRGB = opts["Short color"] or {1, .2, .2},  -- Color for cooldowns shorter than ChangeColorTime.
		Point = opts["Pivot point"] or "BOTTOM", -- Where to place cooldown text. More info: http://www.wowwiki.com/API_Region_SetPoint
	}

	local function GetFormattedTime(s)
		 if s >= 3600 then
			return format('%dh', floor(s/3600 + 0.5)), s % 3600
		elseif s >= 60 then
			return format('%dm', floor(s/60 + 0.5)), s % 60
		end
		return floor(s + 0.5), s - floor(s)
	end

	local function Timer_OnUpdate(self, elapsed)
		if self.text:IsShown() then
			if self.nextUpdate > 0 then
				self.nextUpdate = self.nextUpdate - elapsed
			else
				local remain = self.duration - (GetTime() - self.start)
				if floor(remain + 0.5) > 0 then
					local time, nextUpdate = GetFormattedTime(remain)
					self.text:SetText(time)
					self.nextUpdate = nextUpdate
						 if(floor(remain + 0.5) > OmniCC_Settings.ChangeColorTime) then
							  self.text:SetTextColor(unpack(OmniCC_Settings.longRGB))
						 else
							  self.text:SetTextColor(unpack(OmniCC_Settings.shortRGB))
						 end
				else
					self.text:Hide()
				end
			end
		end
	end

	local function Timer_Create(self)
		if self:GetParent() then
		 local realsize = self:GetParent():GetWidth() * OmniCC_Settings.FontSize / OmniCC_Settings.NormalizedSize
		 if(realsize>8) then
			  local text = self:CreateFontString(nil, "OVERLAY")
			  text:SetPoint(OmniCC_Settings.Point, 0, 0)
			  text:SetJustifyH("CENTER")
			  text:SetFont(settings["Main"].Font, realsize, "THINOUTLINE")
			  self.text = text
			  self:SetScript("OnUpdate", Timer_OnUpdate)

			  return text
		 end
		end
	end

	local function Timer_Start(self, start, duration)
		self.start = start
		self.duration = duration
		self.nextUpdate = 0

		local text = self.text or Timer_Create(self)
		if text then
			text:Show()
		end
	end
	
	local methods = getmetatable(ActionButton1Cooldown).__index
	hooksecurefunc(methods, "SetCooldown", function(self, start, duration)
		if(start>0 and duration>3) then
			Timer_Start(self, start, duration)
		else
			local text = self.text
			if text then
				text:Hide()
			end
		end
	end)
end
tinsert(fui.modules, module) -- finish him!