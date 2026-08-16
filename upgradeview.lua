-- ============================================================================
-- SlotMachine - Aufwertungsfenster (B4)
-- ============================================================================
--
-- Eine Zeile je Slot. Das ANGELEGTE Teil steht in einer festen Mittelspalte,
-- links davon absteigend die schwaecheren Teile aus dem Bestand, rechts davon
-- aufsteigend die besseren. So entsteht pro Zeile eine von links nach rechts
-- aufsteigende Reihe, und ueber alle Zeilen eine senkrechte Linie aus dem,
-- was man traegt.
--
-- WARUM UEBERHAUPT: Das Charakterfenster taugt zum Aussuchen nicht. Man muss
-- mit der Maus auf den Slot, Alt halten, dann klappt ein rasterfoermiges
-- Taschenfenster auf, und die Tooltips verdecken den halben Inhalt.
--
-- ABGRENZUNG: Diese Datei baut nur die ANSICHT. Sie rechnet nichts und scannt
-- nichts, sondern liest ns.Inventory.state. Rechtsklick zum Ausruesten ist C2,
-- die Einbettung als Reiter neben Dungeon und Raid ist C3. Deshalb steht das
-- Fenster vorerst allein und wird ueber /sm upgrade geoeffnet.

local AddonName, ns = ...

ns.UpgradeView = {}
local View = ns.UpgradeView

-- Design-Tokens identisch mit ui.lua, damit beide Fenster wie ein System
-- wirken. Bewusst kopiert statt importiert: ui.lua haelt sie als local.
local BG      = { 0.060, 0.080, 0.100, 0.97 }
local SURFACE = { 0.125, 0.125, 0.137 }
local EDGE    = { 0.467, 0.471, 0.482, 0.5 }
local ACCENT  = "ffe8c15a"
local INK     = "ffd6d2c8"
local INK_DIM = "ff8d887e"

-- Breite knapp an den Inhalt gelegt: Rand, Beschriftung, drei Icon-Plaetze
-- links, Mittelspalte, drei rechts, Rand. Die erste Fassung stand auf 720 und
-- war ueber 200 Pixel zu breit, das Fenster wirkte dadurch halb leer.
-- Zwei Icon-Plaetze mehr als frueher: Die Mittelspalte kann bei Ringen und
-- Schmuck zwei Teile breit sein, und rechts sollen trotzdem MAX_SIDE
-- Kandidaten Platz haben.
local WIDTH       = 392
local PAD         = 14
local ICON        = 28
local ICON_GAP    = 4
local LABEL_W     = 84     -- Spalte fuer den Slot-Namen

-- ZEILENHOEHE: Icon plus die Itemlevel-Zahl darunter plus Luft.
--
-- Erste Fassung stand auf 34 und war zu klein. Das Icon ist 28 hoch, die Zahl
-- haengt 11 Pixel darunter, macht 39 Pixel Inhalt in 34 Pixel Zeile. Ergebnis
-- im Spiel: Die Zahl jeder Zeile stanzte ins Icon der naechsten, und die
-- Ansicht sah aus wie ein durchgehender senkrechter Streifen statt wie
-- vierzehn Zeilen. Merksatz: Zeilenhoehe immer gegen den TATSAECHLICHEN
-- Inhalt rechnen, nicht gegen das Icon allein.
local LABEL_DROP  = 13              -- so weit haengt die Kennung unter dem Icon
local ROW_H       = ICON + LABEL_DROP + 9

local MAX_SIDE    = 3      -- hoechstens so viele Icons je Seite

-- Mittelspalte so weit rechts, dass MAX_SIDE Icons davor passen, und keinen
-- Pixel weiter. Vorher stand hier ein fester Wert von 300, der eine breite
-- leere Flaeche zwischen Beschriftung und Icons erzeugt hat.
local CENTER_X    = PAD + LABEL_W + MAX_SIDE * (ICON + ICON_GAP) + 8

local function AddEdges(f, alpha)
    local r, g, b = EDGE[1], EDGE[2], EDGE[3]
    local a = alpha or EDGE[4]
    local t = f:CreateTexture(nil, "BORDER")
    t:SetColorTexture(r, g, b, a); t:SetHeight(1)
    t:SetPoint("TOPLEFT"); t:SetPoint("TOPRIGHT")
    local b2 = f:CreateTexture(nil, "BORDER")
    b2:SetColorTexture(r, g, b, a); b2:SetHeight(1)
    b2:SetPoint("BOTTOMLEFT"); b2:SetPoint("BOTTOMRIGHT")
    local l = f:CreateTexture(nil, "BORDER")
    l:SetColorTexture(r, g, b, a); l:SetWidth(1)
    l:SetPoint("TOPLEFT", t, "BOTTOMLEFT"); l:SetPoint("BOTTOMLEFT", b2, "TOPLEFT")
    local r2 = f:CreateTexture(nil, "BORDER")
    r2:SetColorTexture(r, g, b, a); r2:SetWidth(1)
    r2:SetPoint("TOPRIGHT", t, "BOTTOMRIGHT"); r2:SetPoint("BOTTOMRIGHT", b2, "TOPRIGHT")
