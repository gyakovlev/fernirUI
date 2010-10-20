local settings = nil
local mult = 1
local color = _G["RAID_CLASS_COLORS"][select(2, UnitClass("player"))] or {r=1,g=1,b=1,a=1}
local backcolor, bordercolor = { .2, .2, .2, .9 }, { .4, .4, .4, 1 }

function SetFlatTemplate(f,...)
   local bg
   if fuiDB then
      bg = fuiDB["Main"].Texture
   else
      bg = "Interface\\Buttons\\WHITE8x8"
   end
   
   f:SetBackdrop({
		bgFile = bg,
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		tile = false,
		tileSize = 0,
		edgeSize = 1,
		insets = {left =0, right =0, top =0, bottom =0},
   })
	f:SetBackdropColor(unpack(backcolor))
	f:SetBackdropBorderColor(unpack(bordercolor))
end

function SetTemplate(f,...)
   if fuiDB["Main"]["ClassColorTheme"] == false then
      color = { r=1, g=1, b=1, a=1 }
   end
   
   local s, mult = ..., 1
   if s then
      mult = 1/s
   end

   local bg

   if fuiDB then
      bg = fuiDB["Main"].Texture
   else
      bg = "Interface\\Buttons\\WHITE8x8"
   end

   f:SetBackdrop({
		bgFile = bg,
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		tile = false,
		tileSize = 0,
		edgeSize = mult,
		insets = {left =-mult, right =-mult, top =-mult, bottom =-mult},
   })
	f:SetBackdropColor(color.r*backcolor[1], color.g*backcolor[2], color.b*backcolor[3], backcolor[4])
	f:SetBackdropBorderColor(color.r*bordercolor[1], color.g*bordercolor[2], color.b*bordercolor[3], bordercolor[4])
end

function SetTemplateButton(f)
	f:SetNormalTexture("")
	f:SetHighlightTexture("")
	f:SetPushedTexture("")
	f:SetDisabledTexture("")
	
	f.SetNormalTexture = function() end
	f.SetHighlightTexture = function() end
	f.SetPushedTexture = function() end
	f.SetDisabledTexture = function() end

   SetTemplate(f)
   f:HookScript("OnEnter", function(self) self:SetBackdropBorderColor(.69,.31,.31) self:SetBackdropColor(.69,.31,.31,.1) end)
   f:HookScript("OnLeave", function(self) SetTemplate(self) end)
end

function CreatePanel(f, w, h, a1, p, a2, x, y)
   f:SetFrameLevel(1)
   f:SetHeight(h)
   f:SetWidth(w)
   f:SetFrameStrata("BACKGROUND")
   f:SetPoint(a1, p, a2, x, y)
   SetTemplate(f)
end

function MakeMovable(f, ...)
   f:EnableMouse(true)
   f:RegisterForDrag("LeftButton")
   f:SetClampedToScreen(true)
   f:SetMovable(true)
   f:SetScript("OnDragStart", function(self) self:StartMoving() end)
   f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
end


function makeResizable(f, ...)
	f:SetResizable(true)
	local resize = CreateFrame("button", f:GetName().."_resizebutton", f, "UIPanelButtonTemplate")
	f:SetMinResize(f:GetWidth(), f:GetHeight())
	f:SetMaxResize(800, 800)
	resize:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -2, 2)
	resize:SetWidth(16)
	resize:SetHeight(16)
	resize:SetNormalTexture("Interface\\Buttons\\WHITE8x8")
	resize:GetNormalTexture():SetVertexColor(0, 0, 0, .5)
	resize:SetPushedTexture("Interface\\Buttons\\WHITE8x8")
	resize:GetPushedTexture():SetVertexColor(0, .8, .5, .5)

	resize:SetScript("OnMouseDown", function(self) f:StartSizing() end)
	resize:SetScript("OnMouseUp", function(self) f:StopMovingOrSizing() end)
end

