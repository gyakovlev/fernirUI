local settings = fdb.settings

local NUM_WORLDMAP_POIS, DEFAULT_POI_ICON_SIZE, NUM_MAP_OVERLAYS = 0, 12, 0
local mapbg = CreateFrame("Button", nil, UIParent)
mapbg:SetPoint("CENTER")
mapbg:SetWidth(select(3,GetMapInfo())+256)
mapbg:SetHeight(select(2,GetMapInfo()))
SetTemplate(mapbg)
mapbg:Hide()

local tcount = 0
mapbg.texture = {}
for i = 1, 3 do
   for j = 1, 4 do
      tcount = tcount + 1
		mapbg.texture[tcount] = mapbg:CreateTexture("texture"..tcount, "ARTWORK")
		if i==1 and j==1 then
			mapbg.texture[tcount]:SetPoint("TOPLEFT")
		else
			if (j==1) then
				mapbg.texture[tcount]:SetPoint("TOPLEFT", mapbg.texture[tcount-4], "BOTTOMLEFT", 0, 0)
			else
				mapbg.texture[tcount]:SetPoint("TOPLEFT", mapbg.texture[tcount-1], "TOPRIGHT", 0, 0)
			end
		end
	end
end

mapbg:SetScale(.8)
local txt = mapbg:CreateFontString(nil, "ARTWORK")
txt:SetFont(settings.font, settings.fsize)
txt:SetPoint("TOPLEFT", 0, 0)
txt:SetPoint("BOTTOMRIGHT", mapbg, "TOPRIGHT", 0, -40)


mapbg:SetScript("OnShow", function(self)
	self:Update()
end)

-- Make it moveable 
mapbg:RegisterForDrag("LeftButton")
mapbg:SetClampedToScreen(true)
mapbg:SetMovable(true)
mapbg:SetScript("OnDragStart", function(self) self:StartMoving() end)
mapbg:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

mapbg:RegisterEvent("RAID_ROSTER_UPDATE")
mapbg:RegisterEvent("PARTY_MEMBERS_CHANGED")
mapbg:RegisterEvent("PLAYER_ENTERING_WORLD")
mapbg:RegisterEvent("WORLD_MAP_UPDATE")
mapbg:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" then
		if mapbg:IsShown() then
			SetMapToCurrentZone()
			self:Update()
		end
	elseif event == "WORLD_MAP_UPDATE" then
		if mapbg:IsShown() then
			self:Update()
		end
	elseif event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" then
		if self:IsShown() then
		end
	end
end)


