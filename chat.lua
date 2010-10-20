local module = {}
module.name = "Chat"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
	
	-- variables
	local settings = fuiDB
	local opts = settings[module.name]
	
	local color = _G["RAID_CLASS_COLORS"][select(2, UnitClass("player"))] or {0,0,0}

	local AddOn = CreateFrame("Frame")
	local OnEvent = function(self, event, ...) self[event](self, event, ...) end
	AddOn:SetScript("OnEvent", OnEvent)

	local _G = _G
	local replace = string.gsub
	local find = string.find

	local replaceschan = {
		['Гильдия'] = '[Г]',
		['Группа'] = '[Гр]',
		['Рейд'] = '[Р]',
		['Лидер рейда'] = '[ЛР]',
		['Объявление рейду'] = '[ОР]',
		['Офицер'] = '[О]',
		['Поле боя'] = '[ПБ]',
		['Лидер поля боя'] = '[ЛПБ]',
		['(%d+)%. .-'] = '[%1]',
	}

	if opts.ChatScroll then
		SetCVar("chatMouseScroll", 1)
	else
		SetCVar("chatMouseScroll", 0)
	end
	
	SetCVar("showTimestamps", "none")
	SetCVar("chatStyle", "classic")
	SetCVar("WholeChatWindowClickable", 0)
	SetCVar("ConversationMode", "inline")
	
	
	-- Player entering the world
	local function PLAYER_ENTERING_WORLD()
		ChatFrameMenuButton:Hide()
		ChatFrameMenuButton:SetScript("OnShow", function(self) self:Hide() end)

		-- Hide friends micro button (added in 3.3.5)
		FriendsMicroButton:SetScript("OnShow", FriendsMicroButton.Hide)
		FriendsMicroButton:Hide()

		GeneralDockManagerOverflowButton:SetScript("OnShow", GeneralDockManagerOverflowButton.Hide)
		GeneralDockManagerOverflowButton:Hide()
		
		hooksecurefunc("ChatEdit_OnTextSet", function(text, chatFrame)
			if ( not chatFrame ) then
				chatFrame = DEFAULT_CHAT_FRAME;
			end
			local x=({chatFrame.editBox:GetRegions()})
			local r,g,b,a = x[9]:GetVertexColor()
			chatFrame.editBox:SetBackdropBorderColor(r,g,b)
		end)
		
		hooksecurefunc("ChatEdit_OnEscapePressed", function(eb)
			eb:Hide()
		end)
		
		for i = 1, NUM_CHAT_WINDOWS do
			_G["ChatFrame"..i]:SetClampRectInsets(0,0,0,0)
			
			-- Hide chat buttons
			_G["ChatFrame"..i.."ButtonFrameUpButton"]:Hide()
			_G["ChatFrame"..i.."ButtonFrameDownButton"]:Hide()
			_G["ChatFrame"..i.."ButtonFrameBottomButton"]:Hide()
			_G["ChatFrame"..i.."ButtonFrameMinimizeButton"]:Hide()
			_G["ChatFrame"..i.."ButtonFrame"]:Hide()

			_G["ChatFrame"..i.."ButtonFrameUpButton"]:SetScript("OnShow", function(self) self:Hide() end)
			_G["ChatFrame"..i.."ButtonFrameDownButton"]:SetScript("OnShow", function(self) self:Hide() end)
			_G["ChatFrame"..i.."ButtonFrameBottomButton"]:SetScript("OnShow", function(self) self:Hide() end)
			_G["ChatFrame"..i.."ButtonFrameMinimizeButton"]:SetScript("OnShow", function(self) self:Hide() end)
			_G["ChatFrame"..i.."ButtonFrame"]:SetScript("OnShow", function(self) self:Hide() end)


			-- Stop the chat frame from fading out
			_G["ChatFrame"..i]:SetFading(false)

			_G["ChatFrame"..i]:SetFrameStrata("LOW")
			_G["ChatFrame"..i]:SetMovable(true)
			_G["ChatFrame"..i]:SetUserPlaced(true)

			for j = 1, 10 do
				local x=({_G["ChatFrame"..j.."EditBox"]:GetRegions()})
				x[9]:SetAlpha(0)
				x[10]:SetAlpha(0)
				x[11]:SetAlpha(0)
				_G["ChatFrame"..j.."EditBox"]:SetFont(fuiDB["Main"].Font, fuiDB["Main"].FontSize)
			end
			
			-- Texture and align the chat edit box
			local editbox = _G["ChatFrame"..i.."EditBox"]
			local left, mid, right = select(6, editbox:GetRegions())
			left:Hide(); mid:Hide(); right:Hide()
			SetTemplate(editbox)
			editbox:ClearAllPoints();
			editbox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", 0, 30)
			editbox:SetPoint("TOPRIGHT", ChatFrame1, "TOPRIGHT", 0, 60)
			
			editbox:Hide()
			
			-- Disable alt key usage
			editbox:SetAltArrowKeyMode(false)
		end

		-- Remember last channel
		ChatTypeInfo.WHISPER.sticky = 1
		ChatTypeInfo.BN_WHISPER.sticky = 1
		ChatTypeInfo.OFFICER.sticky = 1
		ChatTypeInfo.RAID_WARNING.sticky = 1
		ChatTypeInfo.CHANNEL.sticky = 1
	end

	AddOn:RegisterEvent("PLAYER_ENTERING_WORLD")
	AddOn["PLAYER_ENTERING_WORLD"] = PLAYER_ENTERING_WORLD

	-- Hook into the AddMessage function
	local AddMessageOriginal = ChatFrame1.AddMessage
	local function AddMessageHook(frame, text, ...)
		-- chan text smaller or hidden
		for k,v in pairs(replaceschan) do
			text = text:gsub('|h%['..k..'%]|h', '|h'..v..'|h')
		end
		text = replace(text, "has come online.", "is now |cff298F00online|r !")
		text = replace(text, "|Hplayer:(.+)|h%[(.+)%]|h has earned", "|Hplayer:%1|h%2|h has earned")
		text = replace(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h whispers:", "From [|Hplayer:%1:%2|h%3|h]:")
		text = replace(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h says:", "[|Hplayer:%1:%2|h%3|h]:")	
		text = replace(text, "|Hplayer:(.+):(.+)|h%[(.+)%]|h yells:", "[|Hplayer:%1:%2|h%3|h]:")	
		return AddMessageOriginal(frame, text, ...)
	end
	
	for i = 1, NUM_CHAT_WINDOWS do
		if ( i ~= 2 ) then
		local frame = _G["ChatFrame"..i]
			AddMessageOriginal = frame.AddMessage
			frame.AddMessage = AddMessageHook
		end
	end

	local AddMessageOriginal3 = ChatFrame3.AddMessage
	local function AddMessageHook3(frame, text, ...)
		-- chan text smaller or hidden
		text = text:gsub('|h%[(%d+)%. .-%]|h', '|h[%1]|h')

		return AddMessageOriginal3(frame, text, ...)
	end
	ChatFrame3.AddMessage = AddMessageHook3


	local function AddTime(frame, msg, ...)
		if msg and msg ~= '' then
			msg = format("[%02d:%02d] %s", date('%H'), date('%M'), msg)
		end
		
		frame:tChat_Original_AddMessage(msg, ...)
	end

	-----------------------------------------------------------------------------
	-- copy url
	-----------------------------------------------------------------------------
	if opts.CopyURL then
		local color = "0022FF"
		local pattern = "[wWhH][wWtT][wWtT][\46pP]%S+[^%p%s]"

		function string.color(text, color)
			return "|cff"..color..text.."|r"
		end

		function string.link(text, type, value, color)
			return "|H"..type..":"..tostring(value).."|h"..tostring(text):color(color or "ffffff").."|h"
		end

		StaticPopupDialogs["LINKME"] = {
			text = "URL COPY",
			button2 = CANCEL,
			hasEditBox = true,
			hasWideEditBox = true,
			timeout = 0,
			exclusive = 1,
			hideOnEscape = 1,
			EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
			whileDead = 1,
			maxLetters = 255,
		}

		local function f(url)
			return string.link("["..url.."]", "url", url, color)
		end

		local function hook(self, text, ...)
			self:f(text:gsub(pattern, f), ...)
		end

		for i = 1, NUM_CHAT_WINDOWS do
			if ( i ~= 2 ) then
				local frame = _G["ChatFrame"..i]
				frame.f = frame.AddMessage
				frame.AddMessage = hook
			end
		end

		local f = ChatFrame_OnHyperlinkShow
		function ChatFrame_OnHyperlinkShow(self, link, text, button)
			local type, value = link:match("(%a+):(.+)")
			if ( type == "url" ) then
				local dialog = StaticPopup_Show("LINKME")
				local editbox = _G[dialog:GetName().."WideEditBox"]  
				editbox:SetText(value)
				editbox:SetFocus()
				editbox:HighlightText()
				local button = _G[dialog:GetName().."Button2"]
						
				button:ClearAllPoints()
					  
				button:SetPoint("CENTER", editbox, "CENTER", 0, -30)
			else
				f(self, link, text, button)
			end
		end
	end
	------------------------------------------------------------------------
	-- No more click on item chat link
	------------------------------------------------------------------------
	if opts.HoverLinks then
		local orig1, orig2 = {}, {}
		local GameTooltip = GameTooltip

		local linktypes = {item = true, enchant = true, spell = true, quest = true, unit = true, talent = true, achievement = true, glyph = true}


		local function OnHyperlinkEnter(frame, link, ...)
			local linktype = link:match("^([^:]+)")
			if linktype and linktypes[linktype] then
				GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
				GameTooltip:SetHyperlink(link)
				GameTooltip:Show()
			end

			if orig1[frame] then return orig1[frame](frame, link, ...) end
		end

		local function OnHyperlinkLeave(frame, ...)
			GameTooltip:Hide()
			if orig2[frame] then return orig2[frame](frame, ...) end
		end


		local _G = getfenv(0)
		for i=1, NUM_CHAT_WINDOWS do
			local frame = _G["ChatFrame"..i]
			orig1[frame] = frame:GetScript("OnHyperlinkEnter")
			frame:SetScript("OnHyperlinkEnter", OnHyperlinkEnter)

			orig2[frame] = frame:GetScript("OnHyperlinkLeave")
			frame:SetScript("OnHyperlinkLeave", OnHyperlinkLeave)
		end
	end
	
	-----------------------------------------------------------------------------
	-- Copy Chat (credit: shestak for this version)
	-----------------------------------------------------------------------------
	if opts.CopyChat then
		local lines = {}
		local frame = nil
		local editBox = nil
		local isf = nil

		local function CreatCopyFrame()
			frame = CreateFrame("Frame", "CopyFrame", UIParent)
			SetTemplate(frame)
			frame:SetWidth(410)
			frame:SetHeight(200)
			frame:SetScale(1)
			frame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 10)
			frame:Hide()
			frame:SetFrameStrata("DIALOG")

			local scrollArea = CreateFrame("ScrollFrame", "CopyScroll", frame, "UIPanelScrollFrameTemplate")
			scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
			scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)

			editBox = CreateFrame("EditBox", "CopyBox", frame)
			editBox:SetMultiLine(true)
			editBox:SetMaxLetters(99999)
			editBox:EnableMouse(true)
			editBox:SetAutoFocus(false)
			editBox:SetFontObject(ChatFontNormal)
			editBox:SetWidth(410)
			editBox:SetHeight(200)
			editBox:SetScript("OnEscapePressed", function() frame:Hide() end)

			scrollArea:SetScrollChild(editBox)

			local close = CreateFrame("Button", "CopyCloseButton", frame, "UIPanelCloseButton")
			close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")

			isf = true
		end

		local function GetLines(...)
			--[[ Grab all those lines ]]--
			local ct = 1
			for i = select("#", ...), 1, -1 do
				local region = select(i, ...)
				if region:GetObjectType() == "FontString" then
					lines[ct] = tostring(region:GetText())
					ct = ct + 1
				end
			end
			return ct - 1
		end

		local function Copy(cf)
			local _, size = cf:GetFont()
			FCF_SetChatWindowFontSize(cf, cf, 0.01)
			local lineCt = GetLines(cf:GetRegions())
			local text = table.concat(lines, "\n", 1, lineCt)
			FCF_SetChatWindowFontSize(cf, cf, size)
			if not isf then CreatCopyFrame() end
			frame:Show()
			editBox:SetText(text)
			editBox:HighlightText(0)
		end

		for i = 1, NUM_CHAT_WINDOWS do
			if i ~= 2 then
				local cf = _G[format("ChatFrame%d",  i)]
				local but = CreateFrame("button", "copybutton_"..i, cf)
				but:SetPoint("TOPRIGHT", 0, 0)
				but:SetHeight(10)
				but:SetWidth(10)
				but:SetAlpha(0)
				SetTemplate(but)
				but:SetScript("OnClick", function(self) Copy(self:GetParent()) end)
				but:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
				but:SetScript("OnLeave", function(self) self:SetAlpha(0) end)
			end
		end
	end

	--[[ Extras ]]--
	local chatsetup = CreateFrame("Frame")
	chatsetup:RegisterEvent("PLAYER_ENTERING_WORLD")
	chatsetup:SetScript("OnEvent", function(self, event)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")

		local cbgg = CreateFrame("frame", nil, UIParent)
		cbgg:SetPoint("BOTTOMLEFT", ChatFrame1, "BOTTOMLEFT", -4, -4)
		cbgg:SetPoint("TOPRIGHT", ChatFrame1, "TOPRIGHT", 4, 4)
		SetTemplate(cbgg)
		cbgg:SetFrameStrata("LOW")
		
		-----------------------------------------------------------------------
		-- OVERWRITE GLOBAL VAR FROM BLIZZARD
		-----------------------------------------------------------------------

		-- seconds to wait when chatframe fade, default is 2
		CHAT_FRAME_FADE_OUT_TIME = 0

		-- seconds to wait when tabs are not on mouseover, default is 1
		CHAT_TAB_HIDE_DELAY = 0

		-- alpha of the current tab, default in 3.3.5 are 1 for mouseover and 0.4 for nomouseover
		CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
		CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0

		-- alpha of non-selected and non-alert tabs, defaut on mouseover is 0.6 and on nomouseover, 0.2
		CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
		CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0

		-- alpha of alerts (example: whisper via another tab)
		CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
		CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 0

		for i = 1, NUM_CHAT_WINDOWS do

			-- Hide chat textures backdrop
			--for j = 1, #CHAT_FRAME_TEXTURES do
				--_G["ChatFrame"..i..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
			--end 
			
			
		--[[_G[format("ChatFrame%dTabLeft", i)]:SetTexture(nil)
			_G[format("ChatFrame%dTabRight", i)]:SetTexture(nil)
			_G[format("ChatFrame%dTabMiddle", i)]:SetTexture(nil)
			_G[format("ChatFrame%dTabSelectedLeft", i)]:SetTexture(nil)
			_G[format("ChatFrame%dTabSelectedRight", i)]:SetTexture(nil)
			_G[format("ChatFrame%dTabSelectedMiddle", i)]:SetTexture(nil)
			_G[format("ChatFrame%dTabGlow", i)]:SetTexture(nil)
			_G[format("ChatFrame%dTabHighlightLeft", i)]:SetTexture(nil)
			_G[format("ChatFrame%dTabHighlightMiddle", i)]:SetTexture(nil)
			_G[format("ChatFrame%dTabHighlightRight", i)]:SetTexture(nil)]]
			
			_G[format("ChatFrame%dTabText", i)]:SetFont(fuiDB["Main"].Font, fuiDB["Main"].FontSize, "THINOUTLINE")
			_G[format("ChatFrame%dTabText", i)]:SetShadowOffset(0, 0)
			
			_G[format("ChatFrame%d", i)]:SetFont("Fonts\\ARIALN.ttf", 14, "OUTLINE")
			_G[format("ChatFrame%d", i)]:SetShadowOffset(0, 0)
			_G[format("ChatFrame%d", i)]:SetFrameLevel(cbgg:GetFrameLevel()+1)
			_G[format("ChatFrame%d", i)]:SetMinResize(50,50)
		end
		
		ChatFrame1:SetPoint("BOTTOMLEFT", 8, 8)
		ChatFrame1:SetPoint("BOTTOMRIGHT", _G["ActionButton1"], "BOTTOMLEFT", -8, 0)
		
	 end)
	
 end
 tinsert(fui.modules, module) -- finish him!