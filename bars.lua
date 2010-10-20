--Addon author: Allez
local module = {}
module.name = "ActionBars"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
	
	local settings = fuiDB
	
	-- Config start
	local size = settings[module.name].ButtonSize or 28
	local spacing = settings[module.name].ButtonSpace or 4

	local frame_positions = {
		[1]  =  { a = "BOTTOM",         x = 0,    y = 4   },  -- MainBar
		[2]  =  { a = "BOTTOM",         x = 0,    y = 37   },  -- MultiBarBottomLeftBar
		[3]  =  { a = "BOTTOM",         x = 0,    y = 68   },  -- MultiBarBottomRightBar
		[4]  =  { a = "RIGHT",          x = -35,  y = -80 },  -- MultiBarLeftBar
		[5]  =  { a = "RIGHT",          x = -4,   y = -80 },  -- MultiBarRightBar
		[6]  =  { a = "BOTTOM",         x = 100,    y = 94  },  -- PetBar
		[7]  =  { a = "BOTTOM",         x = 0,    y = 94  },  -- ShapeShiftBar
		[10] =  { a = "BOTTOM",           x = 251,  y = -6   },  -- VehicleBar
	}
	-- Config end

	local dummy = function() end

	--[[ selfcast ]]
	local bars = {
		"MainMenuBarArtFrame",
		"MultiBarBottomLeft",
		"MultiBarBottomRight",
		"MultiBarRight",
		"MultiBarLeft",
		"BonusActionBarFrame",
		"ShapeshiftBarFrame",
		"PossessBarFrame",
	}

	for i, v in ipairs(bars) do
		local bar = getglobal(v)
		bar:SetAttribute("unit2", "player")
	end
		
	--[[ Totem Bar ]]
	local anchor = CreateFrame('Frame', 'MultiCastActionBarFrameAnchor')
	anchor:RegisterEvent('PLAYER_ENTERING_WORLD')
	anchor:SetHeight(10)
	anchor:SetWidth(10)
	anchor:ClearAllPoints()
	anchor:SetPoint('CENTER', UIParent)
	anchor:SetMovable(true)
	anchor:SetUserPlaced(true)
	anchor:SetScript('OnEvent', function(self, event)
		MultiCastActionBarFrame:SetParent(anchor)
		MultiCastActionBarFrame:ClearAllPoints()   
		MultiCastActionBarFrame:SetPoint('CENTER', anchor) 
		MultiCastActionBarFrame.SetPoint = function() end
		self:UnregisterAllEvents()
	end)

	for i = 1, 12 do
		for _, button in pairs({
			_G['MultiCastActionButton'..i],

			_G['MultiCastSlotButton1'],
			_G['MultiCastSlotButton2'],
			_G['MultiCastSlotButton3'],
			_G['MultiCastSlotButton4'],

			_G['MultiCastRecallSpellButton'],
			_G['MultiCastSummonSpellButton'],
		}) do
			
			button:RegisterForDrag('LeftButton')

			local icon = select(1, button:GetRegions())
			icon:SetDrawLayer("ARTWORK")
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT",button,"TOPLEFT",2,-2)
			icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-2,2)
			icon:SetTexCoord(.09,.91,.09,.91)
	
			SetTemplate(button)
	
			if button.overlay then
				button.overlay:SetTexture(nil)
			end
			
			button:GetRegions():SetDrawLayer("ARTWORK")
   
			button:HookScript('OnDragStart', function() if (IsAltKeyDown() and IsControlKeyDown()) then anchor:StartMoving() end end)
			button:HookScript('OnDragStop', function() anchor:StopMovingOrSizing() end)
		end
	end

	MultiCastActionButton1:ClearAllPoints()
	MultiCastActionButton1:SetPoint('CENTER', MultiCastSlotButton1) 
	MultiCastActionButton5:ClearAllPoints()
	MultiCastActionButton5:SetPoint('CENTER', MultiCastSlotButton1) 
	MultiCastActionButton9:ClearAllPoints()
	MultiCastActionButton9:SetPoint('CENTER', MultiCastSlotButton1) 

	hooksecurefunc('MultiCastFlyoutFrame_LoadSlotSpells', function(self, slot, ...)
		local numSpells = select('#', ...)
		if (numSpells == 0) then return false end
		numSpells = numSpells + 1
		 for i = 2, numSpells do
			  _G['MultiCastFlyoutButton'..i..'Icon']:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		 end
	end)

	local CreateBarFrame = function(name, pos)
		local bar = CreateFrame("Frame", name, UIParent)
		bar:SetPoint(pos.a, pos.x, pos.y)
		return bar
	end

	local Move = function(bar, button, num, orient, isize)
		for i = 1, num do
			if _G[button..i] then
				_G[button..i]:ClearAllPoints()
				_G[button..i]:SetWidth(isize)
				_G[button..i]:SetHeight(isize)
				if _G[button..i.."Cooldown"] then
					_G[button..i.."Cooldown"]:SetWidth(isize)
					_G[button..i.."Cooldown"]:SetHeight(isize)
				end
				if _G[button..i.."Shine"] then
					_G[button..i.."Shine"]:SetWidth(isize)
					_G[button..i.."Shine"]:SetHeight(isize)
				end
				if _G[button..i.."AutoCastable"] then
					_G[button..i.."AutoCastable"]:SetWidth(isize*2)
					_G[button..i.."AutoCastable"]:SetHeight(isize*2)
				end

				if i == 1 then
					_G[button..i]:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
				else
					if orient == "H" then
						_G[button..i]:SetPoint("TOPLEFT", _G[button..(i-1)], "TOPRIGHT", spacing, 0)
					else
						_G[button..i]:SetPoint("TOPLEFT", _G[button..(i-1)], "BOTTOMLEFT", 0, -spacing)
					end
				end
				--_G[button..i].SetPoint = dummy
				--_G[button..i]:Show()
			end
			if orient == "H" then
				bar:SetWidth(isize*num + spacing*(num-1))
				bar:SetHeight(isize)
			else
				bar:SetWidth(isize)
				bar:SetHeight(isize*num + spacing*(num-1))
			end
		end
	end


	local mainbar = CreateBarFrame("mod_MainBar", frame_positions[1])
	local bottomleftbar = CreateBarFrame("mod_MultiBarBottomLeftBar", frame_positions[2])
	local bottomrightbar = CreateBarFrame("mod_MultiBarBottomRightBar", frame_positions[3])
	local leftbar = CreateBarFrame("mod_MultiBarLeftBar", frame_positions[4])
	local rightbar = CreateBarFrame("mod_MultiBarRightBar", frame_positions[5])
	local petbar = CreateBarFrame("mod_PetBar", frame_positions[6])
	local shapeshiftbar = CreateBarFrame("mod_ShapeShiftBar", frame_positions[7])
	local vehiclebar = CreateBarFrame("mod_VehicleBar", frame_positions[10])
	
	local VehicleLeaveButton = CreateFrame("Button", "VehicleLeaveButton1", UIParent)
	VehicleLeaveButton:SetNormalTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Up")
	VehicleLeaveButton:SetPushedTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
	VehicleLeaveButton:SetHighlightTexture("Interface\\Vehicles\\UI-Vehicles-Button-Exit-Down")
	VehicleLeaveButton:RegisterEvent("UNIT_ENTERED_VEHICLE")
	VehicleLeaveButton:RegisterEvent("UNIT_EXITED_VEHICLE")
	VehicleLeaveButton:SetScript("OnClick", function(self) 
		VehicleExit()
	end)
	VehicleLeaveButton:SetScript("OnEvent", function(self)
		if CanExitVehicle() then
			self:Show()
		else
			self:Hide()
		end
	end)
	VehicleLeaveButton:Hide()

	for i = 1, 12 do
		_G["ActionButton"..i]:SetParent(UIParent)
	end
	BonusActionBarFrame:SetParent(UIParent)
	MultiBarBottomLeft:SetParent(UIParent)
	MultiBarBottomRight:SetParent(UIParent)
	MultiBarLeft:SetParent(UIParent)
	MultiBarRight:SetParent(UIParent)
	PetActionBarFrame:SetParent(UIParent)
	ShapeshiftBarFrame:SetParent(UIParent)
	PossessBarFrame:SetParent(UIParent)
	
	if settings[module.name]["Hide right bars"] then
		local togglebars = function(val)
			for i=1, 12 do
				_G["MultiBarRightButton"..i]:SetAlpha(val)
				_G["MultiBarLeftButton"..i]:SetAlpha(val)
			end
		end
		
		rightbar:EnableMouse(true)
		leftbar:EnableMouse(true)
		rightbar:SetScript("OnEnter", function(self) togglebars(1) end)
		leftbar:SetScript("OnEnter", function(self) togglebars(1) end)
		rightbar:SetScript("OnLeave", function(self) togglebars(0) end)
		leftbar:SetScript("OnLeave", function(self) togglebars(0) end)

		for i=1, 12 do
			local pb = _G["MultiBarRightButton"..i]
			pb:HookScript("OnEnter", function(self) togglebars(1) end)
			pb:HookScript("OnLeave", function(self) togglebars(0) end)
			
			pb = _G["MultiBarLeftButton"..i]
			pb:HookScript("OnEnter", function(self) togglebars(1) end)
			pb:HookScript("OnLeave", function(self) togglebars(0) end)
		end
		
		togglebars(0)
	end

	local checkpos = function()
		local bsize, bspace = settings[module.name].ButtonSize or 28, settings[module.name].ButtonSpace or 4
		local bl, br, r, l = SHOW_MULTI_ACTIONBAR_1 or 0, SHOW_MULTI_ACTIONBAR_2 or 0, SHOW_MULTI_ACTIONBAR_3 or 0, SHOW_MULTI_ACTIONBAR_4 or 0
		local clh = 0
		if CoolLine then clh = 18 end
		return (bl+br+1)*(bsize+bspace)+bspace+clh
	end
	petbar:SetPoint("RIGHT", ActionButton12, "RIGHT", 0, 0)

	
	Move(mainbar, "ActionButton", NUM_ACTIONBAR_BUTTONS, "H", size)
	Move(mainbar, "BonusActionButton", NUM_ACTIONBAR_BUTTONS, "H", size)
	Move(bottomleftbar, "MultiBarBottomLeftButton", NUM_ACTIONBAR_BUTTONS, "H", size)
	Move(bottomrightbar, "MultiBarBottomRightButton", NUM_ACTIONBAR_BUTTONS, "H", size)
	Move(leftbar, "MultiBarLeftButton", NUM_ACTIONBAR_BUTTONS, "V", size)
	Move(rightbar, "MultiBarRightButton", NUM_ACTIONBAR_BUTTONS, "V", size)
	Move(shapeshiftbar, "PossessButton", NUM_POSSESS_SLOTS, "H", size)
	Move(petbar, "PetActionButton", NUM_PET_ACTION_SLOTS, "H", size-3)
	Move(vehiclebar, "VehicleLeaveButton", 1, "H", size)
	hooksecurefunc("ShapeshiftBar_Update", function()
		Move(shapeshiftbar, "ShapeshiftButton", NUM_SHAPESHIFT_SLOTS, "H", size-3)
	end)
	
	_G["MultiBarBottomRight"]:HookScript("OnShow", function()
		shapeshiftbar:SetPoint("BOTTOMLEFT", _G["ActionButton1"], "BOTTOMLEFT", 0, checkpos())
		petbar:SetPoint("BOTTOM", 60, checkpos()+settings[module.name].ButtonSpace)
	end)
	_G["MultiBarBottomRight"]:HookScript("OnHide", function()
		shapeshiftbar:SetPoint("BOTTOMLEFT", _G["ActionButton1"], "BOTTOMLEFT", 0, checkpos())
		petbar:SetPoint("BOTTOM", 60, checkpos()+settings[module.name].ButtonSpace)
	end)

	_G["MultiBarBottomLeft"]:HookScript("OnHide", function()
		bottomrightbar:SetPoint("BOTTOMLEFT", mainbar, "TOPLEFT", 0, spacing)
		shapeshiftbar:SetPoint("BOTTOMLEFT", _G["ActionButton1"], "BOTTOMLEFT", 0, checkpos())
		petbar:SetPoint("BOTTOM", 60, checkpos()+settings[module.name].ButtonSpace)
	end)

	_G["MultiBarBottomLeft"]:HookScript("OnShow", function()
		bottomrightbar:SetPoint("BOTTOMLEFT", bottomleftbar, "TOPLEFT", 0, spacing)
		shapeshiftbar:SetPoint("BOTTOMLEFT", _G["ActionButton1"], "BOTTOMLEFT", 0, checkpos())
		petbar:SetPoint("BOTTOM", 60, checkpos()+settings[module.name].ButtonSpace)
	end)
	
	for _, obj in pairs({
		SlidingActionBarTexture0,
		SlidingActionBarTexture1,
		BonusActionBarTexture0,
		BonusActionBarTexture1,
		ShapeshiftBarLeft,
		ShapeshiftBarRight,
		ShapeshiftBarMiddle,
		MainMenuBar,
		VehicleMenuBar,
	}) do
		if obj:GetObjectType() == 'Texture' then
			obj:SetTexture(nil)
			obj:SetWidth(1)
			obj:SetHeight(1)
		else
			obj:SetScale(0.001)
			obj:SetAlpha(0)
		end
	end

	AchievementMicroButton_Update = function() end
	VehicleMenuBar_MoveMicroButtons = function() end

	BonusActionBarFrame:HookScript("OnShow", function(self)
		for i = 1, 12 do
			_G["ActionButton"..i]:SetAlpha(0)
		end
	end)
	BonusActionBarFrame:HookScript("OnHide", function(self)
		for i = 1, 12 do
			_G["ActionButton"..i]:SetAlpha(1)
		end
	end)


end
tinsert(fui.modules, module) -- finish him!