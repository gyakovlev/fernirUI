local settings = nil
local GS_Settings = {
   ["Player"] = 1,
   ["Item"] = 1,
   ["Show"] = 1,
   ["Compare"] = -1,
   ["Level"] = -1,
   ["Average"] = 1,
}

GS_DefaultSettings = {
   ["Player"] = 1,
   ["Item"] = 1,
   ["Show"] = 1,
   ["Compare"] = -1,
   ["Level"] = -1,
   ["Average"] = 1,
}

local module = {}
module.name = "GearScore"
module.Init = function()
 if not fuiDB.modules[module.name] then return end
   
 settings = fuiDB.settings
 --GS_Settings = settings.GS_Settings
 if not ( GS_Data ) then GS_Data = {}; end; if not ( GS_Data[GetRealmName()] ) then GS_Data[GetRealmName()] = { ["Players"] = {} }; end
 for i, v in pairs(GS_DefaultSettings) do if not ( GS_Settings[i] ) then GS_Settings[i] = GS_DefaultSettings[i]; end; end
 ------------------------ GUI PROGRAMS -------------------------------------------------------

 local f = CreateFrame("Frame", "GearScore", UIParent);
 f:SetScript("OnEvent", GearScore_OnEvent);
 f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED");
 f:RegisterEvent("PLAYER_REGEN_ENABLED")
 f:RegisterEvent("PLAYER_REGEN_DISABLED")
 GameTooltip:HookScript("OnTooltipSetUnit", GearScore_HookSetUnit)
 GameTooltip:HookScript("OnTooltipSetItem", GearScore_HookSetItem)
 ShoppingTooltip1:HookScript("OnTooltipSetItem", GearScore_HookCompareItem)
 ShoppingTooltip2:HookScript("OnTooltipSetItem", GearScore_HookCompareItem2)
 ItemRefTooltip:HookScript("OnTooltipSetItem", GearScore_HookRefItem)
 PaperDollFrame:HookScript("OnShow", MyPaperDoll)
 PaperDollFrame:CreateFontString("PersonalGearScore")
 PersonalGearScore:SetFontObject(GameTooltipTextSmall)

 PersonalGearScore:SetText("GS: 0")
 PersonalGearScore:SetPoint("BOTTOMLEFT",PaperDollFrame,"TOPLEFT",72,-253)
 PersonalGearScore:Show()
 PaperDollFrame:CreateFontString("GearScore2")
 GearScore2:SetFontObject(GameTooltipTextSmall)

 GearScore2:SetText("GearScore")
 GearScore2:SetPoint("BOTTOMLEFT",PaperDollFrame,"TOPLEFT",72,-265)
 GearScore2:Show()
 GearScore_Original_SetInventoryItem = GameTooltip.SetInventoryItem
 GameTooltip.SetInventoryItem = GearScore_OnEnter

 SlashCmdList["MY2SCRIPT"] = GS_MANSET
 SLASH_MY2SCRIPT1 = "/gset"
 SLASH_MY2SCRIPT2 = "/gs"
 SLASH_MY2SCRIPT3 = "/gearscore"

end
tinsert(fui.modules, module) -- finish him!

