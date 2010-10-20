local settings = nil

local module = {}
module.name = "CoolLine"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
	
	CoolLine = CreateFrame("Frame", "CoolLine", UIParent)
	CoolLine.loaded = true
	
	settings = fuiDB
	
	local self = CoolLine
	self:SetScript("OnEvent", function(this, event, ...) this[event](this, ...) end)

	local _G = getfenv(0)
	local pairs, ipairs = pairs, ipairs
	local tinsert, tremove = tinsert, tremove
	local GetTime = GetTime
	local random = math.random
	local strmatch = strmatch
	local UnitExists, HasPetUI = UnitExists, HasPetUI

	local db, block
	local backdrop = { edgeSize=16, }
	local section, iconsize = 0, 0
	local tick0, tick1, tick10, tick30, tick60, tick120, tick300
	local BOOKTYPE_SPELL = BOOKTYPE_SPELL
	local spells = { [BOOKTYPE_SPELL] = { }, }
	local frames, cooldowns = { }, { }

	local SetValue, updatelook, createfs, ShowOptions, RuneCheck
	local function SetValueH(this, v, just)
		this:SetPoint(just or "CENTER", self, "LEFT", v, 0)
	end
	local function SetValueHR(this, v, just)
		this:SetPoint(just or "CENTER", self, "LEFT", db.w - v, 0)
	end
	local function SetValueV(this, v, just)
		this:SetPoint(just or "CENTER", self, "BOTTOM", 0, v)
	end
	local function SetValueVR(this, v, just)
		this:SetPoint(just or "CENTER", self, "BOTTOM", 0, db.h - v)
	end

		db = {
				w = (_G["MultiBarBottomLeftButton12"]:GetRight()-_G["MultiBarBottomLeftButton1"]:GetLeft()) or 394, h = 18, x = 0, y = _G["ChatFrame1"]:GetTop(),
				bgcolor = { r = 0, g = 0, b = 0, a = .5, },
				border = "Blizzard Dialog",
				font = settings["Main"].Font,
				fontsize = 10,
				fontcolor = { r = 1, g = 1, b = 1, a = 1, },
				spellcolor = { r = 0.8, g = 0.4, b = 0, a = 1, },
				nospellcolor = { r = 0, g = 0, b = 0, a = 1, },
				inactivealpha = 1,
				activealpha = 1,
				iconplus = 2,
				block = {  -- [spell or item name] = true,
					[GetItemInfo(6948) or "Hearthstone"] = true,  -- Hearthstone
				},
			}
		block = db.block
		
		if select(2, UnitClass("player")) == "DEATHKNIGHT" then
			local runecd = {  -- fix by NeoSyrex
				[GetSpellInfo(50977) or "Death Gate"] = 11,
				[GetSpellInfo(43265) or "Death and Decay"] = 11,
				[GetSpellInfo(48263) or "Frost Presence"] = 1,
				[GetSpellInfo(48266) or "Blood Presence"] = 1,
				[GetSpellInfo(48265) or "Unholy Presence"] = 1, 
				[GetSpellInfo(42650) or "Army of the Dead"] = 11,
				[GetSpellInfo(49222) or "Bone Shield"] = 11,
				[GetSpellInfo(47476) or "Strangulate"] = 11,
				[GetSpellInfo(51052) or "Anti-Magic Zone"] = 11,
				[GetSpellInfo(63560) or "Ghoul Frenzy"] = 10,
				[GetSpellInfo(49184) or "Howling Blast"] = 8,
				[GetSpellInfo(51271) or "Unbreakable Armor"] = 11,
				[GetSpellInfo(55233) or "Vampiric Blood"] = 11,
				[GetSpellInfo(49005) or "Mark of Blood"] = 11,
				[GetSpellInfo(48982) or "Rune Tap"] = 11,
			}
			RuneCheck = function(name, duration)
				local rc = runecd[name]
				if not rc or (rc <= duration and (rc > 10 or rc >= duration)) then
					return true
				end
			end
		end
		
		createfs = function(f, text, offset, just)
			local fs = f or self.overlay:CreateFontString(nil, "OVERLAY")
			fs:SetFont(settings["Main"].Font, 8, "THINOUTLINE")
			fs:SetTextColor(db.fontcolor.r, db.fontcolor.g, db.fontcolor.b, db.fontcolor.a)
			fs:SetText(text)
			fs:SetWidth(db.fontsize * 3)
			fs:SetHeight(db.fontsize + 2)
			fs:SetShadowColor(db.bgcolor.r, db.bgcolor.g, db.bgcolor.b, db.bgcolor.a)
			fs:SetShadowOffset(1, -1)
			if just then
				fs:ClearAllPoints()
				offset = offset + ((just == "LEFT" and 1) or -1)
				fs:SetJustifyH(just)
			else
				fs:SetJustifyH("CENTER")
			end
			SetValue(fs, offset, just)
			return fs
		end
		
		updatelook = function()
			self:SetWidth(db.w or 130)
			self:SetHeight(db.h or 18)
			local cdf = self
			
			local checkpos = function()
				local bsize, bspace = settings["ActionBars"].ButtonSize, settings["ActionBars"].ButtonSpace
				local bl, br, r, l = SHOW_MULTI_ACTIONBAR_1 or 0, SHOW_MULTI_ACTIONBAR_2 or 0, SHOW_MULTI_ACTIONBAR_3 or 0, SHOW_MULTI_ACTIONBAR_4 or 0
				return (bl+br+1)*(bsize+bspace)+bspace
			end
			
			cdf:SetPoint("BOTTOM", 0, checkpos())

			MultiBarBottomRight:HookScript("OnShow", function()
				cdf:SetPoint("BOTTOM", 0, checkpos())
			end)
			MultiBarBottomRight:HookScript("OnHide", function()
				cdf:SetPoint("BOTTOM", 0, checkpos())
			end)
			MultiBarBottomLeft:HookScript("OnShow", function()
				cdf:SetPoint("BOTTOM", 0, checkpos())
			end)
			MultiBarBottomLeft:HookScript("OnHide", function()
				cdf:SetPoint("BOTTOM", 0, checkpos())
			end)
			
			SetTemplate(self)
			
			self.overlay = self.overlay or CreateFrame("Frame", nil, self)
			self.overlay:SetFrameLevel(11)

			section = db.w / 6
			iconsize = db.h + (db.iconplus or 0)
			SetValue = (db.reverse and SetValueVR or SetValueV) and (db.reverse and SetValueHR or SetValueH)
			
			tick0 = createfs(tick0, "0", 0, "LEFT")
			tick1 = createfs(tick1, "1", section)
			tick10 = createfs(tick10, "3", section * 2)
			tick30 = createfs(tick30, "10", section * 3)
			tick60 = createfs(tick60, "60", section * 4)
			tick120 = createfs(tick120, "2m", section * 5)
			tick300 = createfs(tick300, "6m", section * 6, "RIGHT")

			CoolLine:SetAlpha((CoolLine.unlock or #cooldowns > 0) and db.activealpha or db.inactivealpha)
			for _, frame in ipairs(cooldowns) do
				frame:SetWidth(iconsize)
				frame:SetHeight(iconsize)
			end
		end
		
		self:RegisterEvent("PLAYER_LOGIN")
		
	--------------------------------
	function CoolLine:PLAYER_LOGIN()
	--------------------------------
		self.PLAYER_LOGIN = nil
		self:RegisterEvent("SPELL_UPDATE_COOLDOWN")
		self:RegisterEvent("SPELLS_CHANGED")
		updatelook()
		self:SPELLS_CHANGED()
		self:SPELL_UPDATE_COOLDOWN()
		self:SetAlpha((#cooldowns == 0 and db.inactivealpha) or db.activealpha)
	end

	local elapsed, throt, ptime, isactive = 0, 1.5, 0, false

	local function ClearCooldown(f, name)
		name = name or (f and f.name)
		for index, frame in ipairs(cooldowns) do
			if frame.name == name then
				frame:Hide()
				frame.name = nil
				frame.endtime = nil
				tinsert(frames, tremove(cooldowns, index))
				break
			end
		end
	end

	local function SetupIcon(frame, position, tthrot, active, fl)
		throt = (throt < tthrot and throt) or tthrot
		isactive = active or isactive
		if fl then
			frame:SetFrameLevel(random(1,4) * 2 + 2)
		end
		SetValue(frame, position)
	end

	local function OnUpdate(this, a1, ctime, dofl)
		elapsed = elapsed + a1
		if elapsed < throt then return end
		elapsed = 0
		
		if #cooldowns == 0 then
			if not CoolLine.unlock then
				self:SetScript("OnUpdate", nil)
				self:SetAlpha(db.inactivealpha)
			end
			return
		end
		
		ctime = ctime or GetTime()
		if ctime > ptime then
			dofl, ptime = true, ctime + 0.4
		end
		isactive, throt = false, 1.5
		for index, frame in pairs(cooldowns) do
			local remain = frame.endtime - ctime
			if remain < 3 then
				if remain > 1 then
					SetupIcon(frame, section * (remain + 1) * 0.5, 0.02, true, dofl)
				elseif remain > 0.3 then
					SetupIcon(frame, section * remain, 0, true, dofl)
				elseif remain > 0 then
					local size = iconsize * (0.5 - remain) * 5
					frame:SetWidth(size)
					frame:SetHeight(size)
					SetupIcon(frame, section * remain, 0, true, dofl)
				elseif remain > -1 then
					SetupIcon(frame, 0, 0, true, dofl)
					frame:SetAlpha(1 + remain)  -- fades
				else
					throt = (throt < 0.2 and throt) or 0.2
					isactive = true
					ClearCooldown(frame)
				end
			elseif remain < 10 then
				SetupIcon(frame, section * (remain + 11) * 0.143, remain > 4 and 0.05 or 0.02, true, dofl)  -- 2 + (remain - 3) / 7
			elseif remain < 60 then
				SetupIcon(frame, section * (remain + 140) * 0.02, 0.12, true, dofl)  -- 3 + (remain - 10) / 50
			elseif remain < 120 then
				SetupIcon(frame, section * (remain + 180) * 0.01666, 0.25, true, dofl)  -- 4 + (remain - 60) / 60
			elseif remain < 360 then
				SetupIcon(frame, section * (remain + 1080) * 0.004166, 1.2, true, dofl)  -- 5 + (remain - 120) / 240
				frame:SetAlpha(1)
			else
				SetupIcon(frame, 6 * section, 2, false, dofl)
			end
		end
		if not isactive and not CoolLine.unlock then
			self:SetAlpha(db.inactivealpha)
		end
	end

	local function NewCooldown(name, icon, endtime, isplayer)
		local f
		for index, frame in pairs(cooldowns) do
			if frame.name == name and frame.isplayer == isplayer then
				f = frame
				break
			elseif frame.endtime == endtime then
				return
			end
		end
		if not f then
			f = f or tremove(frames)
			if not f then
				f = CreateFrame("Frame", nil, CoolLine)
				f.icon = f:CreateTexture(nil, "ARTWORK")
				f.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
				f.icon:SetPoint("TOPLEFT", 1, -1)
				f.icon:SetPoint("BOTTOMRIGHT", -1, 1)
			end
			tinsert(cooldowns, f)
		end
		local ctime = GetTime()
		f:SetWidth(iconsize)
		f:SetHeight(iconsize)
		f:SetAlpha((endtime - ctime > 360) and 0.6 or 1)
		f.name, f.endtime, f.isplayer = name, endtime, isplayer
		f.icon:SetTexture(icon)
		local c = db[isplayer and "spellcolor" or "nospellcolor"]
		f:SetBackdropColor(c.r, c.g, c.b, c.a)
		f:Show()
		self:SetScript("OnUpdate", OnUpdate)
		self:SetAlpha(db.activealpha)
		OnUpdate(self, .1, ctime)
	end
	CoolLine.NewCooldown, CoolLine.ClearCooldown = NewCooldown, ClearCooldown

	do  -- cache spells that have a cooldown
		local CLTip = CreateFrame("GameTooltip", "CLTip", CoolLine, "GameTooltipTemplate")
		CLTip:SetOwner(CoolLine, "ANCHOR_NONE")
		local GetSpellName = GetSpellName
		local cooldown1 = gsub(SPELL_RECAST_TIME_MIN, "%%%.%d[fg]", "(.+)")
		local cooldown2 = gsub(SPELL_RECAST_TIME_SEC, "%%%.%d[fg]", "(.+)")
		local function CheckRight(rtext)
			local text = rtext and rtext:GetText()
			if text and (strmatch(text, cooldown1) or strmatch(text, cooldown2)) then
				return true
			end
		end
		local function CacheBook(btype)
			local name, last
			local sb = spells[btype]
			for i = 1, 500, 1 do
				name = GetSpellName(i, btype)
				if not name then break end
				if name ~= last then
					last = name
					if sb[name] then
						sb[name] = i
					else
						CLTip:SetSpell(i, btype)
						if CheckRight(CLTipTextRight2) or CheckRight(CLTipTextRight3) or CheckRight(CLTipTextRight4) then
							sb[name] = i
						end
					end
				end
			end
		end
		----------------------------------
		function CoolLine:SPELLS_CHANGED()
		----------------------------------
			CacheBook(BOOKTYPE_SPELL)
		end
	end

	do  -- scans spellbook to update cooldowns, throttled since the event fires a lot
		local selap = 0
		local spellthrot = CreateFrame("Frame", nil, CoolLine)
		local GetSpellCooldown, GetSpellTexture = GetSpellCooldown, GetSpellTexture
		local function CheckSpellBook(btype)
			for name, id in pairs(spells[btype]) do
				local start, duration, enable = GetSpellCooldown(id, btype)
				if enable == 1 and start > 0 and not block[name] and (not RuneCheck or RuneCheck(name, duration))then
					if duration > 2.5 then
						NewCooldown(name, GetSpellTexture(id, btype), start + duration, btype == BOOKTYPE_SPELL)
					else
						for index, frame in ipairs(cooldowns) do
							if frame.name == name then
								if frame.endtime > start + duration + 0.1 then
									frame.endtime = start + duration
								end
								break
							end
						end
					end
				else
					ClearCooldown(nil, name)
				end
			end
		end
		spellthrot:SetScript("OnUpdate", function(this, a1)
			selap = selap + a1
			if selap < 0.33 then return end
			selap = 0
			this:Hide()
			CheckSpellBook(BOOKTYPE_SPELL)
		end)
		spellthrot:Hide()
		-----------------------------------------
		function CoolLine:SPELL_UPDATE_COOLDOWN()
		-----------------------------------------
			spellthrot:Show()
		end
	end
	
end
tinsert(fui.modules, module) -- finish him!