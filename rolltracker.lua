local module = {}
module.name = "Roll Tracker"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
	
	local settings = fuiDB
   
   --[[
      RollTracker
      Originally written by Coth of Gilneas and Morodan of Khadgar.
   ]]--

   local rollArray, rollNames = {}, {}

   -- hard-coded configs
   local ClearWhenClosed = true

   -- Basic localizations
   local locales = {
      deDE = {
         ["All rolls have been cleared."] = "Alle gewurfelten Zahlen geloscht.",
         ["%d Roll(s)"] = "%d Zahlen gewurfelt",
      },
      esES = {
         ["All rolls have been cleared."] = "Todas las tiradas han sido borradas.",
         ["%d Roll(s)"] = "%d Tiradas",
      },
      ruRU = {
         ["All rolls have been cleared."] = "Все броски костей очищены.",
         ["%d Roll(s)"] = "%d броска(ов)",
      },
   }
   local L = locales[GetLocale()] or {}
   setmetatable(L, {
      -- looks a little messy, may be worth migrating to AceLocale when this list gets bigger
      __index = {
         ["%d Roll(s)"] = "%d Roll(s)",
         ["All rolls have been cleared."] = "All rolls have been cleared.",
      },
   })
   
   local RollTrackerFrame = CreateFrame("frame", nil, UIParent)
   RollTrackerFrame.Title = RollTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
   RollTrackerFrame.StatusText = RollTrackerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
   RollTrackerFrame.ClearButton = CreateFrame("button", nil, RollTrackerFrame, "UIPanelButtonTemplate")
   RollTrackerFrame.RollButton = CreateFrame("button", nil, RollTrackerFrame, "UIPanelButtonTemplate")
   RollTrackerFrame.ResizeGrip = CreateFrame("button", nil, RollTrackerFrame, "UIPanelButtonTemplate")
   RollTrackerFrame.ScrollFrame = CreateFrame("ScrollFrame", "BCMCopyScroll", RollTrackerFrame, "UIPanelScrollFrameTemplate")
   RollTrackerFrame.ScrollFrame.ScrollChild = CreateFrame("frame", nil, RollTrackerFrame.ScrollFrame)
   local RollTrackerRollText = CreateFrame("SimpleHTML", nil, RollTrackerFrame.ScrollFrame.ScrollChild)
   RollTrackerFrame.ScrollFrame:SetScrollChild(RollTrackerFrame.ScrollFrame.ScrollChild)

   
   local function UpdateList()
      local rollText = ""

      table.sort(rollArray, function(a, b) return a.Roll < b.Roll end)

      -- format and print rolls, check for ties
      for i, roll in pairs(rollArray) do
         local tied = (rollArray[i + 1] and roll.Roll == rollArray[i + 1].Roll) or (rollArray[i - 1] and roll.Roll == rollArray[i - 1].Roll)
         rollText = string.format("|c%s%d|r: |c%s%s%s%s|r\n",
               tied and "ffffff00" or "ffffffff",
               roll.Roll,
               ((roll.Low ~= 1 or roll.High ~= 100) or (roll.Count > 1)) and  "ffffcccc" or "ffffffff",
               roll.Name,
               (roll.Low ~= 1 or roll.High ~= 100) and format(" (%d-%d)", roll.Low, roll.High) or "",
               roll.Count > 1 and format(" [%d]", roll.Count) or "") .. rollText
      end
      RollTrackerRollText:SetText(rollText)
      RollTrackerFrame.StatusText:SetText(string.format(L["%d Roll(s)"], table.getn(rollArray)))
   end

   local function ClearRolls()
      rollArray, rollNames = {}, {}
      print(L["All rolls have been cleared."])
      UpdateList()
   end

   local function SaveAnchors()
      settings.RollTrackerDB.X = RollTrackerFrame:GetLeft()
      settings.RollTrackerDB.Y = RollTrackerFrame:GetTop()
      settings.RollTrackerDB.Width = RollTrackerFrame:GetWidth()
      settings.RollTrackerDB.Height = RollTrackerFrame:GetHeight()
   end
   
   --[[ GUI  START ]]--
   RollTrackerFrame:SetResizable(true)
   RollTrackerFrame:SetMovable(true)
   RollTrackerFrame:EnableMouse(true)
   RollTrackerFrame:SetFrameStrata("HIGH")
   RollTrackerFrame:SetPoint("CENTER", 300, 0)
   RollTrackerFrame:SetWidth(180)
   RollTrackerFrame:SetHeight(216)
   RollTrackerFrame:SetClampedToScreen(true)
   SetTemplate(RollTrackerFrame)
   RollTrackerFrame:Hide()
   
   RollTrackerFrame.Title:SetText("Roll Tracker")
   RollTrackerFrame.Title:SetPoint("TOPLEFT", 10, -10)
   RollTrackerFrame.Title:SetPoint("BOTTOMRIGHT", RollTrackerFrame, "TOPRIGHT", -10, -30)

   RollTrackerFrame.StatusText:SetTextColor(.5,.5,1)
   RollTrackerFrame.StatusText:SetPoint("BOTTOMLEFT", 10, 10)
   RollTrackerFrame.StatusText:SetPoint("BOTTOMRIGHT", 0, 20)

   RollTrackerFrame.CloseButton = CreateFrame("button", nil, RollTrackerFrame, "UIPanelCloseButton")
   RollTrackerFrame.CloseButton:SetPoint("TOPRIGHT", RollTrackerFrame, "TOPRIGHT", 0, 0)
   RollTrackerFrame.CloseButton:SetScript("OnClick", function()
      RollTrackerFrame:Hide()
      if ClearWhenClosed then
         ClearRolls()
      end
   end)

   RollTrackerFrame.ClearButton:SetText("Clear")
   RollTrackerFrame.ClearButton:SetPoint("BOTTOMLEFT", RollTrackerFrame.StatusText, "TOPLEFT", -4, 0)
   RollTrackerFrame.ClearButton:SetWidth(75)
   RollTrackerFrame.ClearButton:SetHeight(16)
   RollTrackerFrame.ClearButton:SetScript("OnClick", function()
      ClearRolls()
   end)

   RollTrackerFrame.RollButton:SetText("Roll")
   RollTrackerFrame.RollButton:SetPoint("BOTTOMRIGHT", RollTrackerFrame.StatusText, "TOPRIGHT", -4, 0)
   RollTrackerFrame.RollButton:SetWidth(75)
   RollTrackerFrame.RollButton:SetHeight(16)
   RollTrackerFrame.RollButton:SetScript("OnClick", function()
      RandomRoll(1, 100)
   end)

   RollTrackerFrame.ResizeGrip:SetPoint("BOTTOMRIGHT", RollTrackerFrame, "BOTTOMRIGHT", 0, 0)
   RollTrackerFrame.ResizeGrip:SetWidth(16)
   RollTrackerFrame.ResizeGrip:SetHeight(16)
   RollTrackerFrame.ResizeGrip:SetNormalTexture(settings["Main"].Indicator)
   RollTrackerFrame.ResizeGrip:SetPushedTexture(settings["Main"].Indicator)
   RollTrackerFrame.ResizeGrip:SetScript("OnMouseDown", function()
      RollTrackerFrame:StartSizing()
   end)
   RollTrackerFrame.ResizeGrip:SetScript("OnMouseUp", function()
      RollTrackerFrame:StopMovingOrSizing();
      SaveAnchors()
   end)

   RollTrackerFrame.ScrollFrame:SetPoint("TOPLEFT", 6, -30)
   RollTrackerFrame.ScrollFrame:SetPoint("BOTTOMRIGHT", RollTrackerFrame.RollButton, "TOPRIGHT", -24, 4)
   SetTemplate(RollTrackerFrame.ScrollFrame)
   
   RollTrackerFrame.ScrollFrame.ScrollChild:SetWidth(30)
   RollTrackerFrame.ScrollFrame.ScrollChild:SetHeight(30)

   RollTrackerRollText:SetPoint("TOPLEFT", 4, 0)
   RollTrackerRollText:SetPoint("BOTTOMRIGHT", -4, 0)
   RollTrackerRollText:SetFontObject("ChatFontNormal")

   RollTrackerFrame:SetMinResize(160,160)
   RollTrackerFrame:RegisterForDrag("LeftButton")
   RollTrackerFrame:RegisterEvent("CHAT_MSG_SYSTEM")

   rollArray, rollNames = {}, {}
   
   if not settings.RollTrackerDB then settings.RollTrackerDB = {} end -- fresh DB
   local x, y, w, h = settings.RollTrackerDB.X, settings.RollTrackerDB.Y, settings.RollTrackerDB.Width, settings.RollTrackerDB.Height
   if not x or not y or not w or not h then
      SaveAnchors()
   else
      RollTrackerFrame:ClearAllPoints()
      RollTrackerFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
      RollTrackerFrame:SetWidth(w)
      RollTrackerFrame:SetHeight(h)
   end

   -- slash command
   SLASH_ROLLTRACKER1 = "/rolltracker";
   SLASH_ROLLTRACKER2 = "/rt";
   SlashCmdList["ROLLTRACKER"] = function (msg)
      if msg == "clear" then
         ClearRolls()
      else
         RollTrackerFrame:Show()
         UpdateList()
      end
   end
   
         
   RollTrackerFrame:SetScript("OnEvent", function(self, ...)
      -- using RANDOM_ROLL_RESULT from GlobalStrings.lua
      -- %s rolls %d (%d-%d) to (.+) rolls (%d+) %((%d+)-(%d+)%)
      local pattern = string.gsub(RANDOM_ROLL_RESULT, "[%(%)-]", "%%%1")
      pattern = string.gsub(pattern, "%%s", "(.+)")
      pattern = string.gsub(pattern, "%%d", "%(%%d+%)")

      for name, roll, low, high in string.gmatch(arg1, pattern) do
         -- check for rerolls. >1 if rolled before
         rollNames[name] = rollNames[name] and rollNames[name] + 1 or 1
         table.insert(rollArray, {
            Name = name,
            Roll = tonumber(roll),
            Low = tonumber(low),
            High = tonumber(high),
            Count = rollNames[name]
         })
         -- popup window
         RollTrackerFrame:Show()
         UpdateList()
      end
   end)
   RollTrackerFrame:SetScript("OnDragStart", function(self, ...)
      self:StartMoving()
   end)
   RollTrackerFrame:SetScript("OnDragStop", function(self, ...)
      self:StopMovingOrSizing()
      SaveAnchors()
   end)

   --[[ GUI END ]]--
   
end
tinsert(fui.modules, module) -- finish him!