GS_ItemTypes = {
 ["INVTYPE_RELIC"] = { ["SlotMOD"] = 0.3164, ["ItemSlot"] = 18 },
 ["INVTYPE_TRINKET"] = { ["SlotMOD"] = 0.5625, ["ItemSlot"] = 33 },
 ["INVTYPE_2HWEAPON"] = { ["SlotMOD"] = 2.000, ["ItemSlot"] = 16 },
 ["INVTYPE_WEAPONMAINHAND"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 16 },
 ["INVTYPE_WEAPONOFFHAND"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 17 },
 ["INVTYPE_RANGED"] = { ["SlotMOD"] = 0.3164, ["ItemSlot"] = 18 },
 ["INVTYPE_THROWN"] = { ["SlotMOD"] = 0.3164, ["ItemSlot"] = 18 },
 ["INVTYPE_RANGEDRIGHT"] = { ["SlotMOD"] = 0.3164, ["ItemSlot"] = 18 },
 ["INVTYPE_SHIELD"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 17 },
 ["INVTYPE_WEAPON"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 36 },
 ["INVTYPE_HOLDABLE"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 17 },
 ["INVTYPE_HEAD"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 1 },
 ["INVTYPE_NECK"] = { ["SlotMOD"] = 0.5625, ["ItemSlot"] = 2 },
 ["INVTYPE_SHOULDER"] = { ["SlotMOD"] = 0.7500, ["ItemSlot"] = 3 },
 ["INVTYPE_CHEST"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 5 },
 ["INVTYPE_ROBE"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 5 },
 ["INVTYPE_WAIST"] = { ["SlotMOD"] = 0.7500, ["ItemSlot"] = 6 },
 ["INVTYPE_LEGS"] = { ["SlotMOD"] = 1.0000, ["ItemSlot"] = 7 },
 ["INVTYPE_FEET"] = { ["SlotMOD"] = 0.75, ["ItemSlot"] = 8 },
 ["INVTYPE_WRIST"] = { ["SlotMOD"] = 0.5625, ["ItemSlot"] = 9 },
 ["INVTYPE_HAND"] = { ["SlotMOD"] = 0.7500, ["ItemSlot"] = 10 },
 ["INVTYPE_FINGER"] = { ["SlotMOD"] = 0.5625, ["ItemSlot"] = 31 },
 ["INVTYPE_CLOAK"] = { ["SlotMOD"] = 0.5625, ["ItemSlot"] = 15 },
}

GS_Rarity = {
 [0] = { Red = 0.55, Green = 0.55, Blue = 0.55 },
 [1] = { Red = 1.00, Green = 1.00, Blue = 1.00 },
 [2] = { Red = 0.12, Green = 1.00, Blue = 0.00 },
 [3] = { Red = 0.00, Green = 0.50, Blue = 1.00 },
 [4] = { Red = 0.69, Green = 0.28, Blue = 0.97 },
 [5] = { Red = 0.94, Green = 0.09, Blue = 0.00 },
 [6] = { Red = 1.00, Green = 0.00, Blue = 0.00 },
 [7] = { Red = 0.90, Green = 0.80, Blue = 0.50 },
}

GS_Formula = {
 ["A"] = {
  [4] = { ["A"] = 91.4500, ["B"] = 0.6500 },
  [3] = { ["A"] = 81.3750, ["B"] = 0.8125 },
  [2] = { ["A"] = 73.0000, ["B"] = 1.0000 }
 },
 ["B"] = {
  [4] = { ["A"] = 26.0000, ["B"] = 1.2000 },
  [3] = { ["A"] = 0.7500, ["B"] = 1.8000 },
  [2] = { ["A"] = 8.0000, ["B"] = 2.0000 },
  [1] = { ["A"] = 0.0000, ["B"] = 2.2500 }
 }
}

