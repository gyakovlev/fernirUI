local addonName, ns = ...
local inspectQueque = {}
local iunit = nil
local ourUnit = true
local inspectingUnit = nil

local EventFrame = CreateFrame("frame")
EventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
EventFrame:RegisterEvent("ADDON_LOADED")
EventFrame:RegisterEvent("INSPECT_TALENT_READY")

local classColStr = function(class)
    if RAID_CLASS_COLORS[class] then
        return string.format("%02x%02x%02x", RAID_CLASS_COLORS[class].r*255, RAID_CLASS_COLORS[class].g*255, RAID_CLASS_COLORS[class].b*255)
    else
        return "ffffff"
    end
end

local classColList = function(class)
    if RAID_CLASS_COLORS[class] then
        return {RAID_CLASS_COLORS[class].r, RAID_CLASS_COLORS[class].g, RAID_CLASS_COLORS[class].b}
    else
        return {1,1,1}
    end
end


local createFs = function(parent, justify, fsize)
    local f = _G[parent:GetName().."_fs_"..parent.name] or parent:CreateFontString(parent:GetName().."_fs_"..parent.name, "OVERLAY")
    f:SetFont("Fonts\\skurri.ttf", fsize)
    if justify then
        f:SetJustifyH(justify)
    else
        f:SetJustifyH("LEFT")
    end
    return f
end

local stylefunc = function(f)
    f:SetBackdrop{ bgFile = "Interface\\Buttons\\WHITE8x8",}
    f:SetBackdropColor(.1, .1, .1, .3)
end

local main = CreateFrame("frame", "rcomp_main", UIParent)
main.name = main:GetName()
local buffs = CreateFrame("frame", "rcomp_buffs", main)
local debuffs = CreateFrame("frame", "rcomp_debuffs", main)
local classes = CreateFrame("frame", "rcomp_classes", main)
local raid = CreateFrame("ScrollFrame", "rcomp_raid", main)

local info = CreateFrame("ScrollFrame", "rcomp_info", main)
local scrollchildinfo = CreateFrame("frame", nil, info)
local infotext = CreateFrame("SimpleHTML", nil, scrollchildinfo)
info:SetScrollChild(scrollchildinfo)
infotext:SetFontObject("ChatFontNormal")

local resize = CreateFrame("button", nil, main, "UIPanelButtonTemplate")

local scrollchild = CreateFrame("frame", nil, raid)
local raidtext = CreateFrame("SimpleHTML", nil, scrollchild)
raid:SetScrollChild(scrollchild)
raidtext:SetFontObject("ChatFontNormal")

local status = createFs(main, "LEFT", 11)
status:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 0, 0)

local title = CreateFrame("frame", "rcomp_title", main)
title.name = title:GetName()
local titleText = createFs(title, "LEFT", 16)
titleText:SetPoint("TOPLEFT", title, "TOPLEFT", 4, -2)
titleText:SetText("|cffaaaa00Raid Planner|r")

main:Hide()

local classtokens = {
	["DEATHKNIGHT"] = {["Кровь"] = "1", ["Лед"] = "2", ["Нечестивость"] = "3"},
	["DRUID"] = {["Баланс"] = "4", ["Сила зверя"] = "5", ["Исцеление"] = "6"},
	["HUNTER"] = {["Повелитель зверей"] = "7", ["Стрельба"] = "8", ["Выживание"] = "9"},
	["MAGE"] = {["Тайная магия"] = "a", ["Огонь"] = "b", ["Лед"] = "c"},
	["PALADIN"] = {["Свет"] = "d", ["Защита"] = "e", ["Воздаяние"] = "f"},
	["PRIEST"] = {["Послушание"] = "g", ["Свет"] = "h", ["Темная магия"] = "i"},
	["ROGUE"] = {["Ликвидация"] = "j", ["Бой"] = "k", ["Скрытность"] = "l"},
	["SHAMAN"] = {["Стихии"] = "m", ["Совершенствование"] = "n", ["Исцеление"] = "o"},
	["WARLOCK"] = {["Колдовство"] = "p", ["Демонология"] = "q", ["Разрушение"] = "r"},
	["WARRIOR"] = {["Оружие"] = "s", ["Неистовство"] = "t", ["Защита"] = "u"},
}

