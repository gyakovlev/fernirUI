local settings = nil

function GetMinimapShape() return "SQUARE" end
    
local createFs = function(parent, justify, ownfsize)
    local f = parent:CreateFontString(nil, "OVERLAY")
    f:SetFont(settings["Main"].Font, ownfsize or settings["Main"].FontSize, "OUTLINE")
    if(justify) then f:SetJustifyH(justify) end
    return f
end

local CreateBG = function(parent)
  local bg = CreateFrame("Frame", nil, parent)
  bg:SetPoint("TOPLEFT", parent, "TOPLEFT", -2, 2)
  bg:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 2, -2)
  bg:SetFrameStrata("LOW")
  SetTemplate(bg)
  return bg
end


local function Minimap_CreateDropDown()
    local button = {
        { text = CHARACTER_BUTTON, func = function() ToggleCharacter("PaperDollFrame") end },
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
end 


local module = {}
module.name = "Minimap"
module.Init = function()
    if not fuiDB.modules[module.name] then return end
    settings = fuiDB
    
    MinimapCluster:EnableMouse(false)
    
    Minimap:SetParent(UIParent)
    Minimap:SetMovable(true)
    Minimap:SetSize(settings[module.name].size or 110, settings[module.name].size or 110)
    Minimap:ClearAllPoints()
    Minimap:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -2, 2)
    Minimap.SetPoint = function() end
    
    
    CreateBG(Minimap)

    MiniMapInstanceDifficulty:SetParent(Minimap)

    --[[ World State frame  (ALZA) ]]
    local attempts = createFs(Minimap, nil, 12)
    attempts:SetPoint("TOPRIGHT", 1, 0)

    hooksecurefunc("WorldStateAlwaysUpFrame_Update", function()
       local text = AlwaysUpFrame1Text
       if(not text) then return end
       local inInstance, instanceType = IsInInstance()
       local difficulty = GetInstanceDifficulty()
       if(inInstance and instanceType=="raid" and difficulty==3 or difficulty==4 and text:GetText():find("Осталось попыток")) then
          attempts:SetText(text:GetText():gsub("Осталось попыток: ", ""))
          WorldStateAlwaysUpFrame:SetAlpha(0)
       else
          WorldStateAlwaysUpFrame:SetAlpha(1)
          attempts:SetText("")
       end
    end)

    local ef = CreateFrame("frame")
    ef:RegisterEvent("ADDON_LOADED")
    ef:SetScript("OnEvent", function(self, event, addon)
        if event == "ADDON_LOADED" then
            if(addon=="Blizzard_TimeManager") then 
                for i = 1, select("#", TimeManagerClockButton:GetRegions()) do
                    local texture = select(i, TimeManagerClockButton:GetRegions())
                    if (texture and texture:GetObjectType() == "Texture") then
                        texture:SetTexture(nil)
                    end
                    if (texture and texture:GetObjectType() == "FontString") then
                        local color = _G["RAID_CLASS_COLORS"][select(2, UnitClass("player"))] or {0,0,0}
                        texture:SetFont(settings["Main"].Font, settings["Main"].FontSize, "OUTLINE")
                        texture:SetTextColor(color.r, color.g, color.b)
                        texture:SetParent(Minimap)
                        texture:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -5, 5)
                    end
                end
                TimeManagerClockButton:SetPoint("TOP", -10000, -10000)
            end
        end
    end)

    if (not IsAddOnLoaded("Blizzard_TimeManager")) then
        LoadAddOn("Blizzard_TimeManager")
    end

    GameTimeFrame:SetWidth(14)
    GameTimeFrame:SetHeight(14)
    GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
    GameTimeFrame:ClearAllPoints()
    GameTimeFrame:SetPoint("TOPRIGHT", Minimap, -3.5, -3.5)

    GameTimeFrame:GetFontString():SetFont(settings["Main"].Font, settings["Main"].FontSize, "OUTLINE")
    GameTimeFrame:GetFontString():SetShadowOffset(0, 0)
    GameTimeFrame:GetFontString():SetPoint("TOPRIGHT", GameTimeFrame)
        
    for _, texture in pairs({
        GameTimeCalendarEventAlarmTexture,
        GameTimeCalendarInvitesTexture,
        GameTimeCalendarInvitesGlow,
    }) do
        texture:SetAlpha(0)
        texture.Show = function()
            texture:SetAlpha(0)
            GameTimeFrame:GetFontString():SetTextColor(1, 0, 1)
        end
        
        texture.Hide = function() 
            texture:SetAlpha(0)
            local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
            GameTimeFrame:GetFontString():SetTextColor(classColor.r, classColor.g, classColor.b)
        end
    end

    MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -10, 10)
    MiniMapInstanceDifficulty:SetScale(.7)

    MinimapZoomIn:Hide()
    MinimapZoomOut:Hide()

    MinimapBorder:Hide()
    MinimapBorderTop:Hide()

    MinimapZoneText:Hide()
    MinimapZoneTextButton:Hide()

    MiniMapWorldMapButton:Hide()

    MiniMapLFGFrame:ClearAllPoints()
    MiniMapLFGFrame:SetPoint("BOTTOMLEFT", Minimap, -2, -2)
    MiniMapLFGFrame:SetScale(0.93)

    MiniMapTracking:Hide()
    MiniMapBattlefieldBorder:Hide()
    MiniMapMailBorder:Hide()
    BattlegroundShine:Hide()
    DurabilityFrame:Hide()

    MinimapNorthTag:SetAlpha(0)

    MinimapCluster:SetScale(1.1)
    MinimapCluster:EnableMouse(false)

    Minimap:EnableMouseWheel(true)
    Minimap:ClearAllPoints()
    Minimap:SetPoint("TOPRIGHT", UIParent, -26, -26)
    Minimap:SetMaskTexture("Interface\\ChatFrame\\ChatFrameBackground")

    MiniMapMailText = MiniMapMailFrame:CreateFontString("MiniMapMailText", "OVERLAY")
    MiniMapMailText:SetParent(MiniMapMailFrame)
    MiniMapMailText:SetFont(settings["Main"].Font,settings["Main"].FontSize, "OUTLINE")
    MiniMapMailText:SetPoint("BOTTOMRIGHT", MiniMapMailFrame)
    MiniMapMailText:SetTextColor(1, 0, 1)
    MiniMapMailText:SetText("new")

    MiniMapMailFrame:SetWidth((MiniMapMailText:GetStringWidth()))
    MiniMapMailFrame:SetHeight(18)
    MiniMapMailFrame:ClearAllPoints()
    MiniMapMailFrame:SetPoint("TOP", Minimap, 0, 5)

    MiniMapMailIcon:SetTexture(nil)

    MiniMapBattlefieldFrame:ClearAllPoints()
    MiniMapBattlefieldFrame:SetPoint("TOPLEFT", Minimap, -2, 1)

    MinimapTrackingText = Minimap:CreateFontString("$parentTrackingText", "OVERLAY")
    MinimapTrackingText:SetFont(settings["Main"].Font, settings["Main"].FontSize, "OUTLINE")
    MinimapTrackingText:SetShadowOffset(1, -1)
    MinimapTrackingText:SetPoint("CENTER", Minimap, 0, 35)
    MinimapTrackingText:SetWidth((Minimap:GetWidth() - 25))
    MinimapTrackingText:SetAlpha(0)

    MiniMapLFGFrameBorder:SetAlpha(0)

    Minimap:SetScript("OnMouseWheel", function()
        if (arg1 > 0) then
            Minimap_ZoomIn()
        else
            Minimap_ZoomOut()
        end
    end)

    hooksecurefunc(TicketStatusFrameButton, "Show", function(self)
       SetTemplate(TicketStatusFrameButton)
    end)

    Minimap:SetScript("OnMouseUp", function(self, button)
        if(button == "MiddleButton") then
            ToggleDropDownMenu(1, nil, TimeManagerClockDropDown, self, -0, -0)
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        elseif (button == "LeftButton") then
            ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, - (Minimap:GetWidth() * 0.7), -3)
        else
            Minimap_OnClick(self)
        end
    end)
        
    TimeManagerClockDropDown = CreateFrame("Frame", "TimeManagerClockDropDown", nil, "UIDropDownMenuTemplate")
    UIDropDownMenu_Initialize(TimeManagerClockDropDown, Minimap_CreateDropDown, "MENU")

end
tinsert(fui.modules, module) -- finish him!