GS_Quality = {
 [7000] = {
  ["Red"] = { ["A"] = 1, ["B"] = 6000, ["C"] = 0.00006, ["D"] = 1 },
  ["Green"] = { ["A"] = 0.3, ["B"] = 6000, ["C"] = 0.00047, ["D"] = -1 },
  ["Blue"] = { ["A"] = 0, ["B"] = 0, ["C"] = 0, ["D"] = 0 },
  ["Description"] = "ICC"
 },
 [6000] = {
  ["Red"] = { ["A"] = 0.94, ["B"] = 5000, ["C"] = 0.00006, ["D"] = 1 },
  ["Green"] = { ["A"] = 0.47, ["B"] = 5000, ["C"] = 0.00047, ["D"] = -1 },
  ["Blue"] = { ["A"] = 0, ["B"] = 0, ["C"] = 0, ["D"] = 0 },
  ["Description"] = "Legendary"
 },
 [5000] = {
  ["Red"] = { ["A"] = 0.69, ["B"] = 4000, ["C"] = 0.00025, ["D"] = 1 },
  ["Green"] = { ["A"] = 0.28, ["B"] = 4000, ["C"] = 0.00019, ["D"] = 1 },
  ["Blue"] = { ["A"] = 0.97, ["B"] = 4000, ["C"] = 0.00096, ["D"] = -1 },
  ["Description"] = "Epic"
 },
 [4000] = {
  ["Red"] = { ["A"] = 0.0, ["B"] = 3000, ["C"] = 0.00069, ["D"] = 1 },
  ["Green"] = { ["A"] = 0.5, ["B"] = 3000, ["C"] = 0.00022, ["D"] = -1 },
  ["Blue"] = { ["A"] = 1, ["B"] = 3000, ["C"] = 0.00003, ["D"] = -1 },
  ["Description"] = "Superior"
 },
 [3000] = {
  ["Red"] = { ["A"] = 0.12, ["B"] = 2000, ["C"] = 0.00012, ["D"] = -1 },
  ["Green"] = { ["A"] = 1, ["B"] = 2000, ["C"] = 0.00050, ["D"] = -1 },
  ["Blue"] = { ["A"] = 0, ["B"] = 2000, ["C"] = 0.001, ["D"] = 1 },
  ["Description"] = "Uncommon"
 },
 [2000] = {
  ["Red"] = { ["A"] = 1, ["B"] = 1000, ["C"] = 0.00088, ["D"] = -1 },
  ["Green"] = { ["A"] = 1, ["B"] = 000, ["C"] = 0.00000, ["D"] = 0 },
  ["Blue"] = { ["A"] = 1, ["B"] = 1000, ["C"] = 0.001, ["D"] = -1 },
  ["Description"] = "Common"
 },
 [1000] = {
  ["Red"] = { ["A"] = 0.55, ["B"] = 0, ["C"] = 0.00045, ["D"] = 1 },
  ["Green"] = { ["A"] = 0.55, ["B"] = 0, ["C"] = 0.00045, ["D"] = 1 },
  ["Blue"] = { ["A"] = 0.55, ["B"] = 0, ["C"] = 0.00045, ["D"] = 1 },
  ["Description"] = "Trash"
 },
}



GS_CommandList = {
 [1] = "---GearScore Options List---",
 [2] = "/gs player -> Toggles display of scores on players.",
 [3] = "/gs item -> Toggles display of scores for items.",
 [4] = "/gs level -> Toggles iLevel information.",
 [5] = "/gs reset --> Resets GearScore's Options back to Default.",
 [6] = "/gs compare --> Toggles display of comparative info between you and your target's GearScore.",
}

GS_ShowSwitch = {[0] = 2,[1] = 3,[2] = 0,[3] = 1}
GS_ItemSwitch = {[0] = 3,[1] = 2,[2] = 1,[3] = 0}



-------------------------------------------------------------------------------
--                            GearScoreLite                                  --
--                             Version 3x03                                   --
--        Mirrikat45                                   --
-------------------------------------------------------------------------------

------------------------------------------------------------------------------

function GearScore_OnEvent(GS_Nil, GS_EventName, GS_Prefix, GS_AddonMessage, GS_Whisper, GS_Sender)
 if ( GS_EventName == "PLAYER_REGEN_ENABLED" ) then GS_PlayerIsInCombat = false; return; end
 if ( GS_EventName == "PLAYER_REGEN_DISABLED" ) then GS_PlayerIsInCombat = true; return; end
 if ( GS_EventName == "PLAYER_EQUIPMENT_CHANGED" ) then
     local MyGearScore = GearScore_GetScore(UnitName("player"), "player");
     local Red, Blue, Green = GearScore_GetQuality(MyGearScore)
     PersonalGearScore:SetText(MyGearScore); PersonalGearScore:SetTextColor(Red, Green, Blue, 1)
 end
