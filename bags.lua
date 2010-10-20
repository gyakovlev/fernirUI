local settings = nil
local option

-- texture used to skin buttons, when skinning is enabled.
local BAGS_BACKPACK = {0, 1, 2, 3, 4}
local BAGS_BANK = {-1, 5, 6, 7, 8, 9, 10, 11}

local ST_NORMAL = 1
local ST_SOULBAG = 2
local ST_SPECIAL = 3
local ST_QUIVER = 4

--
-- bag slot stuff
--
local trashParent = CreateFrame("Frame", nil, UIParent)
local trashButton = {}
local trashBag = {}

-- for the tooltip frame used to scan item tooltips
local StuffingTT = nil

-- mostly from cargBags_Aurora
local QUEST_ITEM_STRING = nil

-- from OneBag
local BAGTYPE_QUIVER = 0x0001 + 0x0002 
local BAGTYPE_SOUL = 0x004
local BAGTYPE_PROFESSION = 0x0008 + 0x0010 + 0x0020 + 0x0040 + 0x0080 + 0x0200 + 0x0400

-- drop down menu stuff from Postal
local Stuffing_DDMenu = CreateFrame("Frame", "Stuffing_DropDownMenu")
Stuffing_DDMenu.displayMode = "MENU"
Stuffing_DDMenu.info = {}
Stuffing_DDMenu.HideMenu = function()
     if UIDROPDOWNMENU_OPEN_MENU == Stuffing_DDMenu then
          CloseDropDownMenus()
     end
end


Stuffing = CreateFrame ("Frame", nil, UIParent)

     -- stub for localization.
     local L = setmetatable({}, {
          __index = function (t, v)
               t[v] = v
               return v
          end
     })
     
--
-- config
--

local function SetDefaults()
     settings[option].cols = 10                    -- columns to use for bags.
     settings[option].bankCols = 15               -- columns to use for bank.
     settings[option].bsize = 32                    -- height and width of the item buttons (default: 37).
     settings[option].spacing = 4                    -- spacing between buttons.
     settings[option].padding = 10                    -- left, right and bottom padding.
     settings[option].clamp = true                    -- clamp bag window to screen.
     settings[option].rarity_glow = true               -- color item borders by rarity.
     settings[option].search_glow = {0.8, 0.8, 0.3, 1}     -- glow color used for search highlighting.
     settings[option].locked = false                    -- lock bag frame position.
     settings[option].backdrop_color = {0.1, 0.1, 0.1, 1}
     settings[option].border_color = {0, 0, 0, 1}
     settings[option].quest_glow = true
     settings[option].quest_glow_color = {1.0, 0.3, 0.3, 1}
     settings[option].hide_soulbag = false

     settings[option].force_defaults = false

     settings[option].soulbag_color = {0.8, 0.2, 0.2, 1}
     settings[option].special_color = {0.2, 0.2, 0.8, 1}
     settings[option].quiver_color = {0.8, 0.8, 0.2, 1}

     settings[option].bag_bars = false
end

local function Print (x)
     DEFAULT_CHAT_FRAME:AddMessage("|cFFFF6633Stuffing:|r " .. x)
end

local function Stuffing_Sort(args)
     if not args then
          args = ""
     end

     Stuffing.itmax = 0
     Print(L["Starting sorting, please be patient."])
     Stuffing:SetBagsForSorting(args)
     Stuffing:SortBags()
end

local function Stuffing_OnShow()
     Stuffing:PLAYERBANKSLOTS_CHANGED(29)     -- XXX: hack to force bag frame update

     Stuffing:Layout()
     Stuffing:SearchReset()
end


local function StuffingBank_OnHide()
     CloseBankFrame()
end


local function Stuffing_OnHide()
     if Stuffing.bankFrame and Stuffing.bankFrame:IsShown() then
          Stuffing.bankFrame:Hide()
     end
end


local function Stuffing_Open()
     Stuffing.frame:Show()
end


local function Stuffing_Close()
     Stuffing.frame:Hide()
end


local function Stuffing_Toggle()
     if Stuffing.frame:IsShown() then
          Stuffing_Close()
     else
          Stuffing_Open()
     end
end


local function Stuffing_ToggleBag(id)
     if id == -2 then
          ToggleKeyRing()
          return
     end
     Stuffing_Toggle()
end


local function StartMoving(self)
     self:StartMoving()
     local n = self:GetName()
end


local function StopMoving(self)
     self:StopMovingOrSizing()
     self:SetUserPlaced(true)

     local n = self:GetName()
     local x, y = self:GetCenter()
     settings[option][n .. "PosX"] = x
     settings[option][n .. "PosY"] = y
end