local talenticons = {
	["DEATHKNIGHT"] = {["Кровь"] = "Spell_Shadow_BloodBoil", ["Лед"] = "Spell_Frost_FrostNova", ["Нечестивость"] = "Spell_Shadow_ShadeTrueSight"},
	["DRUID"] = {["Баланс"] = "Spell_Nature_Lightning", ["Сила зверя"] = "Ability_Racial_BearForm", ["Исцеление"] = "Spell_Nature_HealingTouch"},
	["HUNTER"] = {["Повелитель зверей"] = "Ability_Hunter_BeastTaming", ["Стрельба"] = "Ability_Marksmanship", ["Выживание"] = "Ability_Hunter_SwiftStrike"},
	["MAGE"] = {["Тайная магия"] = "Spell_Holy_MagicalSentry", ["Огонь"] = "Spell_Fire_FlameBolt", ["Лед"] = "Spell_Frost_FrostBolt02"},
	["PALADIN"] = {["Свет"] = "Spell_Holy_HolyBolt", ["Защита"] = "Spell_Holy_DevotionAura", ["Воздаяние"] = "Spell_Holy_AuraOfLight"},
	["PRIEST"] = {["Послушание"] = "Spell_Holy_WordFortitude", ["Свет"] = "Spell_Holy_HolyBolt", ["Темная магия"] = "Spell_Shadow_ShadowWordPain"},
	["ROGUE"] = {["Ликвидация"] = "Ability_Rogue_Eviscerate", ["Бой"] = "Ability_BackStab", ["Скрытность"] = "Ability_Stealth"},
	["SHAMAN"] = {["Стихии"] = "Spell_Nature_Lightning", ["Совершенствование"] = "Spell_Nature_LightningShield", ["Исцеление"] = "Spell_Nature_MagicImmunity"},
	["WARLOCK"] = {["Колдовство"] = "Spell_Shadow_DeathCoil", ["Демонология"] = "Spell_Shadow_Metamorphosis", ["Разрушение"] = "Spell_Shadow_RainOfFire"},
	["WARRIOR"] = {["Оружие"] = "Ability_Rogue_Eviscerate", ["Неистовство"] = "Ability_Warrior_InnerRage", ["Защита"] = "INV_Shield_06"},
}

local token2role = {
	["1"] = "t", ["2"] = "t", ["3"] = "t", ["4"] = "r", ["5"] = "t",
	["6"] = "h", ["7"] = "r", ["8"] = "r", ["9"] = "r", ["a"] = "r",
	["b"] = "r", ["c"] = "r", ["d"] = "h", ["e"] = "t", ["f"] = "m",
	["g"] = "h", ["h"] = "h", ["i"] = "r", ["j"] = "m", ["k"] = "m",
	["l"] = "m", ["m"] = "r", ["n"] = "m", ["o"] = "h", ["p"] = "r",
	["q"] = "r", ["r"] = "r", ["s"] = "m", ["t"] = "m", ["u"] = "t",
}

local token2categories = {
	["1"] = {25, 7, 19},
	["2"] = {25, 4, 19},
	["3"] = {25, 19, 13},
	["m"] = {25, 42, 4, 11, 10, 14, 14, 18},
	["n"] = {25, 7, 42, 4, 10, 14},
	["o"] = {25, 42, 39, 4, 32, 10, 14},
	["s"] = {6, 27, 1, 22, 9, 21, 19, 3},
	["t"] = {6, 27, 5, 1, 22, 21, 19},
	["u"] = {6, 27, 1, 22, 19},
	["d"] = {6, 39, 23, 38, 35},
	["e"] = {6, 30, 31, 39, 23, 22, 18, 38, 35, 19},
	["f"] = {6, 17, 16, 39, 34, 23, 22, 18, 38, 35},
	["8"] = {7, 2, 9, 21, 20},
	["7"] = {17, 1, 9, 33, 21, 20},
	["g"] = {30, 32, 29, 26},
	["4"] = {16, 11, 24, 2, 20, 13, 15},
	["6"] = {31, 24, 2},
	["p"] = {27, 28, 29, 2, 22, 33, 12, 13},
	["q"] = {27, 28, 14, 29, 2, 22, 33, 13},
	["r"] = {27, 28, 34, 29, 2, 22, 33, 13},
	["a"] = {28, 33, 12},
	["b"] = {28, 12},
	["c"] = {28, 34, 12},
	["5"] = {5, 24, 2, 22, 9, 19},
	["h"] = {32, 29, 26},
	["9"] = {34, 2, 9, 21, 20},
	["i"] = {34, 29, 26, 15},
	["j"] = {1, 33, 18, 21},
	["k"] = {1, 33, 21, 3},
	["l"] = {1, 33, 21},
}


