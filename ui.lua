-- ============================================================================
-- SlotMachine - Oberflaeche
-- ============================================================================
--
-- Aufbau nach dem Vorbild von Keystone Loot, Optik nach EllesmereUI und
-- Chrissi's Addon v1.1.0.
--
-- Warum diese Struktur: Zeile = Quelle (Boss oder Dungeon), Spalte = Item als
-- Icon. Die erste Fassung hatte es andersherum (Slot links, Textliste rechts).
-- Das war unuebersichtlich, weil ein Itemname dreimal so breit ist wie sein
-- Icon und man nie sieht, wo etwas zu holen ist. Umgestellt am 14.08.2026
-- nach direktem Vergleich beider Fenster im Spiel.
--
-- Der eigene Kern gegenueber Keystone Loot ist die SORTIERUNG: Quellen werden
-- nach der Anzahl markierter Wunsch-Items absteigend gereiht. Wo am meisten
-- fuer dich drin ist, steht oben.

local AddonName, ns = ...

local UI = {}
ns.UI = UI

-- Design-Tokens, identisch mit Chrissi's Addon, damit beide Fenster
-- nebeneinander wie ein System wirken.
local BG      = { 0.060, 0.080, 0.100, 0.97 }
local SURFACE = { 0.125, 0.125, 0.137 }
local EDGE    = { 0.467, 0.471, 0.482, 0.5 }
local ACCENT  = "ffe8c15a"
local INK     = "ffd6d2c8"
local INK_DIM = "ff8d887e"
local GREEN   = "ff0ca30c"

local WIDTH, HEIGHT = 620, 560
local PAD           = 14
local ICON          = 26      -- Kantenlaenge eines Item-Icons
local ICON_GAP      = 3
local ROW_H         = ICON + 8
local HEAD_H        = 20      -- Hoehe einer Instanz-Ueberschrift
local LABEL_W       = 170     -- Breite der Quellenspalte links

local function HexToRGB(hex)
    if #hex == 8 then hex = hex:sub(3) end
    return tonumber(hex:sub(1, 2), 16) / 255,
           tonumber(hex:sub(3, 4), 16) / 255,
           tonumber(hex:sub(5, 6), 16) / 255
end

local function AddEdges(f, alpha)
    local r, g, b = EDGE[1], EDGE[2], EDGE[3]
    local a = alpha or EDGE[4]
    local top = f:CreateTexture(nil, "BORDER")
    top:SetColorTexture(r, g, b, a); top:SetHeight(1)
    top:SetPoint("TOPLEFT"); top:SetPoint("TOPRIGHT")
    local bot = f:CreateTexture(nil, "BORDER")
    bot:SetColorTexture(r, g, b, a); bot:SetHeight(1)
    bot:SetPoint("BOTTOMLEFT"); bot:SetPoint("BOTTOMRIGHT")
    local le = f:CreateTexture(nil, "BORDER")
    le:SetColorTexture(r, g, b, a); le:SetWidth(1)
    le:SetPoint("TOPLEFT", top, "BOTTOMLEFT"); le:SetPoint("BOTTOMLEFT", bot, "TOPLEFT")
    local ri = f:CreateTexture(nil, "BORDER")
    ri:SetColorTexture(r, g, b, a); ri:SetWidth(1)
    ri:SetPoint("TOPRIGHT", top, "BOTTOMRIGHT"); ri:SetPoint("BOTTOMRIGHT", bot, "TOPRIGHT")
    return { top, bot, le, ri }
end

-- ----------------------------------------------------------------------------
-- Slot-Gruppen
-- ----------------------------------------------------------------------------
-- Die Zuordnung equipLoc zu Slot ist eindeutig, aber NICHT eins zu eins.
-- INVTYPE_ROBE und INVTYPE_CHEST meinen beide die Brust, INVTYPE_RANGED und
-- INVTYPE_RANGEDRIGHT beide die Distanzwaffe. Wer nur auf eine Konstante
-- filtert, verliert die Haelfte der Items.