end
-------------------------- Get Mouseover Score -----------------------------------
function GearScore_GetScore(Name, Target)
 if ( UnitIsPlayer(Target) ) then
     local PlayerClass, PlayerEnglishClass = UnitClass(Target);
  local GearScore = 0; local PVPScore = 0; local ItemCount = 0; local LevelTotal = 0; local TitanGrip = 1; local TempEquip = {}; local TempPVPScore = 0

  if ( GetInventoryItemLink(Target, 16) ) and ( GetInventoryItemLink(Target, 17) ) then
        local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(GetInventoryItemLink(Target, 16))
            if ( ItemEquipLoc == "INVTYPE_2HWEAPON" ) then TitanGrip = 0.5; end
  end

  if ( GetInventoryItemLink(Target, 17) ) then
   local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(GetInventoryItemLink(Target, 17))
   if ( ItemEquipLoc == "INVTYPE_2HWEAPON" ) then TitanGrip = 0.5; end
   TempScore, ItemLevel = GearScore_GetItemScore(GetInventoryItemLink(Target, 17));
   if ( PlayerEnglishClass == "HUNTER" ) then TempScore = TempScore * 0.3164; end
   GearScore = GearScore + TempScore * TitanGrip; ItemCount = ItemCount + 1; LevelTotal = LevelTotal + ItemLevel
  end
  
  for i = 1, 18 do
   if ( i ~= 4 ) and ( i ~= 17 ) then
          ItemLink = GetInventoryItemLink(Target, i)
          GS_ItemLinkTable = {}
    if ( ItemLink ) then
           local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(ItemLink)
           if ( GS_Settings["Detail"] == 1 ) then GS_ItemLinkTable[i] = ItemLink; end
         TempScore = GearScore_GetItemScore(ItemLink);
     if ( i == 16 ) and ( PlayerEnglishClass == "HUNTER" ) then TempScore = TempScore * 0.3164; end
     if ( i == 18 ) and ( PlayerEnglishClass == "HUNTER" ) then TempScore = TempScore * 5.3224; end
     if ( i == 16 ) then TempScore = TempScore * TitanGrip; end
     GearScore = GearScore + TempScore; ItemCount = ItemCount + 1; LevelTotal = LevelTotal + ItemLevel
    end
   end;
  end
  if ( GearScore <= 0 ) and ( Name ~= UnitName("player") ) then
   GearScore = 0; return 0,0;
  elseif ( Name == UnitName("player") ) and ( GearScore <= 0 ) then
      GearScore = 0; end
 if ( ItemCount == 0 ) then LevelTotal = 0; end      
 return floor(GearScore), floor(LevelTotal/ItemCount)
 end
end

-------------------------------------------------------------------------------

------------------------------ Get Item Score ---------------------------------
function GearScore_GetItemScore(ItemLink)
 local QualityScale = 1; local PVPScale = 1; local PVPScore = 0; local GearScore = 0
 if not ( ItemLink ) then return 0, 0; end
 local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(ItemLink); local Table = {}; local Scale = 1.8618
  if ( ItemRarity == 5 ) then QualityScale = 1.3; ItemRarity = 4;
 elseif ( ItemRarity == 1 ) then QualityScale = 0.005;  ItemRarity = 2
 elseif ( ItemRarity == 0 ) then QualityScale = 0.005;  ItemRarity = 2 end
    if ( ItemRarity == 7 ) then ItemRarity = 3; ItemLevel = 187.05; end
    if ( GS_ItemTypes[ItemEquipLoc] ) then
        if ( ItemLevel > 120 ) then Table = GS_Formula["A"]; else Table = GS_Formula["B"]; end
  if ( ItemRarity >= 2 ) and ( ItemRarity <= 4 )then
            local Red, Green, Blue = GearScore_GetQuality((floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * 1 * Scale)) * 11.25 )
            GearScore = floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * GS_ItemTypes[ItemEquipLoc].SlotMOD * Scale * QualityScale)
   if ( ItemLevel == 187.05 ) then ItemLevel = 0; end
   if ( GearScore < 0 ) then GearScore = 0;   Red, Green, Blue = GearScore_GetQuality(1); end
   if ( PVPScale == 0.75 ) then PVPScore = 1; GearScore = GearScore * 1; 
   else PVPScore = GearScore * 0; end
   GearScore = floor(GearScore)
   PVPScore = floor(PVPScore)
   return GearScore, ItemLevel, GS_ItemTypes[ItemEquipLoc].ItemSlot, Red, Green, Blue, PVPScore, ItemEquipLoc;
  end
   end
 return -1, ItemLevel, 50, 1, 1, 1, PVPScore, ItemEquipLoc
