-- if this value is undercut, the GCD hack has been found
local GCD_ALERT_VALUE = 1.3
-- value for the over time calculation
local GCD_BALANCE_VALUE = 1.9
-- max entries of the log table per player
local GCD_LOG_MAXENTRIES = 50
-- the last amount of log events to look at and divided by for the overall calculation and local shouting
local GCD_NOTICE_TRESHOLD = 10

local GCD_SPELL_CHECKS = {
   -- WARRIOR
   [47486]		= true,		-- Mortal Strike
   [1680]		= true,		-- Whirlwind
   [47471]		= true,		-- Execute
   [57755]		= true,		-- Heroic Throw
   [12323]		= true,		-- Piercing Howl
   [1715]		= true,		-- Hamstring
   [5246]		= true,		-- Intimidating Shout
   [47465]		= true,		-- Rend
   [47440]		= true,		-- Commanding Shout
   [47436]		= true,		-- Battle Shout
   [47437]		= true,		-- Demoralizing Shout
   [7386]		= true,		-- Sunder Armor

   -- HUNTER
   [49050]		= true,		-- Aimed Shot
   [53209]		= true,		-- Chimera Shot
   [49045]		= true,		-- Arcane Shot
   [19503]		= true,		-- Scatter Shot
   [60192]		= true,		-- Freezing Arrow
   [49001]		= true,		-- Serpent Sting
   [14311]		= true,		-- Freezing Trap
   [13809]		= true,		-- Frost Trap
   [34600]		= true,		-- Snake Trap
   [53338]		= true,		-- Hunter's Mark
   [19801]		= true,		-- Tranquilizing Shot
   [5116]		= true,		-- Concurssive Shot
   [1543]		= true,		-- Flare
   [49056]		= true,		-- Immolation Trap
   [49067]		= true,		-- Explosive Trap
   [3043]		= true,		-- Scorpid Sting
   [3034]		= true,		-- Viper Sting
}

local eframe = CreateFrame("frame")
eframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

eframe.watching = {} -- contains names of people who are to track
eframe.log = {} -- saves the temporary logs
eframe.noticed = {} -- storing player names, so the user won't be bothered every event
eframe.watchee = "" -- name of the current watched
eframe.temps = {} -- saves all temporary events of certain player

local calculateOverallGcd = function(self, name)
	local t = self.temps[name]
	local gcd, i, total, num = 0, 0, 0, 0
	for i = #t, #t - GCD_NOTICE_TRESHOLD + 1, -1 do
		if (t[i]) then
			_, _, _, _, gcd = strsplit(";", t[i])
			total = total + tonumber(gcd)
			num = num + 1
		else
			print(i) -- TODO REMOVE
		end
	end
	return floor(total/num*1000)/1000
end


eframe:SetScript("OnEvent", function(self, event, ...)
	local timestamp, type, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical = ...
	
   if (type ~= "SPELL_CAST_SUCCESS") then return end
	
   --if not GCD_SPELL_CHECKS[spellId] then return end
   
   --print(select))
   local dest, crit = "", ""
   if (destName) then dest = " -> " .. destName end
   if (critical) then crit = "(critical) " end
   local log = "[0.000] " .. sourceName .. " -> " .. spellName .. dest
   if (self.watching[sourceName]) then	
      -- add name to watch list, if already there -> touche
      local time, spell = strsplit(";", self.watching[sourceName])
      --if ((timestamp - time) < GCD_ALERT_VALUE) then
      if ((timestamp - time) < GCD_BALANCE_VALUE) then
         local gcd = floor(((timestamp - time))*1000)/1000
         local msg = "|cff5eafe8<NOGCD Hunter>|r " .. sourceName .. " > " .. gcd .. " sec GCD! (" .. spell .. " -> " .. spellName .. ")"
         if (self.noticed[sourceName] and self.noticed[sourceName] >= GCD_NOTICE_TRESHOLD) then
            -- check overall
            local avgGcd = calculateOverallGcd(self, sourceName)
            if (avgGcd < GCD_ALERT_VALUE) then
               local msg = "|cff5eafe8<NOGCD Hunter>|r " .. sourceName .. " busted! Average GCD: " .. avgGcd .. " sec through " .. GCD_NOTICE_TRESHOLD .. " records."
               print(msg)
               self.noticed[sourceName] = 0
            end
         else
            if (not self.noticed[sourceName]) then 
               self.noticed[sourceName] = 1 
            else
               self.noticed[sourceName] = self.noticed[sourceName] + 1
            end
         end
         -- TODO shouting according to shout property
         local newlog = "[" .. gcd .. "] " .. sourceName .. " -> " .. spellName .. dest
         self.log[sourceName] = self.log[sourceName] .. ";" .. newlog .. ";" .. GetZoneText() .. ";" .. date("%m/%d/%y %H:%M:%S") .. ";" .. gcd
         if (not self.temps[sourceName]) then
            self.temps[sourceName] = {}
         end
         -- save only suspicious occurences
         table.insert(self.temps[sourceName], self.log[sourceName])
         self.log[sourceName] = log
         -- to keep the temporary table as small as needed
         if (#self.temps[sourceName] > GCD_NOTICE_TRESHOLD) then
            table.remove(self.temps[sourceName], 1)
         end
         -- setting newest watched skill
         self.watching[sourceName] = timestamp .. ";" .. spellName
      else
         -- if GCD is fine, renew name
         self.watching[sourceName] = timestamp .. ";" .. spellName
         self.log[sourceName] = log
      end
   else
      self.watching[sourceName] = timestamp .. ";" .. spellName
      self.log[sourceName] = log
   end
   
end)