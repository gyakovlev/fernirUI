local module = {}
module.name = "Helpers"
module.Init = function()
	if not fuiDB.modules[module.name] then return end

   local settings = fuiDB
   
   SlashCmdList.RELOADUI = ReloadUI
   SLASH_RELOADUI1 = "/rl"
   SLASH_RELOADUI2 = "/кд"

   SlashCmdList.RCSLASH = DoReadyCheck
   SLASH_RCSLASH1 = "/rc"
   SLASH_RCSLASH2 = "/кс"

    
   --[[ Clear UIErrors frame ]]
   UIErrorsFrame:SetScale(0.8)
   WatchFrameTitle:SetAlpha(0)

   -- Disabled WoW's combat log at startup
   local f = CreateFrame("Frame")
   f:SetScript("OnEvent", function()  
      f:UnregisterEvent("COMBAT_LOG_EVENT")
      COMBATLOG:UnregisterEvent("COMBAT_LOG_EVENT")
   end)
   f:RegisterEvent("COMBAT_LOG_EVENT")

   if settings["Helpers"]["Hide errors"] then
       local blocked = {
          SPELL_FAILED_NO_COMBO_POINTS,
          SPELL_FAILED_TARGETS_DEAD,
          SPELL_FAILED_SPELL_IN_PROGRESS,
          SPELL_FAILED_TARGET_AURASTATE,
          SPELL_FAILED_CASTER_AURASTATE,
          SPELL_FAILED_NO_ENDURANCE,
          SPELL_FAILED_BAD_TARGETS,
          SPELL_FAILED_NOT_MOUNTED,
          SPELL_FAILED_NOT_ON_TAXI,
          SPELL_FAILED_NOT_INFRONT,
          SPELL_FAILED_NOT_IN_CONTROL,
          SPELL_FAILED_MOVING,
          ERR_ATTACK_FLEEING,
          ERR_ITEM_COOLDOWN,
          ERR_GENERIC_NO_TARGET,
          ERR_ABILITY_COOLDOWN,
          ERR_OUT_OF_ENERGY,
          ERR_NO_ATTACK_TARGET,
          ERR_SPELL_COOLDOWN,
          ERR_OUT_OF_RAGE,
          ERR_INVALID_ATTACK_TARGET,
          ERR_NOEMOTEWHILERUNNING,
          OUT_OF_ENERGY,
       }

       local errF = CreateFrame("Frame")
       errF:SetScript("OnEvent",function(self, event, errorstr)
           for i, err in pairs(blocked) do
               if errorstr:find(err) then return end
           end
           UIErrorsFrame:AddMessage(error, 1, .1, .1)
       end)
       errF:RegisterEvent("UI_ERROR_MESSAGE")
       UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
   end

   --[[ Autogreed on green items ]]
   if(settings["Helpers"].AutoGreedOnGreen) then
       local f = CreateFrame("Frame")
       f:RegisterEvent("START_LOOT_ROLL")
       f:SetScript("OnEvent", function(_, _, id)
           if(id and select(4, GetLootRollItemInfo(id))==2) then
               RollOnLoot(id, 2)
           end
       end)
   end

   --[[ Accept invites ]]
   if(settings["Helpers"].AcceptInvites) then
       local IsFriend = function(name)
           for i=1, GetNumFriends() do if(GetFriendInfo(i)==name) then return true end end
           if(IsInGuild()) then for i=1, GetNumGuildMembers() do if(GetGuildRosterInfo(i)==name) then return true end end end
       end

       local ai = CreateFrame("Frame")
       ai:RegisterEvent("PARTY_INVITE_REQUEST")
       ai:SetScript("OnEvent", function(frame, event, name)
           if(IsFriend(name)) then
               AcceptGroup()
               for i = 1, 4 do
                   local frame = _G["StaticPopup"..i]
                   if(frame:IsVisible() and frame.which=="PARTY_INVITE") then
                       frame.inviteAccepted = 1
                       StaticPopup_Hide("PARTY_INVITE")
                       return
                   end
               end
           else
               SendWho(name)
           end
       end)
   end

   hooksecurefunc("WorldStateAlwaysUpFrame_Update", function()
       for i = 1, NUM_EXTENDED_UI_FRAMES do
           local cb = _G["WorldStateCaptureBar"..i]
               if cb and cb:IsShown() then
               cb:ClearAllPoints()
               cb:SetPoint("TOP", UIParent, "TOP", -100, -120)
           end
       end
   end)

   local module = CreateFrame("Frame",nil,UIParent)
    
   local sells,tmp_money = 0,0
    
   -- нормальный формат вывода денег
    
   local money_format = function(val)
      return format("|cffffd700%dg|r |cffc7c7cf%ds|r |cffeda55f%dc|r",mod(val/10000,10000),mod(val/100,100),mod(val,100))
   end
    
   module.MERCHANT_SHOW = function(self)
       if (settings["Helpers"].AutoRepair) then
       -- чинимся  
        
          if (CanMerchantRepair()) then
             local cost,money = GetRepairAllCost(),GetMoney()
             if cost > 0 then
               RepairAllItems(1)
               local _, rneed = GetRepairAllCost()
               if rneed then RepairAllItems() end
               print(string.format("repairing cost : %s",money_format(math.min(cost, money))))
             end
          end
       end

       if (settings["Helpers"].SellGreyCrap) then
       -- продаем мусор
        
          local bag,slot 
          tmp_money = GetMoney() 
          for bag = 0,4 do
             if GetContainerNumSlots(bag) > 0 then
                for slot = 0, GetContainerNumSlots(bag) do
                   local link = GetContainerItemLink(bag,slot)
                   if(link) then
                      local _,_,i_rar=GetItemInfo(link)
                      if i_rar == 0 then
                         UseContainerItem(bag,slot)
                         sells = sells+GetItemCount(link)
                      end
                   end
                end
             end
          end
       end
   end

   module.PLAYER_MONEY = function(self)
      if(sells>0) then
         print(string.format("sold %d items for %s",sells,money_format(GetMoney()-tmp_money)))   
         sells = 0
      end
   end
    
   -------------------------------------------------------------------------------------------------------------
    
   module:SetScript("OnEvent",function(self,event,...) self[event](self,event,...) end)
    
   module:RegisterEvent("MERCHANT_SHOW")
   module:RegisterEvent("PLAYER_MONEY")

end
tinsert(fui.modules, module) -- finish him!