local module = {}
module.name = "Skinner"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
   
   settings = fuiDB
   local opts = settings[module.name]
   
   backcolor, bordercolor = fuiDB["Main"]["OwnBackColor"] or { .2, .2, .2, .9 }, fuiDB["Main"]["OwnBackgroundColor"] or { .4, .4, .4, 1 }
   
   local function skinPallyPower()
      if not PallyPower then return end
            
      SetTemplate(PallyPowerAuto)
      SetTemplate(PallyPowerRF)
      SetTemplate(PallyPowerAura)
      _G["PallyPowerAuraIcon"]:SetTexCoord(.1,.9,.1,.9)
      _G["PallyPowerRFIcon"]:SetTexCoord(.1,.9,.1,.9)
      _G["PallyPowerAutoIcon"]:SetTexCoord(.1,.9,.1,.9)
      
      if PallyPower.classButtons then
         for i = 1, PALLYPOWER_MAXCLASSES do
            local cBtn = PallyPower.classButtons[i]
            SetTemplate(cBtn)
            local classIcon = _G[cBtn:GetName().."ClassIcon"]
            local buffIcon = _G[cBtn:GetName().."BuffIcon"]
            classIcon:SetTexCoord(.1,.9,.1,.9)
            buffIcon:SetTexCoord(.1,.9,.1,.9)
            
            for j = 1, PALLYPOWER_MAXPERCLASS do
               local pBtn = PallyPower.playerButtons[i][j]
               buffIcon = _G[pBtn:GetName().."BuffIcon"]
               buffIcon:SetTexCoord(.1,.9,.1,.9)
               SetTemplate(pBtn)
               pBtn:SetScale(PallyPowerAuto:GetScale())
            end
         end
      end
   end

   local function skinRecount()
      local Recount = _G.Recount
      if not Recount then return end
      
      local function SkinFrame(frame)
         SetTemplate(frame)
         if not frame.bgMain then
            frame.bgMain = CreateFrame("Frame", nil, frame)
            frame.bgMain:SetPoint("TOPLEFT", 0, -29)
            frame.bgMain:SetPoint("BOTTOMRIGHT")
            frame.bgMain:SetFrameLevel(frame:GetFrameLevel()+1)
            SetTemplate(frame.bgMain)
         end
         if not frame.bgTitle then
            frame.bgTitle = CreateFrame("Frame", nil, frame)
            frame.bgTitle:SetPoint("TOPLEFT")
            frame.bgTitle:SetPoint("TOPRIGHT")
            frame.bgTitle:SetPoint("BOTTOM",frame,"TOP",0,-30)
            frame.bgTitle:SetFrameLevel(frame:GetFrameLevel()+1)
            SetTemplate(frame.bgTitle)
         end
         frame.CloseButton:SetPoint("TOPRIGHT",frame, "TOPRIGHT", -4, -4)
         frame.Title:SetParent(frame.bgTitle)
         frame.Title:SetPoint("TOPLEFT", 6, -7)
         frame:SetBackdrop(nil)
      end

      Recount.UpdateBarTextures = function(self)
         for k, v in pairs(Recount.MainWindow.Rows) do
            v.StatusBar:SetStatusBarTexture(settings["Main"].Texture)
            v.LeftText:SetFont(settings["Main"].Font, settings["Main"].FontSize)
            v.LeftText:SetShadowOffset(.5,-.5)
            v.RightText:SetFont(settings["Main"].Font, settings["Main"].FontSize)
            v.RightText:SetShadowOffset(.5,-.5)
         end
      end
      Recount.SetBarTextures = Recount.UpdateBarTextures
      
      -- Fix bar textures as they're created
      Recount.SetupBar_ = Recount.SetupBar
      Recount.SetupBar = function(self, bar)
         self:SetupBar_(bar)
         bar.StatusBar:SetStatusBarTexture(settings["Main"].Texture)
      end
      
      -- Skin frames when they're created
      Recount.CreateFrame_ = Recount.CreateFrame
      Recount.CreateFrame = function(self, Name, Title, Height, Width, ShowFunc, HideFunc)
          local frame = self:CreateFrame_(Name, Title, Height, Width, ShowFunc, HideFunc)
          SkinFrame(frame)
          return frame
      end

      -- Skin existing frames
      if Recount.MainWindow then SkinFrame(Recount.MainWindow) end
      if Recount.ConfigWindow then SkinFrame(Recount.ConfigWindow) end
      if Recount.GraphWindow then SkinFrame(Recount.GraphWindow) end
      if Recount.DetailWindow then SkinFrame(Recount.DetailWindow) end
      if Recount.ResetFrame then SkinFrame(Recount.ResetFrame) end
      if _G["Recount_Realtime_!RAID_DAMAGE"] then SkinFrame(_G["Recount_Realtime_!RAID_DAMAGE"].Window) end
      if _G["Recount_Realtime_!RAID_HEALING"] then SkinFrame(_G["Recount_Realtime_!RAID_HEALING"].Window) end
      if _G["Recount_Realtime_!RAID_HEALINGTAKEN"] then SkinFrame(_G["Recount_Realtime_!RAID_HEALINGTAKEN"].Window) end
      if _G["Recount_Realtime_!RAID_DAMAGETAKEN"] then SkinFrame(_G["Recount_Realtime_!RAID_DAMAGETAKEN"].Window) end
      if _G["Recount_Realtime_Bandwidth Available_AVAILABLE_BANDWIDTH"] then SkinFrame(_G["Recount_Realtime_Bandwidth Available_AVAILABLE_BANDWIDTH"].Window) end
      if _G["Recount_Realtime_FPS_FPS"] then SkinFrame(_G["Recount_Realtime_FPS_FPS"].Window) end
      if _G["Recount_Realtime_Latency_LAG"] then SkinFrame(_G["Recount_Realtime_Latency_LAG"].Window) end
      if _G["Recount_Realtime_Downstream Traffic_DOWN_TRAFFIC"] then SkinFrame(_G["Recount_Realtime_Downstream Traffic_DOWN_TRAFFIC"].Window) end
      if _G["Recount_Realtime_Upstream Traffic_UP_TRAFFIC"] then SkinFrame(_G["Recount_Realtime_Upstream Traffic_UP_TRAFFIC"].Window) end
      -- Let's update me some textures!
      Recount:UpdateBarTextures()
   end

   local function skinOmen()
      local Omen = LibStub("AceAddon-3.0"):GetAddon("Omen")
      if not Omen then return end
      --Skin Title/Bars backgrounds
      Omen.UpdateBackdrop_ = Omen.UpdateBackdrop
      Omen.UpdateBackdrop = function(self)
          self:UpdateBackdrop_()
          SetTemplate(self.BarList)
          SetTemplate(self.Title)
          self.BarList:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT",0,-1)
      end
      -- Skin Title Bar
      Omen.UpdateTitleBar_ = Omen.UpdateTitleBar
      Omen.UpdateTitleBar = function(self)
          self:UpdateTitleBar_()
          self.TitleText:SetFont(settings["Main"].Font, self.db.profile.TitleBar.FontSize)
          self.BarList:SetPoint("TOPLEFT", self.Title, "BOTTOMLEFT",0,-1)
      end
      -- Skin Bar Texture
      Omen.UpdateBarTextureSettings_ = Omen.UpdateBarTextureSettings
      Omen.UpdateBarTextureSettings = function(self)
          for i, v in ipairs(self.Bars) do
              v.texture:SetTexture(settings["Main"].Texture)
          end
      end
      -- Skin Bar fonts
      Omen.UpdateBarLabelSettings_ = Omen.UpdateBarLabelSettings
      Omen.UpdateBarLabelSettings = function(self)
          self:UpdateBarLabelSettings_()
          for i, v in ipairs(self.Bars) do
              v.Text1:SetFont(settings["Main"].Font,self.db.profile.Bar.FontSize)
              v.Text2:SetFont(settings["Main"].Font,self.db.profile.Bar.FontSize)
              v.Text3:SetFont(settings["Main"].Font,self.db.profile.Bar.FontSize)
          end
      end

      -- Hook bar creation to apply settings
      local meta = getmetatable(Omen.Bars)
      local oldidx = meta.__index
      meta.__index = function(self, barID)
          local bar = oldidx(self, barID)
          Omen:UpdateBarTextureSettings()
          Omen:UpdateBarLabelSettings()
          return bar
      end
      -- Option Overrides
      if Omen.db then
         Omen.db.profile.Scale = 1
         Omen.db.profile.Background.EdgeSize = 1
         Omen.db.profile.Background.BarInset = 2
         Omen.db.profile.Bar.Spacing = 1
         Omen.db.profile.TitleBar.UseSameBG = true
         Omen.db.profile.PositionY = 90
         Omen.db.profile.PositionX = 925
         Omen.db.profile.PositionW = 300
         Omen.db.profile.PositionH = 90
      end
      -- Force updates
      Omen:UpdateBarTextureSettings()
      Omen:UpdateBarLabelSettings()
      Omen:UpdateTitleBar()
      Omen:UpdateBackdrop()
      Omen:ReAnchorBars()
      Omen:ResizeBars()
   end
   
   local function skinCarbonite()
      ---------------------------------
      -- CARBONITE --------------------
      ---------------------------------
      if IsAddOnLoaded("Carbonite") then
         -- Reskins Carbonite's Map
         local CarboniteMap = CreateFrame("Frame", "Carbonite Map", NxMap1)
         CreatePanel(CarboniteMap, 262, 150, "BOTTOM", NxMap1, "BOTTOM", 0, 5)
         CarboniteMap:SetFrameLevel(4)
         CarboniteMap:SetFrameStrata("BACKGROUND")

         -- Reskins Carbonite's Quest Watch
         local CarboniteQuestWatch = CreateFrame("Frame", "Carbonite Quest Watcher", NxQuestWatch)
         CreatePanel(CarboniteQuestWatch, 262, 230, "TOPRIGHT", NxQuestWatch, "TOPRIGHT", 0, 5)
         CarboniteQuestWatch:SetFrameLevel(4)
         CarboniteQuestWatch:SetFrameStrata("BACKGROUND")
      end
   end

   local function skinSkada()
      if Skada then
         local Skada = Skada

         local function StripOptions(options)
            options.baroptions.args.bartexture = options.windowoptions.args.height
            options.baroptions.args.bartexture.order = 12
            options.baroptions.args.bartexture.max = 1
            options.baroptions.args.barspacing = nil
            options.titleoptions.args.texture = nil
            options.titleoptions.args.bordertexture = nil
            options.titleoptions.args.thickness = nil
            options.titleoptions.args.margin = nil
            options.titleoptions.args.color = nil
            options.windowoptions = nil
            options.baroptions.args.barfont = nil
            options.titleoptions.args.font = nil
         end

         do
            -- Hook the bar mod
            local barmod = Skada.displays["bar"]
            barmod.ApplySettings_ = barmod.ApplySettings
            barmod.ApplySettings = function(self, win)
            win.db.enablebackground = true
            win.db.background.borderthickness = 2
            win.db.background.height = 90
            
            barmod:ApplySettings_(win)
            if win.db.enabletitle then
               win.bargroup.button:SetBackdrop({
                  bgFile = settings["Main"].Texture,
                  tile = false,
                  tileSize = 0
               })
            end
            win.bargroup:SetTexture(settings["Main"].Texture)
            win.bargroup:SetSpacing(1)
            win.bargroup:SetFont(settings["Main"].Font, 10)
            
            local titlefont = CreateFont("TitleFont"..win.db.name)
            titlefont:SetFont(settings["Main"].Font, 10)
            win.bargroup.button:SetNormalFontObject(titlefont)
            local color = win.db.title.color
            win.bargroup.button:SetBackdropColor(color.r, color.g, color.b, color.a or 1)
            if win.bargroup.bgframe then
               SetTemplate(win.bargroup.bgframe)
               if win.db.reversegrowth then
                  win.bargroup.bgframe:SetPoint("BOTTOM", win.bargroup.button, "BOTTOM", 0, -mult * (win.db.enabletitle and 2 or 1))
               else
                  win.bargroup.bgframe:SetPoint("TOP", win.bargroup.button, "TOP", 0, mult * (win.db.enabletitle and 2 or 1))
               end
            end
            self:AdjustBackgroundHeight(win)
            win.bargroup:SetMaxBars(win.db.barmax)
            win.bargroup:SortBars()
            end

            barmod.AdjustBackgroundHeight = function(self,win)
            local numbars = 0
            if win.bargroup:GetBars() ~= nil then
               if win.db.background.height == 0 then
                  for name, bar in pairs(win.bargroup:GetBars()) do if bar:IsShown() then numbars = numbars + 1 end end
               else
                  numbars = win.db.barmax
               end
               if win.db.enabletitle then numbars = numbars + 1 end
               if numbars < 1 then numbars = 1 end
               local height = numbars * (win.db.barheight + 1) + 3
               if win.bargroup.bgframe:GetHeight() ~= height then
                  --win.bargroup.bgframe:SetHeight(height)
               end
            end
            end

            barmod.AddDisplayOptions_ = barmod.AddDisplayOptions
            barmod.AddDisplayOptions = function(self, win, options)
            self:AddDisplayOptions_(win, options)
            StripOptions(options)
            end
            -- Update pre-existing displays
            for k, window in ipairs(Skada:GetWindows()) do
               window:UpdateDisplay()
            end
            for k, options in pairs(Skada.options.args.windows.args) do
               if options.type == "group" then
                  StripOptions(options.args)
               end
            end
         end
      end
   end
   
   if DBM then
      hooksecurefunc(DBT, "CreateBar", function(self)
         for bar in self:GetBarIterator() do
            local frame = bar.frame
            local tbar = getglobal(frame:GetName().."Bar")
            local texture = getglobal(frame:GetName().."BarTexture")
            local icon1 = getglobal(frame:GetName().."BarIcon1")
            local icon2 = getglobal(frame:GetName().."BarIcon2")
            local name = getglobal(frame:GetName().."BarName")
            local timer = getglobal(frame:GetName().."BarTimer")
                        
            SetTemplate(bar.frame)
            tbar:SetPoint("TOPLEFT", 2, -2)
            tbar:SetPoint("BOTTOMRIGHT", 0, 2)
            
            texture:SetTexture(settings["Main"].Texture)
            texture.SetTexture = function() end
            icon1:SetTexCoord(.1,.9,.1,.9)
            icon1:SetWidth(tbar:GetHeight()-4)
            icon1:SetHeight(tbar:GetHeight()-4)
            icon1:SetPoint("TOPRIGHT", tbar, "TOPLEFT", -6, 0)
            icon2:SetTexCoord(.1,.9,.1,.9)
            name:SetPoint("TOPLEFT", tbar, "TOPLEFT", 4, 0)
            name:SetPoint("BOTTOMRIGHT", timer, "BOTTOMLEFT", 0, 0)
            name:SetJustifyH("LEFT")
            name:SetJustifyV("MIDDLE")
            name:SetFont(settings["Main"].Font, tbar:GetHeight()-4)
            name:SetShadowOffset(1.5, -1.5)
            name.SetFont = function() end
            timer:SetPoint("RIGHT", -4, 0)
            timer:SetFont(settings["Main"].Font, tbar:GetHeight()-4)
            timer:SetShadowOffset(1.5, -1.5)
            timer.SetFont = function() end
            
            if not bar.iconBg then
               bar.iconBg = CreateFrame("frame", nil, bar.frame)
               bar.iconBg:SetPoint("TOPLEFT", icon1, "TOPLEFT", -2, 2)
               bar.iconBg:SetPoint("BOTTOMRIGHT", icon1, "BOTTOMRIGHT", 2, -2)
               bar.iconBg:SetFrameLevel(bar.frame:GetFrameLevel()+1)
               SetTemplate(bar.iconBg)
            end

         end
      end)

      hooksecurefunc(DBM.BossHealth, "AddBoss", function(cId, name)
         local i = 1
         local bars = {}
         while (_G[format("DBM_BossHealth_Bar_%d", i)]) do
            local bar = _G[format("DBM_BossHealth_Bar_%d", i)]
            local background = _G[bar:GetName().."BarBorder"]
            local progress = _G[bar:GetName().."Bar"]
            local name = _G[bar:GetName().."BarName"]
            local timer = _G[bar:GetName().."BarTimer"]
            bar:SetScale(UIParent:GetScale())
            bar:SetHeight(16)
            background:SetNormalTexture(nil)
            progress:SetStatusBarTexture(settings["Main"].Texture)
            progress:SetPoint("TOPLEFT", bar, "TOPLEFT", 2, -2)
            progress:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)
            progress:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)
            SetFlatTemplate(bar)
            name:SetPoint("CENTER")
            name:SetPoint("LEFT", 4, 0)
            name:SetFont(settings["Main"].Font, settings["Main"].FontSize)
            name:SetShadowOffset(1.5, -1.5)
            timer:SetPoint("CENTER")
            timer:SetPoint("RIGHT", -4, 0)
            timer:SetFont(settings["Main"].Font, settings["Main"].FontSize)
            timer:SetShadowOffset(1.5, -1.5)
            tinsert(bars, _G[format("DBM_BossHealth_Bar_%d", i)])
            i = i + 1
         end
      end)
   end
   
   
   local SkinButtons = function()
		local skins = {
			"StaticPopup1",
			"StaticPopup2",
			"StaticPopup3",
			"StaticPopup4",
			"GameMenuFrame",
			"GameMenuFrame",
			"InterfaceOptionsFrame",
			"VideoOptionsFrame",
			"AudioOptionsFrame",
			"LFDDungeonReadyStatus",
			"LFDDungeonReadyDialog",
		}
		 
		for i = 1, 2 do
			for j = 1, 2 do
				SetTemplateButton(_G["StaticPopup"..i.."Button"..j])
			end
		end
		 
		for i = 1, getn(skins) do
			SetTemplate(_G[skins[i]])
		end
		 
		local menuButtons = {"Options", "SoundOptions", "UIOptions", "Keybindings", "Macros", "AddOns", "Logout", "Quit", "Continue", "MacOptions", "AddonManager"}
		for i = 1, getn(menuButtons) do
		local button = _G["GameMenuButton"..menuButtons[i]]
			if button then
				SetTemplateButton(button)
			end
		end
		
		local header = {"GameMenuFrame", "InterfaceOptionsFrame", "AudioOptionsFrame", "VideoOptionsFrame"}
		for i = 1, getn(header) do
         local title = _G[header[i].."Header"]
			if title then
				title:SetTexture("")
				title:ClearAllPoints()
				if title == _G["GameMenuFrameHeader"] then
					title:SetPoint("TOP", GameMenuFrame, 0, 7)
				else
					title:SetPoint("TOP", header[i], 0, 0)
				end
            MakeMovable(_G[header[i]])
            --makeResizable(_G[header[i]])
			end
		end
      
		-- here we reskin "normal" buttons
		local buttons = {"VideoOptionsFrameOkay", "VideoOptionsFrameCancel", "VideoOptionsFrameDefaults", "VideoOptionsFrameApply", "AudioOptionsFrameOkay", "AudioOptionsFrameCancel", "AudioOptionsFrameDefaults", "InterfaceOptionsFrameDefaults", "InterfaceOptionsFrameOkay", "InterfaceOptionsFrameCancel"}
		for i = 1, getn(buttons) do
		local reskinbutton = _G[buttons[i]]
			if reskinbutton then
				SetTemplateButton(reskinbutton)
			end
		end
		
		-- if a button position is not really where we want, we move it here	 
		_G["VideoOptionsFrameCancel"]:ClearAllPoints()
		_G["VideoOptionsFrameCancel"]:SetPoint("RIGHT",_G["VideoOptionsFrameApply"],"LEFT",-4,0)		 
		_G["VideoOptionsFrameOkay"]:ClearAllPoints()
		_G["VideoOptionsFrameOkay"]:SetPoint("RIGHT",_G["VideoOptionsFrameCancel"],"LEFT",-4,0)	
		_G["AudioOptionsFrameOkay"]:ClearAllPoints()
		_G["AudioOptionsFrameOkay"]:SetPoint("RIGHT",_G["AudioOptionsFrameCancel"],"LEFT",-4,0)		 	 
		_G["InterfaceOptionsFrameOkay"]:ClearAllPoints()
		_G["InterfaceOptionsFrameOkay"]:SetPoint("RIGHT",_G["InterfaceOptionsFrameCancel"],"LEFT", -4,0)
		
		-- reskin battle.net popup
		SetTemplate(BNToastFrame)
		
		-- reskin dropdown list on unitframes
		SetTemplate(DropDownList1MenuBackdrop)
		SetTemplate(DropDownList2MenuBackdrop)
		SetTemplate(DropDownList1Backdrop)
		SetTemplate(DropDownList2Backdrop)
   end
   
   skinCarbonite()
   if Skada and opts["Skin Skada"] then skinSkada() end
   if Omen and opts["Skin Omen"] then skinOmen() end
   if Recount and opts["Skin Recount"] then skinRecount() end
   if PallyPower and opts["Skin PallyPower"] then 
      hooksecurefunc(PallyPower, "UpdateLayout", skinPallyPower)
   end
   
   local lf = CreateFrame("frame")
   lf:RegisterEvent("ADDON_LOADED")
   lf:RegisterEvent("PLAYER_ENTERING_WORLD")
   lf:SetScript("OnEvent", function(self, event,...)
      if event == "ADDON_LOADED" then 
         if arg1=="Skada" and opts["Skin Skada"] then
            skinSkada()
         elseif arg1:find("Carbonite") then
            skinCarbonite()
         elseif arg1=="Omen" and opts["Skin Omen"] then
            skinOmen()
         elseif arg1=="Recount" and opts["Skin Recount"] then
            print(1)
            skinRecount()
         elseif arg1=="PallyPower" and opts["Skin PallyPower"] then
            hooksecurefunc(PallyPower, "UpdateLayout", skinPallyPower)
         end
      end
      if event == "PLAYER_ENTERING_WORLD" then
         if opts["Skin default frames"] then
            SkinButtons()
         end
      end
   end)

end
tinsert(fui.modules, module) -- finish him!