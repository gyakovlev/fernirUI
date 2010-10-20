local _G = getfenv(0)
local guildtable = {}
local objects = {}
local get_guild = "# / #"
local tcolor, stime = "|cff637eae", 0, 0, 0
local damage = 0
local settings = nil
local color = _G["RAID_CLASS_COLORS"][select(2, UnitClass("player"))] or { r=1, g=1, b=1, a=1 }

core = CreateFrame("Frame", nil, UIParent)

letter = function(value)
    if value then
       if value < 1 then
          return string.format("%.2f", value)
       elseif value >= 10000000 then 
          return string.format("%.1fm", value / 1000000) 
       elseif value >= 1000000 then
          return string.format("%.2fm", value / 1000000) 
       elseif value >= 100000 then
          return string.format("%.0fk", value / 1000) 
       elseif value >= 10000 then
          return string.format("%.1fk", value / 1000) 
       else
          return math.ceil(value)
       end
    end
end
    
rgb2str = function(col) local r, g, b = unpack(col) return format("|cff%02x%02x%02x", r*255, g*255, b*255) end
rgb2str = function(r, g, b) return format("|cff%02x%02x%02x", r*255, g*255, b*255) end

gradient_s = function(val, bad, good)
    gradient = function(val, bad, good)
        local percent, r, g
        if (good > bad) then 
            percent = val/(good-bad)
        else 
            percent = 1-val/(bad-good) 
        end
        if (percent > 1) then percent = 1 end
        if (percent < 0) then percent = 0 end
        if(percent < 0.5) then r, g = 1, 2*percent   else  r, g = (1-percent)*2, 1 end
        return r, g, 0
    end
    return rgb2str(gradient(val, bad, good))
end 
   
local line  = function(m1, m2) GameTooltip:AddDoubleLine(m1, m2, 0.5, 02, 0.7, 0.7, 0.7, 0.2) end
local space = function() GameTooltip:AddLine("\n") end

local aFrame = CreateFrame("Frame", "aFrame", UIParent)

local createFs = function(parent, justify, ownfsize, fstyle)
    if fuiDB["Main"]["ClassColorTheme"] == false then
        color = { r=1, g=1, b=1, a=1 }
    end
    local f = parent:CreateFontString(nil, "ARTWORK")
    f:SetFont(settings["Main"].Font, ownfsize or settings["Main"].FontSize-2, fstyle)
    f:SetTextColor(color.r, color.g, color.b)
    f:SetShadowOffset(1, -1)
    if(justify) then 
        f:SetJustifyH(justify) 
    end
    return f
end
    
function checkStats()
    for i, object in pairs(objects) do
        if (i=="gold") then
            object.text:SetText(format("|cffffd700%d|r.|cffbbbbdd%d|r.|cffeda55f%d|r", mod(GetMoney()/10000, 10000), mod(GetMoney()/100, 100), mod(GetMoney(), 100)))
        elseif i=="Menu" then
            object.text:SetText("Menu")
        elseif i=="dura" then
            object.text:SetText(select(1, show_durability()))
            object.progress:SetValue(select(2, show_durability()) or 0)
        elseif i=="fps" then
            object.text:SetText(format("%sfps:|r %d", tcolor, floor(GetFramerate())))
        elseif i=="tm" then
            object.text:SetText(format("%s%s|r", tcolor, date("%H:%M")))
        elseif i=="lag" then
            object.text:SetText(format("%s ping:|r %d", tcolor, select(3, GetNetStats())))
        elseif i=="loot" then
            if UnitInParty("player") or UnitInRaid("player") then
                object.text:SetText(show_loot())
            end
        elseif i=="xp" then
            if UnitLevel("player") < 80 then
                object.text:SetText(format("%s XP: %s (%s)|r", tcolor, letter((UnitXPMax("player")-UnitXP("player")) + 1), letter(GetXPExhaustion() or 0))) 
                object.progress:SetValue((floor((UnitXP("player")/UnitXPMax("player"))*100)))
            else
                object.progress = nil
            end
        elseif i=="guild" then
            if IsInGuild() then
                object.text:SetText(get_guild)
            end
        elseif i=="mem" then
            object.text:SetText(format("%s M:|r %s", tcolor, memoryval(collectgarbage("count"))))
        elseif i=="wgtime" then
            object.text:SetText(format("%sWG:|r %s", tcolor, WGConvertTime(GetWintergraspWaitTime())))
        elseif i=="honor" then
            object.text:SetText(format("%shonor:|r %s", tcolor, letter(GetHonorCurrency())))
        elseif i=="zone" then
            object.text:SetText(GetMinimapZoneText())
        elseif i=="dps" then
        else
        end
        
        if (object.bar:GetWidth() < (object.text:GetStringWidth()+10) or  object.bar:GetWidth() > (object.text:GetStringWidth()+20)) then
            object.bar:SetWidth(object.text:GetStringWidth()+15)
        end
    end