local categories = {
    ["1"] = {
		stype = "d",
        name = ARMOR.." (Major)",
        spells = {
            {id = 55754, class = "HUNTER"},
            {id = 8647, class = "ROGUE"},
            {id = 58567, class = "WARRIOR"},
        },
    },
    ["2"] = {
		stype = "d",
        name = ARMOR.." (Minor)",
        spells = {
            {id = 50511, class = "WARLOCK", spellimp = 18180},
            {id = 16857, class = "DRUID"},
            {id = 56631, class = "HUNTER"},
        },
    },
    ["3"] = {
		stype = "d",
        name = "Physical Vulnerability",
        spells = {
            {id = 29859, class = "WARRIOR"},
            {id = 58413, class = "ROGUE"},
        },
    },
    ["4"] = {
		stype = "b",
        name = ITEM_MOD_HASTE_MELEE_RATING_SHORT,
        spells = {
            {id = 55610, class = "DEATHKNIGHT"},
            {id = 8512, class = "SHAMAN", spellimp = 29193},
        },
    },
    ["5"] = {
		stype = "b",
        name = ITEM_MOD_CRIT_MELEE_RATING_SHORT,
        spells = {
            {id = 17007, class = "DRUID"},
            {id = 29801, class = "WARRIOR"},
        },
    },
    ["6"] = {
		stype = "b",
        name = ITEM_MOD_MELEE_ATTACK_POWER_SHORT.." (Minor)",
        spells = {
            {id = 47436, class = "WARRIOR", spellimp = 12861},
            {id = 48932, class = "PALADIN", spellimp = 20045},
        },
    },
    ["7"] = {
		stype = "b",
        name = ITEM_MOD_MELEE_ATTACK_POWER_SHORT.." (Major)",
        spells = {
            {id = 53138, class = "DEATHKNIGHT"},
            {id = 19506, class = "HUNTER"},
            {id = 30809, class = "SHAMAN"},
        },
    },
    ["9"] = {
		stype = "d",
        name = "Bleed Damage",
        spells = {
            {id = 48564, class = "DRUID"},
            {id = 57393, class = "HUNTER"},
            {id = 46855, class = "WARRIOR"},
        },
    },
    ["10"] = {
		stype = "b",
        name = "Spell Haste",
        spells = {
            {id = 3738, class = "SHAMAN"},
        },
    },
    ["11"] = {
		stype = "b",
        name = "Spell Critical Strike Chance",
        spells = {
            {id = 51470, class = "SHAMAN"},
            {id = 24907, class = "DRUID"},
        },
    },
    ["12"] = {
		stype = "d",
        name = "Spell Critical Strike Chance",
        spells = {
            {id = 12873, class = "MAGE"},
            {id = 17803, class = "WARLOCK"},
            {id = 28593, class = "MAGE"},
        },
    },
    ["13"] = {
		stype = "d",
        name = "Spell Damage Taken",
        spells = {
            {id = 47865, class = "WARLOCK", spellimp = 32484},
            {id = 48511, class = "DRUID"},
            {id = 51161, class = "DEATHKNIGHT"},
        },
    },
    ["14"] = {
		stype = "b",
        name = "Spell Power",
        spells = {
            {id = 47240, class = "WARLOCK"},
            {id = 58656, class = "SHAMAN"},
            {id = 57722, class = "SHAMAN"},
        },
    },
    ["15"] = {
		stype = "d",
        name = "Spell Hit Chance Taken",
        spells = {
            {id = 33602, class = "DRUID"},
            {id = 33193, class = "PRIEST"},
        },
    },
    ["16"] = {
		stype = "b",
        name = "Haste",
        spells = {
            {id = 48396, class = "DRUID"},
            {id = 53648, class = "PALADIN"},
        },
    },
    ["17"] = {
		stype = "b",
        name = "Damage",
        spells = {
            {id = 31583, class = "HUNTER"},
            {id = 34460, class = "HUNTER"},
            {id = 31869, class = "PALADIN"},
        },
    },
    ["18"] = {
		stype = "d",
        name = "Critical Strike Chance Taken",
        spells = {
            {id = 20337, class = "PALADIN"},
            {id = 58410, class = "ROGUE"},
            {id = 30706, class = "SHAMAN"},
        },
    },
    ["19"] = {
		stype = "d",
        name = "Melee Attack Speed Slow",
        spells = {
            {id = 49909, class = "DEATHKNIGHT", spellimp = 51456},
            {id = 48485, class = "DRUID", spellimp = 48485},
            {id = 53696, class = "PALADIN"},
            {id = 47502, class = "WARRIOR", spellimp = 12666},
        },
    },
    ["20"] = {
		stype = "d",
        name = "Melee Hit Chance Reduction",
        spells = {
            {id = 48468, class = "DRUID"},
            {id = 3043, class = "HUNTER"},
        },
    },
    ["21"] = {
		stype = "d",
        name = "Healing",
        spells = {
            {id = 49050, class = "HUNTER"},
            {id = 46911, class = "WARRIOR"},
            {id = 47486, class = "WARRIOR"},
            {id = 57978, class = "ROGUE"},
        },
    },
    ["22"] = {
		stype = "d",
        name = "Attack Power",
        spells = {
            {id = 50511, class = "WARLOCK", spellimp = 18180},
            {id = 48560, class = "DRUID", spellimp = 16862},
            {id = 47437, class = "WARRIOR", spellimp = 12879},
            {id = 26016, class = "PALADIN"},
        },
    },
    ["23"] = {
		stype = "b",
        name = "Stat Multiplier",
        spells = {
            {id = 20217, class = "PALADIN"},
        },
    },
    ["24"] = {
		stype = "b",
        name = "Stat Add",
        spells = {
            {id = 48469, class = "DRUID", spellimp = 17051},
        },
    },
    ["25"] = {
		stype = "b",
        name = AGI..", "..STR,
        spells = {
            {id = 57623, class = "DEATHKNIGHT"},
            {id = 58643, class = "SHAMAN", spellimp = 52456 },
        },
    },
    ["26"] = {
		stype = "b",
        name = STA,
        spells = {
            {id = 48161, class = "PRIEST", spellimp = 14767},
        },
    },
    ["27"] = {
		stype = "b",
        name = HEALTH,
        spells = {
            {id = 47982, class = "WARLOCK", spellimp = 18696},
            {id = 47440, class = "WARRIOR", spellimp = 12861},
        },
    },
    ["28"] = {
		stype = "b",
        name = INT,
        spells = {
            {id = 42995, class = "MAGE"},
            {id = 57567, class = "WARLOCK"},
        },
    },
    ["29"] = {
		stype = "b",
        name = SPI,
        spells = {
            {id = 48073, class = "PRIEST"},
            {id = 57567, class = "WARLOCK"},
        },
    },
    ["30"] = {
		stype = "b",
        name = "Damage Reduction",
        spells = {
            {id = 20911, class = "PALADIN"},
            {id = 57472, class = "PRIEST"},
        },
    },
    ["31"] = {
		stype = "b",
        name = "Healing Received",
        spells = {
            {id = 20140, class = "PALADIN"},
            {id = 33891, class = "DRUID"},
        },
    },
    ["32"] = {
		stype = "b",
        name = "Physical Damage Reduction",
        spells = {
            {id = 16240, class = "SHAMAN"},
            {id = 15363, class = "PRIEST"},
        },
    },
    ["33"] = {
		stype = "d",
        name = "Cast Speed Slow",
        spells = {
            {id = 11719, class = "WARLOCK"},
            {id = 58611, class = "HUNTER"},
            {id = 5761, class = "ROGUE"},
            {id = 31589, class = "MAGE"},
        },
    },
    ["34"] = {
		stype = "b",
        name = "Replenishment",
        spells = {
            {id = 44561, class = "MAGE"},
            {id = 53292, class = "HUNTER"},
            {id = 54118, class = "WARLOCK"},
            {id = 31878, class = "PALADIN"},
            {id = 48160, class = "PRIEST"},
        },
    },
    ["35"] = {
		stype = "d",
        name = "Mana Restore",
        spells = {
            {id = 53408, class = "PALADIN"},
        },
    },
    ["38"] = {
		stype = "d",
        name = "Health Restore",
        spells = {
            {id = 20271, class = "PALADIN"},
        },
    },
    ["39"] = {
		stype = "b",
        name = MANA_REGEN,
        spells = {
            {id = 48936, class = "PALADIN", spellimp = 20245},
            {id = 58774, class = "SHAMAN", spellimp = 16206},
        },
    },
    ["42"] = {
		stype = "b",
        name = "Bloodlust / Heroism",
        spells = {
            {id = 2825, class = "SHAMAN"},
        },
    },
}
for _,v in pairs(categories) do v.exist = false end

