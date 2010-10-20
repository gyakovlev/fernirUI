local eventframe = CreateFrame("Frame", nil, UIParent)
	
local SetFont = function(obj, font, size, style, r, g, b, sr, sg, sb, sox, soy)
	obj:SetFont(font, size, style)
	if sr and sg and sb then obj:SetShadowColor(sr, sg, sb) end
	if sox and soy then obj:SetShadowOffset(sox, soy) end
   obj:SetShadowOffset(1,-1)
	if r and g and b then obj:SetTextColor(r, g, b)
	elseif r then obj:SetAlpha(r) end
end

local FixTitleFont = function()
	for _,butt in pairs(PlayerTitlePickerScrollFrame.buttons) do
		butt.text:SetFontObject(GameFontHighlightSmallLeft)
	end
end

eventframe:RegisterEvent("PLAYER_ENTERING_WORLD")
eventframe:SetScript("OnEvent", function(self, event, addon)
	
   local NORMAL     = fuiDB["Main"].Font
	local COMBAT     = fuiDB["Main"].Font
	local NUMBER     = fuiDB["Main"].Font
	local fSize      = fuiDB["Main"].FontSize or 12

	UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = 12
	CHAT_FONT_HEIGHTS = {12, 13, 15, 15, 16, 17, 18, 19, 20}

	UNIT_NAME_FONT     = NORMAL
	NAMEPLATE_FONT     = NORMAL
	DAMAGE_TEXT_FONT   = COMBAT
	STANDARD_TEXT_FONT = NORMAL

	-- Base fonts
	SetFont(GameTooltipHeader,                  NORMAL, fSize)
	SetFont(NumberFont_OutlineThick_Mono_Small, NUMBER, fSize, "OUTLINE")
	SetFont(NumberFont_Outline_Huge,            NUMBER, 28, "THICKOUTLINE", 28)
	SetFont(NumberFont_Outline_Large,           NUMBER, fSize+3, "OUTLINE")
	SetFont(NumberFont_Outline_Med,             NUMBER, fSize, "OUTLINE")
	SetFont(NumberFont_Shadow_Med,              NORMAL, fSize)
	SetFont(NumberFont_Shadow_Small,            NORMAL, fSize)
	SetFont(QuestFont,                          NORMAL, fSize+2)
	SetFont(QuestFont_Large,                    NORMAL, fSize+2)
	SetFont(SystemFont_Large,                   NORMAL, fSize+2)
	SetFont(SystemFont_Med1,                    NORMAL, fSize-1)
	SetFont(SystemFont_Med3,                    NORMAL, fSize-1)
	SetFont(SystemFont_OutlineThick_Huge2,      NORMAL, fSize+7, "THICKOUTLINE")
	SetFont(SystemFont_Outline_Small,           NUMBER, fSize, "OUTLINE")
	SetFont(SystemFont_Shadow_Large,            NORMAL, fSize+2)
	SetFont(SystemFont_Shadow_Med1,             NORMAL, fSize)
	SetFont(SystemFont_Shadow_Med3,             NORMAL, fSize)
	SetFont(SystemFont_Shadow_Outline_Huge2,    NORMAL, fSize+7, "OUTLINE")
	SetFont(SystemFont_Shadow_Small,            NORMAL, fSize)
	SetFont(SystemFont_Small,                   NORMAL, fSize)
	SetFont(SystemFont_Tiny,                    NORMAL, fSize)
	SetFont(Tooltip_Med,                        NORMAL, fSize)
	SetFont(Tooltip_Small,                      NORMAL, fSize)
	SetFont(CombatTextFont,                     COMBAT, 100, "OUTLINE") -- number here just increase the font quality.

	hooksecurefunc("PlayerTitleFrame_UpdateTitles", FixTitleFont)
	FixTitleFont()

	SetFont = nil
	self:SetScript("OnEvent", nil)
	self:UnregisterAllEvents()
	self = nil
end)