end
-------------------------------------------------------------------------------

-------------------------------- Get Quality ----------------------------------

function GearScore_GetQuality(ItemScore)
 local Red = 0.1; local Blue = 0.1; local Green = 0.1; local GS_QualityDescription = "Legendary"
    if not ( ItemScore ) then return 0, 0, 0, "Trash"; end
 for i = 0,6 do
  if ( ItemScore > i * 1000 ) and ( ItemScore <= ( ( i + 1 ) * 1000 ) ) then
      local Red = GS_Quality[( i + 1 ) * 1000].Red["A"] + (((ItemScore - GS_Quality[( i + 1 ) * 1000].Red["B"])*GS_Quality[( i + 1 ) * 1000].Red["C"])*GS_Quality[( i + 1 ) * 1000].Red["D"])
            local Blue = GS_Quality[( i + 1 ) * 1000].Green["A"] + (((ItemScore - GS_Quality[( i + 1 ) * 1000].Green["B"])*GS_Quality[( i + 1 ) * 1000].Green["C"])*GS_Quality[( i + 1 ) * 1000].Green["D"])
            local Green = GS_Quality[( i + 1 ) * 1000].Blue["A"] + (((ItemScore - GS_Quality[( i + 1 ) * 1000].Blue["B"])*GS_Quality[( i + 1 ) * 1000].Blue["C"])*GS_Quality[( i + 1 ) * 1000].Blue["D"])
   --if not ( Red ) or not ( Blue ) or not ( Green ) then return 0.1, 0.1, 0.1, nil; end
   return Red, Green, Blue, GS_Quality[( i + 1 ) * 1000].Description
  end
 end
return 0.1, 0.1, 0.1
end
-------------------------------------------------------------------------------

----------------------------- Hook Set Unit -----------------------------------
function GearScore_HookSetUnit(arg1, arg2)
 if ( GS_PlayerIsInCombat ) then return; end
 local Name = GameTooltip:GetUnit();local MouseOverGearScore, MouseOverAverage = 0,0
 if ( CanInspect("mouseover") ) and ( UnitName("mouseover") == Name ) and not ( GS_PlayerIsInCombat ) then 
  NotifyInspect("mouseover"); MouseOverGearScore, MouseOverAverage = GearScore_GetScore(Name, "mouseover"); 
 end
  if ( MouseOverGearScore ) and ( MouseOverGearScore > 0 ) and ( GS_Settings["Player"] == 1 ) then 
  local Red, Blue, Green = GearScore_GetQuality(MouseOverGearScore)
  if ( GS_Settings["Level"] == 1 ) then 
   GameTooltip:AddDoubleLine("GearScore: "..MouseOverGearScore, "(iLevel: "..MouseOverAverage..")", Red, Green, Blue, Red, Green, Blue)
  else
   GameTooltip:AddLine("GearScore: "..MouseOverGearScore, Red, Green, Blue)
  end
  if ( GS_Settings["Compare"] == 1 ) then
   local MyGearScore = GearScore_GetScore(UnitName("player"), "player");
   local TheirGearScore = MouseOverGearScore
   if ( MyGearScore  > TheirGearScore  ) then GameTooltip:AddDoubleLine("YourScore: "..MyGearScore  , "(+"..(MyGearScore - TheirGearScore  )..")", 0,1,0, 0,1,0); end
   if ( MyGearScore   < TheirGearScore   ) then GameTooltip:AddDoubleLine("YourScore: "..MyGearScore, "(-"..(TheirGearScore - MyGearScore  )..")", 1,0,0, 1,0,0); end 
   if ( MyGearScore   == TheirGearScore   ) then GameTooltip:AddDoubleLine("YourScore: "..MyGearScore  , "(+0)", 0,1,1,0,1,1); end 
  end
 end