end

-- ----------------------------------------------------------------------------
-- Fenster
-- ----------------------------------------------------------------------------

local frame = CreateFrame("Frame", "SlotMachine_UpgradeFrame", UIParent)
frame:SetSize(WIDTH, 480)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:SetClampedToScreen(true)
frame:SetFrameStrata("HIGH")
frame:Hide()

local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(BG[1], BG[2], BG[3], BG[4])
AddEdges(frame)

local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOPLEFT", PAD, -PAD)
title:SetText("|c" .. ACCENT .. "Aufwertung|r")

local subtitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
subtitle:SetText("|c" .. INK_DIM .. "Angelegt in der Mitte, besser nach rechts|r")

local closeBtn = CreateFrame("Button", nil, frame)
closeBtn:SetSize(20, 20)
closeBtn:SetPoint("TOPRIGHT", -PAD, -PAD)
closeBtn.label = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
closeBtn.label:SetAllPoints()
closeBtn.label:SetText("|c" .. INK_DIM .. "X|r")
closeBtn:SetScript("OnClick", function() frame:Hide() end)
closeBtn:SetScript("OnEnter", function(self)
    self.label:SetText("|c" .. ACCENT .. "X|r")
end)
closeBtn:SetScript("OnLeave", function(self)
    self.label:SetText("|c" .. INK_DIM .. "X|r")
end)

-- Senkrechte Linie hinter der Mittelspalte. Sie ist der eigentliche Trick der
-- Ansicht: Alles links davon ist schlechter als das Getragene, alles rechts
-- davon besser. Das sieht man ohne eine einzige Zahl zu lesen.
local centerLine = frame:CreateTexture(nil, "ARTWORK")
centerLine:SetColorTexture(1, 1, 1, 0.10)
centerLine:SetWidth(ICON + 6)

local rows = {}

-- ----------------------------------------------------------------------------
-- Ein Item-Icon
-- ----------------------------------------------------------------------------