function Stuffing:SlotUpdate(b)
     local texture, count, locked = GetContainerItemInfo (b.bag, b.slot)
     local clink = GetContainerItemLink(b.bag, b.slot)

     if b.Cooldown then
          local cd_start, cd_finish, cd_enable = GetContainerItemCooldown(b.bag, b.slot)
          CooldownFrame_SetTimer(b.Cooldown, cd_start, cd_finish, cd_enable)
     end

     if(clink) then
          local iType
          b.name, _, b.rarity, _, _, iType = GetItemInfo(clink)

          if settings[option].quest_glow then
               if not StuffingTT then
                    StuffingTT = CreateFrame("GameTooltip", "StuffingTT", nil, "GameTooltipTemplate")
                    StuffingTT:Hide()
               end

               if QUEST_ITEM_STRING == nil then
                    -- GetItemInfo returns a localized item type.
                    -- this is to figure out what that string is.
                    local t = {GetAuctionItemClasses()}
                    QUEST_ITEM_STRING = t[#t]     -- #t2
               end

               -- load tooltip, check if ITEM_BIND_QUEST ("Quest Item") is in it.
               -- If the tooltip says its a quest item, we assume it is a quest item
               -- and ignore the item type from GetItemInfo.
               StuffingTT:SetOwner(WorldFrame, "ANCHOR_NONE")
               StuffingTT:ClearLines()
               StuffingTT:SetBagItem(b.bag, b.slot)
               for i = 1, StuffingTT:NumLines() do
                    local txt = getglobal("StuffingTTTextLeft" .. i)
                    if txt then
                         local text = txt:GetText()
                         if string.find (txt:GetText(), ITEM_BIND_QUEST) then
                              --print (txt:GetText())
                              --print (b.name)
                              --if iType then print(iType) end
                              iType = QUEST_ITEM_STRING
                         end
                    end
               end

               if iType and iType == QUEST_ITEM_STRING then
                    --print (iType .. " " .. b.name)
                    b.qitem = true
               else
                    b.qitem = nil
               end
          end
     else
          b.name, b.rarity, b.qitem = nil, nil, nil
     end

     SetItemButtonTexture(b.frame, texture)
     SetItemButtonCount(b.frame, count)
     SetItemButtonDesaturated(b.frame, locked, 0.5, 0.5, 0.5)

     if b.Glow then
          b.Glow:Hide()
          if b.rarity then
               if b.rarity > 1 then
                    b.Glow:SetVertexColor(GetItemQualityColor(b.rarity))
                    b.Glow:Show()
               elseif b.qitem and settings[option].quest_glow then
                    b.Glow:SetVertexColor(unpack(settings[option].quest_glow_color))
                    b.Glow:Show()
               end
          end
     end

     b.frame:Show()
end


function Stuffing:BagSlotUpdate(bag)
     if not self.buttons then
          return
     end

     for _, v in ipairs (self.buttons) do
          if v.bag == bag then
               self:SlotUpdate(v)
          end
     end
end


function Stuffing:BagFrameSlotNew (slot, p)
     for _, v in ipairs(self.bagframe_buttons) do
          if v.slot == slot then
               --print ("found " .. slot)
               return v, false
          end
     end

     --print ("new " .. slot)
     local ret = {}
     local tpl

     if slot > 3 then
          ret.slot = slot
          slot = slot - 4
          tpl = "BankItemButtonBagTemplate"
          ret.frame = CreateFrame("CheckButton", "StuffingBBag" .. slot, p, tpl)
          ret.frame:SetID(slot + 4)
          table.insert(self.bagframe_buttons, ret)

          BankFrameItemButton_Update(ret.frame)
          BankFrameItemButton_UpdateLocked(ret.frame)

          if not ret.frame.tooltipText then
               ret.frame.tooltipText = ""
          end
     else
          tpl = "BagSlotButtonTemplate"
          ret.frame = CreateFrame("CheckButton", "StuffingFBag" .. slot .. "Slot", p, tpl)
          ret.slot = slot
          table.insert(self.bagframe_buttons, ret)
     end

     return ret
end


function Stuffing:SlotNew (bag, slot)
     for _, v in ipairs(self.buttons) do
          if v.bag == bag and v.slot == slot then
               return v, false
          end
     end

     local tpl = "ContainerFrameItemButtonTemplate"

     if bag == -1 then
          tpl = "BankItemButtonGenericTemplate"
     end

     local ret = {}

     if #trashButton > 0 then
          local f = -1
          for i, v in ipairs(trashButton) do
               local b, s = v:GetName():match("(%d+)_(%d+)")

               b = tonumber(b)
               s = tonumber(s)

               --print (b .. " " .. s)
               if b == bag and s == slot then
                    f = i
                    break
               end
          end

          if f ~= -1 then
               --print("found it")
               ret.frame = trashButton[f]
               table.remove(trashButton, f)
          end
     end

     if not ret.frame then
          ret.frame = CreateFrame("Button", "StuffingBag" .. bag .. "_" .. slot, self.bags[bag], tpl)
     end

     ret.bag = bag
     ret.slot = slot
     ret.frame:SetID(slot)

     if settings[option].rarity_glow and not ret.Glow then
          -- from cargBags_Aurora
          local glow = ret.frame:CreateTexture(nil, "OVERLAY")
          glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
          glow:SetBlendMode("ADD")
          glow:SetAlpha(.8)
          glow:SetPoint("CENTER", ret.frame)
          ret.Glow = glow
     end

     ret.Cooldown = _G[ret.frame:GetName() .. "Cooldown"]
     ret.Cooldown:Show()

     self:SlotUpdate (ret)

     return ret, true
end

function Stuffing:BagType(bag)
     local bagType = select(2, GetContainerNumFreeSlots(bag))

     if bit.band(bagType, BAGTYPE_QUIVER) > 0 then
          return ST_QUIVER
     elseif bit.band(bagType, BAGTYPE_SOUL) > 0 then
          return ST_SOULBAG
     elseif bit.band(bagType, BAGTYPE_PROFESSION) > 0 then
          return ST_SPECIAL
     end

     return ST_NORMAL
end


function Stuffing:BagNew (bag, f)
     for i, v in pairs(self.bags) do
          if v:GetID() == bag then
               v.bagType = self:BagType(bag)
               return v
          end
     end

     local ret

     if #trashBag > 0 then
          local f = -1
          for i, v in pairs(trashBag) do
               if v:GetID() == bag then
                    f = i
                    break
               end
          end

          if f ~= -1 then
               --print("found bag " .. bag)
               ret = trashBag[f]
               table.remove(trashBag, f)
               ret:Show()
               ret.bagType = self:BagType(bag)
               return ret
          end
     end

     --print("new bag " .. bag)
     ret = CreateFrame("Frame", "StuffingBag" .. bag, f)
     ret.bagType = self:BagType(bag)

     ret:SetID(bag)
     return ret
end


function Stuffing:SearchUpdate(str)
     str = string.lower(str)

     for _, b in ipairs(self.buttons) do
          if b.name then
               if not string.find (string.lower(b.name), str) then
                    SetItemButtonDesaturated(b.frame, 1, 1, 1, 1)
                    if b.Glow then
                         b.Glow:Hide()
                    end
               else
                    SetItemButtonDesaturated(b.frame, 0, 1, 1, 1)
                    if b.Glow then
                         b.Glow:Show()
                         b.Glow:SetVertexColor(unpack(settings[option].search_glow))
                    end
               end
          end
     end
end


function Stuffing:SearchReset()
     for _, b in ipairs(self.buttons) do
          SetItemButtonDesaturated(b.frame, 0, 1, 1, 1)
          if b.Glow then
               b.Glow:Hide()
               if b.rarity then
                    if b.rarity > 1 then
                         b.Glow:SetVertexColor(GetItemQualityColor(b.rarity))
                         b.Glow:Show()
                    elseif b.qitem and settings[option].quest_glow then
                         b.Glow:SetVertexColor(unpack(settings[option].quest_glow_color))
                         b.Glow:Show()
                    end
               end
          end
     end
end


function Stuffing.Menu(self, level)
     if not level then
          return
     end

     local info = self.info

     wipe(info)

     if level ~= 1 then
          return
     end

     wipe(info)
     info.isTitle = 1
     info.text = "Stuffing"
     info.notCheckable = 1
     UIDropDownMenu_AddButton(info, level)

     wipe(info)
     info.disabled = 1
     info.text = nil
     info.func = nil
     UIDropDownMenu_AddButton(info, level)

     wipe(info)
     info.text = "Sort"
     info.notCheckable = 1
     info.func = function()
          Stuffing_Sort("d")
     end
     UIDropDownMenu_AddButton(info, level)

     wipe(info)
     info.text = "Sort Special"
     info.notCheckable = 1
     info.func = function()
          Stuffing_Sort("c/p")
     end
     UIDropDownMenu_AddButton(info, level)

     wipe(info)
     info.text = "Stack"
     info.notCheckable = 1
     info.func = function()
          Stuffing:SetBagsForSorting("d")
          Stuffing:Restack()
     end
     UIDropDownMenu_AddButton(info, level)

     wipe(info)
     info.text = "Stack Special"
     info.notCheckable = 1
     info.func = function()
          Stuffing:SetBagsForSorting("c/p")
          Stuffing:Restack()
     end
     UIDropDownMenu_AddButton(info, level)

     wipe(info)
     info.disabled = 1
     info.notCheckable = 1
     info.text = nil
     info.func = nil
     UIDropDownMenu_AddButton(info, level)

     wipe(info)
     info.text = "Show Bags"
     info.checked = function()
          return settings[option].bag_bars == true
     end

     info.func = function()
          if settings[option].bag_bars then
               settings[option].bag_bars = false
          else
               settings[option].bag_bars = 1
          end
          Stuffing:Layout()
          if Stuffing.bankFrame and Stuffing.bankFrame:IsShown() then
               Stuffing:Layout(true)
          end

     end
     UIDropDownMenu_AddButton(info, level)

     wipe(info)
     info.disabled = 1
     info.text = nil
     info.func = nil
     UIDropDownMenu_AddButton(info, level)

     wipe(info)
     info.text = "Show Keyring"
     info.notCheckable = 1
     info.func = ToggleKeyRing
     UIDropDownMenu_AddButton(info, level)

     wipe(info)
     info.disabled = 1
     info.text = nil
     info.func = nil
     UIDropDownMenu_AddButton(info, level)

     wipe(info)
     info.disabled = nil
     info.notCheckable = 1
     info.text = CLOSE
     info.func = self.HideMenu
     info.tooltipTitle = CLOSE
     UIDropDownMenu_AddButton(info, level)
end


function Stuffing:CreateBagFrame(w)
     local n = "StuffingFrame"  .. w
     local f = CreateFrame ("Frame", n, UIParent)
     f:EnableMouse(1)
     f:SetMovable(1)
     f:SetToplevel(1)
     f:SetFrameStrata("HIGH")

     if w == "Bank" then
          f:SetScript("OnMouseDown", StartMoving)
          f:SetScript("OnMouseUp", StopMoving)
     else
          if not settings[option].locked then
               f:SetScript("OnMouseDown", StartMoving)
               f:SetScript("OnMouseUp", StopMoving)
          end
     end

     local x = settings[option][n .. "PosX"] or 0
     local y = settings[option][n .. "PosY"] or 0
     f:SetPoint ("CENTER", UIParent, "BOTTOMLEFT", x, y)

     -- close button
     f.b_close = CreateFrame("Button", "Stuffing_CloseButton" .. w, f, "UIPanelCloseButton")
     f.b_close:SetWidth(32)
     f.b_close:SetHeight(32)
     f.b_close:SetPoint("TOPRIGHT", -3, -3)
     f.b_close:SetScript("OnClick", function(self, btn)
          if self:GetParent():GetName() == "StuffingFrameBags" and btn == "RightButton" then
               if Stuffing_DDMenu.initialize ~= Stuffing.Menu then
                    CloseDropDownMenus()
                    Stuffing_DDMenu.initialize = Stuffing.Menu
               end
               ToggleDropDownMenu(1, nil, Stuffing_DDMenu, self:GetName(), 0, 0)
               return
          end
          self:GetParent():Hide()
     end)
     f.b_close:RegisterForClicks("AnyUp")
     f.b_close:GetNormalTexture():SetDesaturated(1)

     -- create the bags frame
     local fb = CreateFrame ("Frame", n .. "BagsFrame", f)
     fb:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 2)
     fb:SetFrameStrata("HIGH")
     f.bags_frame = fb

     return f
