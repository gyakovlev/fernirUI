local module = {}
module.name = "CombatLog fixer"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
	
   local LogFixer = {}
   local frame, instanceType, lastEvent

   frame = CreateFrame("Frame")
   CombatLogFixDB = CombatLogFixDB or {zone = true, auto = true, report = true, wait = false}
   frame:SetScript("OnEvent", function(self, event, ...) self[event](LogFixer, event, ...) end)
   frame:SetScript("OnUpdate", checkTimeout)
   frame:Hide()

   local optionText = {["zone"] = "Zone clearing", ["auto"] = "Auto clearing", ["report"] = "Message report", ["wait"] = "Wait on clear"}
   SLASH_LOGFIXER1 = "/clf"
   SLASH_LOGFIXER2 = "/fixer"
   SLASH_LOGFIXER3 = "/logfix"
   SlashCmdList["LOGFIXER"] = function(msg)
      msg = string.lower(msg or "")
      if( msg == "status" ) then
         Print("Showing set options")
         for key, text in pairs(optionText) do
            if( CombatLogFixDB[key] ) then
               DEFAULT_CHAT_FRAME:AddMessage(string.format("%s is |cff20ff20enabled|r", text))
            else
               DEFAULT_CHAT_FRAME:AddMessage(string.format("%s is |cffff2020disabled|r", text))
            end
         end
         return
      end
      
      -- Show help
      if( not optionText[msg] ) then
         Print("Slash commands")
         DEFAULT_CHAT_FRAME:AddMessage("/logfix zone - Toggles clearing on zone type change")
         DEFAULT_CHAT_FRAME:AddMessage("/logfix auto - Toggles clearing combat log when it breaks")
         DEFAULT_CHAT_FRAME:AddMessage("/logfix wait - Toggles not clearing until you drop combat")
         DEFAULT_CHAT_FRAME:AddMessage("/logfix report - Toggles reporting how many messages were found when it broke")
         DEFAULT_CHAT_FRAME:AddMessage("/logfix status - List of set options")
         return
      end
      
      CombatLogFixDB[msg] = not CombatLogFixDB[msg]
      CheckEvents()
      
      if( CombatLogFixDB[msg] ) then
         Print(string.format("%s is now |cff20ff20enabled|r", optionText[msg]))
      else
         Print(string.format("%s is now |cffff2020disabled|r", optionText[msg]))
      end
   end

   function CheckEvents()
      if( CombatLogFixDB.zone ) then
         frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
         frame:RegisterEvent("PLAYER_ENTERING_WORLD")
      else
         frame:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
         frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
      end
      
      if( CombatLogFixDB.auto ) then
         frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
         frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
      else
         frame:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
         frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
         frame:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
         frame:Hide()
      end	
   end

   -- Clear on zone type change
   function frame.ZONE_CHANGED_NEW_AREA()
      local type = select(2, IsInInstance())
      if( instanceType and type ~= instanceType ) then
         CombatLogClearEntries()
      end
      
      instanceType = type
   end

   frame.PLAYER_ENTERING_WORLD = frame.ZONE_CHANGED_NEW_AREA

   -- Queued clear
   function PLAYER_REGEN_ENABLED()
      frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
      CombatLogClearEntries()
   end

   -- When the cast is sent, we expect some sort of combat log event within the next 2
   local playerSpells = setmetatable({}, {
      __index = function(tbl, name)
         local cost = select(4, GetSpellInfo(name))
         rawset(tbl, name, not not (cost and cost > 0))
         return rawget(tbl, name)
      end
   })

   function frame.UNIT_SPELLCAST_SUCCEEDED(event, unit, name, rank, castID)
      if( unit == "player" and name and playerSpells[name] ) then
         frame.timeout = 0.50
         frame:Show()
      end
   end

   function frame.COMBAT_LOG_EVENT_UNFILTERED()
      lastEvent = GetTime()
   end

   local function checkTimeout(self, elapsed)
      self.timeout = self.timeout - elapsed
      if( self.timeout > 0 ) then return end
      self:Hide()
      
      -- If the last combat log event was within a second of the cast succeeding, we're fine
      if( lastEvent and ( GetTime() - lastEvent ) <= 1 ) then return end

      -- Try and narrow it down
      if( CombatLogFixDB.report ) then
         if( not throttleBreak or throttleBreak < GetTime() ) then
            Print(string.format("%d filtered/%d events found. Cleared combat log, as it broke. Please report this!", CombatLogGetNumEntries(), CombatLogGetNumEntries(true)))
            throttleBreak = GetTime() + 60
         end
      end
      
      -- Might need to queue the clear
      if( CombatLogFixDB.wait and InCombatLockdown() ) then
         frame:RegisterEvent("PLAYER_REGEN_ENABLED")
      else
         CombatLogClearEntries()
      end
   end

   -- Slash commands
   function Print(msg)
      DEFAULT_CHAT_FRAME:AddMessage(string.format("|cff33ff99Log Fixer|r: %s", msg))
   end

   CheckEvents()

   
end
tinsert(fui.modules, module) -- finish him!