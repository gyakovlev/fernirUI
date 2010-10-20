addonName, ns = ...
oUF = ns.oUF or oUF
if not oUF then return end

local media = "Interface\\Addons\\"..addonName.."\\media\\"
local _, playerclass = UnitClass("player")
local settingsChanged = false

DefaultSettings = {
	firstStart = true,
	
	["Main"] = {
		["Set WatchFrame movable"] = true,
		["UIScale"] = true,
		["Texture"] = media.."tex_striped",           -- texture for all frames
		["Border texture"] = media.."neav_border",    -- border texture
		["Glow texture"] = media.."glowTex",          -- shadow texture for frames
		["Indicator"] = media.."indicator",           -- raid corner texture
		["Font"] = media.."caith.ttf",               -- global font
		["FontSize"] = 12,                            -- global font size
		["ClassColorTheme"] = true,                  -- color theme by class
		["OwnBackColor"] = { .1, .1, .1, .9 },
		["OwnBorderColor"] = { .3, .3, .3, 1 },
	},
	
	["Helpers"] = {
		["AutoGreedOnGreen"] = true,
		["AutoRepair"] = true,
		["SellGreyCrap"] = true,
		["AcceptInvites"] = true,
		["Hide errors"] = true,
	},
	
	["Minimap"] = {
		["size"] = 110,
	},
  
	["ActionBarsStyler"] = {
		["hide_hotkey"] = false,
		["range_color"] = { 0.8, 0.1, 0.1, 1 },
		["mana_color"] = { 0.1, 0.3, 1, 1 },
		["usable_color"] = { 1, 1, 1, 1 },
		["unusable_color"] = { 0.4, 0.4, 0.4, 1 },
		["update_timer"] = ATTACK_BUTTON_FLASH_TIME,
	},
  
	["ActionBars"] = {
		["ButtonSize"] = 28,
		["ButtonSpace"] = 4,
		["Hide right bars"] = true,
	},
  
	["ArenaTracker"] = {
		["XPos"] = 677,
		["YPos"]= 383,
		["Orientation"] = "HORIZONTALRIGHT",
		["IconSize"] = 36,
	},

	["Chat"] = {
		["CopyURL"] = true,
		["HoverLinks"]= false,
		["CopyChat"] = true,
		["ChatScroll"] = true,
	},
  
	["CombatText"] = {
		["StartX"]= 305,
		["EndX"] = 305,
		["StartY"] = 550,
		["EndY"] = 300,
		["FontHeight"] = 25,
	},
	
	["Cooldowns"]= {
		["FadeInTime"] = 0.3, 
		["FadeOutTime"] = 0.2, 
		["MaxAlpha"] = 1, 
		["AnimScale"] = 1.5, 
		["IconSize"] = 75, 
		["HoldTime"] = 0, 
		["PosY"] = UIParent:GetWidth()/2, 
		["PosX"] = UIParent:GetHeight()/2,
	},
	
	["Data text"] = {
		["Gold"] = true,
		["Durability"] = true,
		["Latency"] = true,
		["Guild information"] = true,
		["Show loot settings"] = true,
		["Experience bar"] = true,
		["Addon memory usage"] = true,
		["Wintergasp time"] = true,
		["Honor"] = true,
		["FPS"] = true,
		["Self DPS"] = true,
		["Zone text"] = true,
	},
	
	["LootFrames"] = {
		["Loot frame scale"] = 1,
		["Icon size"] = 28,
	},
	
	["Nameplates"] = {
		["Height"] = 10,
		["Width"] = 80,
		["Icon size"] = 30,
		["Totem icon"] = true,
		["Class icon"] = true,
	},
	
	["OmniCC"] = {
		["Font size"] = 13,               -- Font size for frames of NormalizedSize, will be scaled for other sizes
		["Normalized size"] = 31,         -- At this frame width font will have 100% size
		["Change color time"] = 5,        -- Time in seconds when text color will be changed
		["Long color"] = {.8, .8, .8, 1}, -- Color for cooldowns longer than ChangeColorTime. More info: http://www.wowwiki.com/API_FontString_SetTextColor
		["Short color"] = {1, .2, .2, 1}, -- Color for cooldowns shorter than ChangeColorTime.
		["Pivot point"] = "BOTTOM",       -- Where to place cooldown text. More info: http://www.wowwiki.com/API_Region_SetPoint
	},
	
	["Skinner"] = {
		["Skin Skada"] = true,
		["Skin Omen"] = true,
		["Skin Recount"] = true,
		["Skin PallyPower"] = true,
		["Skin default frames"] = true,
	},
	
	["SpellAlerter"] = {
		["PVP trinket"] = true,
		["WOTF using"] = true,
		["Watch drinking"] = true,
		["Watch manaburn"] = true,
		["Color"] = {1, .2, .2, 1},
	},
	
	["ThreatMeter"] = {
		["Width"] = 120, 
		["Height"] = 13,
		["Anchor"] = "CENTER",
		["PosX"] = 0, 
		["PosY"] = -185,
		["Spacing"] = 3,
		["maxBars"] = 3,
	},
	
	["Tooltips"] = {
		["Point"] = "BOTTOMRIGHT",
		["XPoint"] = -100,
		["YPoint"] = 215,
		["Pivot to cursor"] = false,
		["Player titles"] = false,
		["Colorized status bar"] = true,
		["Background color"] = {.05, .05, .05, 1}, --Background color
		["Border color"] = {.3, .3, .3, 1}, --Border color
		["Guild color"] = { 255/255, 20/255, 200/255, 1}, --Guild Color
		["Text target you"] = "<You>",
		["World boss"] = "??",
		["Rare and elite mob"] = "Rare+",
		["Rare mob"] = "Rare",
	},
	
	["TotemSkinner"] = {
		["ButtonSize"] = 27,
		["FlyoutSize"] = 24,
		["ButtonSpacing"] = 3,
		["BorderSpacing"] = 2,
	},
	
	["MirrorBars"] = {
		["Width"] = 200,
		["Height"] = 18,
		["Spacing"] = 4,
		["Anchor"] = "TOP",
		["PosX"] = 0,
		["PosY"] = -100,
	},
	
	["UnitFrames"] = {
		["player"] = {Width = 200, Height = 40, ManaBarHeight = 24, },
		["target"] = {Width = 200, Height = 40, ManaBarHeight = 24, },
		["targettarget"] = {Width = 100, Height = 25, ManaBarHeight = 8, },
		["focus"] = {Width = 150, Height = 30, ManaBarHeight = 24, },
		["focustarget"] = {Width = 100, Height = 30, ManaBarHeight = 14, },
		["pet"] = {Width = 40, Height = 40, ManaBarHeight = 8},
		["arena"] = {Width = 100, Height = 40, ManaBarHeight = 24, },
		["arenatarget"] = {Width = 40, Height = 40, ManaBarHeight = 14},
		["boss"] = {Width = 100, Height = 40, ManaBarHeight = 24, },
		["raid"] = {Width = 45, Height = 45, ManaBarHeight = 2, },
		["Smooth"] = false,
		["Show raid when solo"] = true,
		["MaxGroups"] = 8,
		["Corner points"] = true,
		["Portraits"] = true,
		["ClassColor"] = true,               -- color healthbar by class or reaction
		["OwnColor"] = { 0.6, 1, 0.9, 1 },      -- or use own color
		["PowerColorByType"] = true,         -- color power bar by power type (rage = red, mana = blue tc)
		["OwnPowerColor"] = { 0.2, 0.2, 1, 1 }, -- or use own power color
		["Rune colors"] = {
			[1] = {.2, 0, 0},
			[2] = {.2, 0, 0},
			[3] = {0, .4, 0},
			[4] = {0, .4, 0},
			[5] = {0, .2, .2},
			[6] = {0, .2, .2},
		},
		["Power colors"] = { -- my colors for power bars
			["MANA"] = {0.31, 0.45, 0.63},
			["RAGE"] = {0.69, 0.31, 0.31},
			["FOCUS"] = {0.71, 0.43, 0.27},
			["ENERGY"] = {0.65, 0.63, 0.35},
			["RUNES"] = {0.55, 0.57, 0.61},
			["RUNIC_POWER"] = {0, 0.82, 1},
			["AMMOSLOT"] = {0.8, 0.6, 0},
			["FUEL"] = {0, 0.55, 0.5},
			["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
			["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},
		},
		["TotemBar colors"] = {
		  [1] = {0.752,0.172,0.02},
		  [2] = {0.741,0.580,0.04},
		  [3] = {0,0.443,0.631},
		  [4] = {0.6,1,0.945},
		},
	},
	
	corners = {
		{spellID = 47486, action = "HARMFUL", }, --mortal strike
		{spellID = 43235, action = "HARMFUL", }, --wound poison
		{spellID = 49050, action = "HARMFUL", }, --Aimed Shot
	},
	
}


local setupClassCorners = function()
	if playerclass == "DEATHKNIGHT" then
		table.insert(fuiDB.corners, 
			{spellID = 57623, point = "TOPLEFT", width = 10, height = 10, action = "HELPFUL", count = false, color = {0, 0, 1, 1 }, }
		)--winter horn
	elseif playerclass == "DRUID" then
		table.insert(fuiDB.corners,
			{spellID = 48440, point = "BOTTOMLEFT", width = 10, height = 10, action = "HELPFUL", count = false, color = {1, .1, 1, 1 }, } --rejuvenation
		)
		table.insert(fuiDB.corners,
			{spellID = 48443, point = "TOPLEFT", width = 10, height = 10, action = "HELPFUL", count = false, color = { 0, 1, .4, 1 }, } --regrowth
		)
		table.insert(fuiDB.corners,
			{spellID = 48450, point = "TOPRIGHT", width = 10, height = 10, action = "HELPFUL", count = true, color = { 0, 1, 0, 1 }, } --lifebloom
		)
		table.insert(fuiDB.corners,
			{spellID = 53249, point = "BOTTOMRIGHT", width = 10, height = 10, action = "HELPFUL", count = false, color = { 1, .8, 0, 1 }, } --wildgrowth
		)
	elseif playerclass == "SHAMAN" then
		table.insert(fuiDB.corners, 
			{spellID = 57960, point = "TOPLEFT", width = 15, height = 15, action = "HELPFUL", count = false, color = {0, 0, 1, 1 }, }
		)--water shield
	elseif playerclass == "PALADIN" then
		table.insert(fuiDB.corners, 
			{spellID = 53563, point = "TOPLEFT", width = 10, height = 10, action = "HELPFUL", count = false, color = {1, 0, 1, 1 }, } --частица света
		)
		table.insert(fuiDB.corners, 
			{spellID = 53601, point = "TOPRIGHT", width = 10, height = 10, action = "HELPFUL", count = false, color = {1, 1, 0, 1 }, } -- священнывй щит
		)
	end
end

local function setupVars()
	SetCVar("buffDurations", 1)
	SetCVar("lootUnderMouse", 1)
	SetCVar("autoSelfCast", 1)
	SetCVar("showItemLevel", 1)
	SetCVar("equipmentManager", 1)
	SetCVar("mapQuestDifficulty", 1)
	SetCVar("previewTalents", 1)
	SetCVar("scriptErrors", 0)
	SetCVar("nameplateShowFriends", 0)
	SetCVar("nameplateShowFriendlyPets", 0)
	SetCVar("nameplateShowFriendlyGuardians", 0)
	SetCVar("nameplateShowFriendlyTotems", 0)
	SetCVar("nameplateShowEnemies", 1)
	SetCVar("nameplateShowEnemyPets", 0)
	SetCVar("nameplateShowEnemyGuardians", 0)
	SetCVar("nameplateShowEnemyTotems", 1)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("cameraDistanceMax", 50)
	SetCVar("cameraDistanceMaxFactor", 3.4)
	SetCVar("nameplateAllowOverlap", 1)
   
	SetCVar("CombatDamage", 1)
	SetCVar("CombatHealing", 1)
	SetCVar("showTutorials", 0)
	SetCVar("showNewbieTips", 0)
	SetCVar("hidePartyInRaid", 1)
	SetCVar("Maxfps", 120)
	SetCVar("autoDismountFlying", 1)
	SetCVar("autoQuestWatch", 0)
	SetCVar("autoQuestProgress", 0)
	SetCVar("showLootSpam", 1)
	SetCVar("guildMemberNotify", 1)
	SetCVar("chatBubblesParty", 1)
	SetCVar("chatBubbles", 1)
	SetCVar("UnitNameEnemyTotemName", 1)
	SetCVar("UberTooltips", 1)
	SetCVar("removeChatDelay", 1)
end

local function SetValue(group, option, value, parent)
	if parent then
		fuiDB[parent][group][option] = value
		settingsChanged = true
	else
		fuiDB[group][option] = value
		settingsChanged = true
	end
end


local NewButton = function(text,parent)
	local result = CreateFrame("Button", nil, parent)
	local label = result:CreateFontString(nil,"OVERLAY","GameFontNormal")
	label:SetText(text)
	result:SetWidth(label:GetWidth())
	result:SetHeight(label:GetHeight())
	result:SetFontString(label)
	SetTemplate(result)
	return result
end

parseOptions = function(mainframe, group, opt, parent)
	if not opt then return end
	
	local scrollf = CreateFrame("ScrollFrame", "interface_scrollf"..group, mainframe, "UIPanelScrollFrameTemplate")
	local frame = CreateFrame("frame", nil, scrollf)
	scrollf:SetScrollChild(frame)
	scrollf:SetPoint("TOPLEFT", mainframe, "TOPLEFT", 20, -40)
	scrollf:SetPoint("BOTTOMRIGHT", mainframe, "BOTTOMRIGHT", -40, 45)
	frame:SetPoint("TOPLEFT")
   frame:SetWidth(130)
   frame:SetHeight(130)
	SetTemplate(scrollf)
	
	local offset=5
	local tmparr = {}
	for option, value in pairs(opt) do
		table.insert(tmparr, { ["option"] = option, ["value"] = value })
	end
	table.sort(tmparr, function(a,b) return tostring(a.option) < tostring(b.option) end)
	
	for index, array in ipairs(tmparr) do
		local option, value = array.option, array.value
		if type(value) == "boolean" then
			local button = CreateFrame("CheckButton", "config_"..option, frame, "InterfaceOptionsCheckButtonTemplate")
			_G["config_"..option.."Text"]:SetText(option)
			_G["config_"..option.."Text"]:SetFont(fuiDB["Main"].Font, fuiDB["Main"].FontSize)
			button:SetChecked(value)
			button:SetScript("OnClick", function(self) SetValue(group,option,(self:GetChecked() and true or false), parent); _G[self:GetName().."Text"]:SetTextColor(.1,1,.1); end)
			button:SetHeight(20)
			button:SetWidth(20)
			button:SetPoint("TOPLEFT", 15, -(offset))
			offset = offset+25
		elseif type(value) == "number" or type(value) == "string" and not value:find("function") then
			local label = frame:CreateFontString(nil,"OVERLAY", "GameFontNormal")
			label:SetText(option)
			label:SetWidth(220)
			label:SetHeight(20)
			label:SetJustifyH("LEFT")
			label:SetPoint("TOPLEFT", 15, -(offset))
			
			local editbox = CreateFrame("EditBox", nil, frame)
			editbox:SetAutoFocus(false)
			editbox:SetMultiLine(false)
			editbox:SetWidth(220)
			editbox:SetHeight(20)
			editbox:SetMaxLetters(255)
			editbox:SetTextInsets(3,0,0,0)
			editbox:SetJustifyH("LEFT")
			editbox:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8x8", 
				tiled = false,
			})
			editbox:SetBackdropColor(0,0,0,0.5)
			editbox:SetBackdropBorderColor(0,0,0,1)
			editbox:SetFontObject("GameFontHighlight")
			editbox:SetPoint("TOPLEFT", 15, -(offset+20))
			editbox:SetText(value)
			
			SetTemplate(editbox)
			
			local save = NewButton("+", frame)
			save:SetWidth(20)
			save:SetHeight(20)
			save:SetPoint("LEFT", editbox, "RIGHT", 5, 0)
			save:SetScript("OnClick", function(self) 
				editbox:ClearFocus()
				editbox:SetBackdropBorderColor(.2,1,.2)
				if type(value) == "number" then
					SetValue(group,option,tonumber(editbox:GetText()), parent)
				else
					SetValue(group,option,tostring(editbox:GetText()), parent)
				end
			end)
			
			offset = offset+45
		elseif type(value) == "table" then
			if table.getn(value) <= 4 and type(value[1]) == "number" and value[1] <= 1 and value[2] <= 1 and value[3] <= 1 then
				local label = frame:CreateFontString(nil,"OVERLAY", "GameFontNormal")
				label:SetText(option)
				label:SetWidth(220)
				label:SetHeight(20)
				label:SetJustifyH("LEFT")

				local but = CreateFrame("Button", nil, frame)
				but:SetWidth(20)
				but:SetHeight(20)
				but:SetPoint("TOPLEFT", 15, -(offset))
				
				label:SetPoint("LEFT", but, "RIGHT", 5, 0)
				
				but.tex = but:CreateTexture(nil)
				but.tex:SetTexture(value[1], value[2], value[3], value[4] or 1)
				but.tex:SetPoint("TOPLEFT", 2, -2)
				but.tex:SetPoint("BOTTOMRIGHT", -2, 2)
				offset = offset+25
				
				SetTemplate(but)
				
				but:SetScript("OnClick", function(self) 
					self = self.tex
				
					local function ColorCallback(self,r,g,b,a,isAlpha)
						but.tex:SetTexture(r, g, b, a)
						
						if ColorPickerFrame:IsVisible() then
							--colorpicker is still open
						else
							--colorpicker is closed, color callback is first, ignore it,
							--alpha callback is the final call after it closes so confirm now
							if isAlpha then
								value = {r, g, b, a}
								if parent then
									fuiDB[parent][group][option] = {r, g, b, a}
								else
									fuiDB[group][option] = {r, g, b, a}
								end
								but:SetBackdropBorderColor(.1, 1, .1)
							end
						end
					end
					
					HideUIPanel(ColorPickerFrame)
					ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
					
					ColorPickerFrame.func = function()
						local r,g,b = ColorPickerFrame:GetColorRGB()
						local a = 1 - OpacitySliderFrame:GetValue()
						ColorCallback(self,r,g,b,a, true)
					end
					
					ColorPickerFrame.hasOpacity = value[4] or false
					ColorPickerFrame.opacityFunc = function()
						local r,g,b = ColorPickerFrame:GetColorRGB()
						local a = 1 - OpacitySliderFrame:GetValue()
						ColorCallback(self,r,g,b,a,true)
					end
					
					local r, g, b, a = value[1], value[2], value[3], value[4]
					ColorPickerFrame.opacity = 1 - (a or 0)
					ColorPickerFrame:SetColorRGB(r, g, b)
					
					ColorPickerFrame.cancelFunc = function()
						ColorCallback(self,r,g,b,a,true)
					end
					ShowUIPanel(ColorPickerFrame)
				end)
			else
				local childpanel = CreateFrame("frame", nil, InterfaceOptionsFramePanelContainer)
				childpanel.name = option
				childpanel.parent = mainframe.name
				
				local label = childpanel:CreateFontString(nil,"OVERLAY", "GameFontNormal")
				label:SetText(option)
				label:SetWidth(220)
				label:SetHeight(20)
				label:SetPoint("TOP", 0, -10)

				InterfaceOptions_AddCategory(childpanel)
				
				parseOptions(childpanel, option, value, group)

				local save = NewButton("Save", childpanel)
				save:SetWidth(80)
				save:SetHeight(20)
				save:SetPoint("BOTTOMRIGHT", -10, 10)
				save:SetScript("OnClick", function(self) ReloadUI() end)
		
			end
		elseif type(value) == "string" and value:find("function") then
			local button = NewButton(option, frame)
			button:SetHeight(20)
			button:SetWidth(80)
			local func = value:gsub("function(.+)", "%1")
			button:SetScript("OnClick", function(self) RunScript(func) end)
			button:SetPoint("TOPLEFT", 15, -(offset))
			offset = offset+25
		end
	end
			
   frame:SetHeight(offset)
	mainframe:Hide()