end


function Stuffing:InitBank()
     if self.bankFrame then
          return
     end

     local f = self:CreateBagFrame("Bank")
     f:SetScript("OnHide", StuffingBank_OnHide)
     self.bankFrame = f
end


local parent_startmoving = function(self)
     StartMoving(self:GetParent())
end


local parent_stopmovingorsizing = function (self)
     StopMoving(self:GetParent())
end


function Stuffing:LockUnlock()
     local f = self.frame

     if not settings[option].locked then
          f:SetScript("OnMouseDown", StartMoving)
          f:SetScript("OnMouseUp", StopMovingOrSizing)
          f.button:SetScript("OnMouseDown", parent_startmoving)
          f.button:SetScript("OnMouseUp", parent_stopmovingorsizing)
     else
          f:SetScript("OnMouseDown", nil)
          f:SetScript("OnMouseUp", nil)
          f.button:SetScript("OnMouseDown", nil)
          f.button:SetScript("OnMouseUp", nil)
     end
end


function Stuffing:InitBags()
     if self.frame then
          return
     end

     self.buttons = {}
     self.bags = {}
     self.bagframe_buttons = {}

     local f = self:CreateBagFrame("Bags")
     f:SetScript("OnShow", Stuffing_OnShow)
     f:SetScript("OnHide", Stuffing_OnHide)

     -- search editbox (tekKonfigAboutPanel.lua)
     local editbox = CreateFrame("EditBox", nil, f)
     editbox:Hide()
     editbox:SetAutoFocus(true)
     editbox:SetHeight(32)

     local left = editbox:CreateTexture(nil, "BACKGROUND")
     left:SetWidth(8) left:SetHeight(20)
     left:SetPoint("LEFT", -5, 0)
     left:SetTexture("Interface\\Common\\Common-Input-Border")
     left:SetTexCoord(0, 0.0625, 0, 0.625)

     local right = editbox:CreateTexture(nil, "BACKGROUND")
     right:SetWidth(8) right:SetHeight(20)
     right:SetPoint("RIGHT", 0, 0)
     right:SetTexture("Interface\\Common\\Common-Input-Border")
     right:SetTexCoord(0.9375, 1, 0, 0.625)

     local center = editbox:CreateTexture(nil, "BACKGROUND")
     center:SetHeight(20)
     center:SetPoint("RIGHT", right, "LEFT", 0, 0)
     center:SetPoint("LEFT", left, "RIGHT", 0, 0)
     center:SetTexture("Interface\\Common\\Common-Input-Border")
     center:SetTexCoord(0.0625, 0.9375, 0, 0.625)

     local resetAndClear = function (self)
          self:GetParent().detail:Show()
          self:GetParent().gold:Show()
          self:ClearFocus()
          Stuffing:SearchReset()
     end

     local updateSearch = function(self, t)
          if t == true then
               Stuffing:SearchUpdate(self:GetText())
          end
     end

     editbox:SetScript("OnEscapePressed", resetAndClear)
     editbox:SetScript("OnEnterPressed", resetAndClear)
     editbox:SetScript("OnEditFocusLost", editbox.Hide)
     editbox:SetScript("OnEditFocusGained", editbox.HighlightText)
     editbox:SetScript("OnTextChanged", updateSearch)
     editbox:SetText("Search")


     local detail = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
     detail:SetPoint("TOPLEFT", f, settings[option].padding, -10)
     detail:SetPoint("RIGHT", -(16 + 24), 0)
     detail:SetJustifyH("LEFT")
     detail:SetText("|cff9999ff" .. "Search")
     editbox:SetAllPoints(detail)

     local gold = f:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
     gold:SetJustifyH("RIGHT")
     gold:SetPoint("RIGHT", f.b_close, "LEFT", -3, 0)

     f:SetScript("OnEvent", function (self, e)
          self.gold:SetText (GetCoinTextureString(GetMoney(), settings["Main"].FontSize))
     end)

     f:RegisterEvent("PLAYER_MONEY")
     f:RegisterEvent("PLAYER_LOGIN")
     f:RegisterEvent("PLAYER_TRADE_MONEY")
     f:RegisterEvent("TRADE_MONEY_CHANGED")

     local OpenEditbox = function(self)
          self:GetParent().detail:Hide()
          self:GetParent().gold:Hide()
          self:GetParent().editbox:Show()
          self:GetParent().editbox:HighlightText()
     end

     local button = CreateFrame("Button", nil, f)
     button:EnableMouse(1)
     button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
     button:SetAllPoints(detail)
     button:SetScript("OnClick", function(self, btn)
          if btn == "RightButton" then
               OpenEditbox(self)
          else
               if self:GetParent().editbox:IsShown() then
                    self:GetParent().editbox:Hide()
                    self:GetParent().editbox:ClearFocus()
                    self:GetParent().detail:Show()
                    self:GetParent().gold:Show()
                    Stuffing:SearchReset()
               end
          end
     end)

     local tooltip_hide = function()
          GameTooltip:Hide()
     end

     local tooltip_show = function (self)
          GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
          GameTooltip:ClearLines()
          GameTooltip:SetText("Right-click to search.")
     end

     button:SetScript("OnEnter", tooltip_show)
     button:SetScript("OnLeave", tooltip_hide)

     if not settings[option].locked then
          button:SetScript("OnMouseDown", parent_startmoving)
          button:SetScript("OnMouseUp", parent_stopmovingorsizing)
     end

     f.editbox = editbox
     f.detail = detail
     f.button = button
     f.gold = gold
     self.frame = f
     f:Hide()