local getTalents = function()
    local maxpoints = 0
    local retname, rettexture = "", ""
    for tab=1, 3 do
        local name, iconTexture, pointsSpent, background, previewPointsSpent = GetTalentTabInfo(tab, true)
        if name ~= nil then
            if maxpoints < pointsSpent then
                maxpoints = pointsSpent
                retname, rettexture = name, iconTexture
            end
        end
    end
    return retname, iconTexture
end


local makeGUI = function()

    classes:SetWidth(main:GetWidth()/3-4)
    classes:SetHeight(main:GetHeight()-resize:GetHeight()-4)
    classes:SetPoint("TOPLEFT", 4, -2)

    raid:SetWidth(main:GetWidth()/3-4)
    raid:SetHeight(main:GetHeight()/1.5-resize:GetHeight()-4)
    raid:SetPoint("TOPLEFT", classes, "TOPRIGHT", 2, 0)
    
    info:SetWidth(main:GetWidth()/3-4)
    info:SetHeight((main:GetHeight()-raid:GetHeight())-resize:GetHeight()-6)
    info:SetPoint("TOPLEFT", raid, "BOTTOMLEFT", 0, -2)
    
    buffs:SetWidth(main:GetWidth()/3-4)
    buffs:SetHeight((main:GetHeight()-resize:GetHeight()-2)/1.6)
    buffs:SetPoint("TOPLEFT", raid, "TOPRIGHT", 2, 0)
    buffs.name = buffs:GetName()

    debuffs:SetWidth(main:GetWidth()/3-4)
    debuffs:SetHeight((main:GetHeight()-resize:GetHeight()-buffs:GetHeight()-2))
    debuffs:SetPoint("TOPLEFT", buffs, "BOTTOMLEFT", 0, -2)
    debuffs.name = debuffs:GetName()
    
    scrollchildinfo:SetWidth(30)
    scrollchildinfo:SetHeight(30)
    infotext:SetAllPoints(scrollchildinfo)
    
    scrollchild:SetWidth(30)
    scrollchild:SetHeight(30)
    raidtext:SetAllPoints(scrollchild)

    title:SetPoint("BOTTOMLEFT", main, "TOPLEFT", 0, 0)
    title:SetPoint("TOPRIGHT", main, "TOPRIGHT", 0, 20)
    title:SetBackdropColor(0,0,0,1)

    
    local index, barheight = 0, classes:GetHeight()/40
    for i,v in pairs(classtokens) do
        local bar = _G[classes:GetName().."_"..i] or CreateFrame("frame", classes:GetName().."_"..i, classes)
        bar:SetHeight(barheight-3)
        bar:SetWidth(classes:GetWidth()-4)
        bar:SetPoint("TOPLEFT", 2, -index*barheight-2)
        bar.name = i
        stylefunc(bar)

        local tex = _G[classes:GetName().."_tex_"..i] or bar:CreateTexture(classes:GetName().."_tex_"..i, "OVERLAY")
        tex:SetWidth(bar:GetHeight()-2)
        tex:SetHeight(tex:GetWidth())
        tex:SetPoint("TOPLEFT", 2, -2)
        tex:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
        tex:SetTexCoord(unpack(CLASS_ICON_TCOORDS[i]))

        local fs = createFs(bar, "LEFT", bar:GetHeight()-4)
        fs:SetPoint("TOPLEFT", tex, "TOPRIGHT", 2, -2)
        fs:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)
        
        fs:SetText("|cff"..classColStr(i)..LOCALIZED_CLASS_NAMES_MALE[i].."|r")

        bar:EnableMouse(true)
        
        local iconindex = 0
        for o, k in pairs(v) do
            index = index + 1
            iconindex = iconindex + 1

            local bar2 = _G[classes:GetName().."_bar2_"..o..i] or CreateFrame("frame", classes:GetName().."_bar2_"..o..i, classes)
            bar2:SetHeight(barheight-3)
            bar2:SetWidth(classes:GetWidth()-4-20)
            bar2:SetPoint("TOPLEFT", 2+20, -index*barheight-2)
            bar2.name = o
            stylefunc(bar2)

            local tex2 = _G[classes:GetName().."_tex2_"..o..i] or bar2:CreateTexture(classes:GetName().."_tex2_"..o..i, "OVERLAY")
            tex2:SetWidth(bar2:GetHeight()-2)
            tex2:SetHeight(tex2:GetWidth())
            tex2:SetPoint("TOPLEFT", 2, -2)
            tex2:SetTexture("Interface\\Icons\\"..talenticons[i][o])
        
            local fs2 = createFs(bar2, "LEFT", bar2:GetHeight()-4)
            fs2:SetPoint("TOPLEFT", tex2, "TOPRIGHT", 2, -2)
            fs2:SetPoint("BOTTOMRIGHT", bar2, "BOTTOMRIGHT", -2, 2)
            
            fs2:SetText(o)

            bar2:EnableMouse(true)
            bar2:SetScript("OnEnter", function(self) 
                for e,q in pairs(token2categories[classtokens[i][self.name]]) do
                    local cbar = _G["rcomp_buffs_"..q]
                    if cbar then
                        cbar:SetBackdropColor(0,1,0,.2)
                    else
                        cbar = _G["rcomp_debuffs_"..q]
                        cbar:SetBackdropColor(1,0,0,.2)
                    end
                end
                self:SetBackdropColor(1,1,1,.2) 
            end)
            bar2:SetScript("OnLeave", function(self)
                for i,v in pairs(categories) do
                    local cbar = _G["rcomp_buffs_"..i]
                    if cbar then
                        stylefunc(cbar)
                    else
                        cbar = _G["rcomp_debuffs_"..i]
                        stylefunc(cbar)
                    end
                end
                stylefunc(self) 
            end)
        end
        index = index + 1
    end

    local makeBars = function(parent, stype, caption)
        local index, barheight = 0, 0
        for i,v in pairs(categories) do if v.stype==stype then index = index + 1 end  end
        barheight = parent:GetHeight() / (index+1)

        index = 0
        local fs1 = createFs(parent, "LEFT", barheight-4)
        fs1:SetPoint("TOPLEFT", 2, 0)
        fs1:SetText(caption)

        for i,v in pairs(categories) do
            if v.stype == stype then
                local bar = _G[parent:GetName().."_"..i] or CreateFrame("frame", parent:GetName().."_"..i, parent)
                bar:SetHeight(barheight-2)
                bar:SetWidth(parent:GetWidth()-4)
                bar:SetPoint("TOPLEFT", 2, -index*barheight-barheight)
                bar.ready = "Interface\\RAIDFRAME\\ReadyCheck-Ready"
                bar.notready = "Interface\\RAIDFRAME\\ReadyCheck-NotReady"
                bar.name = v.name
                stylefunc(bar)

                local tex = _G[parent:GetName().."_tex_"..i] or  bar:CreateTexture(parent:GetName().."_tex_"..i, "OVERLAY")
                tex:SetWidth(bar:GetHeight()-4)
                tex:SetHeight(tex:GetWidth())
                tex:SetPoint("TOPLEFT", 2, -2)
                if v.exist then
                    tex:SetTexture(bar.ready)
                else
                    tex:SetTexture(bar.notready)
                end

                local fs = createFs(bar, "LEFT", bar:GetHeight()-4)
                fs:SetPoint("TOPLEFT", tex, "TOPRIGHT", 2, 0)
                fs:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", -2, 2)
                fs:SetText(v.name)

                bar:EnableMouse(true)
                bar:SetScript("OnMouseUp", function(self)
                    local txt = self.name.."|n|n"
                    for j,k in pairs(v.spells) do
                        local name, _, icon = GetSpellInfo(k.id)
                        local spec = ""
                        for f, u in pairs(token2categories) do
                            for s, n in pairs(u) do
                                if tostring(n) == tostring(i) then
                                    for t,q in pairs(classtokens[k.class]) do
                                        if q==f then
                                            spec = t
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        local spellimp = ""
                        if k.spellimp then spellimp = " Улучшается талантами" end
                        local ccol = classColList(k.class)
                        txt = txt.."|cff"..classColStr(k.class)..LOCALIZED_CLASS_NAMES_MALE[k.class].." - "..spec.."|r|n      ".."|T"..icon..":0:0:0:-1|t ".."|cff71d5ff|Hspell:"..k.id.."|h["..name.."]|h|r |cffffffff"..spellimp.."|r|n"
                    end
                    infotext:SetText(txt)
                    infotext:SetScript("OnHyperlinkEnter", function(self, link, text, button)
                        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
                        GameTooltip:SetHyperlink(link)
                        GameTooltip:Show()
                    end)
                    infotext:SetScript("OnHyperlinkLeave", function(self, ...)
                        GameTooltip:Hide()
                    end)
                    
                end)
                
                bar:SetScript("OnEnter", function(self)
                    GameTooltip:ClearLines()
                    GameTooltip:SetOwner(self, ANCHOR_TOPRIGHT)
                    GameTooltip:AddLine(self.name)
                    for j,k in pairs(v.spells) do
                        local name, _, icon = GetSpellInfo(k.id)
                        local spec = ""
                        for f, u in pairs(token2categories) do
                            for s, n in pairs(u) do
                                if tostring(n) == tostring(i) then
                                    for t,q in pairs(classtokens[k.class]) do
                                        if q==f then
                                            spec = t
                                            break
                                        end
                                    end
                                end
                            end
                        end
                        self:SetBackdropColor(0,1,0,.2)
                        local spellimp = ""
                        if k.spellimp then spellimp = " [Улучшается талантами]" end
                        local ccol = classColList(k.class)
                        GameTooltip:AddDoubleLine(LOCALIZED_CLASS_NAMES_MALE[k.class], spec, ccol[1],ccol[2],ccol[3], ccol[1],ccol[2],ccol[3])
                        GameTooltip:AddDoubleLine(" ", "|T"..icon..":0:0:0:-1|t "..name.."|cffffffff"..spellimp.."|r")
                        --local cbar = _G["rcomp_classes_"..k.class]
                        --cbar:SetBackdropColor(0,1,0,.2)
                        local cbar2 = _G["rcomp_classes_bar2_"..spec..k.class]
                        cbar2:SetBackdropColor(0,1,0,.2)
                        GameTooltip:Show()
                    end
                end)
                bar:SetScript("OnLeave", function(self)
                    GameTooltip:ClearLines()
                    GameTooltip:Hide()
                    stylefunc(self)
                    for n,m in pairs(classtokens) do
                        local cbar = _G["rcomp_classes_"..n]
                        stylefunc(cbar)
                        for nn, mm in pairs(m) do
                            local cbar2 = _G["rcomp_classes_bar2_"..nn..n]
                            stylefunc(cbar2)
                        end
                    end
                end)
                index = index + 1
            end
        end
    end

    makeBars(buffs, "b", "|cff00AA00Buffs|r")
    makeBars(debuffs, "d", "|cffAA0000Debuffs|r")

