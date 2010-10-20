local module = {}
module.name = "ArenaTracker"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
	
	local settings = fuiDB
	local opts = settings[module.name]
	
	local spells = {
		[1766] = 10, --kick
		[6554] = 10, --pummel
		[2139] = 24, --counterspell
		[19647] = 24, --spell lock
		[10890] = 27, --fear priest
		[47528] = 10, --mindfreeze
		[34490] = 20, --hunter silencing shot
		[29166] = 180, --innervate
		[47528] = 10, --Mind Freeze
		[1044] = 25, --Hand of Freedom
		[72] = 12, --Shield Bash
		[6552] = 10, --Pummel
		[1719] = 300, --Recklessness
		[29166] = 180, --Innervate
		[8983] = 30, --Bash
		[64901] = 360, --Hymn of Hope
		[15487] = 45, --Silence
		[10890] = 26, --Psychic Scream
		[48011] = 8, --Devour Magic (Felhunter)
		[19647] = 24, --Spell Lock
		[51514] = 45, --Hex
		[57994] = 6, --Wind Shock
		[34490] = 20, --Silencing Shot
		[26090] = 30, --Pummel
		[44572] = 30, --Deep Freeze
		[2139] = 24, -- Counterspell
		[2094] = 120, -- Blind
	}


	tracker = CreateFrame("frame")
	tracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	tracker:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	tracker.Orientations = {
		["HORIZONTALRIGHT"] = { ["point"] = "TOPLEFT", ["rpoint"] = "TOPRIGHT", ["x"] = 3, ["y"] = 0 },
		["HORIZONTALLEFT"] = { ["point"] = "TOPRIGHT", ["rpoint"] = "TOPLEFT", ["x"] = -3, ["y"] = 0 },
		["VERTICALDOWN"] = { ["point"] = "TOPLEFT", ["rpoint"] = "BOTTOMLEFT", ["x"] = 0, ["y"] = -3 },
		["VERTICALUP"] = { ["point"] = "BOTTOMLEFT", ["rpoint"] = "TOPLEFT", ["x"] = 0, ["y"] = 3 },
	}

	tracker.Spells = spells

	SlashCmdList["tracker"] = function(msg) tracker.SlashHandler(msg) end
	SLASH_tracker1 = "/ct"
	SLASH_tracker2 = "/tracker"
	tracker:SetScript("OnEvent", function(this, event, ...) tracker[event](...) end)

	tracker.Icons = {}

	function tracker.CreateIcon()
		local i = (#tracker.Icons)+1

		tracker.Icons[i] = CreateFrame("frame","trackerIcon"..i,UIParent)
		tracker.Icons[i]:SetClampedToScreen(true)
		tracker.Icons[i]:SetHeight(opts.IconSize - 2)
		tracker.Icons[i]:SetWidth(opts.IconSize - 2)

		tracker.Icons[i]:Hide()

		tracker.Icons[i].Texture = tracker.Icons[i]:CreateTexture(nil,"ARTWORK")
		tracker.Icons[i].Texture:SetTexture("Interface\\Icons\\Spell_Nature_Cyclone.blp")
		tracker.Icons[i].Texture:SetTexCoord(.1, .9, .1, .9)
		tracker.Icons[i].Texture:SetAllPoints(tracker.Icons[i])

		tracker.Icons[i].border = tracker.Icons[i]:CreateTexture(nil,"BACKGROUND")
		tracker.Icons[i].border:SetTexture(0,0,0)
		tracker.Icons[i].border:SetHeight(opts.IconSize)
		tracker.Icons[i].border:SetWidth(opts.IconSize)
		tracker.Icons[i].border:SetPoint("CENTER", tracker.Icons[i], "CENTER", 0, 0)

		tracker.Icons[i].TimerText = tracker.Icons[i]:CreateFontString("trackerTimerText","OVERLAY")
		tracker.Icons[i].TimerText:SetFont(STANDARD_TEXT_FONT,14,"Outline")
		tracker.Icons[i].TimerText:SetTextColor(1,.9294,.7607)
		tracker.Icons[i].TimerText:SetShadowColor(0,0,0)
		tracker.Icons[i].TimerText:SetShadowOffset(1,-1)
		tracker.Icons[i].TimerText:SetPoint("BOTTOM", tracker.Icons[i], "BOTTOM", 0, 1)
		tracker.Icons[i].TimerText:SetText(5)

		return i
	end

	tracker.CreateIcon()
	tracker.Icons[1]:RegisterForDrag("LeftButton")
	tracker.Icons[1]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", opts.XPos, opts.YPos)
	tracker.Icons[1]:SetScript("OnDragStart", function() tracker.Icons[1]:StartMoving() end)
	tracker.Icons[1]:SetScript("OnDragStop", function()
		tracker.Icons[1]:StopMovingOrSizing()
		opts.XPos = math.floor(tracker.Icons[1]:GetLeft())
		opts.YPos = math.floor(tracker.Icons[1]:GetTop())
		end)

	function tracker.SlashHandler(msg)
		arg = string.upper(msg)
		if (tracker[arg]) then
			tracker[arg]()
		else
			tracker.Print("Cooldown Tracker Options:")
			print(" - /ct unlock")
			print(" - /ct lock")
			print(" - /ct reset")
			print(" - /ct horizontalright")
			print(" - /ct horizontalleft")
			print(" - /ct verticaldown")
			print(" - /ct verticalup")
		end
	end

	function tracker.UNLOCK()
		if (not tracker.Icons[1]:IsMouseEnabled()) then
			tracker.StopAllTimers()
			tracker.Icons[1]:EnableMouse(true)
			tracker.Icons[1]:SetMovable(true)
			tracker.Icons[1]:SetUserPlaced(true)
			tracker.StartTimer(1,60,nil)
		end
	end

	function tracker.LOCK()
		if (tracker.Icons[1]:IsMouseEnabled()) then
			tracker.Icons[1]:EnableMouse(false)
			tracker.Icons[1]:SetMovable(false)
			tracker.StopTimer(1)
		end
	end

	function tracker.RESET()
		opts.XPos = 677
		opts.YPos = 383
		tracker.Icons[1]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", opts.XPos, opts.YPos)
		tracker.Print("Position reset successfully.")
	end

	function tracker.HORIZONTALRIGHT()
		opts.Orientation = "HORIZONTALRIGHT"
		tracker.Print("Icons will now stack horizontally to the right.")
	end

	function tracker.HORIZONTALLEFT()
		opts.Orientation = "HORIZONTALLEFT"
		tracker.Print("Icons will now stack horizontally to the left.")
	end

	function tracker.VERTICALDOWN()
		opts.Orientation = "VERTICALDOWN"
		tracker.Print("Icons will now stack vertically downwards.")
	end

	function tracker.VERTICALUP()
		opts.Orientation = "VERTICALUP"
		tracker.Print("Icons will now stack vertically upwards.")
	end

	function tracker.Print(msg, ...)
		print("|cFFFFFF33[Cooldown Tracker]|r "..format(msg, ...))
	end

	--

	function tracker.COMBAT_LOG_EVENT_UNFILTERED(timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellID)
			isArena, isRegistered = IsActiveBattlefieldArena();
			if isArena then
				if (event == "SPELL_CAST_SUCCESS" and not tracker.Icons[1]:IsMouseEnabled() and (bit.band(sourceFlags,COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE)) then
					if (sourceName ~= UnitName("player")) then
						if (tracker.Spells[spellID]) then
							local _,_,texture = GetSpellInfo(spellID)
							tracker.StartTimer(tracker.NextAvailable(),tracker.Spells[spellID],texture,spellID)
						end
					end
				end
			end
	end

	function tracker.NextAvailable()
		for i=1,#tracker.Icons do
			if (not tracker.Timers[i]) then
				return i
			end
		end
		return tracker.CreateIcon()
	end

	tracker.Timers = {}
	function tracker.StartTimer(icon, duration, texture, spellID)
		tracker.Timers[(icon)] = {
			["Start"] = GetTime(),
			["Duration"] = duration,
			["SpellID"] = spellID,
		}
		UIFrameFadeIn(tracker.Icons[icon],0.2,0.0,1.0)
		if (texture) then
			tracker.Icons[(active or icon)].Texture:SetTexture(texture)
			tracker.Icons[(active or icon)].Texture:SetTexCoord(.1, .9, .1, .9)
		end
		tracker.Reposition()
		tracker:SetScript("OnUpdate", function(this, arg1) tracker.OnUpdate(arg1) end)
	end

	function tracker.StopTimer(icon)
		if (tracker.Icons[icon]:IsMouseEnabled()) then
			tracker.LOCK()
		end
		UIFrameFadeOut(tracker.Icons[icon],0.2,1.0,0.0)
		tracker.Timers[icon] = nil
		tracker.Reposition()
		if (#tracker.Timers == 0) then
			tracker:SetScript("OnUpdate", nil)
		end
	end

	function tracker.StopAllTimers()
		for i in pairs(tracker.Timers) do
			tracker.StopTimer(i)
		end
	end

	function tracker.Reposition()
		local sorttable = {}
		local indexes = {}

		for i in pairs(tracker.Timers) do
			tinsert(sorttable, tracker.Timers[i].Start)
			indexes[tracker.Timers[i].Start] = i
		end

		table.sort(sorttable)

		local currentactive = 0
		for k=1,#sorttable do
			local v = sorttable[k]
			local i = indexes[v]
			tracker.Icons[i]:ClearAllPoints()
			if (currentactive == 0) then
				tracker.Icons[i]:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", opts.XPos, opts.YPos)
			else
				tracker.Icons[i]:SetPoint(tracker.Orientations[opts.Orientation].point,
					tracker.Icons[currentactive],
					tracker.Orientations[opts.Orientation].rpoint,
					tracker.Orientations[opts.Orientation].x,
					tracker.Orientations[opts.Orientation].y)
			end
			currentactive = i
		end
	end

	local updatetimer = 1
	function tracker.OnUpdate(elapsed)
		if (updatetimer >= elapsed) then
			updatetimer = 0.05
			if (#tracker.Timers > 0) then
				for i in pairs(tracker.Timers) do
					local timeleft = tracker.Timers[i].Duration+1-(GetTime()-tracker.Timers[i].Start)
					if (timeleft < 0) then
						tracker.StopTimer(i)
					else
						tracker.Icons[i].TimerText:SetText(tracker.GetFormattedTime(math.floor(timeleft)))
					end
				end
			else
				updatetimer = updatetimer - elapsed;
			end
		end
	end

	function tracker:ZONE_CHANGED_NEW_AREA()
			local pvpType = GetZonePVPInfo()

			if not pvpType ~= "Arena" then
				for i in pairs(tracker.Timers) do
				tracker.StopTimer(i)
				end
			end
	end

	function tracker.GetFormattedTime(s)
		 if s >= 3600 then
			return format('%dh', floor(s/3600 + 0.5)), s % 3600
		elseif s >= 60 then
			return format('%dm', floor(s/60 + 0.5)), s % 60
		end
		return floor(s + 0.5), s - floor(s)
	end

	--* Create the minimap menu icon
	local menuIcon = CreateFrame("Button", "RecapsMinimap", Minimap)
	menuIcon:SetWidth(33)
	menuIcon:SetHeight(33)
	menuIcon:SetFrameStrata("LOW")
	menuIcon:SetMovable(true)
	menuIcon:RegisterForClicks("AnyUp")
	menuIcon:RegisterForDrag("LeftButton")
	menuIcon:SetPoint("CENTER", -12, -80)

	menuIcon.icon = menuIcon:CreateTexture(nil, "BACKGROUND")
	menuIcon.icon:SetTexture("interface\\TargetingFrame\\UI-TargetingFrame-Skull")
	menuIcon.icon:SetWidth(22)
	menuIcon.icon:SetHeight(22)
	menuIcon.icon:SetPoint("CENTER")

	menuIcon.border = menuIcon:CreateTexture(nil, "ARTWORK")
	menuIcon.border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	menuIcon.border:SetWidth(52)
	menuIcon.border:SetHeight(52)
	menuIcon.border:SetPoint("TOPLEFT")

	local minimapShapes = {
		["ROUND"] = {true, true, true, true},
		["SQUARE"] = {false, false, false, false},
		["CORNER-TOPLEFT"] = {true, false, false, false},
		["CORNER-TOPRIGHT"] = {false, false, true, false},
		["CORNER-BOTTOMLEFT"] = {false, true, false, false},
		["CORNER-BOTTOMRIGHT"] = {false, false, false, true},
		["SIDE-LEFT"] = {true, true, false, false},
		["SIDE-RIGHT"] = {false, false, true, true},
		["SIDE-TOP"] = {true, false, true, false},
		["SIDE-BOTTOM"] = {false, true, false, true},
		["TRICORNER-TOPLEFT"] = {true, true, true, false},
		["TRICORNER-TOPRIGHT"] = {true, false, true, true},
		["TRICORNER-BOTTOMLEFT"] = {true, true, false, true},
		["TRICORNER-BOTTOMRIGHT"] = {false, true, true, true},
	}

	local function onupdate(self)
		if self.isMoving then
			-- –асчитываем угол позиции кнопки относительно центра миникарты
			local mx, my = Minimap:GetCenter()
			local px, py = GetCursorPosition()
			local scale = Minimap:GetEffectiveScale()
			px, py = px / scale, py / scale
		
			local angle = math.rad(math.deg(math.atan2(py - my, px - mx)) % 360)
			
			local x, y, q = math.cos(angle), math.sin(angle), 1
			if x < 0 then q = q + 1 end
			if y > 0 then q = q + 2 end
			-- ¬ зависимости от формы миникарты позиционирование измен€етс€
			local minimapShape = GetMinimapShape and GetMinimapShape() or "ROUND"
			local quadTable = minimapShapes[minimapShape]
			if quadTable[q] then
				x, y = x*80, y*80
			else
				local diagRadius = 103.13708498985 --math.sqrt(2*(80)^2)-10
				x = math.max(-80, math.min(x*diagRadius, 80));
				y = math.max(-80, math.min(y*diagRadius, 80));
			end
			self:ClearAllPoints();
			self:SetPoint("CENTER", Minimap, "CENTER", x, y);
		end
	end

	menuIcon:SetScript("OnClick",
		function(self, button)
			if IsShiftKeyDown() then
				ReloadUI()
			else
				if (button == 'RightButton') then
					ToggleDropDownMenu(1, nil, maindd, self, -0, -0)
					GameTooltip:SetOwner(self, 'ANCHOR_BOTTOMLEFT')
				end
			end
		end)

	menuIcon:SetScript("OnDragStart",
		function(self)
			if IsShiftKeyDown() then
				self.isMoving = true
				self:SetScript("OnUpdate", function(self) onupdate(self) end)
			end
		end)

	menuIcon:SetScript("OnDragStop",
		function(self)
			self.isMoving = nil
			self:SetScript("OnUpdate", nil)
			self:SetUserPlaced(true)
		end)
	menuIcon:SetScript("OnEnter",
		function(self)
			GameTooltip:SetOwner(self, "ANCHOR_LEFT")
			GameTooltip:AddLine("Fernir UI", 0, 0.75, 1)
			GameTooltip:AddLine("Shift + Drag - Move Button", 0.75, 0.75, 0.75)
			GameTooltip:AddLine("Shift + Click - ReloadUI", 0.75, 0.75, 0.75)
			GameTooltip:Show()
		end)

	menuIcon:SetScript("OnLeave", function() GameTooltip:Hide() end)

	function addDrop(array)
		local info = array
		
		local function dropDown_create(self, level)
			 for i, j in pairs(info) do
				UIDropDownMenu_AddButton(j, level)
			 end
		end

		local dd = CreateFrame('frame', "dd", nil, 'UIDropDownMenuTemplate')
		UIDropDownMenu_Initialize(dd, dropDown_create, 'MENU', level)
		return dd
	end

	maindd = addDrop({
			{ text = "Arena tracker", isTitle = 1, notCheckable = 1, keepShownOnClick = 1 },
			{ text = "Lock/Unlock", func = function() 
				if tracker then 
					if (not tracker.Icons[1]:IsMouseEnabled()) then
						tracker.UNLOCK()
					else
						tracker.LOCK()
					end
				end 
			end },
			{ text = "horizontalright", func = function() if tracker then tracker.HORIZONTALRIGHT() end end },
			{ text = "horizontalleft", func = function() if tracker then tracker.HORIZONTALLEFT() end end },
			{ text = "verticaldown", func = function() if tracker then tracker.VERTICALDOWN() end end },
			{ text = "verticalup", func = function() if tracker then tracker.VERTICALUP() end end },
			{ text = "Reset", func = function() if tracker then tracker.RESET() end end },
	})
	

end
tinsert(fui.modules, module) -- finish him!