local function MakeIcon(parent)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(ICON, ICON)
    b.tex = b:CreateTexture(nil, "ARTWORK")
    b.tex:SetAllPoints()
    b.tex:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    -- Itemlevel in die untere rechte Ecke DES ICONS, wie WoW es bei
    -- Stapelgroessen macht. So bleibt der Platz unter dem Icon frei fuer die
    -- Track-Kennung, und beide passen nebeneinander in 32 Pixel Breite.
    b.lvl = b:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmall")
    b.lvl:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 1, 1)

    -- Track-Kennung darunter, im selben Format wie im Hauptfenster: "H 3/6"
    -- in der Farbe des Tracks.
    b.badge = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.badge:SetPoint("TOP", b, "BOTTOM", 0, -1)
    b:SetScript("OnEnter", function(self)
        if not self.link then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetHyperlink(self.link)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return b
end

local function FillIcon(b, item, isEquipped)
    b.link = item.link
    local icon = 134400   -- Fragezeichen als Rueckfall
    if item.itemID and C_Item and C_Item.GetItemIconByID then
        local ok, i = pcall(C_Item.GetItemIconByID, item.itemID)
        if ok and i then icon = i end
    end
    b.tex:SetTexture(icon)

    -- Angelegtes voll, Bestand leicht abgedunkelt. Der Blick soll zuerst auf
    -- die Mittelspalte fallen.
    b.tex:SetDesaturated(false)
    b.tex:SetAlpha(isEquipped and 1.0 or 0.82)

    -- Itemlevel schlicht in Weiss auf dem Icon. Die Farbe traegt die Kennung
    -- darunter, sonst konkurrieren zwei eingefaerbte Zahlen um denselben Blick.
    b.lvl:SetText(tostring(item.ilvl or "?"))

    -- Kennung im Format des Hauptfensters. Ohne erkannten Track bleibt die
    -- Zeile leer statt "?" zu zeigen: Ein Teil ohne aktuellen Track ist nicht
    -- aufwertbar, da gibt es schlicht keinen Rang zu nennen.
    b.badge:SetText(ns.TrackBadge and ns.TrackBadge(item.track, item.rank) or "")
    b:Show()
end

-- ----------------------------------------------------------------------------
-- Aufbau
-- ----------------------------------------------------------------------------

function View:Refresh()
    local Inv = ns.Inventory
    if not Inv then return end

    local st       = Inv.state or {}
    local equipped = st.equipped or {}
    local bag      = st.bag or {}
    local groups   = Inv.GroupOrder and Inv:GroupOrder() or nil
    if not groups then return end

    -- Bestand nach Slot-Gruppe sortieren
    local byGroup = {}
    for _, it in ipairs(bag) do
        local g = Inv:GroupOf(it.equipLoc)
        if g then
            byGroup[g] = byGroup[g] or {}
            table.insert(byGroup[g], it)
        end
    end

    local y = -(PAD + 42)
    local shown, withHigher = 0, 0

    for idx, grp in ipairs(groups) do
        local row = rows[idx]
        if not row then
            row = CreateFrame("Frame", nil, frame)
            row:SetHeight(ROW_H)

            -- Jede zweite Zeile leicht abgesetzt. Ohne das verschwimmen
            -- vierzehn gleich aussehende Zeilen zu einem Block, und man
            -- verliert beim Lesen die Spur zur Beschriftung.
            row.stripe = row:CreateTexture(nil, "BACKGROUND")
            row.stripe:SetAllPoints()
            row.stripe:SetColorTexture(1, 1, 1, (idx % 2 == 0) and 0.025 or 0)

            row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.label:SetPoint("LEFT", row, "LEFT", PAD, 0)
            row.label:SetJustifyH("LEFT")
            row.label:SetWidth(LABEL_W)
            -- Mittelspalte als LISTE, nicht als einzelnes Icon.
            --
            -- Ringe, Schmuck und Waffen belegen zwei Plaetze. Die erste
            -- Fassung zeigte dort nur das schwaechere der beiden, damit war
            -- die Haelfte der getragenen Ausruestung unsichtbar. Jetzt stehen
            -- beide nebeneinander, das schwaechere zuerst, weil genau das
            -- ersetzt wuerde.
            row.left, row.right, row.center = {}, {}, {}
            for i = 1, 2 do
                local c = MakeIcon(row)
                c:SetPoint("LEFT", row, "LEFT", CENTER_X + (i - 1) * (ICON + ICON_GAP), 0)
                row.center[i] = c
            end

            -- Hinweis fuer Zeilen ohne Bestand. Sonst wirkt eine leere Zeile
            -- wie ein Fehler statt wie "hier gibt es nichts zu tun".
            row.hint = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.hint:SetPoint("LEFT", row.center, "RIGHT", ICON_GAP + 4, 0)
            row.hint:SetJustifyH("LEFT")

            rows[idx] = row
        end
        row:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, y)
        row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, y)
        row:Show()

        row.label:SetText("|c" .. INK .. grp.label .. "|r")

        -- Alle angelegten Teile dieser Gruppe, schwaechstes zuerst.
        local worn = {}
        for _, slotID in ipairs(grp.slots) do
            local it = equipped[slotID]
            if it and it.ilvl then worn[#worn + 1] = it end
        end
        table.sort(worn, function(a, b) return a.ilvl < b.ilvl end)

        -- Vergleichswert bleibt das SCHWAECHSTE, weil genau das ersetzt wuerde.
        local eq = worn[1]

        for i = 1, 2 do
            local c = row.center[i]
            if worn[i] then
                FillIcon(c, worn[i], true)
            elseif i == 1 then
                -- Leerer Slot: Platzhalter, damit die Spalte nicht ausfranst
                c.link = nil
                c.tex:SetTexture(134400)
                c.tex:SetAlpha(0.25)
                c.lvl:SetText("")
                c.badge:SetText("")
                c:Show()
            else
                c:Hide()
            end
        end
        local centerCount = math.max(#worn, 1)

        -- Bestand aufteilen. Nur Teile mit erkanntem Track, alles andere ist
        -- nicht aufwertbar und damit hier bedeutungslos.
        --
        -- GLEICHES Itemlevel gehoert nach links, nicht ins Nichts. Die erste
        -- Fassung kannte nur groesser und kleiner; ein Teil mit exakt dem
        -- gleichen Itemlevel fiel aus beiden Zweigen und verschwand. Es ist
        -- kein Upgrade, aber eine Alternative mit womoeglich besseren
        -- Sekundaerstats und gehoert damit gezeigt.
        local lower, higher = {}, {}
        for _, it in ipairs(byGroup[grp.key] or {}) do
            if it.track and it.ilvl and eq and eq.ilvl then
                if it.ilvl > eq.ilvl then
                    higher[#higher + 1] = it
                else
                    lower[#lower + 1] = it
                end
            end
        end
        table.sort(lower,  function(a, b) return a.ilvl > b.ilvl end)  -- naechstbestes zuerst
        table.sort(higher, function(a, b) return a.ilvl < b.ilvl end)  -- aufsteigend nach rechts

        -- Links: absteigend nach aussen
        for i = 1, MAX_SIDE do
            local b = row.left[i]
            if not b then
                b = MakeIcon(row)
                b:SetPoint("RIGHT", row, "LEFT", CENTER_X - (i - 1) * (ICON + ICON_GAP) - ICON_GAP, 0)
                row.left[i] = b
            end
            if lower[i] then FillIcon(b, lower[i], false) else b:Hide() end
        end

        -- Rechts: aufsteigend nach aussen. Der Startpunkt haengt davon ab, ob
        -- die Mittelspalte ein oder zwei Icons breit ist, sonst ueberlappen
        -- die Kandidaten bei Ringen und Schmuck das zweite getragene Teil.
        for i = 1, MAX_SIDE do
            local b = row.right[i]
            if not b then
                b = MakeIcon(row)
                row.right[i] = b
            end
            b:ClearAllPoints()
            b:SetPoint("LEFT", row, "LEFT",
                CENTER_X + (centerCount + i - 1) * (ICON + ICON_GAP), 0)
            if higher[i] then FillIcon(b, higher[i], false) else b:Hide() end
        end

        -- Der Hinweis je Zeile ist wieder raus.
        --
        -- Im Spiel stand er in vierzehn von vierzehn Zeilen und war damit
        -- reines Rauschen: Wenn ueberall dasselbe steht, sagt es nichts mehr.
        -- Stattdessen eine einzige Zeile unten, wenn wirklich nirgends etwas
        -- liegt. Faustregel: Ein Hinweis, der immer erscheint, ist keiner.
        row.hint:SetText("")
        row.hint:Hide()
        if #higher > 0 then withHigher = withHigher + 1 end

        y = y - ROW_H
        shown = shown + 1
    end

    -- Ueberzaehlige Zeilen ausblenden, falls die Gruppenliste je schrumpft
    for i = shown + 1, #rows do rows[i]:Hide() end

    local height = PAD + 42 + shown * ROW_H + PAD
    frame:SetHeight(height)
    -- Linie mittig hinter der Icon-Spalte, nicht am linken Rand des Icons.
    centerLine:SetPoint("TOP", frame, "TOPLEFT", CENTER_X + ICON / 2 + 1, -(PAD + 42))
    centerLine:SetHeight(shown * ROW_H)

    -- Eine Statuszeile statt vierzehn gleichlautender Hinweise
    if not st.stamp then
        subtitle:SetText("|c" .. INK_DIM .. "Bestand wird noch erfasst ...|r")
    elseif not st.complete then
        subtitle:SetText("|c" .. INK_DIM .. "Daten noch unvollständig, gleich mehr|r")
    elseif withHigher == 0 then
        subtitle:SetText("|c" .. INK_DIM .. "In keinem Slot liegt etwas Aufwertbares über dem Angelegten|r")
    elseif withHigher == 1 then
        subtitle:SetText("|c" .. ACCENT .. "1 Slot|r|c" .. INK_DIM .. " hat etwas Besseres im Bestand|r")
    else
        subtitle:SetText("|c" .. ACCENT .. withHigher .. " Slots|r|c" .. INK_DIM .. " haben etwas Besseres im Bestand|r")
    end
end

-- Auf Aenderungen am Bestand hoeren und neu zeichnen, solange das Fenster
-- offen ist.
--
-- WARUM DAS NOETIG IST: Ohne diese Anmeldung zeigt das Fenster den Stand vom
-- Oeffnungszeitpunkt und bleibt darauf stehen. Am 16.08.2026 fehlte deshalb
-- ein Kandidat an der Taille, der nachweislich in der Tasche lag: Beim
-- Oeffnen war der Bestand noch nicht fertig geladen, und danach hat niemand
-- mehr neu gezeichnet.
function View:Init()
    if not ns.Inventory or not ns.Inventory.Subscribe then return end
    ns.Inventory:Subscribe(function()
        if frame:IsShown() then View:Refresh() end
    end)
end

function View:Toggle()
    if frame:IsShown() then
        frame:Hide()
    else
        self:Refresh()
        frame:Show()
        -- Beim Oeffnen einmal anstossen. Kostet nichts, wenn der Stand frisch
        -- ist, und holt ihn nach, falls er es nicht war.
        if ns.Inventory and ns.Inventory.Update then ns.Inventory:Update() end
    end
end

function View:IsShown() return frame:IsShown() end