end


local StartCheckRaid = function()
    local count, gtype = 0, ""
    iunit = nil
    inspectQueque = {}
    raidtext:SetText("")
    for _,v in pairs(categories) do v.exist = false end
    
    if UnitInParty("player") then count = GetNumPartyMembers() gtype = "party" end
    if UnitInRaid("player") then count = GetNumRaidMembers() gtype = "raid" end
    
    if count then
        for i=1, count do
            local unit = gtype..i
            local class = select(2, UnitClass(unit))
            inspectQueque[unit] = { ["unit"] = unit, ["class"] = class, ["inspected"] = false, ["talents"] = "", }
        end
        
        if inspectQueque[gtype.."1"] ~= nil then
            iunit = inspectQueque[gtype.."1"].unit
            inspectingUnit = iunit
            NotifyInspect(inspectQueque[gtype.."1"].unit)
        end
    end
end

local inspectButton = CreateFrame("button", nil, main, "UIPanelButtonTemplate")
inspectButton:SetText("Inspect raid")
inspectButton:SetPoint("BOTTOM", main, "BOTTOM", 0, 0)
inspectButton:SetWidth(100)
inspectButton:SetHeight(20)
inspectButton:SetScript("OnClick", function()
    StartCheckRaid()
end)


EventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        if arg1 == addonName then

            stylefunc(main)
            main:SetBackdropColor(0,0,0,1)
            stylefunc(buffs)
            stylefunc(debuffs)
            stylefunc(classes)
            stylefunc(raid)
            stylefunc(title)
            stylefunc(info)

            main:SetPoint("CENTER")
            main:SetWidth(800)
            main:SetHeight(600)
            
            main:SetResizable(true)
            main:SetMovable(true)
            main:EnableMouse(true)
            main:SetClampedToScreen(true)
            main:SetFrameStrata("HIGH")
            main:SetMinResize(400,400)
            main:SetMaxResize(1000,800)
            main:RegisterForDrag("LeftButton")   

            resize:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", -2, 2)
            resize:SetWidth(16)
            resize:SetHeight(16)
            resize:SetNormalTexture("Interface\\Buttons\\WHITE8x8")
            resize:GetNormalTexture():SetVertexColor(0,0,0,.5)
            resize:SetPushedTexture("Interface\\Buttons\\WHITE8x8")    
            resize:GetPushedTexture():SetVertexColor(0,1,0,.5)

            CloseButton = CreateFrame("button", nil, main, "UIPanelCloseButton")
            CloseButton:SetPoint("TOPRIGHT", title, "TOPRIGHT", 4, 6)
            CloseButton:SetScript("OnClick", function()
                main:Hide()
                print("|cffff00f0RaidComp:|r use /com or /raidcomp commands for show the RaidComp")
            end)
           
            print("|cffff00f0RaidComp:|r use /com or /raidcomp commands for show the RaidComp")

            makeGUI()
            EventFrame:UnregisterEvent("ADDON_LOADED")
        end
    
    elseif event == "INSPECT_TALENT_READY" then
        if not ourUnit then 
            for g, f in pairs(inspectQueque) do
                if f.inspected == false then
                    if CheckInteractDistance(f.unit, 1) and UnitIsVisible(f.unit) and CanInspect(f.unit, false) then
                        iunit = f.unit
                        --print("Sending to inspect "..UnitName(f.unit))
                        inspectingUnit = iunit
                        NotifyInspect(f.unit)
                        return
                    end
                end
            end
        end
        
        if not UnitInParty("player") or not UnitInRaid("player") then return end
        if not iunit then return end
        
        if CheckInteractDistance(iunit, 1) and UnitIsVisible(iunit) and CanInspect(iunit, false) then
            inspectQueque[iunit].talents = select(1, getTalents())
            inspectQueque[iunit].inspected = true
            status:SetText("Inspectiong "..UnitName(iunit))
        end
        
        local txt = ""
        for g, f in pairs(inspectQueque) do
            if f.inspected == false then
                txt = txt.."|cffff0000"..UnitName(f.unit).."|r|n"
            else
                txt = txt.."|cff"..classColStr(f.class)..UnitName(f.unit).."|r "..f.talents.."|n"
            end
        end
        raidtext:SetText(txt)
        
        for vv, cc in pairs(classtokens[inspectQueque[iunit].class]) do
            if vv == inspectQueque[iunit].talents then
                local token = cc
                local cat = token2categories[token]
                
                for j=1, #cat do
                    for k, v in pairs(categories) do
                        if tonumber(k) == tonumber(cat[j]) then
                            categories[k].exist = true
                            makeGUI()
                            break
                        end
                    end
                end
                break
            end
        end
        
        for g, f in pairs(inspectQueque) do
            if f.inspected == false then
                if CheckInteractDistance(f.unit, 1) and UnitIsVisible(f.unit) and CanInspect(f.unit, false) then
                    iunit = f.unit
                    --print("Sending to inspect "..UnitName(f.unit))
                    inspectingUnit = iunit
                    NotifyInspect(f.unit)
                    return
                end
            end
        end
        
    elseif event == "RAID_ROSTER_UPDATE" then
        local count, gtype = 0, ""
        iunit = nil
        inspectQueque = {}
        
        for _,v in pairs(categories) do v.exist = false end
        
        if UnitInParty("player") then count = GetNumPartyMembers() gtype = "party" end
        if UnitInRaid("player") then count = GetNumRaidMembers() gtype = "raid" end

        for i=1, count do
            local unit = gtype..i
            local class = select(2, UnitClass(unit))
            inspectQueque[unit] = { ["unit"] = unit, ["class"] = class, ["inspected"] = false, ["talents"] = "", }
        end

        if inspectQueque[gtype.."1"] ~= nil then
            iunit = inspectQueque[gtype.."1"].unit
            inspectingUnit = inspectQueque[gtype.."1"].unit
            NotifyInspect(inspectQueque[gtype.."1"].unit)
        end
    end

end)

hooksecurefunc("NotifyInspect", function(unit)
    if unit == inspectingUnit then
        ourUnit = true
    else
        ourUnit = false
    end
end)


main:SetScript("OnDragStart", function(self, ...) self:StartMoving() end)
main:SetScript("OnDragStop", function(self, ...) self:StopMovingOrSizing() end)

resize:SetScript("OnMouseDown", function(self)
    main:StartSizing()
end)

resize:SetScript("OnMouseUp", function(self)
    makeGUI()
    main:StopMovingOrSizing()
end)

-- slash command
SLASH_RAIDCOMP1 = "/raidcomp";
SLASH_RAIDCOMP2 = "/com";
SlashCmdList["RAIDCOMP"] = function (msg)
  main:Show()
end