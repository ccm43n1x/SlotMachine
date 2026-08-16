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
local WIDTH       = 420
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

    -- ALLE Icons stehen bei voller Deckkraft. Alte Ware wird ENTSAETTIGT.
    --
    -- Zwei Irrwege bis hierher, beide am 16.08.2026:
    --
    -- 1. Erst wurde alles abgedunkelt, was nicht angelegt war. Falsche Achse:
    --    Der Grossteil dieser Icons sind vollwertige Kandidaten.
    --
    -- 2. Dann nur noch alte Ware, aber weiterhin ueber die Deckkraft. Das
    --    Grundproblem blieb, und es liegt in der Methode selbst: Deckkraft
    --    senken heisst, den dunklen Fensterhintergrund durchscheinen zu
    --    lassen. Das ergibt keinen "zurueckgenommenen" Gegenstand, sondern
    --    einen grauen Schleier ueber der ganzen Ansicht.
    --
    -- Entsaettigung ist das richtige Mittel. Sie nimmt die Farbe, nicht die
    -- Helligkeit: Das Icon bleibt klar erkennbar und tritt trotzdem sichtbar
    -- hinter allem Farbigen zurueck. WoW benutzt dieselbe Sprache fuer
    -- nicht verfuegbare Faehigkeiten.
    b.tex:SetAlpha(1.0)
    local isCurrent = isEquipped or (item.track ~= nil)
    b.tex:SetDesaturated(not isCurrent)

    -- Itemlevel in der Farbe des Tracks.
    --
    -- Erst stand es in Weiss, mit dem Gedanken, zwei eingefaerbte Zahlen
    -- wuerden konkurrieren. Das war falsch gedacht: Farbe und Kennung sagen
    -- dasselbe und verstaerken sich. Wichtiger noch, bei alten Teilen OHNE
    -- Kennung ist die Farbe die einzige Information, die bleibt.
    --
    -- Altcontent bekommt deshalb ein gedaempftes Grau. Es soll lesbar sein,
    -- aber nicht um Aufmerksamkeit buhlen.
    local lvlColor = INK_DIM
    if item.track and ns.TRACKS[item.track] then
        lvlColor = ns.TRACKS[item.track].color
    end
    b.lvl:SetText("|c" .. lvlColor .. tostring(item.ilvl or "?") .. "|r")

    -- Kennung im Format des Hauptfensters. Ohne erkannten Track bleibt die
    -- Zeile leer statt "?" zu zeigen: Ein Teil ohne aktuellen Track ist nicht
    -- aufwertbar, da gibt es schlicht keinen Rang zu nennen.
    b.badge:SetText(ns.TrackBadge and ns.TrackBadge(item.track, item.rank) or "")
    b:Show()
end

-- ----------------------------------------------------------------------------
-- Aufbau
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- Anzeigezeilen aufbauen
-- ----------------------------------------------------------------------------
-- Ringe, Schmuck und Waffen belegen zwei Plaetze. Sie bekommen deshalb ZWEI
-- Zeilen, damit jedes getragene Teil einzeln sichtbar ist.
--
-- Die Kandidaten aus dem Bestand stehen aber nur EINMAL, senkrecht mittig
-- zwischen den beiden Zeilen. Sie gelten fuer beide Plaetze, doppelt gezeigt
-- waeren sie eine Behauptung, die nicht stimmt.
local function BuildDisplayRows(groups)
    local out = {}
    for _, grp in ipairs(groups) do
        local n = #grp.slots
        for i, slotID in ipairs(grp.slots) do
            out[#out + 1] = {
                label   = (n > 1) and string.format("%s %d", grp.label, i) or grp.label,
                key     = grp.key,
                slot    = slotID,
                slots   = grp.slots,   -- fuer den Gruppen-Vergleichswert
                anchor  = (i == 1),    -- nur hier werden Kandidaten gezeichnet
                span    = n,
            }
        end
    end
    return out
end

