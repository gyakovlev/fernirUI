--Addon author: ALZA
local module = {}
module.name = "Aero frames"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
	
	
	for i, v in pairs({ "PlayerTalentFrame","MailFrame", "LootFrame", "ArenaFrame", "TradeFrame", "QuestFrame", "GossipFrame", "TabardFrame", "FriendsFrame", "StaticPopup1", "OptionsFrame", "OpacityFrame", "ItemRefTooltip", "OpenMailFrame", "MerchantFrame", "QuestLogFrame", "SpellBookFrame", "PetStableFrame", "PVPTeamDetails", "CharacterFrame", "BattlefieldFrame", "StackSplitFrame", "LFGParentFrame", "PVPParentFrame", "GameMenuFrame", "ColorPickerFrame", "GearManagerDialog", "AudioOptionsFrame", "VideoOptionsFrame", "GuildRegistrarFrame", "ArenaRegistrarFrame", "ReputationDetailFrame", "InterfaceOptionsFrame", }) do
		if(_G[v]) then 
			if(_G[v]:GetScript("OnShow")) then
				_G[v]:HookScript("OnShow", function(self) 
					UIFrameFadeIn(self, .2, 0, 1)
				end)
			end
		end
	end

end
tinsert(fui.modules, module) -- finish him!