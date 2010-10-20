local eventframe = CreateFrame("frame")
eventframe:RegisterEvent("ADDON_LOADED")
eventframe:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_AuctionUI" then
		AuctionFrame:SetMovable(true)
		AuctionFrame:SetClampedToScreen(true)
		AuctionFrame:SetScript("OnMouseDown", function(self) self:StartMoving() end)
		AuctionFrame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

		local handleAuctionFrame = function(self)
			if AuctionFrame:GetAttribute("UIPanelLayout-enabled") then
				if AuctionFrame:IsVisible() then
					AuctionFrame.Hide = function() end
					HideUIPanel(AuctionFrame)
					AuctionFrame.Hide = nil
				end
				AuctionFrame:SetAttribute("UIPanelLayout-enabled", nil)
			else
				if AuctionFrame:IsVisible() then
					AuctionFrame.IsShown = function() end
					ShowUIPanel(AuctionFrame)
					AuctionFrame.IsShown = nil
				end
			end
		end
		hooksecurefunc("AuctionFrame_Show", handleAuctionFrame)
		hooksecurefunc("AuctionFrame_Hide", handleAuctionFrame)
      
      self:UnregisterEvent"ADDON_LOADED"
      self:SetScript("OnEvent", nil)
	end
end)