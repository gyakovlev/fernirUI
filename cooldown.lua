local module = {}
module.name = "Cooldowns"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
   local opts = fuiDB[module.name]
   
    local fadeInTime
    local fadeOutTime
    local maxAlpha
    local animScale
    local iconSize
    local holdTime

    local config = { 
        fadeInTime = opts.FadeInTime or 0.3, 
        fadeOutTime = opts.FadeOutTime or 0.2, 
        maxAlpha = opts.MaxAlpha or 1, 
        animScale = opts.AnimScale or 1.5, 
        iconSize = opts.IconSize or 75, 
        holdTime = opts.HoldTime or 0, 
        x = opts.PosY or UIParent:GetWidth()/2, 
        y = opts.PosX or UIParent:GetHeight()/2 
    }

    local GetTime = GetTime


    local DCP = CreateFrame("frame")
    DCP:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
    DCP:SetMovable(true)
    DCP:RegisterForDrag("LeftButton")
    DCP:SetScript("OnDragStart", function(self) self:StartMoving() end)
    DCP:SetScript("OnDragStop", function(self) 
        self:StopMovingOrSizing() 
        config.x = self:GetLeft()+self:GetWidth()/2 
        config.y = self:GetBottom()+self:GetHeight()/2 
        self:ClearAllPoints() 
        self:SetPoint("CENTER",UIParent,"BOTTOMLEFT",config.x,config.y)
    end)

    local DCPT = DCP:CreateTexture(nil,"BACKGROUND")
    DCPT:SetAllPoints(DCP)

    local cooldowns = { }
    local animating = { }
    local watching = { }

    function DCP:ADDON_LOADED(addon)
        self:RefreshLocals()
        self:SetPoint("CENTER",UIParent,"BOTTOMLEFT",config.x,config.y)
        self:UnregisterEvent("ADDON_LOADED")
    end
    DCP:RegisterEvent("ADDON_LOADED")

    function DCP:UNIT_SPELLCAST_SUCCEEDED(unit,spell)
        if (unit == "player") then
            watching[spell] = {GetTime(),"spell",spell}
            if (not self:IsMouseEnabled()) then
                self:SetScript("OnUpdate", function(self, elapsed) self:OnUpdate(elapsed) end)
            end
        end
    end
    DCP:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

    function DCP:COMBAT_LOG_EVENT_UNFILTERED(...)
        local _,event,_,_,sourceFlags,_,_,_,spellID = ...
        if (event == "SPELL_CAST_SUCCESS") then
            if (bit.band(sourceFlags,COMBATLOG_OBJECT_TYPE_PET) == COMBATLOG_OBJECT_TYPE_PET and bit.band(sourceFlags,COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE) then
                local name = GetSpellInfo(spellID)
                local index = self:GetPetActionIndexByName(name)
                if (index and not select(7,GetPetActionInfo(index))) then
                    watching[name] = {GetTime(),"pet",index}
                elseif (not index and name) then
                    watching[name] = {GetTime(),"spell",name}
                else
                    return
                end
                if (not self:IsMouseEnabled()) then
                    self:SetScript("OnUpdate", function(self, elapsed) self:OnUpdate(elapsed) end)
                end
            end
        end
    end

    function DCP:UNIT_PET()
        if (HasPetUI()) then
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        else
            self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
    end
    DCP:RegisterEvent("UNIT_PET")

    function DCP:PLAYER_ENTERING_WORLD()
        local inInstance,instanceType = IsInInstance()
        if (inInstance and instanceType == "arena") then
            self:SetScript("OnUpdate",nil)
            cooldowns = { }
            watching = { }
        end
    end
    DCP:RegisterEvent("PLAYER_ENTERING_WORLD")

    hooksecurefunc("UseInventoryItem", function(slot)
        local item = GetItemInfo(GetInventoryItemLink("player",slot) or "")
        if (item) then
            watching[item] = {GetTime(),"inventory",slot}
        end
    end)
    hooksecurefunc("UseContainerItem", function(bag,slot)
        local item = GetItemInfo(GetContainerItemLink(bag,slot) or "")
        if (item) then
            watching[item] = {GetTime(),"container",bag,slot}
        end
    end)

    function DCP:RefreshLocals()
        fadeInTime = config.fadeInTime
        fadeOutTime = config.fadeOutTime
        maxAlpha = config.maxAlpha
        animScale = config.animScale
        iconSize = config.iconSize
        holdTime = config.holdTime
    end

    local elapsed = 0
    local runtimer = 0
    function DCP:OnUpdate(update)
        elapsed = elapsed + update
        if (elapsed > 0.05) then
            for i,v in pairs(watching) do
                if (GetTime() >= v[1] + 0.5) then
                    local start, duration, enabled, texture
                    if (v[2] == "spell") then
                        texture = GetSpellTexture(v[3])
                        start, duration, enabled = GetSpellCooldown(v[3])
                    elseif (v[2] == "inventory") then
                        texture = select(10,GetItemInfo(GetInventoryItemLink("player",v[3])))
                        start, duration, enabled = GetInventoryItemCooldown("player",v[3])
                    elseif (v[2] == "container") then
                        texture = select(10,GetItemInfo(GetContainerItemLink(v[3],v[4]) or ""))
                        start, duration, enabled = GetContainerItemCooldown(v[3],v[4])
                    elseif (v[2] == "pet") then
                        texture = select(3,GetPetActionInfo(v[3]))
                        start, duration, enabled = GetPetActionCooldown(v[3])
                    end
                    if (enabled ~= 0) then
                        if (duration and duration > 2.0 and texture) then
                            cooldowns[i] = { start, duration, texture }
                        end
                    end
                    if (not (enabled == 0 and v[2] == "spell")) then
                        watching[i] = nil
                    end
                end
            end
            for i,v in pairs(cooldowns) do
                local remaining = v[2]-(GetTime()-v[1])
                if (remaining <= 0) then
                    tinsert(animating, v[3])
                    cooldowns[i] = nil
                end
            end
            
            elapsed = 0
            if (#animating == 0 and self:tcount(watching) == 0 and self:tcount(cooldowns) == 0) then
                self:SetScript("OnUpdate",nil)
                return
            end
        end
        
        if (#animating > 0) then
            runtimer = runtimer + update
            if (runtimer > (fadeInTime + holdTime + fadeOutTime)) then
                tremove(animating,1)
                runtimer = 0
                DCPT:SetTexture(nil)
            else
                if (not DCPT:GetTexture()) then
                    DCPT:SetTexture(animating[1])
                    DCPT:SetTexCoord(.1,.9,.1,.9)
                end
                local alpha = maxAlpha
                if (runtimer < fadeInTime) then
                    alpha = maxAlpha * (runtimer / fadeInTime)
                elseif (runtimer >= fadeInTime + holdTime) then
                    alpha = maxAlpha - ( maxAlpha * ((runtimer - holdTime - fadeInTime) / fadeOutTime))
                end
                self:SetAlpha(alpha)
                local scale = iconSize+(iconSize*((animScale-1)*(runtimer/(fadeInTime+holdTime+fadeOutTime))))
                self:SetWidth(scale)
                self:SetHeight(scale)
            end
        end
    end

    function DCP:tcount(tab)
        local n = 0
        for _ in pairs(tab) do
            n = n + 1
        end
        return n
    end

    function DCP:GetPetActionIndexByName(name)
        for i=1, NUM_PET_ACTION_SLOTS, 1 do
            if (GetPetActionInfo(i) == name) then
                return i
            end
        end
        return nil
    end

end
tinsert(fui.modules, module) -- finish him!