local SLOT_GROUPS = {
    { key = "ALL",      label = "Alle Slots" },
    { key = "WISH",     label = "Wunschliste" },
    { key = "HEAD",     label = "Kopf",        loc = { INVTYPE_HEAD = true } },
    { key = "NECK",     label = "Hals",        loc = { INVTYPE_NECK = true } },
    { key = "SHOULDER", label = "Schultern",   loc = { INVTYPE_SHOULDER = true } },
    { key = "BACK",     label = "Rücken",      loc = { INVTYPE_CLOAK = true } },
    { key = "CHEST",    label = "Brust",       loc = { INVTYPE_CHEST = true, INVTYPE_ROBE = true } },
    { key = "WRIST",    label = "Handgelenke", loc = { INVTYPE_WRIST = true } },
    { key = "HANDS",    label = "Hände",       loc = { INVTYPE_HAND = true } },
    { key = "WAIST",    label = "Taille",      loc = { INVTYPE_WAIST = true } },
    { key = "LEGS",     label = "Beine",       loc = { INVTYPE_LEGS = true } },
    { key = "FEET",     label = "Füße",        loc = { INVTYPE_FEET = true } },
    { key = "FINGER",   label = "Ringe",       loc = { INVTYPE_FINGER = true } },
    { key = "TRINKET",  label = "Schmuck",     loc = { INVTYPE_TRINKET = true } },
    { key = "WEAPON",   label = "Waffen",      loc = { INVTYPE_WEAPON = true, INVTYPE_2HWEAPON = true,
                                                      INVTYPE_WEAPONMAINHAND = true,
                                                      INVTYPE_RANGED = true, INVTYPE_RANGEDRIGHT = true } },
    { key = "OFFHAND",  label = "Nebenhand",   loc = { INVTYPE_SHIELD = true, INVTYPE_HOLDABLE = true } },
}

local locToGroup = {}
for _, g in ipairs(SLOT_GROUPS) do
    if g.loc then for loc in pairs(g.loc) do locToGroup[loc] = g.key end end
end

local function GroupOfItem(itemID)
    local rec = ns.ITEMS and ns.ITEMS[itemID]
    if not rec or not rec.e then return nil end
    local loc = ns.EQUIP and ns.EQUIP[rec.e]
    return loc and locToGroup[loc] or nil
end

-- ----------------------------------------------------------------------------
-- Raid oder Dungeon?
-- ----------------------------------------------------------------------------
-- Steht nicht in den Daten, weil der Scan es nicht mitgeschrieben hat. Statt
-- deswegen neu zu scannen, wird die Liste einmal beim ersten Aufbau aus dem
-- Journal geholt. Kostet zwei Schleifen und ist danach im Speicher.

local raidSet = nil
local function IsRaid(instanceID)
    if not raidSet then
        raidSet = {}
        local idx = 1
        while true do
            local ok, id = pcall(EJ_GetInstanceByIndex, idx, true)
            if not ok or not id then break end
            raidSet[id] = true
            idx = idx + 1
            if idx > 60 then break end
        end
    end
    return raidSet[instanceID] or false
end

-- ----------------------------------------------------------------------------
-- Wunschliste
-- ----------------------------------------------------------------------------

local function Wanted(itemID)
    return (SlotMachineCharDB.wanted and SlotMachineCharDB.wanted[itemID]) and true or false
end

local function ToggleWanted(itemID)
    SlotMachineCharDB.wanted = SlotMachineCharDB.wanted or {}
    SlotMachineCharDB.wanted[itemID] = (not SlotMachineCharDB.wanted[itemID]) or nil
end

-- ----------------------------------------------------------------------------
-- Zustand
-- ----------------------------------------------------------------------------

local currentTab  = "DUNGEON"   -- oder "RAID"
local currentSlot = "ALL"

-- ----------------------------------------------------------------------------
-- Daten fuer die Anzeige aufbereiten
-- ----------------------------------------------------------------------------

local function PassesSlot(itemID)
    if currentSlot == "ALL"  then return true end
    if currentSlot == "WISH" then return Wanted(itemID) end
    return GroupOfItem(itemID) == currentSlot
end

