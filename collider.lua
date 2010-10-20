local module = {}
module.name = "Collider"
module.Init = function()
	if not fuiDB.modules[module.name] then return end
   
	settings = fuiDB
   
	local opts = settings[module.name] or {}
   
   if not opts["Direction"] then opts["Direction"] = "UP" end
   
   local direction = opts["Direction"] or "UP" -- UP, DOWN
   
   local mmButtons = {}
   local showhide = false

   local cc = _G["RAID_CLASS_COLORS"][select(2, UnitClass("player"))] or {1,1,1}

   local bIgnore = {"MiniMapTrackingFrame", "MiniMapMeetingStoneFrame", "MiniMapMailFrame", "MiniMapBattlefieldFrame", "MiniMapWorldMapButton", "MiniMapPing", "MinimapBackdrop", "MinimapZoomIn", "MinimapZoomOut", "BookOfTracksFrame", "GatherNote", "FishingExtravaganzaMini", "MiniNotePOI", "RecipeRadarMinimapIcon", "FWGMinimapPOI", "CartographerNotesPOI", "EnhancedFrameMinimapButton", "GFW_TrackMenuFrame", "GFW_TrackMenuButton", "TDial_TrackingIcon", "TDial_TrackButton", "MiniMapTracking", "GatherMatePin", "HandyNotesPin", "TimeManagerClockButton", "GameTimeFrame",
   }

   local bevents = { "OnChar", "OnClick", "OnDoubleClick", "OnDragStart", "OnDragStop", "OnEnter", "OnEvent", "OnHide", "OnKeyDown", "OnKeyUp", "OnLeave", "OnLoad", "OnMouseDown", "OnMouseUp", "OnMouseWheel", "OnReceiveDrag", "OnShow", "OnSizeChanged", "OnUpdate", "PostClick", "PreClick", }
   
   local eventf = CreateFrame("button", nil, UIParent)
   eventf:SetScript("OnUpdate", function(self, elapsed, ...)
      if not self.time then self.time = 0 end

      if self.time >= .5 then
         self.time = 0
         local children = {Minimap:GetChildren()}
         for _, child in ipairs(children) do
            if child:IsVisible() and (child:HasScript("OnClick") or child:HasScript("OnMouseDown") or child:HasScript("OnMouseUp")) and child:GetName()~= nil and not child.done then
               for i=1, #bIgnore do
                  if child:GetName() == bIgnore[i] then
                     child.done = true
                     return
                  end
               end
               child.done = true
               child.name = child:GetName()
               if not mmButtons[child.name] then
                  mmButtons[child.name] = {}
                  mmButtons[child.name].name = child.name
                  mmButtons[child.name].button = _G[child.name]
                  for ind, be in pairs(bevents) do
                     if _G[child.name]:HasScript(be) then
                        mmButtons[child.name][be] = _G[child.name]:GetScript(be)
                     end
                  end
               end
               
               child:Hide()
            end
         end
      else
         self.time = self.time + elapsed
      end
      
      local index = 0
      local parent = nil
      
      for i,v in pairs(mmButtons) do
         v.frame = _G[v.name.."mbf"] or CreateFrame("button", v.name.."mbf", eventf)
         if v.button.dataObject then v.frame.dataObject = v.button.dataObject end
         for n, m in pairs(v.button) do
            if n~=0 then
               v.frame[n] = m
            end
         end
         v.frame:SetWidth(eventf:GetWidth()*Minimap:GetScale())
         v.frame:SetHeight(24)
         if not parent then parent = eventf end
         
         if direction == "DOWN" then
            v.frame:SetPoint("TOP",parent, "BOTTOM", 0, 0)
         elseif direction == "UP" then
            v.frame:SetPoint("BOTTOM",parent, "TOP", 0, 0)
         end
         
         for ind, be in pairs(bevents) do
            if v[be] then
               v.frame:SetScript(be, v[be])
            end
         end
         
         SetTemplate(v.frame)
         
         v.frame.tex = _G[v.name.."mbftex"] or v.frame:CreateTexture(v.name.."mbftex", "ARTWORK")
         v.frame.tex:SetPoint("LEFT")
         v.frame.tex:SetHeight(v.frame:GetHeight())
         v.frame.tex:SetWidth(v.frame:GetHeight())
         
         
         local tex = nil
         
         if v.button:GetObjectType() == "Button" and v.button:GetNormalTexture() then
            tex = v.button:GetNormalTexture():GetTexture()
         else
            for _, r in pairs({v.button:GetRegions()}) do
               if r:GetObjectType() == "Texture" then
                  if not (string.find(r:GetTexture(), "TrackingBorder")) then
                     tex = r:GetTexture()
                  end
               end
            end
         end
         
         v.frame.tex:SetTexture(tex)
         
         v.frame.txt = _G[v.name.."mbftxt"] or v.frame:CreateFontString(v.name.."mbftxt", "OVERLAY", "GameFontNormal")
         v.frame.txt:SetPoint("LEFT", v.frame.tex, "RIGHT", 0, 0)
         v.frame.txt:SetWidth(v.frame:GetWidth() - v.frame:GetHeight()-4)
         v.frame.txt:SetHeight(v.frame:GetHeight())
         v.frame.txt:SetJustifyH("LEFT")
         
         local aname = ""
         for k=1, GetNumAddOns() do
            aname = GetAddOnInfo(k)
            if strfind(v.name, aname) then
               v.frame.txt:SetText(aname)
               break
            else
               v.frame.txt:SetText(v.name)
            end
         end
         
         index = index + 1
         
         if not showhide then
            v.frame:Hide()
         else
            v.frame:Show()
         end
         
         parent = v.frame
      end
   end)

   eventf:SetScript("OnClick", function(self, button, ...)
      if IsShiftKeyDown() then
         ReloadUI()
         return
      end
      
      showhide = not showhide
   end)

   SetTemplate(eventf)
   if direction == "DOWN" then
      eventf:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -2, 0)
      eventf:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 2, -12)
   elseif direction == "UP" then
      eventf:SetPoint("BOTTOMLEFT", Minimap, "TOPLEFT", -2, 0)
      eventf:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 2, 12)
   end
end
tinsert(fui.modules, module) -- finish him!