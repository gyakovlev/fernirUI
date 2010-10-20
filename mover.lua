local errorsQueued = {}

local FramesDB = {
   PlayerFrame, SpellBookFrame, PlayerTalentFrame,
	QuestLogFrame, CharacterFrame, MerchantFrame, 
	AuctionFrame, CalendarFrame, AchievementFrame
}

local frameMoverFrame = CreateFrame("frame")

local function makeMovable(self)
		self:EnableMouse(true)
		self:SetMovable(true)
		self:SetUserPlaced(true)
		self:SetClampedToScreen(true)
		self:SetScript("OnMouseDown", function(self) self:StartMoving() end)
		self:SetScript("OnMouseUp", function(self)
			self:StopMovingOrSizing()
			self.x1, self.y1 = self:GetLeft(), self:GetBottom()
			self.x2 = self.x1 + self:GetWidth()
			self.y2 = self.y1 + self:GetHeight()
			self:ClearAllPoints()
			self:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", self.x1, self.y1)
			self:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", self.x2, self.y2)
		end)
end

frameMoverFrame.ADDON_LOADED = function(self)
	for ndx, frame in pairs(FramesDB) do
		makeMovable(frame)
	end
end

frameMoverFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)
frameMoverFrame:RegisterEvent("ADDON_LOADED")