end

function GearScore_SetDetails(tooltip, Name)
    if not ( UnitName("mouseover") ) or ( UnitName("mouseover") ~= Name )then return; end
   for i = 1,18 do
       if not ( i == 4 ) then
      local ItemName, ItemLink, ItemRarity, ItemLevel, ItemMinLevel, ItemType, ItemSubType, ItemStackCount, ItemEquipLoc, ItemTexture = GetItemInfo(GS_ItemLinkTable[i])
   if ( ItemLink ) then
    local GearScore, ItemLevel, ItemType, Red, Green, Blue = GearScore_GetItemScore(ItemLink)
    --local Red, Green, Blue = GearScore_GetQuality((floor(((ItemLevel - Table[ItemRarity].A) / Table[ItemRarity].B) * 1 * 1.8618)) * 11.25 )
    if ( GearScore ) and ( i ~= 4 ) then
           local Add = ""
           if ( GS_Settings["Level"] == 1 ) then Add = " (iLevel "..tostring(ItemLevel)..")"; end
               tooltip:AddDoubleLine("["..ItemName.."]", tostring(GearScore)..Add, GS_Rarity[ItemRarity].Red, GS_Rarity[ItemRarity].Green, GS_Rarity[ItemRarity].Blue, Red, Blue, Green)
          end
   end
  end
 end
end
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
function GearScore_HookSetItem() ItemName, ItemLink = GameTooltip:GetItem(); GearScore_HookItem(ItemName, ItemLink, GameTooltip); end
function GearScore_HookRefItem() ItemName, ItemLink = ItemRefTooltip:GetItem(); GearScore_HookItem(ItemName, ItemLink, ItemRefTooltip); end
function GearScore_HookCompareItem() ItemName, ItemLink = ShoppingTooltip1:GetItem(); GearScore_HookItem(ItemName, ItemLink, ShoppingTooltip1); end
function GearScore_HookCompareItem2() ItemName, ItemLink = ShoppingTooltip2:GetItem(); GearScore_HookItem(ItemName, ItemLink, ShoppingTooltip2); end
function GearScore_HookItem(ItemName, ItemLink, Tooltip)
 if ( GS_PlayerIsInCombat ) then return; end
 local PlayerClass, PlayerEnglishClass = UnitClass("player");
 if not ( IsEquippableItem(ItemLink) ) then return; end
 local ItemScore, ItemLevel, EquipLoc, Red, Green, Blue, PVPScore, ItemEquipLoc = GearScore_GetItemScore(ItemLink);
  if ( ItemScore >= 0 ) then
  if ( GS_Settings["Item"] == 1 ) then
     if ( ItemLevel ) and ( GS_Settings["Level"] == 1 ) then Tooltip:AddDoubleLine("GearScore: "..ItemScore, "(iLevel "..ItemLevel..")", Red, Blue, Green, Red, Blue, Green);
    if ( PlayerEnglishClass == "HUNTER" ) then
     if ( ItemEquipLoc == "INVTYPE_RANGEDRIGHT" ) or ( ItemEquipLoc == "INVTYPE_RANGED" ) then
      Tooltip:AddLine("HunterScore: "..floor(ItemScore * 5.3224), Red, Blue, Green)
     end
     if ( ItemEquipLoc == "INVTYPE_2HWEAPON" ) or ( ItemEquipLoc == "INVTYPE_WEAPONMAINHAND" ) or ( ItemEquipLoc == "INVTYPE_WEAPONOFFHAND" ) or ( ItemEquipLoc == "INVTYPE_WEAPON" ) or ( ItemEquipLoc == "INVTYPE_HOLDABLE" )  then
      Tooltip:AddLine("HunterScore: "..floor(ItemScore * 0.3164), Red, Blue, Green)
     end
    end
   else
    Tooltip:AddLine("GearScore: "..ItemScore, Red, Blue, Green)
    if ( PlayerEnglishClass == "HUNTER" ) then
     if ( ItemEquipLoc == "INVTYPE_RANGEDRIGHT" ) or ( ItemEquipLoc == "INVTYPE_RANGED" ) then
      Tooltip:AddLine("HunterScore: "..floor(ItemScore * 5.3224), Red, Blue, Green)
     end
     if ( ItemEquipLoc == "INVTYPE_2HWEAPON" ) or ( ItemEquipLoc == "INVTYPE_WEAPONMAINHAND" ) or ( ItemEquipLoc == "INVTYPE_WEAPONOFFHAND" ) or ( ItemEquipLoc == "INVTYPE_WEAPON" ) or ( ItemEquipLoc == "INVTYPE_HOLDABLE" )  then
      Tooltip:AddLine("HunterScore: "..floor(ItemScore * 0.3164), Red, Blue, Green)
     end
    end
      end