-- Liefert eine Liste von Quellen, sortiert nach Anzahl der Wunsch-Items.
-- Das ist der Kern des Add-ons: Wo am meisten fuer dich drin ist, steht oben.
local function BuildSources()
    local out = {}
    if not ns.LOOT then return out end

    for instID, bosses in pairs(ns.LOOT) do
        local isRaid = IsRaid(instID)
        if (currentTab == "RAID") == isRaid then
            for encID, items in pairs(bosses) do
                local shown, wish = {}, 0
                for _, itemID in ipairs(items) do
                    if PassesSlot(itemID) then
                        shown[#shown + 1] = itemID
                        if Wanted(itemID) then wish = wish + 1 end
                    end
                end
                if #shown > 0 then
                    table.sort(shown)
                    out[#out + 1] = {
                        instanceID = instID, encounterID = encID,
                        items = shown, wish = wish, isRaid = isRaid,
                    }
                end
            end
        end
    end

    -- Absteigend nach Wunsch-Anzahl, dann nach Instanz, damit die Reihenfolge
    -- bei Gleichstand stabil bleibt und die Liste nicht springt.
    table.sort(out, function(a, b)
        if a.wish ~= b.wish then return a.wish > b.wish end
        if a.instanceID ~= b.instanceID then return a.instanceID < b.instanceID end
        return a.encounterID < b.encounterID
    end)
    return out
end

-- ----------------------------------------------------------------------------
-- Fenster
-- ----------------------------------------------------------------------------

local frame = CreateFrame("Frame", "SlotMachine_MainFrame", UIParent)
frame:SetSize(WIDTH, HEIGHT)
frame:SetPoint("CENTER")
frame:SetFrameStrata("MEDIUM")
frame:SetClampedToScreen(true)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, _, rp, x, y = self:GetPoint()
    SlotMachineDB.point, SlotMachineDB.relPoint = p, rp
    SlotMachineDB.x, SlotMachineDB.y = x, y
end)
frame:Hide()

local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(BG[1], BG[2], BG[3], BG[4])
AddEdges(frame)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD, -PAD)
title:SetText("|c" .. ACCENT .. "SlotMachine|r")

local subTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
subTitle:SetPoint("LEFT", title, "RIGHT", 8, 0)

local closeBtn = CreateFrame("Button", nil, frame)
closeBtn:SetSize(20, 20)
closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -PAD + 4, -PAD + 4)
closeBtn.label = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
closeBtn.label:SetPoint("CENTER")
closeBtn.label:SetText("|c" .. INK_DIM .. "x|r")
closeBtn:SetScript("OnEnter", function(self) self.label:SetText("|c" .. ACCENT .. "x|r") end)
closeBtn:SetScript("OnLeave", function(self) self.label:SetText("|c" .. INK_DIM .. "x|r") end)
closeBtn:SetScript("OnClick", function() frame:Hide() end)

-- Filterleiste ---------------------------------------------------------------

local slotBtn = CreateFrame("Button", nil, frame)
slotBtn:SetSize(130, 22)
slotBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD, -(PAD + 26))
slotBtn.fill = slotBtn:CreateTexture(nil, "BACKGROUND")
slotBtn.fill:SetAllPoints()
slotBtn.fill:SetColorTexture(SURFACE[1], SURFACE[2], SURFACE[3], 0.85)
AddEdges(slotBtn)
slotBtn.text = slotBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
slotBtn.text:SetPoint("LEFT", slotBtn, "LEFT", 8, 0)
slotBtn.arrow = slotBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
slotBtn.arrow:SetPoint("RIGHT", slotBtn, "RIGHT", -8, 0)
slotBtn.arrow:SetText("|c" .. INK_DIM .. "v|r")

local slotMenu = CreateFrame("Frame", nil, frame)
slotMenu:SetSize(130, #SLOT_GROUPS * 20 + 8)
slotMenu:SetPoint("TOPLEFT", slotBtn, "BOTTOMLEFT", 0, -2)
slotMenu:SetFrameStrata("DIALOG")
slotMenu:Hide()
local mbg = slotMenu:CreateTexture(nil, "BACKGROUND")
mbg:SetAllPoints()
mbg:SetColorTexture(BG[1], BG[2], BG[3], 0.98)
AddEdges(slotMenu)

for i, g in ipairs(SLOT_GROUPS) do
    local e = CreateFrame("Button", nil, slotMenu)
    e:SetSize(126, 20)
    e:SetPoint("TOPLEFT", slotMenu, "TOPLEFT", 2, -(2 + (i - 1) * 20))
    e.fill = e:CreateTexture(nil, "BACKGROUND")
    e.fill:SetAllPoints()
    e.fill:SetColorTexture(1, 1, 1, 0)
    e.text = e:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    e.text:SetPoint("LEFT", e, "LEFT", 8, 0)
    e.text:SetText("|c" .. INK .. g.label .. "|r")
    e:SetScript("OnEnter", function(self) self.fill:SetColorTexture(1, 1, 1, 0.08) end)
    e:SetScript("OnLeave", function(self) self.fill:SetColorTexture(1, 1, 1, 0) end)
    e:SetScript("OnClick", function()
        currentSlot = g.key
        slotMenu:Hide()
        UI:Render()
    end)
end

slotBtn:SetScript("OnClick", function()
    if slotMenu:IsShown() then slotMenu:Hide() else slotMenu:Show() end
end)

-- Tabs -----------------------------------------------------------------------

local function MakeTab(label, key, anchor, xoff)
    local b = CreateFrame("Button", nil, frame)
    b:SetSize(80, 22)
    if anchor then
        b:SetPoint("LEFT", anchor, "RIGHT", xoff or 6, 0)
    else
        b:SetPoint("TOPLEFT", slotBtn, "TOPRIGHT", 10, 0)
    end
    b.fill = b:CreateTexture(nil, "BACKGROUND")
    b.fill:SetAllPoints()
    AddEdges(b)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.text:SetPoint("CENTER")
    b.underline = b:CreateTexture(nil, "OVERLAY")
    b.underline:SetHeight(2)
    b.underline:SetPoint("BOTTOMLEFT"); b.underline:SetPoint("BOTTOMRIGHT")
    b.underline:Hide()
    b.key = key
    b:SetScript("OnClick", function()
        currentTab = key
        UI:Render()
    end)
    return b
end

local tabDungeon = MakeTab("Dungeons", "DUNGEON")
local tabRaid    = MakeTab("Raids", "RAID", tabDungeon)

-- Liste ----------------------------------------------------------------------

local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD, -(PAD + 56))
scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -(PAD + 22), PAD + 22)
local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(1, 1)
scrollFrame:SetScrollChild(content)

