local BankSlots = { -1,5,6,7,8,9,10,11 }
local isAtBank = false
local preserve = {}
for i=-2,11 do
   preserve[i] = {}
end
SetCVar("equipmentManager", 1)
   
local invSlots = {
   _G["CharacterHeadSlot"],
   _G["CharacterNeckSlot"],
   _G["CharacterShoulderSlot"],
   _G["CharacterShirtSlot"],
   _G["CharacterChestSlot"],
   _G["CharacterWaistSlot"],
   _G["CharacterLegsSlot"],
   _G["CharacterFeetSlot"],
   _G["CharacterWristSlot"],
   _G["CharacterHandsSlot"],
   _G["CharacterFinger0Slot"],
   _G["CharacterFinger1Slot"],
   _G["CharacterTrinket0Slot"],
   _G["CharacterTrinket1Slot"],
   _G["CharacterBackSlot"],
   _G["CharacterMainHandSlot"],
   _G["CharacterSecondaryHandSlot"],
   _G["CharacterRangedSlot"],
   _G["CharacterTabardSlot"],
}

function getCurrentSetName()
   for i = 1, MAX_EQUIPMENT_SETS_PER_PLAYER do
      if _G["GearSetButton"..i]:GetChecked() then
         return _G["GearSetButton" .. i .. "Name"]:GetText()
      end
   end
end
   
function ValidBag(bagid)
	local linkid,bagtype
	if bagid==0 or bagid==-1 then
		return 1
	else
		if GetItemFamily(string.match(GetInventoryItemLink("player",ContainerIDToInventoryID(bagid)) or "","item:(%-?%d+)"))==0 then
			return 1
		end
	end
end

function haveBankSlots()
   if not isAtBank then return end
	for _,i in pairs(BankSlots) do
		if ValidBag(i) then
			for j=1,GetContainerNumSlots(i) do
				if not GetContainerItemLink(i,j) and not preserve[i][j] then
					preserve[i][j] = 1
					return i,j
				end
			end
		end
	end
end

function PutSet(msg) 
   local a1, a2 = {}, {}
   a1=GetEquipmentSetLocations(getCurrentSetName())
   if a1 then
      for _, v in pairs(a1) do
         local player, bank, bags, slot, bag = EquipmentManager_UnpackLocation(v)
         local freebag, freeslot= 0, 0
         if slot then
            freebag, freeslot = haveBankSlots()
            if bag then
               PickupContainerItem(bag, slot)
            elseif player and not bag then
               PickupInventoryItem(slot)
            end
            PickupContainerItem(freebag, freeslot)
         end
      end
      clearPreserve()
      ClearCursor()
   end
end

function clearPreserve()
   for i=-2,11 do
		for j in pairs(preserve[i]) do
			preserve[i][j] = nil
		end
	end
end

function LinkToID(link)
	if link == nil then return 0, 0, 0 end
	local found, _, itemString = string.find(link, "^|c%x+|H(.+)|h%[.*%]")
	local _, itemId, _, _, _, _, _, suffixId, uniqueId = strsplit(":", itemString)
	return itemId, suffixId, uniqueId
end


local frm = CreateFrame("frame")
frm:RegisterEvent("BANKFRAME_OPENED")
frm:RegisterEvent("BANKFRAME_CLOSED")
frm:RegisterEvent("PLAYER_ENTERING_WORLD")
frm:SetScript("OnEvent", function(self, event, ...)
   if event =="PLAYER_ENTERING_WORLD" then
      local ef = _G["GearManagerDialog"]
      ef:SetHeight(195)
      local putb = CreateFrame("button", "butbank_button", ef, "UIPanelButtonTemplate")
      putb:SetWidth(_G["GearManagerDialogDeleteSet"]:GetWidth())
      putb:SetHeight(22)
      putb:SetPoint("BOTTOMLEFT", _G["GearManagerDialogDeleteSet"], "TOPLEFT", 0, 4)
      putb:SetText("in bank")
      putb:Disable()
      putb:SetScript("OnClick", function()
         local sname = getCurrentSetName()
         if isAtBank then
            if not sname then 
               UIErrorsFrame:AddMessage("Select set!", 1.0, 0.1, 0.1, 1.0)
               return 
            end
            PutSet(true)
         else
            UIErrorsFrame:AddMessage("You should open bank", 1.0, 0.1, 0.1, 1.0)
         end
      end)


      for _, v in pairs(invSlots) do
         v.tex = v:CreateTexture(nil, "OVERLAY")
         v.tex:SetTexture (1,0,0, 0.4)
         v.tex:SetAllPoints(v)
         v.tex:Hide()
      end
      
		GearManagerDialog:HookScript("OnHide", function()
         for _, v in pairs(invSlots) do
            v.tex:Hide()
         end
      end)
      
      local function markItems()
         for _, v in pairs(invSlots) do
            v.tex:Hide()
         end
         local setname = getCurrentSetName()
         if setname then
            local items = GetEquipmentSetItemIDs(setname)
            for i, k in pairs(invSlots) do
               local invid = GetInventorySlotInfo(select(3, strfind(k:GetName(),"Character(.+)")))
               for n=1, #items do
                  local id = LinkToID(GetInventoryItemLink("player", invid))
                  if items[n] == tonumber(id) then
                     k.tex:Show()
                  end
               end
            end
         end
      end
		hooksecurefunc ("GearSetButton_OnClick",markItems)
		GearManagerDialog:HookScript ("OnShow", markItems)
      

   elseif event == "BANKFRAME_OPENED" then
      isAtBank = true
      _G["butbank_button"]:Enable()
   elseif event == "BANKFRAME_CLOSED" then
      isAtBank = false
      _G["butbank_button"]:Disable()
   end
end)