--RebuildThis            if ( GS_Settings["ML"] == 1 ) then GearScore_EquipCompare(Tooltip, ItemScore, EquipLoc, ItemLink); end
    end
 else
     if ( GS_Settings["Level"] == 1 ) and ( ItemLevel ) then
         Tooltip:AddLine("iLevel "..ItemLevel)
  end
    end
end
function GearScore_OnEnter(Name, ItemSlot, Argument)
 if ( UnitName("target") ) then NotifyInspect("target"); GS_LastNotified = UnitName("target"); end
 local OriginalOnEnter = GearScore_Original_SetInventoryItem(Name, ItemSlot, Argument); return OriginalOnEnter
end
function MyPaperDoll()
 if ( GS_PlayerIsInCombat ) then return; end
 local MyGearScore = GearScore_GetScore(UnitName("player"), "player");
 local Red, Blue, Green = GearScore_GetQuality(MyGearScore)
    PersonalGearScore:SetText(MyGearScore); PersonalGearScore:SetTextColor(Red, Green, Blue, 1)
end
-------------------------------------------------------------------------------

----------------------------- Reports -----------------------------------------

---------------GS-SPAM Slasch Command--------------------------------------
function GS_MANSET(Command)
 if ( strlower(Command) == "" ) or ( strlower(Command) == "options" ) or ( strlower(Command) == "option" ) or ( strlower(Command) == "help" ) then for i,v in ipairs(GS_CommandList) do print(v); end; return end
 if ( strlower(Command) == "show" ) then GS_Settings["Player"] = GS_ShowSwitch[GS_Settings["Player"]]; if ( GS_Settings["Player"] == 1 ) or ( GS_Settings["Player"] == 2 ) then print("Player Scores: On"); else print("Player Scores: Off"); end; return; end
 if ( strlower(Command) == "player" ) then GS_Settings["Player"] = GS_ShowSwitch[GS_Settings["Player"]]; if ( GS_Settings["Player"] == 1 ) or ( GS_Settings["Player"] == 2 ) then print("Player Scores: On"); else print("Player Scores: Off"); end; return; end
    if ( strlower(Command) == "item" ) then GS_Settings["Item"] = GS_ItemSwitch[GS_Settings["Item"]]; if ( GS_Settings["Item"] == 1 ) or ( GS_Settings["Item"] == 3 ) then print("Item Scores: On"); else print("Item Scores: Off"); end; return; end
 if ( strlower(Command) == "level" ) then GS_Settings["Level"] = GS_Settings["Level"] * -1; if ( GS_Settings["Level"] == 1 ) then print ("Item Levels: On"); else print ("Item Levels: Off"); end; return; end
 if ( strlower(Command) == "compare" ) then GS_Settings["Compare"] = GS_Settings["Compare"] * -1; if ( GS_Settings["Compare"] == 1 ) then print ("Comparisons: On"); else print ("Comparisons: Off"); end; return; end
 print("GearScore: Unknown Command. Type '/gs' for a list of options")
end