local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
hint:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", PAD, PAD - 2)
hint:SetText("|c" .. INK_DIM .. "Klick auf ein Item setzt es auf die Wunschliste. Quellen mit den meisten Wünschen stehen oben.|r")

-- ----------------------------------------------------------------------------
-- Aufbau
-- ----------------------------------------------------------------------------

local rowPool, headPool = {}, {}

local function GetRow(i)
    local r = rowPool[i]
    if r then return r end

    r = CreateFrame("Frame", nil, content)
    r:SetSize(WIDTH - PAD * 2 - 24, ROW_H)
    r.fill = r:CreateTexture(nil, "BACKGROUND")
    r.fill:SetAllPoints()

    r.name = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    r.name:SetPoint("LEFT", r, "LEFT", 6, 0)
    r.name:SetWidth(LABEL_W - 34)
    r.name:SetJustifyH("LEFT")
    r.name:SetWordWrap(false)

    r.badge = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    r.badge:SetPoint("LEFT", r, "LEFT", LABEL_W - 26, 0)

    r.icons = {}
    rowPool[i] = r
    return r
end

local function GetIcon(row, i)
    local b = row.icons[i]
    if b then return b end

    b = CreateFrame("Button", nil, row)
    b:SetSize(ICON, ICON)
    b:SetPoint("LEFT", row, "LEFT", LABEL_W + (i - 1) * (ICON + ICON_GAP), 0)
    b.tex = b:CreateTexture(nil, "ARTWORK")
    b.tex:SetPoint("TOPLEFT", 1, -1)
    b.tex:SetPoint("BOTTOMRIGHT", -1, 1)
    b.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)   -- Blizzard-Rand wegschneiden
    b.edges = AddEdges(b, 0.35)
    row.icons[i] = b
    return b
end

local function GetHeader(i)
    local h = headPool[i]
    if h then return h end
    h = CreateFrame("Frame", nil, content)
    h:SetSize(WIDTH - PAD * 2 - 24, HEAD_H)
    h.text = h:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    h.text:SetPoint("LEFT", h, "LEFT", 4, 0)
    h.rule = h:CreateTexture(nil, "ARTWORK")
    h.rule:SetHeight(1)
    h.rule:SetColorTexture(1, 1, 1, 0.10)
    h.rule:SetPoint("LEFT", h.text, "RIGHT", 8, 0)
    h.rule:SetPoint("RIGHT", h, "RIGHT", -4, 0)
    headPool[i] = h
    return h
end