end


local LaunchMain = function(settings)
	if settings["Main"].UIScale then
		local tmp = CreateFrame("frame")
		tmp:RegisterEvent("PLAYER_LOGIN")
		tmp:SetScript("OnEvent", function(self, ...)
			local index = GetCurrentResolution()
			local resolution = select(index, GetScreenResolutions())
			SetCVar("useUiScale", 1)
			SetCVar("uiScale", 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
			SetMultisampleFormat(1)
		end)
	else
		SetCVar("useUiScale", 0)
	end
	
	if settings["Main"]["Set WatchFrame movable"] then
		local wf = _G["WatchFrame"]
		if wf then
			wf:SetFrameStrata("TOOLTIP")
			wf:SetHeight(600)
			wf.ClearAllPoints = function() end
			wf.SetPoint = function() end
			wf.SetAllPoints = function() end
			wf:SetMovable(true)
			WatchFrameCollapseExpandButton:RegisterForDrag("LeftButton")
			wf:SetUserPlaced(true)
			_G["WatchFrameCollapseExpandButton"]:HookScript("OnDragStart", function(self) wf:StartMoving() end)
			_G["WatchFrameCollapseExpandButton"]:HookScript("OnDragStop", function(self) wf:StopMovingOrSizing() end)
			_G["WatchFrameCollapseExpandButton"].Hide = function() end
			WatchFrame_Collapse(wf)
		end
	end
	
	TicketStatusFrame:ClearAllPoints()
	TicketStatusFrame:SetPoint("TOPLEFT", 4, -20)
end

StaticPopupDialogs["INSTALL"] = {
	text = "Это первый запуск сборки.|nПерезагрузить интерфейс для сохранения всех настроек?|n В дальнейшем сделать это можно, зайдя в |cffaaaaffНастройки - Интерфейс - Модификации - fUI|r и нажать кнопку |cffaaffaaSave|r",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() fuiDB.firstStart = false; setupVars(); ReloadUI(); end,
	OnCancel = function() fuiDB.firstStart = true end,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["SAVEOPTS"] = {
	text = "Вы изменили настройки сборки.|nПерезагрузить интерфейс для их сохранения?",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI(); end,
	OnCancel = function() end,
	timeout = 0,
	whileDead = 1,
}


fui = CreateFrame("frame")
fui.modules = {}
fui:RegisterEvent("VARIABLES_LOADED")
fui:SetScript("OnEvent", function()
	if not fuiDB or fuiDB.firstStart then
		 StaticPopup_Show("INSTALL")
	end
   fuiDB = fuiDB or DefaultSettings
	
	for k,v in pairs(DefaultSettings) do
		if fuiDB[k] == nil then
			fuiDB[k] = v
			if type(v) == "table" then
				for n,m in pairs(v) do
					if fuiDB[k][n] == nil then
						fuiDB[k][n] = m
						print("|cffaaffaaRestored|r "..k.." |cffaaffaaoption."..n.."|r value")
					end
				end
			end
			print("|cffaaffaaRestored|r "..k.." |cffaaffaaoption|r")
		end
	end
 
	InterfaceOptionsFrameOkay:HookScript("OnClick", function() 
		if settingsChanged then
			StaticPopup_Show("SAVEOPTS")
		end
	end)
	
	setupClassCorners()
	
   if not fuiDB.modules then fuiDB.modules = {} end
   fui.main = CreateFrame("frame", nil, InterfaceOptionsFramePanelContainer)
   fui.main.name = "|cffff0000fUI|r"
   InterfaceOptions_AddCategory(fui.main)
		
	parseOptions(fui.main, "Main", fuiDB["Main"])
	
	LaunchMain(fuiDB)
	
	local resetm = NewButton("|cffff0000Reset All|r", fui.main)
	resetm:SetWidth(80)
	resetm:SetHeight(20)
	resetm:SetPoint("BOTTOMLEFT",10, 10)
	resetm:SetScript("OnClick", function(self) fuiDB = nil ReloadUI() end)
	
	local savem = NewButton("Save", fui.main)
	savem:SetWidth(80)
	savem:SetHeight(20)
	savem:SetPoint("BOTTOMRIGHT", -10, 10)
	savem:SetScript("OnClick", function(self) ReloadUI() end)
		
	table.sort(fui.modules, function(a,b) return a.name < b.name end)
   for i, module in pairs(fui.modules) do
      if fuiDB.modules[module.name] == nil then fuiDB.modules[module.name] = true end
		
		if not module.name:find("Raid") then
		
			local childpanel = CreateFrame("frame", nil, InterfaceOptionsFramePanelContainer)
			childpanel.name = module.name
			childpanel.parent = fui.main.name
			
			local label = childpanel:CreateFontString(nil,"OVERLAY", "GameFontNormal")
			label:SetText(module.name)
			label:SetWidth(220)
			label:SetHeight(20)
			label:SetPoint("TOP", 0, -10)

			local checkbox = CreateFrame("CheckButton", "cb_module"..module.name, childpanel, "InterfaceOptionsCheckButtonTemplate")
			if fuiDB.modules[module.name] then
				_G["cb_module"..module.name.."Text"]:SetText("|cff00ff00Enable|r")
			else
				_G["cb_module"..module.name.."Text"]:SetText("|cffff0000Enable|r")
			end
			_G["cb_module"..module.name.."Text"]:SetFontObject("GameFontNormal")
			checkbox:SetChecked(fuiDB.modules[module.name])
			checkbox:SetScript("OnClick", function() 
				fuiDB.modules[module.name] = not fuiDB.modules[module.name] 
				if fuiDB.modules[module.name] then
					_G["cb_module"..module.name.."Text"]:SetText("|cff00ff00Enable|r")
				else
					_G["cb_module"..module.name.."Text"]:SetText("|cffff0000Enable|r")
				end
			end)
			checkbox:SetHeight(20)
			checkbox:SetWidth(20)
			checkbox:SetPoint("TOPLEFT", childpanel, 20, -20)
				
			InterfaceOptions_AddCategory(childpanel)
			
			parseOptions(childpanel, module.name, fuiDB[module.name])

			local reset = NewButton("Reset module options", childpanel)
			reset:SetWidth(140)
			reset:SetHeight(20)
			reset:SetPoint("BOTTOMLEFT",10, 10)
			reset:SetScript("OnClick", function(self) fuiDB[module.name] = nil ReloadUI() end)
		
			local save = NewButton("Save", childpanel)
			save:SetWidth(80)
			save:SetHeight(20)
			save:SetPoint("BOTTOMRIGHT", -10, 10)
			save:SetScript("OnClick", function(self) ReloadUI() end)
		end
		
		module.Init()
   end
   fui:UnregisterEvent("VARIABLES_LOADED")
   fui:SetScript("OnEvent", nil)
end)