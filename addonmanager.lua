local module = {}
module.name = "Addon Manager"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
	
	settings = fuiDB
	local opts = settings[module.name]
	
	local loadf = CreateFrame("frame", "aLoadFrame", UIParent)
	loadf:SetWidth(400)
	loadf:SetHeight(600)
	loadf:SetPoint("CENTER")
	loadf:EnableMouse(true)
	loadf:SetMovable(true)
	loadf:SetUserPlaced(true)
	loadf:SetClampedToScreen(true)
	loadf:SetScript("OnMouseDown", function(self) self:StartMoving() end)
	loadf:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
	loadf:SetFrameStrata("DIALOG")
	tinsert(UISpecialFrames, "aLoadFrame")

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

	SetTemplate(loadf)
	loadf:Hide()
	loadf:SetScript("OnHide", function(self) ShowUIPanel(GameMenuFrame) end)
	print("|cffff0000ALoad:|r use /al or /aload commands for show the addon window, or see game menu")


	loadf:SetResizable(true)
	local resize = CreateFrame("button", nil, loadf, "UIPanelButtonTemplate")
	loadf:SetMinResize(200, 400)
	loadf:SetMaxResize(800, 800)
	resize:SetPoint("BOTTOMRIGHT", loadf, "BOTTOMRIGHT", -2, 2)
	resize:SetWidth(16)
	resize:SetHeight(16)
	resize:SetNormalTexture("Interface\\Buttons\\WHITE8x8")
	resize:GetNormalTexture():SetVertexColor(0, 0, 0, .5)
	resize:SetPushedTexture("Interface\\Buttons\\WHITE8x8")
	resize:GetPushedTexture():SetVertexColor(0, .8, .5, .5)

	resize:SetScript("OnMouseDown", function(self)   
		loadf:StartSizing()
	end)

	resize:SetScript("OnMouseUp", function(self)
		loadf:StopMovingOrSizing()
	end)


	local title = loadf:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOPLEFT", 10, -10)
	title:SetText("ALoad")


	local scrollf = CreateFrame("ScrollFrame", "aload_Scroll", loadf, "UIPanelScrollFrameTemplate")
	local mainf = CreateFrame("frame", nil, scrollf)

	scrollf:SetPoint("TOPLEFT", loadf, "TOPLEFT", 10, -30)
	scrollf:SetPoint("BOTTOMRIGHT", loadf, "BOTTOMRIGHT", -28, 40)
	scrollf:SetScrollChild(mainf)

	local reloadb = NewButton("Reload UI", loadf)
	reloadb:SetWidth(150)
	reloadb:SetHeight(22)
	reloadb:SetPoint("BOTTOM", 0, 10)
	reloadb:SetScript("OnClick", function() ReloadUI() end)

	local closeb = NewButton("x", loadf)
	closeb:SetWidth(20)
	closeb:SetHeight(20)
	closeb:SetPoint("TOPRIGHT", loadf, "TOPRIGHT", -4, -4)
	closeb:SetScript("OnClick", function()
		loadf:Hide()
		print("|cffff0000ALoad:|r use /al or /aload commands for show the addon window, or see game menu")
	end)

	local makeList = function()
		local self = mainf
		SetTemplate(scrollf)
		self:SetPoint("TOPLEFT")
		self:SetWidth(scrollf:GetWidth())
		self:SetHeight(scrollf:GetHeight())
		self.addons = {}
		for i=1, GetNumAddOns() do
			self.addons[i] = select(1, GetAddOnInfo(i))
		end
		table.sort(self.addons)

		local oldb

		for i,v in pairs(self.addons) do
			local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(v)

			if name then
				local bf = _G[v.."_cbf"] or CreateFrame("button", v.."_cbf", self)
				if i==1 then
					bf:SetPoint("TOPLEFT",self, "TOPLEFT", 0, 0)
					bf:SetPoint("BOTTOMRIGHT",self, "TOPRIGHT", 0, -20)
				else
					bf:SetPoint("TOPLEFT", oldb, "BOTTOMLEFT", 0, 0)
					bf:SetPoint("BOTTOMRIGHT", oldb, "BOTTOMRIGHT", 0, -20)
				end
				
				bf:EnableMouse(true)
				
				bf:SetBackdrop({
					bgFile = "Interface\\Buttons\\WHITE8x8",
				})
				bf:SetBackdropColor(0,0,0,0)
		
				local maketool = function(self, v)
					local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(v)
					GameTooltip:ClearLines()
					GameTooltip:SetOwner(self, ANCHOR_TOPRIGHT)
					
					local s = title.."|n"
					if notes then s = s.."|cffffffff"..notes.."|r|n" end
					if (GetAddOnDependencies(v)) then
						s ="|cffff4400Dependencies: "
						for i=1, select("#", GetAddOnDependencies(v)) do
							s = s..select(i,GetAddOnDependencies(v))
							if (i>1) then s=s..", " end
						end
						s = s.."|r"
					end
					GameTooltip:AddLine(s,_,_,_,1)
					GameTooltip:Show()
				end
				
				bf:SetScript("OnEnter", function(self)
					self:SetBackdropColor(0,1,0,.25)
					maketool(self, v)
				end)
				
				bf:SetScript("OnLeave", function(self)
					self:SetBackdropColor(0,0,0,0)
					GameTooltip:Hide()
				end)
				
				oldb = bf

				local cb = _G[v.."_cb"] or CreateFrame("CheckButton", v.."_cb", bf, "OptionsCheckButtonTemplate")
				cb:SetWidth(16)
				cb:SetHeight(16)
				cb:SetScript("OnClick", function()
					local _, _, _, enabled = GetAddOnInfo(name)
					if enabled then
						DisableAddOn(name)
					else
						EnableAddOn(name)
					end
				end)
				cb:SetChecked(enabled)
				cb:SetPoint("LEFT", 4, 0)

				cb:SetScript("OnEnter", function()
					bf:SetBackdropColor(0,1,0,.25)
					maketool(cb, v)
				end)
				
				cb:SetScript("OnLeave", function()
					bf:SetBackdropColor(0,0,0,0)
					GameTooltip:Hide()
				end)
				
				local fs = _G[v.."_fs"] or bf:CreateFontString(v.."_fs", "OVERLAY", "GameFontNormal")
				fs:SetText(title)
				
				fs:SetJustifyH("LEFT")
				fs:SetPoint("TOPLEFT", cb, "TOPRIGHT", 0, 0)
				fs:SetPoint("BOTTOMRIGHT", bf, "BOTTOMRIGHT", 0, 0)
				
				bf:SetScript("OnClick", function(self)
					cb:Click()
				end)
			end
		end
	end

	makeList()

	-- slash command
	SLASH_ALOAD1 = "/aload"
	SLASH_ALOAD2 = "/al"
	SlashCmdList["ALOAD"] = function (msg)
		loadf:Show()
	end

	local showb = CreateFrame("button", "GameMenuButtonAddonManager", GameMenuFrame, "GameMenuButtonTemplate")
	showb:SetText("Addon Manager")
	showb:SetPoint("TOP", "GameMenuButtonOptions", "BOTTOM", 0, -1)

	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + showb:GetHeight())
	GameMenuButtonSoundOptions:SetPoint("TOP", showb, "BOTTOM", 0, -1)

	showb:SetScript("OnClick", function()
		PlaySound("igMainMenuOption")
		HideUIPanel(GameMenuFrame)
		loadf:Show()
	end)
	
end
tinsert(fui.modules, module) -- finish him!