function UI:Render()
    -- Kopfzeile
    local wish = 0
    for _ in pairs(SlotMachineCharDB.wanted or {}) do wish = wish + 1 end
    local total = 0
    for _ in pairs(ns.ITEMS or {}) do total = total + 1 end
    subTitle:SetText(string.format("|c%s%d Items · %d auf der Wunschliste|r", INK_DIM, total, wish))

    -- Filterknopf
    local lbl = "Alle Slots"
    for _, g in ipairs(SLOT_GROUPS) do if g.key == currentSlot then lbl = g.label end end
    slotBtn.text:SetText("|c" .. (currentSlot == "ALL" and INK or ACCENT) .. lbl .. "|r")

    -- Tabs
    for _, t in ipairs({ tabDungeon, tabRaid }) do
        local active = (currentTab == t.key)
        t.fill:SetColorTexture(SURFACE[1], SURFACE[2], SURFACE[3], active and 0.9 or 0.4)
        t.text:SetText("|c" .. (active and ACCENT or INK_DIM)
            .. (t.key == "DUNGEON" and "Dungeons" or "Raids") .. "|r")
        if active then
            local r, g, b = HexToRGB(ACCENT)
            t.underline:SetColorTexture(r, g, b, 0.9)
            t.underline:Show()
        else
            t.underline:Hide()
        end
    end

    -- Liste aufbauen
    for _, r in ipairs(rowPool)  do r:Hide() end
    for _, h in ipairs(headPool) do h:Hide() end

    local sources = BuildSources()
    local y, rowI, headI = 0, 0, 0
    local lastInstance = nil

    for _, src in ipairs(sources) do
        -- Instanz-Ueberschrift, sobald die Instanz wechselt. Nur sinnvoll,
        -- solange nach Instanz gruppiert wird. Da wir nach Wunsch-Anzahl
        -- sortieren, kann dieselbe Instanz mehrfach auftauchen, deshalb wird
        -- die Ueberschrift nur bei echtem Wechsel gesetzt.
        if src.instanceID ~= lastInstance then
            headI = headI + 1
            local h = GetHeader(headI)
            h:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            local iname = EJ_GetInstanceInfo and EJ_GetInstanceInfo(src.instanceID)
            h.text:SetText("|c" .. INK_DIM .. (iname or ("Instanz " .. src.instanceID)) .. "|r")
            h:Show()
            y = y + HEAD_H
            lastInstance = src.instanceID
        end

        rowI = rowI + 1
        local row = GetRow(rowI)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
        row:Show()

        local bname = EJ_GetEncounterInfo and EJ_GetEncounterInfo(src.encounterID)
        row.name:SetText("|c" .. INK .. (bname or ("Boss " .. src.encounterID)) .. "|r")
        row.badge:SetText(src.wish > 0 and ("|c" .. GREEN .. src.wish .. "|r") or "")
        row.fill:SetColorTexture(1, 1, 1, src.wish > 0 and 0.05 or 0.02)

        for _, b in pairs(row.icons) do b:Hide() end
        for i, itemID in ipairs(src.items) do
            local b = GetIcon(row, i)
            local rec = ns.ITEMS[itemID] or {}
            b.tex:SetTexture(rec.icon or 134400)   -- Fragezeichen als Rueckfall
            b:Show()

            local isWanted = Wanted(itemID)
            -- Nicht gewuenschte Items werden gedimmt, damit die Wunschliste
            -- sofort ins Auge faellt. Farbe traegt hier echte Bedeutung.
            b.tex:SetDesaturated(not isWanted)
            b.tex:SetAlpha(isWanted and 1 or 0.55)
            local er, eg, eb = HexToRGB(ACCENT)
            for _, t in ipairs(b.edges) do
                if isWanted then t:SetColorTexture(er, eg, eb, 0.9)
                else t:SetColorTexture(EDGE[1], EDGE[2], EDGE[3], 0.35) end
            end

            b:SetScript("OnClick", function()
                ToggleWanted(itemID)
                UI:Render()
            end)
            b:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetItemByID(itemID)
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(Wanted(itemID)
                    and "Klick entfernt von der Wunschliste"
                    or  "Klick setzt auf die Wunschliste", 0.65, 0.63, 0.58)
                GameTooltip:Show()
            end)
            b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end

        y = y + ROW_H + 2
    end

    if rowI == 0 then
        headI = headI + 1
        local h = GetHeader(headI)
        h:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -4)
        h.text:SetText("|c" .. INK_DIM .. "Keine Items für diesen Filter.|r")
        h:Show()
        y = HEAD_H
    end

    content:SetSize(WIDTH - PAD * 2 - 24, math.max(1, y))
end

function UI:Toggle()
    if frame:IsShown() then frame:Hide() else frame:Show(); UI:Render() end
end

function UI:RestorePosition()
    if SlotMachineDB.point then
        frame:ClearAllPoints()
        local ok = pcall(frame.SetPoint, frame, SlotMachineDB.point, UIParent,
            SlotMachineDB.relPoint, SlotMachineDB.x, SlotMachineDB.y)
        if not ok then frame:ClearAllPoints(); frame:SetPoint("CENTER") end
    end
end