end

function WGConvertTime(value)
    if(value~=nil)then
        local hours = floor(value / 3600)
        local minutes = value - (hours * 3600)
        minutescorrupt = floor(minutes / 60)
        if (minutescorrupt < 10) then 
            minutesfixed = "0"..minutescorrupt..""
        else 
            minutesfixed = minutescorrupt 
        end
        local seconds = floor(value - ((hours * 3600) + (minutescorrupt * 60)))
        if (seconds < 10) then 
            secondsfixed = "0"..seconds..""
        else
            secondsfixed = seconds 
        end
        if (hours > 0) then
            return hours..":"..minutesfixed..":"..secondsfixed
        elseif (minutescorrupt > 0) then
            return "0:"..minutesfixed..":"..secondsfixed
        else
            return "0:00:"..secondsfixed
        end
    end
    return "too much lags"
end


local openMicroMenu = function(self)
    if not _G["MicroMenuDropDown"] then
        local MicroMenuDropDown = CreateFrame('Frame', 'MicroMenuDropDown', nil, 'UIDropDownMenuTemplate')
        UIDropDownMenu_Initialize(MicroMenuDropDown, function()
            local button = {
                { text = CHARACTER_BUTTON, func = function() ToggleCharacter('PaperDollFrame') end },
                { text = SPELLBOOK_ABILITIES_BUTTON, func = function() ToggleFrame(SpellBookFrame) end },
                { text = TALENTS_BUTTON, func = function() ToggleTalentFrame() end },
                { text = ACHIEVEMENT_BUTTON, func = function() ToggleAchievementFrame() end },
                { text = SLASH_CALENDAR1:gsub("/(.*)","%1"), func = function() ToggleCalendar() end },
                { text = QUESTLOG_BUTTON, func = function() ToggleFrame(QuestLogFrame) end },
                { text = SOCIAL_BUTTON, func = function() ToggleFriendsFrame() end },
                { text = PLAYER_V_PLAYER, func = function() ToggleFrame(PVPParentFrame) end },
                { text = LFG_TITLE, func = function() ToggleLFDParentFrame() end },
                { text = HELP_BUTTON, func = function() ToggleHelpFrame() end },
            }
            
            for i=1, 10 do
                 UIDropDownMenu_AddButton(button[i])
            end
        end, 'MENU')
    end
    ToggleDropDownMenu(1, nil, _G["MicroMenuDropDown"], self, -0, -0)
end

function show_addons(self)
   GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
   local total, addons, all_mem = 0, {}, collectgarbage("count")
    UpdateAddOnMemoryUsage()  
    for i=1, GetNumAddOns(), 1 do  
      if (GetAddOnMemoryUsage(i) > 0 ) then
        memory = GetAddOnMemoryUsage(i)  
        entry = {name=GetAddOnInfo(i), memory = memory}
        table.insert(addons, entry)  
        total = total + memory  
      end
    end  
    table.sort(addons, function(a, b) return a.memory > b.memory end)  
    line("ADDONS MEMORY USAGE :", "\n")  
    i = 0  
    for _, entry in pairs(addons) do  
        line(entry.name, memoryval(entry.memory)) 
        i = i + 1  
        if i >= 50 then  break  end  
    end  
    space()
    line("Addons", memoryval(total))
    line("Blizzard", memoryval(all_mem-total))
    line("Total", memoryval(all_mem))
    if not UnitAffectingCombat("player") then GameTooltip:Show() end
end