function mapbg:Update()
	local mapFileName, textureHeight = GetMapInfo()
	if ( not mapFileName ) then
		return
	end
	local texName
	local dungeonLevel = GetCurrentMapDungeonLevel()
	local completeMapFileName
	if ( dungeonLevel > 0 ) then
		completeMapFileName = mapFileName..dungeonLevel.."_"
	else
		completeMapFileName = mapFileName
	end
	for i=1, NUM_WORLDMAP_DETAIL_TILES do
		texName = "Interface\\WorldMap\\"..mapFileName.."\\"..completeMapFileName..i
		mapbg.texture[i]:SetTexture(texName)
	end
	
	-- Setup the POI's
	local iconSize = DEFAULT_POI_ICON_SIZE-- * GetMapIconScale()
	local numPOIs = GetNumMapLandmarks()
	if ( NUM_WORLDMAP_POIS < numPOIs ) then
		for i=NUM_WORLDMAP_POIS+1, numPOIs do
			createPOI(i)
		end
		NUM_WORLDMAP_POIS = numPOIs
	end

	for i=1, NUM_WORLDMAP_POIS do
		local mPOIName = "mmPOI"..i
		local mPOI = _G[mPOIName]
		if ( i <= numPOIs ) then
			local name, description, textureIndex, x, y, maplinkID = GetMapLandmarkInfo(i)
			local x1, x2, y1, y2 = function(textureIndex)
				local worldMapPixelsPerIcon = DEFAULT_POI_ICON_SIZE
				local worldMapIconDimension = DEFAULT_POI_ICON_SIZE
				
				local offsetPixelsPerSide = (worldMapPixelsPerIcon - worldMapIconDimension)/2
				local normalizedOffsetPerSide = offsetPixelsPerSide * 1/256
				local xCoord1, xCoord2, yCoord1, yCoord2 
				local coordIncrement = worldMapPixelsPerIcon / 256
				local xOffset = mod(index, NUM_WORLDMAP_POI_COLUMNS)
				local yOffset = floor(index / 14)
				
				xCoord1 = xOffset * coordIncrement + normalizedOffsetPerSide
				xCoord2 = xCoord1 + coordIncrement - normalizedOffsetPerSide
				yCoord1 = yOffset * coordIncrement + normalizedOffsetPerSide
				yCoord2 = yCoord1 + coordIncrement - normalizedOffsetPerSide
				
				return xCoord1, xCoord2, yCoord1, yCoord2
			end
			
			_G[mPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2)
			_G[mPOIName.."Texture"]:SetTexture()
			x = x * mapbg:GetWidth()
			y = -y * mapbg:GetHeight()
			mPOI:SetPoint("CENTER", mapbg, "TOPLEFT", x, y )
			mPOI:SetWidth(iconSize)
			mPOI:SetHeight(iconSize)
			mPOI:EnableMouse(true)
			mPOI:SetScript("OnEnter", function(self)
				txt:SetText(name.."|r - "..description)
				GameTooltip:SetOwner(self, "ANCHOR_LEFT")
				GameTooltip:AddLine(name, 0, 0.75, 1)
				GameTooltip:AddLine(description, 0.75, 0.75, 0.75)
				GameTooltip:Show()
			end)
			mPOI:SetScript("OnLeave", function() GameTooltip:Hide() end)
			mPOI:Show()
		else
			mPOI:Hide()
		end
	end
	
	local numOverlays = GetNumMapOverlays()
	local textureCount = 0
	-- Use this value to scale the texture sizes and offsets
	local mapbgScale =  mapbg.texture[1]:GetWidth()/256
	for i=1, numOverlays do
		local textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY = GetMapOverlayInfo(i)
		if (textureName ~= "" or textureWidth == 0 or textureHeight == 0) then
			local numTexturesWide = ceil(textureWidth/256)
			local numTexturesTall = ceil(textureHeight/256)
			local neededTextures = textureCount + (numTexturesWide * numTexturesTall)
			if ( neededTextures > NUM_MAP_OVERLAYS ) then
				for j=NUM_MAP_OVERLAYS+1, neededTextures do
					mapbg:CreateTexture("mapbgOverlay"..j, "OVERLAY")
				end
				NUM_MAP_OVERLAYS = neededTextures
			end
			local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight
			for j=1, numTexturesTall do
				if ( j < numTexturesTall ) then
					texturePixelHeight = 256
					textureFileHeight = 256
				else
					texturePixelHeight = mod(textureHeight, 256)
					if ( texturePixelHeight == 0 ) then
						texturePixelHeight = 256
					end
					textureFileHeight = 16
					while(textureFileHeight < texturePixelHeight) do
						textureFileHeight = textureFileHeight * 2
					end
				end
				for k=1, numTexturesWide do
					textureCount = textureCount + 1
					local texture = _G["mapbgOverlay"..textureCount]
					if ( k < numTexturesWide ) then
						texturePixelWidth = 256
						textureFileWidth = 256
					else
						texturePixelWidth = mod(textureWidth, 256)
						if ( texturePixelWidth == 0 ) then
							texturePixelWidth = 256
						end
						textureFileWidth = 16
						while(textureFileWidth < texturePixelWidth) do
							textureFileWidth = textureFileWidth * 2
						end
					end
					texture:SetWidth(texturePixelWidth*mapbgScale)
					texture:SetHeight(texturePixelHeight*mapbgScale)
					texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight)
					texture:SetPoint("TOPLEFT", mapbg, "TOPLEFT", (offsetX + (256 * (k-1)))*mapbgScale, -((offsetY + (256 * (j - 1)))*mapbgScale))
					texture:SetTexture(textureName..(((j - 1) * numTexturesWide) + k))
					texture:SetAlpha(1)
					texture:Show()
				end
			end
		end
	end
	for i=textureCount+1, NUM_MAP_OVERLAYS do
		_G["mapbgOverlay"..i]:Hide()
	end
end

function createPOI(index)
	local frame = CreateFrame("Frame", "mmPOI"..index, mapbg)
	frame:SetWidth(DEFAULT_POI_ICON_SIZE)
	frame:SetHeight(DEFAULT_POI_ICON_SIZE)
	SetTemplate(frame)
	
	local texture = frame:CreateTexture(frame:GetName().."Texture", "OVERLAY")
	texture:SetAllPoints(frame)
	texture:SetTexture("Interface\\Minimap\\POIIcons"..index)
end

mapbg:SetScript("OnUpdate", function(self, elapsed, ...)
	if not self.updateTimer then self.updateTimer = 0.5 end
	if self.updateTimer < 0 then self.updateTimer = 0.5 end
	self.updateTimer = self.updateTimer - elapsed

	UpdateWorldMapArrowFrames()
	local playerX, playerY = GetPlayerMapPosition("player")
	if ( playerX == 0 and playerY == 0 ) then
		SetMapToCurrentZone()
		playerX, playerY = GetPlayerMapPosition("player")
	end
	if ( playerX == 0 and playerY == 0 ) then
		ShowMiniWorldMapArrowFrame(nil)
	else
		playerX = playerX * mapbg:GetWidth()
		playerY = -playerY * mapbg:GetHeight()
		PositionMiniWorldMapArrowFrame("CENTER", mapbg, "TOPLEFT", playerX, playerY)
		ShowMiniWorldMapArrowFrame(1)
	end
end)

SlashCmdList["mm"] = function(msg) if mapbg:IsShown() then mapbg:Hide() else mapbg:Show() end end
SLASH_mm1 = "/mm"