function View:Refresh()
    local Inv = ns.Inventory
    if not Inv then return end

    local st       = Inv.state or {}
    local equipped = st.equipped or {}
    local bag      = st.bag or {}
    local groups   = Inv.GroupOrder and Inv:GroupOrder() or nil
    if not groups then return end

    -- Hoechstes getragenes Itemlevel als Massstab fuer die Plausibilitaet.

    -- Bestand nach Slot-Gruppe
    local byGroup = {}
    for _, it in ipairs(bag) do
        local g = Inv:GroupOf(it.equipLoc)
        if g then
            byGroup[g] = byGroup[g] or {}
            table.insert(byGroup[g], it)
        end
    end

    local display = BuildDisplayRows(groups)
    local y = -(PAD + 42)
    local shown, withHigher = 0, 0
    local seenGroup = {}

    for idx, d in ipairs(display) do
        local row = rows[idx]
        if not row then
            row = CreateFrame("Frame", nil, frame)
            row:SetHeight(ROW_H)
            row.stripe = row:CreateTexture(nil, "BACKGROUND")
            row.stripe:SetAllPoints()
            row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.label:SetPoint("LEFT", row, "LEFT", PAD, 0)
            row.label:SetJustifyH("LEFT")
            row.label:SetWidth(LABEL_W)
            row.center = MakeIcon(row)
            row.center:SetPoint("LEFT", row, "LEFT", CENTER_X, 0)
            row.left, row.right = {}, {}

            -- Anzeiger fuer Abgeschnittenes. Die Zeile zeigt hoechstens
            -- MAX_SIDE Icons je Seite; was darueber hinaus liegt, wuerde sonst
            -- stillschweigend verschwinden. Das widerspricht der Regel, dass
            -- Ausgeblendetes benannt wird.
            row.moreL = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.moreL:SetPoint("RIGHT", row, "LEFT",
                CENTER_X - MAX_SIDE * (ICON + ICON_GAP) - 2, 0)
            row.moreR = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            row.moreR:SetJustifyH("LEFT")

            rows[idx] = row
        end
        row:SetPoint("TOPLEFT",  frame, "TOPLEFT",  0, y)
        row:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, y)
        row.stripe:SetColorTexture(1, 1, 1, (idx % 2 == 0) and 0.025 or 0)
        row:Show()
        row.label:SetText("|c" .. INK .. d.label .. "|r")

        -- Getragenes Teil dieser Zeile
        local worn = equipped[d.slot]
        if worn then
            FillIcon(row.center, worn, true)
        else
            row.center.link = nil
            row.center.tex:SetTexture(134400)
            row.center.tex:SetAlpha(0.25)
            row.center.lvl:SetText("")
            row.center.badge:SetText("")
            row.center:Show()
        end

        -- Vergleichswert der GRUPPE: das schwaechste getragene Teil, denn
        -- genau das wuerde ersetzt.
        local ref
        for _, sid in ipairs(d.slots) do
            local it = equipped[sid]
            if it and it.ilvl then
                if not ref or it.ilvl < ref then ref = it.ilvl end
            end
        end

        local lower, higher = {}, {}
        if d.anchor then
            for _, it in ipairs(byGroup[d.key] or {}) do
                -- Season-Spanne statt Track-Filter.
                --
                -- Season-1-Ware SOLL sichtbar sein, man kann sie ja tragen.
                -- Sie traegt nur keine Kennung und faellt aus der
                -- Aufwertungs-Logik heraus. Draussen bleibt, was ausserhalb
                -- der Itemlevel-Spanne der laufenden Season liegt: nach oben
                -- der Altcontent auf fremder Skala (ilvl 518, 528), nach unten
                -- alles unterhalb von Adventurer 1/6, etwa ein Ring mit 103.
                --
                -- Grenzen stehen in tracks.lua, weil sie Season-Daten sind.
                local lo = ns.SEASON_ILVL_MIN or 0
                local hi = ns.SEASON_ILVL_MAX or 9999
                local inRange = it.ilvl and it.ilvl >= lo and it.ilvl <= hi
                if inRange and ref then
                    if it.ilvl > ref then
                        higher[#higher + 1] = it
                    else
                        lower[#lower + 1] = it
                    end
                end
            end
            table.sort(lower,  function(a, b) return a.ilvl > b.ilvl end)
            table.sort(higher, function(a, b) return a.ilvl < b.ilvl end)

            if #higher > 0 and not seenGroup[d.key] then
                withHigher = withHigher + 1
                seenGroup[d.key] = true
            end
        end

        -- Bei zwei Zeilen sitzen die Kandidaten senkrecht mittig dazwischen.
        local drop = -(d.span - 1) * ROW_H / 2

        for i = 1, MAX_SIDE do
            local b = row.left[i]
            if not b then b = MakeIcon(row); row.left[i] = b end
            b:ClearAllPoints()
            b:SetPoint("RIGHT", row, "LEFT",
                CENTER_X - (i - 1) * (ICON + ICON_GAP) - ICON_GAP, drop)
            if lower[i] then FillIcon(b, lower[i], false) else b:Hide() end
        end

        for i = 1, MAX_SIDE do
            local b = row.right[i]
            if not b then b = MakeIcon(row); row.right[i] = b end
            b:ClearAllPoints()
            b:SetPoint("LEFT", row, "LEFT",
                CENTER_X + i * (ICON + ICON_GAP), drop)
            if higher[i] then FillIcon(b, higher[i], false) else b:Hide() end
        end

        -- Was nicht mehr passt, wird beziffert statt verschluckt. Die Pfeile
        -- zeigen nach aussen, also in die Richtung, in der es weitergeht.
        local restL = math.max(0, #lower  - MAX_SIDE)
        local restR = math.max(0, #higher - MAX_SIDE)
        -- Guillemets statt Dreieckspfeilen. Das Zeichen U+25C2 gibt es in WoWs
        -- Schriftart nicht und wurde am 16.08.2026 als leeres Kaestchen
        -- gerendert. « und » liegen in Latin-1 und sind sicher vorhanden.
        row.moreL:SetText(restL > 0 and ("|c" .. INK_DIM .. "«" .. restL .. "|r") or "")
        row.moreR:ClearAllPoints()
        row.moreR:SetPoint("LEFT", row, "LEFT",
            CENTER_X + (MAX_SIDE + 1) * (ICON + ICON_GAP) + 2, drop)
        row.moreR:SetText(restR > 0 and ("|c" .. INK_DIM .. restR .. "»|r") or "")

        y = y - ROW_H
        shown = shown + 1
    end

    for i = shown + 1, #rows do rows[i]:Hide() end

    local height = PAD + 42 + shown * ROW_H + PAD
    frame:SetHeight(height)
    centerLine:SetPoint("TOP", frame, "TOPLEFT", CENTER_X + ICON / 2 + 1, -(PAD + 42))
    centerLine:SetHeight(shown * ROW_H)

    if not st.stamp then
        subtitle:SetText("|c" .. INK_DIM .. "Bestand wird noch erfasst ...|r")
    elseif not st.complete then
        subtitle:SetText("|c" .. INK_DIM .. "Daten noch unvollständig, gleich mehr|r")
    elseif withHigher == 0 then
        subtitle:SetText("|c" .. INK_DIM .. "In keinem Slot liegt etwas Besseres im Bestand|r")
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