function cString(name, point, ...)
    
    if fuiDB["Main"]["ClassColorTheme"] == false then
        color = { r=1, g=1, b=1, a=1 }
    end
    
    local lastobject = nil
    for i, object in pairs(objects) do
        if object.child == false then
            objects[i].child = true
            lastobject = objects[i]
            break
        end
    end

    local btn = CreateFrame("button", nil, aFrame)
        
    if (lastobject) then
        btn:SetPoint("LEFT", lastobject.bar, "RIGHT", 0, 0)
    else
        btn:SetPoint("LEFT", aFrame, "LEFT", 0, 0)
    end
    
    btn:SetWidth(UIParent:GetWidth()/table.getn(objects))
    btn:SetHeight(aFrame:GetHeight())
    btn:EnableMouse(true)

    local zstr = createFs(btn, "MIDDLE")
    zstr:SetAllPoints(btn)

    if type(point) == "string" then
        if point == "progress" then
            local val1, val2 = select(1, ...)
            btn.pb = CreateFrame("StatusBar", nil, btn)
            btn.pb:SetStatusBarTexture(settings["Main"].Texture)
            btn.pb:SetPoint("TOPLEFT", btn, "TOPLEFT", 0, -2)
            btn.pb:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 2)
            btn.pb:SetMinMaxValues(val1, val2)
            btn.pb:SetStatusBarColor(color.r*.6, color.g*.6, color.b*.6)

            btn.pb.bg = btn.pb:CreateTexture(nil, "BACKGROUND")
            btn.pb.bg:SetTexture(settings["Main"].Texture)
            btn.pb.bg:SetPoint("TOPLEFT", 0, 0)
            btn.pb.bg:SetPoint("BOTTOMRIGHT", 0, 0)
            btn.pb.bg:SetVertexColor(color.r*.2, color.g*.2, color.b*.23)
            
            zstr = createFs(btn.pb, "MIDDLE")
            zstr:SetAllPoints(btn)
            
            objects[name] = { text = zstr, bar = btn, child = false , progress = btn.pb, }
        end
    elseif type(point) == "function" then
        btn:SetScript("OnClick", point)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        objects[name] = { text = zstr, bar = btn, child = false , progress = nil, }
    else
        objects[name] = { text = zstr, bar = btn, child = false , progress = nil, }
    end

    if select(1,...) == "border" then
        SetTemplate(btn)
    end
    
    return btn
end

function show_durability()
   local cost, ndx, durability, d_val, d_max = GetRepairAllCost(), 0, 0, 0, 0
   for slot = 0, 19 do
      d_val, d_max = GetInventoryItemDurability(slot)
      if(d_val) then durability = durability + d_val/d_max*100 ndx=ndx+1 
      end 
   end
   durability = floor(durability/ndx)
   local out_string = gradient_s(floor(durability), 0, 100)..floor(durability).."|r % "
   if(cost > 0) then return format("%s[%s]", out_string, cost) end
   return out_string, durability + 1
end

function show_guild(self)
   GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")  
   line("guild :", GetGuildInfo("player"))
   space()
   for _, val in ipairs(guildtable) do
        line(string.format("|cffdddd00%s|r  %s|r  [ %s ]", val[1], classcol(val[9])..val[2], val[4], val[5]), val[5])
   end
   if not UnitAffectingCombat("player") then GameTooltip:Show() end
end

function memoryval(val)
    if val > 1024 then 
        return format("%s mb", gradient_s(floor(val), 0, 100)..floor(val/1024).."|r")
    else 
        return format("%s kb", gradient_s(floor(val),0, 100)..floor(val)) 
    end
end

core.GUILD_ROSTER_UPDATE = function(self, ...)
   local total, online = 0, 0
   guildtable = {}
   if IsInGuild() then
      total = GetNumGuildMembers(true)
      for ndx = 0, total do
         name, rnk, irnk, lvl, class, zone, note, onote, on, status, engclass = GetGuildRosterInfo(ndx)
         if(on and name) then 
            online = online + on 
            table.insert(guildtable, {lvl, name, class, zone, note, onote, on, status, engclass})
          end
     end
   end
   get_guild = online.."/"..total
end