end


function Stuffing:Layout(lb)
     local slots = 0
     local rows = 0
     local off = 26
     local cols
     local f
     local bs

     if lb then
          bs = BAGS_BANK
          cols = settings[option].bankCols
          f = self.bankFrame
     else
          bs = BAGS_BACKPACK
          cols = settings[option].cols
          f = self.frame

          f.gold:SetText(GetCoinTextureString(GetMoney(), settings["Main"].FontSize))
          f.editbox:SetFont(settings["Main"].Font, settings["Main"].FontSize)
          f.detail:SetFont(settings["Main"].Font, settings["Main"].FontSize)
          f.gold:SetFont(settings["Main"].Font, settings["Main"].FontSize)

          f.detail:ClearAllPoints()
          f.detail:SetPoint("TOPLEFT", f, settings[option].padding, -10)
          f.detail:SetPoint("RIGHT", -(16 + 24), 0)
     end

     f:SetClampedToScreen(settings[option].clamp)
     SetTemplate(f)

     -- bag frame stuff
     local fb = f.bags_frame
     if settings[option].bag_bars then
          fb:SetClampedToScreen(settings[option].clamp)
          SetTemplate(fb)

          local bsize = 30
          if lb then bsize = 37 end

          local w = 2 * settings[option].padding
          w = w + ((#bs - 1) * bsize)
          w = w + (settings[option].spacing * (#bs - 2))

          fb:SetHeight(2 * settings[option].padding + bsize)
          fb:SetWidth(w)
          fb:Show()
     else
          fb:Hide()
     end


     local idx = 0
     for _, v in ipairs(bs) do
          if (not lb and v <= 3 ) or (lb and v ~= -1) then
               local bsize = 30
               if lb then bsize = 37 end

               local b = self:BagFrameSlotNew(v, fb)

               local xoff = settings[option].padding

               xoff = xoff + (idx * bsize) -- settings[option].bsize)
               xoff = xoff + (idx * settings[option].spacing)

               b.frame:ClearAllPoints()
               b.frame:SetPoint("LEFT", fb, "LEFT", xoff, 0)
               b.frame:Show()


               idx = idx + 1
          end
     end


     for _, i in ipairs(bs) do
          local x = GetContainerNumSlots(i)
          if x > 0 then
               if not self.bags[i] then
                    self.bags[i] = self:BagNew(i, f)
               end

               if not (settings[option].hide_soulbag and self.bags[i].bagType == ST_SOULBAG) then
                    slots = slots + GetContainerNumSlots(i)
               end
          end
     end


     rows = floor (slots / cols)
     if (slots % cols) ~= 0 then
          rows = rows + 1
     end

     f:SetWidth(cols * settings[option].bsize
               + (cols - 1) * settings[option].spacing
               + settings[option].padding * 2)

     f:SetHeight(rows * settings[option].bsize
               + (rows - 1) * settings[option].spacing
               + off + settings[option].padding * 2)


     local idx = 0
     for _, i in ipairs(bs) do
          local bag_cnt = GetContainerNumSlots(i)

          if bag_cnt > 0 then
               self.bags[i] = self:BagNew(i, f)
               local bagType = self.bags[i].bagType

               if not (settings[option].hide_soulbag and bagType == ST_SOULBAG) then
                    self.bags[i]:Show()
                    --print (i .. ": " .. GetContainerNumSlots(i) .. " slots.")
                    for j = 1, bag_cnt do
                         local b, isnew = self:SlotNew (i, j)
                         local xoff
                         local yoff
                         local x = (idx % cols)
                         local y = floor(idx / cols)

                         if isnew then
                              table.insert(self.buttons, idx + 1, b)
                         end

                         xoff = settings[option].padding + (x * settings[option].bsize)
                                   + (x * settings[option].spacing)

                         yoff = off + settings[option].padding + (y * settings[option].bsize)
                                   + ((y - 1) * settings[option].spacing)
                         yoff = yoff * -1

                         b.frame:ClearAllPoints()
                         b.frame:SetPoint("TOPLEFT", f, "TOPLEFT", xoff, yoff)
                         b.frame:SetHeight(settings[option].bsize)
                         b.frame:SetWidth(settings[option].bsize)
                         b.frame:Show()

                         local normalTex = _G[b.frame:GetName() .. "NormalTexture"]
                         normalTex:Hide()
                         SetTemplate(b.frame)
                         
                         if bagType == ST_QUIVER then
                              b.frame:SetBackdropBorderColor(unpack(settings[option].quiver_color))
                         elseif bagType == ST_SOULBAG then
                              b.frame:SetBackdropBorderColor(unpack(settings[option].soulbag_color))
                         elseif bagType == ST_SPECIAL then
                              b.frame:SetBackdropBorderColor(unpack(settings[option].special_color))
                         elseif bagType == ST_NORMAL then
                              b.frame:SetBackdropBorderColor(.2,.2,.2,1)
                         end

                         local iconTex = _G[b.frame:GetName() .. "IconTexture"]
                         iconTex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                         iconTex:ClearAllPoints()
                         iconTex:SetPoint("TOPLEFT", b.frame, "TOPLEFT", 2, -2)
                         iconTex:SetPoint("BOTTOMRIGHT", b.frame, "BOTTOMRIGHT", -2, 2)
                         iconTex:Show()
                         b.iconTex = iconTex

                         if b.Glow then
                              b.Glow:SetWidth(settings[option].bsize / 37 * 65)
                              b.Glow:SetHeight(settings[option].bsize / 37 * 65)
                         end

                         local scount = _G[b.frame:GetName() .. "Count"]
                         scount:SetFont (settings["Main"].Font, settings["Main"].FontSize, "OUTLINE")
                         b.scount = scount
                         
                         idx = idx + 1
                    end
               else
                    -- XXX
                    self.bags[i]:Hide()
               end
          end
     end
end


function Stuffing:SetBagsForSorting(c)
     Stuffing_Open()

     self.sortBags = {}

     local cmd = ((c == nil or c == "") and {"d"} or {strsplit("/", c)})

     for _, s in ipairs(cmd) do
          if s == "c" then
               self.sortBags = {}
          elseif s == "d" then
               if not self.bankFrame or not self.bankFrame:IsShown() then
                    for _, i in ipairs(BAGS_BACKPACK) do
                         if self.bags[i] and self.bags[i].bagType == ST_NORMAL then
                              table.insert(self.sortBags, i)
                         end
                    end
               else
                    for _, i in ipairs(BAGS_BANK) do
                         if self.bags[i] and self.bags[i].bagType == ST_NORMAL then
                              table.insert(self.sortBags, i)
                         end
                    end
               end
          elseif s == "p" then
               if not self.bankFrame or not self.bankFrame:IsShown() then
                    for _, i in ipairs(BAGS_BACKPACK) do
                         if self.bags[i] and self.bags[i].bagType == ST_SPECIAL then
                              table.insert(self.sortBags, i)
                         end
                    end
               else
                    for _, i in ipairs(BAGS_BANK) do
                         if self.bags[i] and self.bags[i].bagType == ST_SPECIAL then
                              table.insert(self.sortBags, i)
                         end
                    end
               end
          else
               if tonumber(s) == nil then
                    Print(string.format(L["Error: don't know what \"%s\" means."], s))
               end

               table.insert(self.sortBags, tonumber(s))
          end
     end

     local bids = "Using bags: "
     for _, i in ipairs(self.sortBags) do
          bids = bids .. i .. " "
     end

     Print(bids)
end


-- slash command handler
local function StuffingSlashCmd(Cmd)
     local cmd, args = strsplit(" ", Cmd:lower(), 2)

     if cmd == "sort" then
          Stuffing_Sort(args)
     elseif cmd == "psort" then
          Stuffing_Sort("c/p")
     elseif cmd == "stack" then
          Print(L["Restacking, please be patient."])
          Stuffing:SetBagsForSorting(args)
          Stuffing:Restack()
     elseif cmd == "test" then
          Stuffing:SetBagsForSorting(args)
     elseif cmd == "purchase" then
          -- XXX
          if Stuffing.bankFrame and Stuffing.bankFrame:IsShown() then
               local cnt, full = GetNumBankSlots()
               if full then
                    Print("can't buy anymore slots")
                    return
               end

               if args == "yes" then
                    PurchaseSlot()
                    return
               end

               Print(string.format("Cost: %.2f gold", GetBankSlotCost() / 10000))
               Print("Buy new slot with /stuffing purchase yes")
          else
               Print("You need to open your bank first")
          end
     else
          Print(string.format(L["Version: %s."], GetAddOnMetadata("Stuffing", "Version")))
          Print(L["Commands:"])
          Print("sort - " .. L["sort your bags or your bank, if open."])
          Print("stack - " .. L["fill up partial stacks in your bags or bank, if open."])
     end
end

function Stuffing:PLAYERBANKSLOTS_CHANGED(id)
     if id > 28 then
          for _, v in ipairs(self.bagframe_buttons) do
               --local texture = nil

               if v.frame and v.frame.GetInventorySlot then

                    BankFrameItemButton_Update(v.frame)
                    BankFrameItemButton_UpdateLocked(v.frame)

                    if not v.frame.tooltipText then
                         v.frame.tooltipText = ""
                    end

               end

          end
     end

     if self.bankFrame and self.bankFrame:IsShown() then
          self:BagSlotUpdate(-1)
     end
end


function Stuffing:BAG_UPDATE(id)
     self:BagSlotUpdate(id)
end


function Stuffing:ITEM_LOCK_CHANGED(bag, slot)
     if slot == nil then
          return
     end

     for _, v in ipairs(self.buttons) do
          if v.bag == bag and v.slot == slot then
               self:SlotUpdate(v)
               break
          end
     end
end


function Stuffing:BANKFRAME_OPENED()
     if not self.bankFrame then
          self:InitBank()
     end

     self:Layout(true)
     for _, x in ipairs(BAGS_BANK) do
          self:BagSlotUpdate(x)
     end
     self.bankFrame:Show()
     Stuffing_Open()
end


function Stuffing:BANKFRAME_CLOSED()
     if not self.bankFrame then
          return
     end

     self.bankFrame:Hide()
end


function Stuffing:BAG_CLOSED(id)
     --Print("BAG_CLOSED: " .. id)

     local b = self.bags[id]
     if b then
          table.remove(self.bags, id)
          b:Hide()
          table.insert (trashBag, #trashBag + 1, b)
--     else
--          print("BAG_CLOSED: no such bag: " .. id)
     end

     while true do
          local changed = false

          for i, v in ipairs(self.buttons) do
               if v.bag == id then
                    v.frame:Hide()
                    --v.normalTex:Hide()
                    v.iconTex:Hide()

                    if v.Glow then
                         v.Glow:Hide()
                    end

                    table.insert (trashButton, #trashButton + 1, v.frame)
                    table.remove(self.buttons, i)

                    v = nil
                    changed = true
               end
          end

          if not changed then
               break
          end
     end
end


function Stuffing:SortOnUpdate(e)
     if not self.elapsed then
          self.elapsed = 0
     end

     if not self.itmax then
          self.itmax = 0
     end

     self.elapsed = self.elapsed + e

     if self.elapsed < 0.1 then
          return
     end

     self.elapsed = 0
     self.itmax = self.itmax + 1

     local changed, blocked  = false, false

     if self.sortList == nil or next(self.sortList, nil) == nil then
          -- wait for all item locks to be released.
          local locks = false

          for i, v in pairs(self.buttons) do
               local _, _, l = GetContainerItemInfo(v.bag, v.slot)
               if l then
                    locks = true
               else
                    v.block = false
               end
          end

          if locks then
               -- something still locked. wait some more.
               return
          else
               -- all unlocked. get a new table.
               self:SetScript("OnUpdate", nil)
               self:SortBags()

               if self.sortList == nil then
                    return
               end
          end
     end

     -- go through the list and move stuff if we can.
     for i, v in ipairs (self.sortList) do
          repeat
               if v.ignore then
                    blocked = true
                    break
               end

               if v.srcSlot.block then
                    changed = true
                    break
               end

               if v.dstSlot.block then
                    changed = true
                    break
               end

               local _, _, l1 = GetContainerItemInfo(v.dstSlot.bag, v.dstSlot.slot)
               local _, _, l2 = GetContainerItemInfo(v.srcSlot.bag, v.srcSlot.slot)

               if l1 then
                    v.dstSlot.block = true
               end

               if l2 then
                    v.srcSlot.block = true
               end

               if l1 or l2 then
                    break
               end

               if v.sbag ~= v.dbag or v.sslot ~= v.dslot then
                    if v.srcSlot.name ~= v.dstSlot.name then
                         v.srcSlot.block = true
                         v.dstSlot.block = true
                         PickupContainerItem (v.sbag, v.sslot)
                         PickupContainerItem (v.dbag, v.dslot)
                         changed = true
                         break
                    end
               end
          until true
     end

     self.sortList = nil

     if (not changed and not blocked) or self.itmax > 250 then
          self:SetScript("OnUpdate", nil)
          self.sortList = nil
          Print (L["Sorting finished."])
     end
end


local function InBags(x)
     if not Stuffing.bags[x] then
          return false
     end

     for _, v in ipairs(Stuffing.sortBags) do
          if x == v then
               return true
          end
     end
     return false
end


function Stuffing:SortBags()
     local bs = self.sortBags
     if #bs < 1 then
          Print (L["Nothing to sort."])
          return
     end

     local st = {}
     local bank = false


     Stuffing_Open()

     -- get a list of all buttons we want to sort and construct
     -- a string to sort them by.
     for i, v in pairs(self.buttons) do
          if InBags(v.bag) then
               self:SlotUpdate(v)

               if v.name then
                    local tex, cnt, _, _, _, _, clink = GetContainerItemInfo(v.bag, v.slot)
                    local n, _, q, iL, rL, c1, c2, _, Sl = GetItemInfo(clink)
                    table.insert(st, {
                         srcSlot = v,
                         sslot = v.slot,
                         sbag = v.bag,
                         --sort = q .. iL .. c1 .. c2 .. rL .. Sl .. n .. i,
                         --sort = q .. iL .. c1 .. c2 .. rL .. Sl .. n .. (#self.buttons - i),
                         sort = q .. c1 .. c2 .. rL .. n .. iL .. Sl .. (#self.buttons - i),
                         --sort = q .. (#self.buttons - i) .. n,
                    })
               end
          end
     end

     -- sort them
     table.sort (st, function(a, b)
          return a.sort > b.sort
     end)

     -- for each button we want to sort, get a destination button
     local st_idx = 1
     local dbag = bs[st_idx]
     local dslot = 1
     local max_dslot = GetContainerNumSlots(dbag)

     for i, v in ipairs (st) do
          v.dbag = dbag
          v.dslot = dslot
          v.dstSlot = self:SlotNew(dbag, dslot)

          dslot = dslot + 1

          if dslot > max_dslot then
               dslot = 1

               while true do
                    st_idx = st_idx + 1

                    if st_idx > #bs then
                         break
                    end

                    dbag = bs[st_idx]

                    if Stuffing:BagType(dbag) == ST_NORMAL or dbag > 4 then
                         break
                    end
               end

               max_dslot = GetContainerNumSlots(dbag)
          end
     end

     -- throw various stuff out of the search list
     local changed = true
     while changed do
          changed = false
          -- XXX why doesn't this remove all x->x moves in one pass?

          for i, v in ipairs (st) do

               -- source is same as destination
               if (v.sslot == v.dslot) and (v.sbag == v.dbag) then
                    table.remove (st, i)
                    changed = true

               -- same item
               --[[
               elseif v.srcSlot.name == v.dstSlot.name then
                    table.remove (st, i) -- XXX
                    changed = true
               --]]
               end
               --
          end
     end

     -- if the destination of something is the source of
     -- something else, don't move it this round.
     --[[
     for i, v in ipairs (st) do
          if not v.ignore then
               for j, w in ipairs (st) do
                    if not w.ignore then
                         if v ~= w and v.dbag == w.sbag and v.dslot == w.sslot then
                              if not (v.sbag == w.dbag and v.sslot == w.dslot) then
                                   w.ignore = true
                              end
                         end
                    end
               end
          end
     end
     --]]


     --[[
     print(#st)
     for i, v in ipairs (st) do
          if not v.ignore then
               print("OK " .. v.sbag .. ":" .. v.sslot .. " -> " .. v.dbag .. ":" .. v.dslot)
          else
               print("IG " .. v.sbag .. ":" .. v.sslot .. " -> " .. v.dbag .. ":" .. v.dslot)
          end
     end
     --]]

     -- kick off moving of stuff, if needed.
     if st == nil or next(st, nil) == nil then
          Print(L["Sorting finished."])
          self:SetScript("OnUpdate", nil)
     else
          self.sortList = st
          self:SetScript("OnUpdate", Stuffing.SortOnUpdate)
     end
end


function Stuffing:RestackOnUpdate(e)
     if not self.elapsed then
          self.elapsed = 0
     end

     self.elapsed = self.elapsed + e

     if self.elapsed < 0.1 then
          return
     end

     self.elapsed = 0
     self:Restack()
end


function Stuffing:Restack()
     local st = {}

     Stuffing_Open()

     for i, v in pairs(self.buttons) do
          if InBags(v.bag) then
               local tex, cnt, _, _, _, _, clink = GetContainerItemInfo(v.bag, v.slot)
               if clink then
                    local n, _, _, _, _, _, _, s = GetItemInfo(clink)

                    if cnt ~= s then
                         if not st[n] then
                              st[n] = {{
                                   item = v,
                                   size = cnt,
                                   max = s
                              }}
                         else
                              table.insert(st[n], {
                                   item = v,
                                   size = cnt,
                                   max = s
                              })
                         end
                    end
               end
          end
     end

     local did_restack = false

     for i, v in pairs(st) do
          if #v > 1 then
               for j = 2, #v, 2 do
                    local a, b = v[j - 1], v[j]
                    local _, _, l1 = GetContainerItemInfo(a.item.bag, a.item.slot)
                    local _, _, l2 = GetContainerItemInfo(b.item.bag, b.item.slot)

                    if l1 or l2 then
                         did_restack = true
                    else
                         PickupContainerItem (a.item.bag, a.item.slot)
                         PickupContainerItem (b.item.bag, b.item.slot)
                         did_restack = true
                    end
               end
          end
     end

     if did_restack then
          self:SetScript("OnUpdate", Stuffing.RestackOnUpdate)
     else
          self:SetScript("OnUpdate", nil)
          Print (L["Restacking finished."])
     end
end


local module = {}
module.name = "Bags"
module.Init = function()
     if not fuiDB.modules[module.name] then return end
     settings = fuiDB
     option = module.name
     
     if not settings[option] then 
          settings[option] = {}
          SetDefaults()
     end
     
     Stuffing:SetScript("OnEvent", function(this, event, ...)
          Stuffing[event](this, ...)
     end)

     Stuffing:RegisterEvent("BAG_UPDATE")
     Stuffing:RegisterEvent("ITEM_LOCK_CHANGED")

     Stuffing:RegisterEvent("BANKFRAME_OPENED")
     Stuffing:RegisterEvent("BANKFRAME_CLOSED")
     Stuffing:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

     Stuffing:RegisterEvent("BAG_CLOSED")

     SlashCmdList["STUFFING"] = StuffingSlashCmd
     SLASH_STUFFING1 = "/stuffing"

     Stuffing:InitBags()

     tinsert(UISpecialFrames,"StuffingFrameBags")

     --
     -- hook functions
     --
     ToggleBackpack = Stuffing_Toggle
     ToggleBag = Stuffing_ToggleBag
     OpenAllBags = Stuffing_Open
     OpenBackpack = Stuffing_Open
     CloseAllBags = Stuffing_Close
     CloseBackpack = Stuffing_Close

     BankFrame:UnregisterAllEvents()

end
tinsert(fui.modules, module) -- finish him!