function show_loot()
    local lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod()
    local master = ""
    if masterlooterPartyID then 
        master = "("..UnitName("party"..masterlooterPartyID)..")" or ""
    elseif masterlooterRaidID then
        master = "("..UnitName("raid"..masterlooterRaidID)..")" or ""
    else
        master = ""
    end

    objects["loot"].bar:SetWidth(objects["loot"].text:GetStringWidth()+30)
    return format("%s%s %s|r", select(4,GetItemQualityColor(GetLootThreshold())), lootmethod, master)
end

function classcol(class)
   if not _G["RAID_CLASS_COLORS"] or class == nil then return ("|cffffffff") end
   local color = _G["RAID_CLASS_COLORS"][strupper(class)]
   return format("|cff%02x%02x%02x", color.r*255, color.g*255, color.b*255)
end

core.PLAYER_REGEN_ENABLED = function(self, ...)
    damage = 0
    stime = 0
    ctime = 0
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

core.PLAYER_REGEN_DISABLED = function(self, ...)
    stime = GetTime()    
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

core.COMBAT_LOG_EVENT_UNFILTERED = function(_, _, timestamp, event, sourceGUID, sourceName, sourceFlags, destGUID, destName, destFlags, meleedamage, _, _, spelldamage)
    if sourceGUID == UnitGUID("player") or  sourceGUID == UnitGUID("playerpet") then      
        local duration = 1
        if ( event == "SWING_DAMAGE" ) then
            damage = damage + meleedamage
            ctime = GetTime()
            if ((ctime - stime) > 1) then
                duration = ctime - stime
            end
            objects["dps"].text:SetText(format("%s DPS:|r %s", tcolor, floor(damage / duration)))
            objects["dps"].bar:SetWidth(objects["dps"].text:GetStringWidth() + 30)
        elseif (event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE") then
            damage = damage + spelldamage
            
            ctime = GetTime()
            if ((ctime - stime) > 1) then
                duration = ctime - stime
            end
            objects["dps"].text:SetText(format("%s DPS:|r %s", tcolor, floor(damage / duration)))
            objects["dps"].bar:SetWidth(objects["dps"].text:GetStringWidth() + 30)
        end
	end
end


local module = {}
module.name = "Data text"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
   
    settings = fuiDB
    local opts = settings[module.name]
    
    aFrame:SetFrameStrata("BACKGROUND")
    SetTemplate(aFrame)
    aFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
    aFrame:SetPoint("BOTTOMRIGHT", UIParent, "TOPRIGHT", 0, -15)
    
    cString("Menu", openMicroMenu, "border")

    if opts["Gold"] then
        cString("gold")
    end
    if opts["Durability"] then
        cString("dura", "progress", 0, 100)
    end
    if opts["Latency"] then
        cString("lag")
    end
    if opts["Guild information"] then
        cString("guild", show_guild)
    end
    if opts["Show loot settings"] then
        cString("loot")
    end
    if opts["Experience bar"] then
        if UnitLevel("player") < 80 then
            cString("xp", "progress", 0, 100)
        end
    end
    if opts["Addon memory usage"] then
        cString("mem", show_addons)
    end
    if opts["Wintergasp time"] then
        cString("wgtime")
    end
    if opts["Honor"] then
        cString("honor")
    end
    if opts["FPS"] then
        cString("fps")
    end
    if opts["Self DPS"] then
        cString("dps", show_dps)
    end
    if opts["Zone text"] then
        cString("zone")
    end
    
    checkStats()
    
    for i, object in pairs(objects) do
        object.bar:SetWidth(object.text:GetStringWidth()+30)
    end
    
    --GuildRoster()
    core.GUILD_ROSTER_UPDATE()
    
    updFrame = CreateFrame("Frame")
    updFrame.timeSinceLastUpdate = 0
    updFrame:SetScript("OnUpdate", function(this, elapsed)  
        updFrame.timeSinceLastUpdate = updFrame.timeSinceLastUpdate + elapsed
        
        if (updFrame.timeSinceLastUpdate >= 1) then
            checkStats()
            updFrame.timeSinceLastUpdate = 0
        end
    end)
    
    core:RegisterEvent("GUILD_ROSTER_UPDATE")
    core:RegisterEvent("PLAYER_REGEN_DISABLED")
    core:RegisterEvent("PLAYER_REGEN_ENABLED")

    core:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)

end
tinsert(fui.modules, module) -- finish him!