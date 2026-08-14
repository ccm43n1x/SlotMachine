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

-- SavedVariables hier absichern, NICHT erst in main.lua.
--
-- Grund, gelernt am 14.08.2026: Die .toc laedt ui.lua VOR main.lua, und
-- main.lua ist die Datei, die SlotMachineDB anlegt. Diese Datei greift aber
-- schon beim Laden auf die Datenbank zu, naemlich wenn die Options-Schalter
-- erzeugt werden und ihren Anfangszustand lesen. Ergebnis war ein Abbruch mit
-- "attempt to index global 'SlotMachineDB' (a nil value)" mitten in der Datei.
--
-- Die Folge war heimtueckisch: ns.UI existierte, war aber leer, weil der
-- Abbruch VOR der Definition von UI:Toggle passierte. Das Fenster liess sich
-- dadurch weder per Slash-Befehl noch ueber den Minimap-Knopf oeffnen,
-- obwohl beides fehlerfrei aussah.
--
-- Regel daraus: Jede Datei, die auf SavedVariables zugreift, sichert sie
-- selbst ab. Verlass dich nie auf die Ladereihenfolge der .toc.
SlotMachineDB     = SlotMachineDB or {}
SlotMachineCharDB = SlotMachineCharDB or {}

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

-- Breite muss die komplette Filterleiste tragen: Slot, zwei Reiter, Spec und
-- Quelle nebeneinander. Die Hoehe ist nur der Startwert, sie wird nach jedem
-- Aufbau an den Inhalt angepasst (siehe FitHeight).
-- 780 statt 720: Die Filterleiste braucht 748 Pixel fuer Slot, zwei Reiter,
-- Spec, Quelle und den Bonus-Roll-Haken. Der Rest kommt den Icon-Reihen zugute.
local WIDTH, HEIGHT = 830, 560
local MIN_HEIGHT, MAX_HEIGHT = 220, 780
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

-- ----------------------------------------------------------------------------
-- Menues schliessen sich, sobald die Maus sie verlaesst
-- ----------------------------------------------------------------------------
-- Vorher blieben sie offen, bis irgendwo hineingeklickt wurde. Das fuehrte zu
-- einem verwirrenden Zustand: Man klickt daneben, etwa auf den Raid-Reiter,
-- der Inhalt dahinter aendert sich, aber das offene Menue zeigt weiter die
-- alte Liste. Es sieht dann so aus, als reagiere das Add-on nicht.
--
-- Die Verzoegerung ist noetig, weil zwischen Knopf und Menue eine kleine
-- Luecke liegt. Ohne sie schnappt das Menue zu, waehrend man mit der Maus
-- hinueberfaehrt.
local AUTO_HIDE_DELAY = 0.4

local function AutoHide(menu, owner, extras)
    menu.hideTimer = 0
    menu:HookScript("OnShow", function(self) self.hideTimer = 0 end)
    menu:SetScript("OnUpdate", function(self, elapsed)
        if not self:IsShown() then return end

        local over = self:IsMouseOver() or (owner and owner:IsMouseOver())
        if not over and extras then
            for _, f in ipairs(extras) do
                if f and f:IsShown() and f:IsMouseOver() then
                    over = true
                    break
                end
            end
        end

        if over then
            self.hideTimer = 0
            return
        end

        self.hideTimer = self.hideTimer + elapsed
        if self.hideTimer > AUTO_HIDE_DELAY then
            self:Hide()
            if extras then
                for _, f in ipairs(extras) do if f then f:Hide() end end
            end
        end
    end)
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
-- Zustand
-- ----------------------------------------------------------------------------
-- STEHT BEWUSST GANZ OBEN, vor jeder Verwendung.
--
-- Diese Variablen standen urspruenglich weiter unten, wurden aber schon in
-- SourceList und CurrentSource benutzt. Dort loeste der Name deshalb auf eine
-- nicht existierende GLOBALE Variable auf, und "currentTab == RAID" war
-- grundsaetzlich falsch. Folge: Der Raid-Tab war korrekt markiert, weil das
-- Rendering weiter unten die echte lokale Variable liest, aber das Dropdown
-- zeigte hartnaeckig die Dungeon-Liste.
--
-- Das ist derselbe Fehler, der am 14.08.2026 viermal zugeschlagen hat: einmal
-- bei ApplyAlpha in Chrissi's Addon, einmal bei MenuEntry, einmal bei rollBtn
-- und hier. In Lua gilt eine lokale Variable erst AB ihrer Deklaration, alles
-- davor greift stillschweigend auf eine Globale zu. Es gibt keine Warnung.
local currentTab   = "DUNGEON"  -- oder "RAID"
local currentSlot  = "ALL"
local currentSpec  = nil        -- nil heisst: alle Spezialisierungen
local currentClass = nil        -- gesetzt, wenn eine ganze Klasse gewaehlt ist

-- ----------------------------------------------------------------------------
-- Item Level
-- ----------------------------------------------------------------------------
-- Keystone Loot zeigt das Itemlevel ABSOLUT an: "dieses Teil hat 311". Die
-- Frage, die man sich beim Loot-Planen aber wirklich stellt, ist eine andere:
-- "ist das besser als das, was ich gerade anhabe?" Dort muss man das im Kopf
-- machen, Slot fuer Slot.
--
-- SlotMachine zeigt deshalb standardmaessig die DIFFERENZ zum eigenen Item.
-- Das absolute Itemlevel gibt es als Option in den Einstellungen.
--
-- Die Technik mit den Bonus-IDs, mit der Keystone Loot den Tooltip auf ein
-- Ziel-Niveau hebt, ist bewusst nicht uebernommen. Sie braucht eine gepflegte
-- Tabelle von Bonus-IDs je Season. Fuer den Vergleich reicht das Basis-Level,
-- das der Client selbst liefert.

-- equipLoc auf die Ausruestungsplaetze der Spielfigur. Ringe, Schmuck und
-- Waffen haben zwei Plaetze, deshalb Listen.
local EQUIP_SLOTS = {
    INVTYPE_HEAD = { 1 }, INVTYPE_NECK = { 2 }, INVTYPE_SHOULDER = { 3 },
    INVTYPE_CHEST = { 5 }, INVTYPE_ROBE = { 5 },
    INVTYPE_WAIST = { 6 }, INVTYPE_LEGS = { 7 }, INVTYPE_FEET = { 8 },
    INVTYPE_WRIST = { 9 }, INVTYPE_HAND = { 10 },
    INVTYPE_FINGER = { 11, 12 }, INVTYPE_TRINKET = { 13, 14 },
    INVTYPE_CLOAK = { 15 },
    INVTYPE_WEAPON = { 16, 17 }, INVTYPE_2HWEAPON = { 16 },
    INVTYPE_WEAPONMAINHAND = { 16 },
    INVTYPE_RANGED = { 16 }, INVTYPE_RANGEDRIGHT = { 16 },
    INVTYPE_SHIELD = { 17 }, INVTYPE_HOLDABLE = { 17 },
}

-- Welche Quelle ist gerade gewaehlt? Getrennt fuer Dungeon und Raid, weil die
-- Stufen dort nichts miteinander zu tun haben.
local function SourceList()
    if currentTab == "RAID" then return ns.SOURCES_RAID or {} end
    return ns.SOURCES_DUNGEON or {}
end

local function CurrentSource()
    local list = SourceList()
    local key  = (currentTab == "RAID") and SlotMachineDB.raidSource or SlotMachineDB.dungeonSource
    for _, s in ipairs(list) do
        if s.key == key then return s end
    end

    -- Kein Treffer. Passiert, wenn in der gespeicherten Einstellung ein
    -- Schluessel der jeweils ANDEREN Liste steht, etwa nach einem Umbau der
    -- Stufen. Dann auf den ersten Eintrag zurueckfallen UND die Einstellung
    -- gleich geradeziehen, sonst bleibt sie dauerhaft falsch.
    local first = list[1]
    if first then
        if currentTab == "RAID" then
            SlotMachineDB.raidSource = first.key
        else
            SlotMachineDB.dungeonSource = first.key
        end
    end
    return first
end

-- forTab wird vom Menue mitgegeben.
--
-- Ohne diesen Parameter wurde der Tab erst beim KLICK geprueft, nicht beim
-- Bauen des Menues. Wechselte man den Tab bei offenem Menue, landete ein
-- Raid-Schluessel in der Dungeon-Einstellung. In den gespeicherten Daten stand
-- dann dungeonSource = "heroic", ein Wert den die Dungeon-Liste gar nicht
-- kennt, und die Anzeige fiel stumm auf den ersten Eintrag zurueck.
local function SetCurrentSource(key, forTab)
    local tab = forTab or currentTab
    if tab == "RAID" then
        SlotMachineDB.raidSource = key
    else
        SlotMachineDB.dungeonSource = key
    end
end

-- Aufgeloeste Quelle, an EINER Stelle. Vorher stand die Bonus-Roll-Pruefung an
-- vier Stellen im Code, was auseinanderdriftet sobald sich die Regel aendert.
-- Beruecksichtigt auch, dass es fuer manche Stufen gar keinen Roll gibt.
local function ResolvedCurrent()
    if not ns.ResolveSource then return nil end
    local src = CurrentSource()
    local useRoll = SlotMachineDB.bonusRoll and ns.HasBonusRoll(src)
    return ns.ResolveSource(src, useRoll), src
end

-- Auf einen konkreten Boss angepasst. Im Raid weicht das Itemlevel je Boss ab,
-- spaetere droppen weiter oben im Track.
local function ResolvedForBoss(encounterID)
    local res, src = ResolvedCurrent()
    if not res or not encounterID or not ns.BossAdjust then return res end

    -- Beim Bonus Roll NICHT auf den Boss anpassen.
    --
    -- Der Roll liefert die Belohnung der Grossen Schatzkammer, und die haengt
    -- allein an der Schwierigkeit, nicht daran welchen Boss man legt. Die
    -- bossabhaengige Staffelung gilt nur fuer direkte Drops.
    --
    -- Vorher wurde beides hintereinander angewandt: ResolveSource lieferte
    -- korrekt Myth 6/6, danach setzte BossAdjust den Rang wieder auf den des
    -- Bosses zurueck. Auf Mythisch aenderte der Bonus Roll deshalb gar nichts.
    local useRoll = SlotMachineDB.bonusRoll and ns.HasBonusRoll(src)
    if useRoll then return res end

    return ns.BossAdjust(res, encounterID, ns.TrackKeyOf(src, false))
end

-- Itemlevel des Items auf dem gewaehlten Niveau. Ohne Track-Auswahl faellt es
-- auf das Basis-Level zurueck, das der Client kennt.
local function ItemLevelOf(itemID, encounterID)
    local resolved = ResolvedForBoss(encounterID)
    if resolved and resolved.ilvl then return resolved.ilvl end
    if not (C_Item and C_Item.GetDetailedItemLevelInfo) then return nil end
    local ok, ilvl = pcall(C_Item.GetDetailedItemLevelInfo, itemID)
    return ok and ilvl or nil
end

-- Itemlevel des angelegten Teils im passenden Slot.
--
-- Bei Doppelplaetzen (Ringe, Schmuck, Einhandwaffen) zaehlt das SCHWAECHERE
-- der beiden. Das ist das Teil, das man ersetzen wuerde, und nur gegen dieses
-- ist der Vergleich ehrlich. Gegen den Durchschnitt oder das bessere zu
-- rechnen wuerde echte Upgrades verstecken.
local function EquippedLevelFor(itemID)
    local rec = ns.ITEMS and ns.ITEMS[itemID]
    if not rec or not rec.e then return nil end
    local loc = ns.EQUIP and ns.EQUIP[rec.e]
    local slots = loc and EQUIP_SLOTS[loc]
    if not slots then return nil end

    local worst, empty = nil, false
    for _, slotID in ipairs(slots) do
        local link = GetInventoryItemLink and GetInventoryItemLink("player", slotID)
        if link then
            local ok, ilvl = pcall(C_Item.GetDetailedItemLevelInfo, link)
            if ok and ilvl and (not worst or ilvl < worst) then worst = ilvl end
        else
            empty = true
        end
    end

    -- Leerer Platz.
    --
    -- Die erste Fassung gab hier 0 zurueck, "alles ist besser als nichts".
    -- Rechnerisch stimmt das, in der Anzeige stand dann aber +292 am Item, und
    -- das liest sich wie ein gewaltiges Upgrade statt wie ein leerer Slot.
    -- Betroffen war vor allem die Nebenhand, die bei Zweihandwaffen frei ist.
    --
    -- nil bedeutet: kein sinnvoller Vergleich moeglich. Die Anzeige zeigt dann
    -- das absolute Itemlevel statt einer Differenz.
    if empty and not worst then return nil end
    return worst
end

-- ----------------------------------------------------------------------------
-- Raid oder Dungeon?
-- ----------------------------------------------------------------------------
-- Steht nicht in den Daten, weil der Scan es nicht mitgeschrieben hat. Statt
-- deswegen neu zu scannen, wird die Liste einmal beim ersten Aufbau aus dem
-- Journal geholt. Kostet zwei Schleifen und ist danach im Speicher.

-- Reihenfolge der Bosse innerhalb einer Instanz.
--
-- Die encounterID taugt dafuer NICHT. Im Venomous Abyss traegt der erste Boss
-- die 2888, waehrend die hoehere 2894 zu einem spaeteren gehoert. Nach ID zu
-- sortieren wuerde den Raid also durcheinanderwerfen.
--
-- Das Encounter Journal listet die Bosse dagegen in der Reihenfolge, in der
-- man sie trifft. Dieser Index wird einmal eingesammelt und danach als
-- Sortierschluessel benutzt.
local encounterOrder = nil
local function EncounterIndex(instanceID, encounterID)
    if not encounterOrder then
        encounterOrder = {}
        for _, isRaid in ipairs({ true, false }) do
            local i = 1
            while true do
                local ok, instID = pcall(EJ_GetInstanceByIndex, i, isRaid)
                if not ok or not instID then break end
                local j = 1
                while true do
                    local ok2, _, _, encID = pcall(EJ_GetEncounterInfoByIndex, j, instID)
                    if not ok2 or not encID then break end
                    encounterOrder[encID] = j
                    j = j + 1
                    if j > 30 then break end
                end
                i = i + 1
                if i > 60 then break end
            end
        end
    end
    return encounterOrder[encounterID] or 99
end

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
-- Wunschliste mit Abstufung
-- ----------------------------------------------------------------------------
-- Vier Stufen statt einem Ja/Nein, Vorbild Keystone Loot.
--
-- Der Grund ist nicht Kosmetik, sondern die Sortierung: Wird nur GEZAEHLT,
-- steht ein Boss mit drei "waere ganz nett" ueber einem mit einem "Best in
-- Slot". Mit Gewichten bildet die Rangfolge ab, wo wirklich am meisten drin
-- ist. Das ist der Kern dieses Add-ons, also muss er stimmen.
--
-- Transmog zaehlt bewusst 0: Es ist ein Sammelziel, kein Fortschritt. Wer nur
-- Aussehen sucht, soll die Farm-Prioritaet nicht verzerren. Markiert wird es
-- trotzdem, damit man beim Run daran denkt.
--
-- Farbwahl: Jede Stufe traegt zusaetzlich ein eigenes ZEICHEN. Farbe ist nie
-- die einzige Information, gleiche Regel wie bei den Blockfarben in Chrissi's
-- Addon. Wer Rot und Gruen nicht unterscheiden kann, liest die Stufe am
-- Symbol ab.

-- Farben sind Blizzards eigene Qualitaetsfarben, von hoch nach niedrig:
-- Legendaer orange, Episch lila, Selten blau, Ungewoehnlich gruen, Schlecht
-- grau. Jeder WoW-Spieler liest diese Rangfolge ohne Legende, weil er sie seit
-- Jahren aus jedem Tooltip kennt. Eine eigene Palette muesste man erst lernen.
--
-- Die Zeichen bleiben im Code, werden aber standardmaessig NICHT angezeigt.
-- Der farbige Rahmen allein genuegt fuer die Unterscheidung. Wer sie braucht,
-- etwa bei Rot-Gruen-Schwaeche, schaltet sie in den Einstellungen zu: Orange
-- und Gruen liegen bei Deuteranopie dicht beieinander.
local TIERS = {
    BIS   = { order = 1, weight = 4, label = "Best in Slot",     mark = "*", color = "ffff8000" },
    MUST  = { order = 2, weight = 2, label = "Muss ich haben",   mark = "!", color = "ffa335ee" },
    NICE  = { order = 3, weight = 1, label = "Wäre ganz nett",   mark = "+", color = "ff0070dd" },
    OFF   = { order = 4, weight = 1, label = "Für den Off-Spec", mark = "o", color = "ff1eff00" },
    -- Weiss statt Grau. Das Grau lag zu nah an der normalen Rahmenfarbe
    -- (#77787b bei 35 Prozent) und war als Markierung schlicht nicht zu
    -- erkennen. Weiss ist in Blizzards Skala die Stufe darueber und passt
    -- inhaltlich: Transmog ist kosmetisch, kein Fortschritt.
    XMOG  = { order = 5, weight = 0, label = "Nur Transmog",     mark = "~", color = "ffffffff" },
}
local TIER_ORDER = { "BIS", "MUST", "NICE", "OFF", "XMOG" }

-- ----------------------------------------------------------------------------
-- Besitz und verbrauchte Bonus Rolls
-- ----------------------------------------------------------------------------
-- Beides pro Charakter, denn beides ist charakterbezogen.
--
-- Getrennt gefuehrt, weil es zwei verschiedene Aussagen sind: "habe ich schon"
-- beendet die Jagd auf dieses Item, "Bonus Roll verbraucht" sagt nur, dass ein
-- Versuch weg ist. Man kann einen Bonus Roll verbrauchen und trotzdem nichts
-- bekommen, das ist ja der Sinn eines Wurfs.

local function Owned(itemID)
    return (SlotMachineCharDB.owned and SlotMachineCharDB.owned[itemID]) and true or false
end

local function SetOwned(itemID, v)
    SlotMachineCharDB.owned = SlotMachineCharDB.owned or {}
    SlotMachineCharDB.owned[itemID] = v or nil
end

local function BonusUsed(itemID)
    return (SlotMachineCharDB.bonusUsed and SlotMachineCharDB.bonusUsed[itemID]) and true or false
end

local function SetBonusUsed(itemID, v)
    SlotMachineCharDB.bonusUsed = SlotMachineCharDB.bonusUsed or {}
    SlotMachineCharDB.bonusUsed[itemID] = v or nil
end

local function TierOf(itemID)
    return SlotMachineCharDB.wanted and SlotMachineCharDB.wanted[itemID] or nil
end

local function Wanted(itemID)
    return TierOf(itemID) ~= nil
end

local function SetTier(itemID, tier)
    SlotMachineCharDB.wanted = SlotMachineCharDB.wanted or {}
    SlotMachineCharDB.wanted[itemID] = tier   -- nil entfernt den Eintrag
end

-- Linksklick schaltet der Reihe nach durch, damit man ohne Menue arbeiten
-- kann. Rechtsklick oeffnet die Auswahl fuer den gezielten Sprung.
local function CycleTier(itemID)
    local cur = TierOf(itemID)
    if not cur then SetTier(itemID, "BIS"); return end
    for i, key in ipairs(TIER_ORDER) do
        if key == cur then
            SetTier(itemID, TIER_ORDER[i + 1])   -- nach XMOG kommt nil
            return
        end
    end
    SetTier(itemID, nil)
end

-- Migration: Die erste Fassung speicherte true statt einer Stufe. Solche
-- Eintraege werden als "Muss ich haben" gelesen, damit niemand seine Liste
-- verliert.
local function MigrateWanted()
    if not SlotMachineCharDB.wanted then return end
    for id, v in pairs(SlotMachineCharDB.wanted) do
        if v == true then SlotMachineCharDB.wanted[id] = "MUST" end
    end
end

-- ----------------------------------------------------------------------------
-- Zustand
-- ----------------------------------------------------------------------------

-- (Zustandsvariablen stehen weiter oben, vor ihrer ersten Verwendung.)

-- ----------------------------------------------------------------------------
-- Spezialisierungen
-- ----------------------------------------------------------------------------
-- Bewusst nur die eigene Klasse im Filter. Ein volles Klassen-Untermenue wie
-- bei Keystone Loot ist fuer den MVP Ballast: Wer Loot plant, plant fuer den
-- Charakter, vor dem er sitzt. Fuer Twinks wechselt man ohnehin den Charakter,
-- und die Wunschliste haengt sowieso am Charakter.

local function SpecsOfClass(classID)
    local out = {}
    local n = 0
    pcall(function() n = GetNumSpecializationsForClassID(classID) or 0 end)
    for i = 1, n do
        local ok, specID, name = pcall(GetSpecializationInfoForClassID, classID, i)
        if ok and specID then out[#out + 1] = { id = specID, name = name, classID = classID } end
    end
    return out
end

local function ActiveSpecID()
    local idx = GetSpecialization and GetSpecialization()
    if not idx then return nil end
    local ok, specID = pcall(GetSpecializationInfo, idx)
    return ok and specID or nil
end

local function FilterLabel()
    if currentSpec then
        local ok, _, name = pcall(GetSpecializationInfoByID, currentSpec)
        return (ok and name) or ("Spec " .. currentSpec)
    end
    if currentClass then
        local info = C_CreatureInfo and C_CreatureInfo.GetClassInfo
            and C_CreatureInfo.GetClassInfo(currentClass)
        return (info and info.className) or ("Klasse " .. currentClass)
    end
    -- Ohne "Alle Klassen" ist "alle" auf die eigene Klasse beschraenkt. Das
    -- muss die Beschriftung auch sagen, sonst wundert man sich, warum nicht
    -- wirklich alles auftaucht.
    if not SlotMachineDB.allClasses then return "Alle meine Specs" end
    return "Alle Specs"
end

-- Alle Spec-IDs einer Klasse, fuer den Fall dass eine ganze Klasse gewaehlt ist
local function SpecIDsOfClass(classID)
    local out = {}
    local n = 0
    pcall(function() n = GetNumSpecializationsForClassID(classID) or 0 end)
    for i = 1, n do
        local ok, specID = pcall(GetSpecializationInfoForClassID, classID, i)
        if ok and specID then out[specID] = true end
    end
    return out
end

-- Welche Klasse gilt gerade als Filter?
--
-- Wichtig fuer den Fall "Alle Specs" bei ausgeschalteter Option "Alle Klassen":
-- Dort bedeutet "alle" natuerlich alle Specs DER EIGENEN KLASSE, nicht alle
-- vierzig im Spiel. Vorher wurde nil einfach als "kein Filter" gelesen, und ein
-- Todesritter bekam Stoffruestung und Zauberstaebe angezeigt.
local function EffectiveClass()
    if currentSpec then return nil end            -- Spec-Filter ist genauer
    if currentClass then return currentClass end
    if not SlotMachineDB.allClasses then
        local _, _, classID = UnitClass("player")
        return classID
    end
    return nil                                    -- wirklich alles
end

-- Kann die gewaehlte Spec oder Klasse dieses Item tragen?
local function PassesSpec(itemID)
    local classFilter = EffectiveClass()
    if not currentSpec and not classFilter then return true end

    local rec = ns.ITEMS and ns.ITEMS[itemID]
    if not rec then return true end
    if rec.s == nil then return true end        -- keine Angabe, nicht ausblenden
    if rec.s == "*" then return true end        -- jede Spec
    if type(rec.s) ~= "table" then return true end

    if currentSpec then
        for _, id in ipairs(rec.s) do
            if id == currentSpec then return true end
        end
        return false
    end

    -- Ganze Klasse: trifft zu, sobald IRGENDEINE ihrer Specs das Item tragen kann
    local wanted = SpecIDsOfClass(classFilter)
    for _, id in ipairs(rec.s) do
        if wanted[id] then return true end
    end
    return false
end

-- ----------------------------------------------------------------------------
-- Daten fuer die Anzeige aufbereiten
-- ----------------------------------------------------------------------------

local function PassesSlot(itemID)
    -- Die Wunschliste ignoriert den Spec-Filter bewusst. Wer etwas markiert
    -- hat, will es sehen, auch wenn es fuer den Off-Spec ist.
    if currentSlot == "WISH" then return Wanted(itemID) end
    if not PassesSpec(itemID) then return false end
    if currentSlot == "ALL"  then return true end
    return GroupOfItem(itemID) == currentSlot
end

-- Sortiert die Items einer Zeile: wichtigstes zuerst, damit ganz links steht
-- was zaehlt.
local function SortItems(list)
    table.sort(list, function(a, b)
        -- TIERS[ta] kann nil sein, wenn in den gespeicherten Daten eine Stufe
        -- steht, die es nicht mehr gibt. Deshalb nicht direkt indizieren.
        local ta, tb = TierOf(a), TierOf(b)
        local wa = (ta and TIERS[ta] and TIERS[ta].order) or 99
        local wb = (tb and TIERS[tb] and TIERS[tb].order) or 99
        if wa ~= wb then return wa < wb end
        return (a or 0) < (b or 0)
    end)
end

-- Liefert die Quellen, sortiert nach Gewicht der Wunsch-Items.
-- Das ist der Kern des Add-ons: Wo am meisten fuer dich drin ist, steht oben.
--
-- Zwei Gruppierungen, umschaltbar in den Einstellungen:
--   Dungeon (Standard) - eine Zeile je Instanz, alle Bosse zusammengefasst.
--     Beantwortet die Frage "wo gehe ich hin", und das ist die Frage, die man
--     sich zuerst stellt.
--   Boss - eine Zeile je Boss. Beantwortet "auf wen freue ich mich", nuetzlich
--     im Raid, wo man einzelne Bosse gezielt ansteuert.
-- Im Raid wird IMMER nach Boss gruppiert, unabhaengig von der Einstellung.
--
-- Der Grund liegt daran, wie man die beiden Inhalte spielt: Einen Dungeon
-- laeuft man am Stueck durch, da lautet die Frage "wo gehe ich hin". Im Raid
-- steuert man einzelne Bosse an, legt sie ueber mehrere Abende oder ueberspringt
-- sie. Eine zusammengefasste Raid-Zeile beantwortet dort keine Frage, die
-- jemand stellt.
local function GroupByDungeon()
    if currentTab == "RAID" then return false end
    return (SlotMachineDB.groupBy or "DUNGEON") == "DUNGEON"
end

local function BuildSources()
    local out = {}
    if not ns.LOOT then return out end

    local byDungeon = GroupByDungeon()

    for instID, bosses in pairs(ns.LOOT) do
        local isRaid = IsRaid(instID)
        if (currentTab == "RAID") == isRaid then
            if byDungeon then
                local shown, wish, score, seen, openWish, pool = {}, 0, 0, {}, 0, 0
                for _, items in pairs(bosses) do
                    for _, itemID in ipairs(items) do
                        -- Ein Item kann bei mehreren Bossen fallen. In der
                        -- Dungeon-Ansicht darf es trotzdem nur einmal stehen.
                        if not seen[itemID] and PassesSlot(itemID) then
                            seen[itemID] = true
                            shown[#shown + 1] = itemID
                            -- Der Bonus-Roll-Pool besteht aus allen Items, die
                            -- man noch NICHT hat. Erhaltene fallen heraus.
                            -- Deshalb wird hier mitgezaehlt, wie viele Items
                            -- ueberhaupt noch im Pool sind.
                            if not Owned(itemID) then pool = pool + 1 end

                            local t = TierOf(itemID)
                            if t then
                                wish = wish + 1
                                -- Bereits erhaltene Items zaehlen nicht mehr
                                -- fuer die Priorisierung. Sonst bliebe ein
                                -- abgehakter Dungeon dauerhaft oben stehen.
                                if not Owned(itemID) then
                                    openWish = openWish + 1
                                    score = score + (TIERS[t] and TIERS[t].weight or 0)
                                end
                            end
                        end
                    end
                end
                if #shown > 0 then
                    SortItems(shown)
                    out[#out + 1] = {
                        instanceID = instID, encounterID = nil,
                        items = shown, wish = openWish, total = #shown,
                        pool = pool, score = score, isRaid = isRaid,
                    }
                end
            else
                for encID, items in pairs(bosses) do
                    local shown, wish, score, openWish, pool = {}, 0, 0, 0, 0
                    for _, itemID in ipairs(items) do
                        if PassesSlot(itemID) then
                            shown[#shown + 1] = itemID
                            if not Owned(itemID) then pool = pool + 1 end
                            local t = TierOf(itemID)
                            if t then
                                wish = wish + 1
                                if not Owned(itemID) then
                                    openWish = openWish + 1
                                    score = score + (TIERS[t] and TIERS[t].weight or 0)
                                end
                            end
                        end
                    end
                    if #shown > 0 then
                        SortItems(shown)
                        out[#out + 1] = {
                            instanceID = instID, encounterID = encID,
                            items = shown, wish = openWish, total = #shown,
                            pool = pool, score = score, isRaid = isRaid,
                        }
                    end
                end
            end
        end
    end

    -- Absteigend nach GEWICHT, nicht nach Anzahl. Ein Best-in-Slot-Teil zaehlt
    -- vier, ein "waere ganz nett" eins. Bei Gleichstand entscheidet die Anzahl,
    -- danach die Instanz, damit die Reihenfolge stabil bleibt und die Liste
    -- nicht bei jedem Klick springt.
    -- ACHTUNG: Alle Felder mit "or 0" absichern.
    --
    -- In der Dungeon-Ansicht ist encounterID nil, weil dort alle Bosse einer
    -- Instanz zusammengefasst sind. Erreichte der Vergleich diese Zeile,
    -- verglich Lua zwei nil-Werte und brach mitten in table.sort ab. Weil das
    -- innerhalb von Render passiert, blieb das Fenster halb aufgebaut stehen
    -- und sah aus, als sei es verschwunden.
    --
    -- Eine Sortierfunktion muss fuer JEDE Kombination ein Ergebnis liefern,
    -- auch fuer die, die man fuer unmoeglich haelt. table.sort vergleicht
    -- Elemente in einer Reihenfolge, die man nicht vorhersagen kann.
    table.sort(out, function(a, b)
        -- Im Raid steht die Reihenfolge der Bosse ueber der Priorisierung.
        -- Ein Raid laeuft man von vorne nach hinten, eine nach Wunsch-Gewicht
        -- umsortierte Bossliste waere dort unbrauchbar. Im Dungeon gilt das
        -- nicht, dort ist die Frage "wo gehe ich hin" und die Sortierung nach
        -- Gewicht genau richtig.
        if currentTab == "RAID" then
            local ia, ib = a.instanceID or 0, b.instanceID or 0
            if ia ~= ib then return ia < ib end
            return EncounterIndex(ia, a.encounterID or 0)
                 < EncounterIndex(ib, b.encounterID or 0)
        end

        local sa, sb = a.score or 0, b.score or 0
        if sa ~= sb then return sa > sb end
        local wa, wb = a.wish or 0, b.wish or 0
        if wa ~= wb then return wa > wb end
        local ia, ib = a.instanceID or 0, b.instanceID or 0
        if ia ~= ib then return ia < ib end
        return EncounterIndex(ia, a.encounterID or 0)
             < EncounterIndex(ib, b.encounterID or 0)
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

AutoHide(slotMenu, slotBtn)

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

-- Spec-Filter ----------------------------------------------------------------

local specBtn = CreateFrame("Button", nil, frame)
specBtn:SetSize(140, 22)
specBtn:SetPoint("LEFT", tabRaid, "RIGHT", 14, 0)
specBtn.fill = specBtn:CreateTexture(nil, "BACKGROUND")
specBtn.fill:SetAllPoints()
specBtn.fill:SetColorTexture(SURFACE[1], SURFACE[2], SURFACE[3], 0.85)
AddEdges(specBtn)
specBtn.text = specBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
specBtn.text:SetPoint("LEFT", specBtn, "LEFT", 8, 0)
specBtn.arrow = specBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
specBtn.arrow:SetPoint("RIGHT", specBtn, "RIGHT", -8, 0)
specBtn.arrow:SetText("|c" .. INK_DIM .. "v|r")

local specMenu = CreateFrame("Frame", nil, frame)
specMenu:SetFrameStrata("DIALOG")
specMenu:Hide()
local spbg = specMenu:CreateTexture(nil, "BACKGROUND")
spbg:SetAllPoints()
spbg:SetColorTexture(BG[1], BG[2], BG[3], 0.98)
AddEdges(specMenu)
specMenu.entries = {}

-- Ein Menueeintrag. Steht bewusst HIER, vor allen Menues die ihn benutzen.
--
-- Waere er weiter unten deklariert, loeste der Name innerhalb der frueheren
-- Funktionen auf eine nicht existierende globale Variable auf. Genau dieser
-- Fehler hat in Chrissi's Addon v0.8.0 die Deckkraft-Knoepfe lahmgelegt:
-- Tooltip ging, Tastenkuerzel ging, der Klick lief ins Leere.
local function MenuEntry(parent, i, width)
    local e = parent.entries[i]
    if not e then
        e = CreateFrame("Button", nil, parent)
        e.fill = e:CreateTexture(nil, "BACKGROUND")
        e.fill:SetAllPoints()
        e.fill:SetColorTexture(1, 1, 1, 0)
        e.text = e:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        e.text:SetPoint("LEFT", e, "LEFT", 8, 0)
        e.arrow = e:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        e.arrow:SetPoint("RIGHT", e, "RIGHT", -6, 0)
        parent.entries[i] = e
    end
    e:SetSize(width - 4, 20)
    e:SetPoint("TOPLEFT", parent, "TOPLEFT", 2, -(2 + (i - 1) * 20))
    e.arrow:SetText("")
    e:SetScript("OnEnter", function(self) self.fill:SetColorTexture(1, 1, 1, 0.08) end)
    e:SetScript("OnLeave", function(self) self.fill:SetColorTexture(1, 1, 1, 0) end)
    e:Show()
    return e
end

-- Track-Waehler ---------------------------------------------------------------

-- Breiter als die anderen Felder, weil hier Beschriftung, Upgrade-Pfad und im
-- Raid zusaetzlich eine Itemlevel-Spanne nebeneinander stehen.
local srcBtn = CreateFrame("Button", nil, frame)
srcBtn:SetSize(196, 22)
srcBtn:SetPoint("LEFT", specBtn, "RIGHT", 8, 0)
srcBtn.fill = srcBtn:CreateTexture(nil, "BACKGROUND")
srcBtn.fill:SetAllPoints()
srcBtn.fill:SetColorTexture(SURFACE[1], SURFACE[2], SURFACE[3], 0.85)
AddEdges(srcBtn)
srcBtn.text = srcBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
srcBtn.text:SetPoint("LEFT", srcBtn, "LEFT", 8, 0)
srcBtn.arrow = srcBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
srcBtn.arrow:SetPoint("RIGHT", srcBtn, "RIGHT", -8, 0)
srcBtn.arrow:SetText("|c" .. INK_DIM .. "v|r")

local srcMenu = CreateFrame("Frame", nil, frame)
srcMenu:SetFrameStrata("DIALOG")
srcMenu:Hide()
local srcbg = srcMenu:CreateTexture(nil, "BACKGROUND")
srcbg:SetAllPoints()
srcbg:SetColorTexture(BG[1], BG[2], BG[3], 0.98)
AddEdges(srcMenu)
srcMenu.entries = {}

local function BuildSourceMenu()
    -- Tab festhalten, fuer den dieses Menue gilt. Siehe SetCurrentSource.
    local builtFor = currentTab
    local list = SourceList()
    for _, e in ipairs(srcMenu.entries) do e:Hide() end

    -- Nur die Quellen. Der Bonus-Roll-Umschalter stand hier frueher zusaetzlich
    -- am Ende, sitzt aber inzwischen als eigener Haken neben dem Waehler. Zwei
    -- Bedienelemente fuer dieselbe Einstellung sind eine Fehlerquelle: Man
    -- weiss nie, welches gerade den Zustand haelt.
    srcMenu:SetSize(200, #list * 20 + 8)
    srcMenu:ClearAllPoints()
    srcMenu:SetPoint("TOPLEFT", srcBtn, "BOTTOMLEFT", 0, -2)

    local cur = CurrentSource()
    for i, s in ipairs(list) do
        local e = MenuEntry(srcMenu, i, 200)
        -- Je Zeile pruefen, ob diese Stufe ueberhaupt einen Roll kennt
        local r = ns.ResolveSource(s, SlotMachineDB.bonusRoll and ns.HasBonusRoll(s))
        local lvl = r and r.ilvl or "?"
        local col = (s.key == cur.key) and ACCENT or INK
        e.text:SetText("|c" .. col .. s.label .. "|r")

        -- Rechts steht der Upgrade-Pfad des Loots plus dessen Itemlevel, beides
        -- in der Farbe des Tracks. Also "H 3/6  311" statt einer Wiederholung
        -- der Schluesselstein-Stufe, die links ohnehin schon dasteht.
        if not r then
            e.arrow:SetText("|c" .. INK_DIM .. "kein Roll|r")
        else
            e.arrow:SetText("|c" .. r.color .. r.badge .. "|r  |c" .. r.color .. lvl .. "|r")
        end
        e:SetScript("OnClick", function()
            SetCurrentSource(s.key, builtFor)
            srcMenu:Hide(); ns.UI:Render()
        end)
    end

end

-- Bonus-Roll-Haken direkt neben der Stufe.
--
-- Steht bewusst hier und nicht nur im Menue: Der Vergleich "was bringt mir ein
-- Bonus Roll auf dieser Stufe" ist genau die Frage, die man mehrfach
-- hintereinander stellt, waehrend man Stufen durchprobiert. Zwei Klicks ins
-- Menue waeren dafuer zu viel.
local rollBtn = CreateFrame("Button", nil, frame)
rollBtn:SetSize(96, 22)
rollBtn:SetPoint("LEFT", srcBtn, "RIGHT", 6, 0)
rollBtn.fill = rollBtn:CreateTexture(nil, "BACKGROUND")
rollBtn.fill:SetAllPoints()
AddEdges(rollBtn)

rollBtn.box = rollBtn:CreateTexture(nil, "ARTWORK")
rollBtn.box:SetSize(11, 11)
rollBtn.box:SetPoint("LEFT", rollBtn, "LEFT", 7, 0)

rollBtn.text = rollBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
rollBtn.text:SetPoint("LEFT", rollBtn, "LEFT", 23, 0)

function rollBtn:Refresh()
    local on = SlotMachineDB.bonusRoll
    -- Gibt es fuer die gewaehlte Stufe ueberhaupt einen Roll? Bei Mythisch 0
    -- nicht, weil M0 nicht fuer die Mythic+-Reihe der Vault zaehlt.
    local possible = ns.HasBonusRoll and ns.HasBonusRoll(CurrentSource())

    self.fill:SetColorTexture(SURFACE[1], SURFACE[2], SURFACE[3], on and 0.9 or 0.4)
    if not possible then
        self.box:SetColorTexture(0.18, 0.18, 0.2, 0.9)
        self.text:SetText("|c" .. INK_DIM .. "kein Roll|r")
    elseif on then
        self.box:SetColorTexture(HexToRGB(ACCENT))
        self.text:SetText("|c" .. ACCENT .. "Bonus Roll|r")
    else
        self.box:SetColorTexture(0.25, 0.25, 0.27, 0.9)
        self.text:SetText("|c" .. INK_DIM .. "Bonus Roll|r")
    end
end

rollBtn:SetScript("OnClick", function(self)
    SlotMachineDB.bonusRoll = (not SlotMachineDB.bonusRoll) or nil
    self:Refresh()
    if srcMenu:IsShown() then BuildSourceMenu() end
    ns.UI:Render()
end)
rollBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:AddLine("Als Bonus Roll rechnen")
    GameTooltip:AddLine("Springt auf die erste Stufe des nächsthöheren Tracks. Aus M0 wird damit ein Hero-Teil statt Champion.", 0.65, 0.63, 0.58, true)
    GameTooltip:AddLine("Umschalten zeigt sofort, was der Roll auf dieser Stufe bringt.", 0.65, 0.63, 0.58, true)
    GameTooltip:Show()
end)
rollBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
rollBtn:Refresh()

AutoHide(srcMenu, srcBtn)

srcBtn:SetScript("OnClick", function()
    if srcMenu:IsShown() then srcMenu:Hide() else BuildSourceMenu(); srcMenu:Show() end
end)
srcBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:AddLine("Woher kommt das Item")
    GameTooltip:AddLine("Bestimmt, mit welchem Itemlevel gerechnet wird. Der Tooltip zeigt dann die echten Werte dieser Stufe.", 0.65, 0.63, 0.58, true)
    GameTooltip:AddLine("Bonus Roll springt auf die erste Stufe des nächsthöheren Tracks.", 0.65, 0.63, 0.58, true)
    GameTooltip:Show()
end)
srcBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Untermenue fuer die Spezialisierungen einer Klasse
local subMenu = CreateFrame("Frame", nil, frame)
subMenu:SetFrameStrata("FULLSCREEN_DIALOG")
subMenu:Hide()
local submbg = subMenu:CreateTexture(nil, "BACKGROUND")
submbg:SetAllPoints()
submbg:SetColorTexture(BG[1], BG[2], BG[3], 0.98)
AddEdges(subMenu)
subMenu.entries = {}

-- Klassenfarbe. Blizzard liefert sie mit, also nicht selbst nachbauen.
local function ClassColorHex(classFile)
    local c = classFile and RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
    if not c then return INK end
    return string.format("ff%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
end

local function OpenSubMenu(anchor, classInfo)
    local specs = SpecsOfClass(classInfo.classID)
    subMenu:SetSize(160, (#specs + 1) * 20 + 8)
    subMenu:ClearAllPoints()
    subMenu:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 2, 2)

    for _, e in ipairs(subMenu.entries) do e:Hide() end

    -- Erster Eintrag: die ganze Klasse, also alle ihre Specs zusammen
    local eAll = MenuEntry(subMenu, 1, 160)
    eAll.text:SetText("|c" .. INK_DIM .. "Alle Spezialisierungen|r")
    eAll:SetScript("OnClick", function()
        currentSpec = nil
        currentClass = classInfo.classID
        subMenu:Hide(); specMenu:Hide(); ns.UI:Render()
    end)

    local active = ActiveSpecID()
    for i, s in ipairs(specs) do
        local e = MenuEntry(subMenu, i + 1, 160)
        local suffix = (s.id == active) and ("  |c" .. INK_DIM .. "(aktiv)|r") or ""
        e.text:SetText("|c" .. INK .. s.name .. "|r" .. suffix)
        e:SetScript("OnClick", function()
            currentSpec = s.id
            currentClass = nil
            subMenu:Hide(); specMenu:Hide(); ns.UI:Render()
        end)
    end

    subMenu:Show()
end

-- Hauptmenue und Untermenue gelten als eine Einheit: Solange die Maus auf
-- einem von beiden liegt, bleiben beide offen.
AutoHide(specMenu, specBtn, { subMenu })
AutoHide(subMenu, specBtn, { specMenu })

local function BuildSpecMenu()
    for _, e in ipairs(specMenu.entries) do e:Hide() end
    subMenu:Hide()

    if not SlotMachineDB.allClasses then
        -- Nur die eigene Klasse: flache Liste, kein Baum noetig
        local list = SpecsOfClass(select(3, UnitClass("player")))
        specMenu:SetSize(150, (#list + 1) * 20 + 8)
        specMenu:ClearAllPoints()
        specMenu:SetPoint("TOPLEFT", specBtn, "BOTTOMLEFT", 0, -2)

        local e1 = MenuEntry(specMenu, 1, 150)
        e1.text:SetText("|c" .. INK .. "Alle meine Specs|r")
        e1:SetScript("OnClick", function()
            currentSpec, currentClass = nil, nil
            specMenu:Hide(); ns.UI:Render()
        end)

        local active = ActiveSpecID()
        for i, s in ipairs(list) do
            local e = MenuEntry(specMenu, i + 1, 150)
            local suffix = (s.id == active) and ("  |c" .. INK_DIM .. "(aktiv)|r") or ""
            e.text:SetText("|c" .. INK .. s.name .. "|r" .. suffix)
            e:SetScript("OnClick", function()
                currentSpec = s.id; currentClass = nil
                specMenu:Hide(); ns.UI:Render()
            end)
        end
        return
    end

    -- Alle Klassen: Baum. Vierzig Specs als flache Liste sind unbrauchbar,
    -- also erste Ebene Klassen, zweite Ebene deren Spezialisierungen.
    local classes = {}
    local numClasses = (GetNumClasses and GetNumClasses()) or 13
    for classID = 1, numClasses do
        local info = C_CreatureInfo and C_CreatureInfo.GetClassInfo
            and C_CreatureInfo.GetClassInfo(classID)
        if info then
            classes[#classes + 1] = {
                classID = classID, name = info.className, file = info.classFile,
            }
        end
    end
    table.sort(classes, function(a, b) return a.name < b.name end)

    specMenu:SetSize(160, (#classes + 1) * 20 + 8)
    specMenu:ClearAllPoints()
    specMenu:SetPoint("TOPLEFT", specBtn, "BOTTOMLEFT", 0, -2)

    local e1 = MenuEntry(specMenu, 1, 160)
    e1.text:SetText("|c" .. INK .. "Alle Specs|r")
    e1:SetScript("OnClick", function()
        currentSpec, currentClass = nil, nil
        subMenu:Hide(); specMenu:Hide(); ns.UI:Render()
    end)
    e1:HookScript("OnEnter", function() subMenu:Hide() end)

    for i, c in ipairs(classes) do
        local e = MenuEntry(specMenu, i + 1, 160)
        e.text:SetText("|c" .. ClassColorHex(c.file) .. c.name .. "|r")
        e.arrow:SetText("|c" .. INK_DIM .. ">|r")
        e:HookScript("OnEnter", function(self) OpenSubMenu(self, c) end)
        -- Klick auf die Klasse selbst waehlt ebenfalls die ganze Klasse aus,
        -- damit man nicht zwingend ins Untermenue muss.
        e:SetScript("OnClick", function()
            currentSpec = nil
            currentClass = c.classID
            subMenu:Hide(); specMenu:Hide(); ns.UI:Render()
        end)
    end
end

specBtn:SetScript("OnClick", function()
    if specMenu:IsShown() then
        specMenu:Hide()
    else
        BuildSpecMenu()
        specMenu:Show()
    end
end)

-- Liste ----------------------------------------------------------------------

local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", PAD, -(PAD + 56))
scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -(PAD + 22), PAD + 22)
local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(1, 1)
scrollFrame:SetScrollChild(content)

local hint = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
hint:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", PAD, PAD - 2)
hint:SetText("|c" .. INK_DIM .. "Linksklick schaltet die Stufe weiter, Rechtsklick wählt direkt. Quellen mit dem höchsten Gewicht stehen oben.|r")

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

    -- Name und Zaehler oben ausgerichtet, weil die Zeile bei vielen Icons
    -- mehrzeilig wird und der Text sonst in der Mitte schwebt.
    r.name = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    r.name:SetPoint("TOPLEFT", r, "TOPLEFT", 6, -6)
    r.name:SetWidth(LABEL_W - 72)
    r.name:SetJustifyH("LEFT")
    r.name:SetWordWrap(false)

    r.badge = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    r.badge:SetPoint("TOPLEFT", r, "TOPLEFT", LABEL_W - 62, -6)
    r.badge:SetWidth(58)
    r.badge:SetJustifyH("RIGHT")

    r.icons = {}
    rowPool[i] = r
    return r
end

-- Wie viele Icons passen nebeneinander, bevor umgebrochen wird. In der
-- Dungeon-Ansicht kommen alle Bosse einer Instanz in EINE Zeile, da reicht
-- eine Reihe nicht mehr aus.
local ICONS_PER_ROW = math.floor((WIDTH - PAD * 2 - 24 - LABEL_W) / (ICON + ICON_GAP))

local function GetIcon(row, i)
    local b = row.icons[i]
    if b then return b end

    b = CreateFrame("Button", nil, row)
    b:SetSize(ICON, ICON)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b.tex = b:CreateTexture(nil, "ARTWORK")
    b.tex:SetPoint("TOPLEFT", 1, -1)
    b.tex:SetPoint("BOTTOMRIGHT", -1, 1)
    b.tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)   -- Blizzard-Rand wegschneiden
    b.edges = AddEdges(b, 0.35)

    -- Stufen-Zeichen unten rechts. Traegt die Information zusaetzlich zur
    -- Farbe, damit Farbsehschwaeche nichts kostet. Dunkler Hintergrund
    -- dahinter, sonst geht das Zeichen auf hellen Icons unter.
    b.markBg = b:CreateTexture(nil, "OVERLAY")
    b.markBg:SetSize(11, 11)
    b.markBg:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -1, 1)
    b.markBg:SetColorTexture(0, 0, 0, 0.75)
    b.markBg:Hide()

    b.mark = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.mark:SetPoint("CENTER", b.markBg, "CENTER", 0, 0)
    b.mark:Hide()

    -- Itemlevel unten links, mit dunklem Streifen darunter. Ohne den Streifen
    -- verschwindet die Zahl auf hellen Icons.
    b.ilvlBg = b:CreateTexture(nil, "OVERLAY")
    b.ilvlBg:SetPoint("BOTTOMLEFT", b, "BOTTOMLEFT", 1, 1)
    b.ilvlBg:SetSize(ICON - 2, 10)
    b.ilvlBg:SetColorTexture(0, 0, 0, 0.7)
    b.ilvlBg:Hide()

    b.ilvl = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.ilvl:SetPoint("BOTTOMLEFT", b, "BOTTOMLEFT", 2, 1)
    b.ilvl:SetJustifyH("LEFT")
    b.ilvl:Hide()

    -- Zwei diagonale Striche fuer einen verbrauchten Bonus Roll.
    --
    -- Keystone Loot blendet dafuer ein kleines Symbol in der Ecke ein. Hier
    -- braucht es mehr, weil zwei Zustaende zu unterscheiden sind: "habe ich
    -- bereits" wird abgedunkelt, "Bonus Roll verbraucht" durchgestrichen. Zwei
    -- verschiedene visuelle Sprachen, damit beides gleichzeitig lesbar bleibt.
    --
    -- Die Laenge ist die Diagonale des Icons, also Kantenlaenge mal Wurzel
    -- zwei, sonst reichen die Striche nicht bis in die Ecken.
    local diag = ICON * 1.42
    b.slash = {}
    for k = 1, 2 do
        local t = b:CreateTexture(nil, "OVERLAY", nil, 6)
        t:SetColorTexture(1, 0.25, 0.25, 0.9)
        t:SetSize(diag, 2)
        t:SetPoint("CENTER", b, "CENTER", 0, 0)
        t:SetRotation(math.rad(k == 1 and 45 or -45))
        t:Hide()
        b.slash[k] = t
    end

    row.icons[i] = b
    return b
end

-- ----------------------------------------------------------------------------
-- Rechtsklick-Menue zur Stufenwahl
-- ----------------------------------------------------------------------------

local tierMenu = CreateFrame("Frame", nil, UIParent)
-- Stufen, Trennung, "von der Liste nehmen", "erhalten", "Bonus Roll verbraucht"
tierMenu:SetSize(190, (#TIER_ORDER + 3) * 20 + 8)
tierMenu:SetFrameStrata("TOOLTIP")
tierMenu:Hide()
local tmbg = tierMenu:CreateTexture(nil, "BACKGROUND")
tmbg:SetAllPoints()
tmbg:SetColorTexture(BG[1], BG[2], BG[3], 0.98)
AddEdges(tierMenu)
tierMenu.entries = {}

for i = 1, #TIER_ORDER + 3 do
    local e = CreateFrame("Button", nil, tierMenu)
    e:SetSize(186, 20)
    e:SetPoint("TOPLEFT", tierMenu, "TOPLEFT", 2, -(2 + (i - 1) * 20))
    e.fill = e:CreateTexture(nil, "BACKGROUND")
    e.fill:SetAllPoints()
    e.fill:SetColorTexture(1, 1, 1, 0)
    e.text = e:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    e.text:SetPoint("LEFT", e, "LEFT", 8, 0)
    e:SetScript("OnEnter", function(self) self.fill:SetColorTexture(1, 1, 1, 0.08) end)
    e:SetScript("OnLeave", function(self) self.fill:SetColorTexture(1, 1, 1, 0) end)
    tierMenu.entries[i] = e
end

local function OpenTierMenu(anchor, itemID)
    for i, key in ipairs(TIER_ORDER) do
        local t = TIERS[key]
        local e = tierMenu.entries[i]
        e.text:SetText("|c" .. t.color .. t.mark .. "|r  |c" .. INK .. t.label .. "|r")
        e:SetScript("OnClick", function()
            SetTier(itemID, key)
            tierMenu:Hide()
            ns.UI:Render()
        end)
        e:Show()
    end
    local last = tierMenu.entries[#TIER_ORDER + 1]
    last.text:SetText("|c" .. INK_DIM .. "-  von der Liste nehmen|r")
    last:SetScript("OnClick", function()
        SetTier(itemID, nil)
        tierMenu:Hide()
        ns.UI:Render()
    end)
    last:Show()

    -- Erhalten. Beendet die Jagd auf dieses Item: es zaehlt nicht mehr fuer
    -- die Priorisierung und wird durchgestrichen dargestellt.
    local eOwn = tierMenu.entries[#TIER_ORDER + 2]
    eOwn.text:SetText(Owned(itemID)
        and ("|c" .. GREEN .. "x  habe ich bereits|r")
        or  ("|c" .. INK .. "x  als erhalten markieren|r"))
    eOwn:SetScript("OnClick", function()
        SetOwned(itemID, not Owned(itemID))
        tierMenu:Hide()
        ns.UI:Render()
    end)
    eOwn:Show()

    -- Bonus Roll verbraucht. Bewusst getrennt vom Besitz, weil ein Wurf auch
    -- ins Leere gehen kann. Die Information ist trotzdem wichtig: der Versuch
    -- ist weg.
    local eBonus = tierMenu.entries[#TIER_ORDER + 3]
    eBonus.text:SetText(BonusUsed(itemID)
        and ("|c" .. ACCENT .. "o  Bonus Roll verbraucht|r")
        or  ("|c" .. INK_DIM .. "o  Bonus Roll verbraucht?|r"))
    eBonus:SetScript("OnClick", function()
        SetBonusUsed(itemID, not BonusUsed(itemID))
        tierMenu:Hide()
        ns.UI:Render()
    end)
    eBonus:Show()

    tierMenu:ClearAllPoints()
    tierMenu:SetPoint("TOPLEFT", anchor, "BOTTOMRIGHT", 2, 0)
    tierMenu:Show()
end

-- Auch das Rechtsklick-Menue schliesst beim Verlassen. Es hat keinen festen
-- Ankerknopf, deshalb ohne owner: Sobald die Maus es verlaesst, laeuft die
-- Frist. Die Verzoegerung reicht, um vom Icon hinueberzufahren.
AutoHide(tierMenu, nil)

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

    -- Filterknöpfe
    local lbl = "Alle Slots"
    for _, g in ipairs(SLOT_GROUPS) do if g.key == currentSlot then lbl = g.label end end
    slotBtn.text:SetText("|c" .. (currentSlot == "ALL" and INK or ACCENT) .. lbl .. "|r")
    specBtn.text:SetText("|c" .. ((currentSpec or currentClass) and ACCENT or INK) .. FilterLabel() .. "|r")

    -- Track-Waehler beschriften: Quelle plus resultierendes Itemlevel
    local res, src = ResolvedCurrent()
    if rollBtn and rollBtn.Refresh then rollBtn:Refresh() end
    if src then
        srcBtn.text:SetText("|c" .. INK .. src.label .. "|r")
    else
        srcBtn.text:SetText("|c" .. INK .. "?|r")
    end
    if res then
        -- Im Raid weicht das Itemlevel je Boss ab, ein Einzelwert waere dort
        -- schlicht falsch. Deshalb die Spanne, sofern es eine gibt.
        local lo, hi = nil, nil
        if currentTab == "RAID" and ns.SourceRange then
            lo, hi = ns.SourceRange(src, SlotMachineDB.bonusRoll and ns.HasBonusRoll(src))
        end
        if lo and hi then
            srcBtn.arrow:SetText(string.format("|c%s%s  %d-%d|r", res.color, res.badge, lo, hi))
        else
            srcBtn.arrow:SetText("|c" .. res.color .. res.badge .. "  " .. res.ilvl .. "|r")
        end
    else
        srcBtn.arrow:SetText("|c" .. INK_DIM .. "v|r")
    end

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

    local byDungeon = GroupByDungeon()

    for _, src in ipairs(sources) do
        -- Instanz-Ueberschrift nur in der Boss-Ansicht. In der Dungeon-Ansicht
        -- IST der Instanzname schon der Zeilenname, eine Ueberschrift darueber
        -- waere die reine Wiederholung.
        if not byDungeon and src.instanceID ~= lastInstance then
            headI = headI + 1
            local h = GetHeader(headI)
            h:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)
            local iname = EJ_GetInstanceInfo and EJ_GetInstanceInfo(src.instanceID)
            -- In Akzentfarbe und Grossbuchstaben. Vorher standen Ueberschrift
            -- und Bossname in derselben Farbe untereinander und liessen sich
            -- kaum unterscheiden.
            h.text:SetText("|c" .. ACCENT .. string.upper(iname or ("Instanz " .. src.instanceID)) .. "|r")
            h:Show()
            y = y + HEAD_H
            lastInstance = src.instanceID
        end

        rowI = rowI + 1
        local row = GetRow(rowI)
        row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -y)

        -- Zeilenhoehe richtet sich nach der Anzahl der Icon-Reihen
        local iconRows = math.max(1, math.ceil(#src.items / ICONS_PER_ROW))
        local rowHeight = iconRows * (ICON + ICON_GAP) + 8
        row:SetHeight(rowHeight)
        row:Show()

        local label
        if src.encounterID then
            label = EJ_GetEncounterInfo and EJ_GetEncounterInfo(src.encounterID)
            label = label or ("Boss " .. src.encounterID)
            -- Nummer davor, damit die Reihenfolge im Raid auf einen Blick
            -- ablesbar ist und nicht nur aus der Anordnung folgt.
            local idx = EncounterIndex(src.instanceID, src.encounterID)
            if idx and idx < 99 then
                label = "|c" .. INK_DIM .. idx .. ".|r  " .. label
            end
        else
            label = EJ_GetInstanceInfo and EJ_GetInstanceInfo(src.instanceID)
            label = label or ("Instanz " .. src.instanceID)
        end
        row.name:SetText("|c" .. INK .. label .. "|r")
        -- BONUS-ROLL-CHANCE. Das ist keine Schaetzung, sondern eine echte
        -- Wahrscheinlichkeit, und zwar aus einem Grund: Ein Bonus Roll zieht
        -- aus dem Pool der Items, die man noch NICHT besitzt. Erhaltene fallen
        -- heraus. Also gilt schlicht:
        --
        --     offene Wunsch-Items / verbleibender Pool
        --
        -- Daraus folgt auch die Spielregel dahinter: Je mehr man besitzt, desto
        -- kleiner der Pool und desto hoeher die Chance auf ein bestimmtes
        -- fehlendes Teil. Deshalb lohnt es, Bonus Rolls aufzusparen und erst
        -- auf hoher Stufe einzusetzen, wenn ein Treffer auch das beste
        -- Itemlevel bringt.
        if src.wish > 0 then
            local pool = math.max(1, src.pool or src.total)
            local pct = math.floor((src.wish / pool) * 100 + 0.5)
            row.badge:SetText(string.format("|c%s%d|r|c%s/%d|r  |c%s%d%%|r",
                ACCENT, src.wish, INK_DIM, pool, GREEN, pct))
        else
            row.badge:SetText("")
        end
        row.fill:SetColorTexture(1, 1, 1, src.score > 0 and 0.06 or 0.02)

        -- Boss dieser Zeile festhalten. Die Klick- und Tooltip-Handler laufen
        -- spaeter und duerfen sich nicht auf die Schleifenvariable verlassen.
        local rowEncounter = src.encounterID

        for _, b in pairs(row.icons) do b:Hide() end
        for i, itemID in ipairs(src.items) do
            local b = GetIcon(row, i)
            local col = (i - 1) % ICONS_PER_ROW
            local lin = math.floor((i - 1) / ICONS_PER_ROW)
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", row, "TOPLEFT",
                LABEL_W + col * (ICON + ICON_GAP), -(4 + lin * (ICON + ICON_GAP)))
            local rec = ns.ITEMS[itemID] or {}
            b.tex:SetTexture(rec.icon or 134400)   -- Fragezeichen als Rueckfall
            b:Show()

            local tierKey = TierOf(itemID)
            local tier    = tierKey and TIERS[tierKey]

            -- Nicht markierte Items werden entsaettigt und abgedunkelt, damit
            -- die Wunschliste sofort ins Auge faellt. 0.7 statt 0.55, weil
            -- eine Liste ohne Markierungen sonst trist und tot aussieht.
            b.tex:SetDesaturated(tier == nil)
            b.tex:SetAlpha(tier and 1 or 0.7)

            -- Erhaltene Items werden stark zurueckgenommen. Sie bleiben
            -- sichtbar, damit man weiss dass der Slot erledigt ist, treten
            -- aber optisch hinter alles zurueck was noch offen ist.
            if Owned(itemID) then
                b.tex:SetDesaturated(true)
                b.tex:SetAlpha(0.3)
            end

            -- Verbrauchter Bonus Roll: durchgestrichen. Der Tooltip bleibt
            -- davon unberuehrt, die Striche sind reine Texturen und fangen
            -- keine Mausereignisse ab.
            local used = BonusUsed(itemID)
            for _, t in ipairs(b.slash) do
                if used then t:Show() else t:Hide() end
            end

            if tier then
                local r, g, bl = HexToRGB(tier.color)
                if Owned(itemID) then r, g, bl = HexToRGB(INK_DIM) end
                for _, t in ipairs(b.edges) do t:SetColorTexture(r, g, bl, 0.95) end
                -- Zeichen nur auf Wunsch. Der farbige Rahmen genuegt normal,
                -- die Zeichen sind fuer Farbsehschwaeche gedacht.
                if SlotMachineDB.showMarks then
                    b.markBg:Show()
                    b.mark:SetText("|c" .. tier.color .. tier.mark .. "|r")
                    b.mark:Show()
                else
                    b.markBg:Hide()
                    b.mark:Hide()
                end
            else
                for _, t in ipairs(b.edges) do
                    t:SetColorTexture(EDGE[1], EDGE[2], EDGE[3], 0.35)
                end
                b.markBg:Hide()
                b.mark:Hide()
            end

            -- Itemlevel: Differenz zum eigenen Teil, oder absolut auf Wunsch
            if SlotMachineDB.hideItemLevel then
                b.ilvlBg:Hide(); b.ilvl:Hide()
            else
                local lvl = ItemLevelOf(itemID, src.encounterID)
                if not lvl then
                    b.ilvlBg:Hide(); b.ilvl:Hide()
                    -- Anstossen, damit es beim naechsten Aufbau da ist
                    if C_Item and C_Item.RequestLoadItemDataByID then
                        pcall(C_Item.RequestLoadItemDataByID, itemID)
                    end
                elseif SlotMachineDB.absoluteItemLevel then
                    -- In der Farbe des Upgrade-Tracks, aus dem das Item
                    -- stammt. Damit sieht man ohne Rechnen, ob es sich um
                    -- Champion-, Hero- oder Myth-Ware handelt.
                    local li = ResolvedForBoss(rowEncounter)
                    b.ilvl:SetText("|c" .. ((li and li.color) or INK) .. lvl .. "|r")
                    b.ilvlBg:Show(); b.ilvl:Show()
                else
                    local mine = EquippedLevelFor(itemID)
                    if not mine then
                        b.ilvl:SetText("|c" .. INK_DIM .. lvl .. "|r")
                    else
                        local d = lvl - mine
                        local col = (d > 0 and GREEN) or INK_DIM
                        if SlotMachineDB.charGain then
                            -- Auswirkung auf das GESAMTE Charakter-Itemlevel.
                            --
                            -- Das Durchschnitts-Itemlevel bildet sich aus
                            -- sechzehn Ausruestungsplaetzen. Ein Zugewinn in
                            -- einem Slot schlaegt also nur mit einem
                            -- Sechzehntel durch. Aus "+26 am Ring" werden
                            -- "+1.6" am Charakter, und das ist die Zahl, die
                            -- am Ende in der Gruppensuche zaehlt.
                            --
                            -- Die Sechzehn ist keine Schaetzung: Sie steht so
                            -- in der eigenen Master-Notiz, wo begruendet wird,
                            -- dass ein einzelnes schwaches Teil den Schnitt um
                            -- rund ein Sechzehntel nach unten zieht.
                            local g = d / 16
                            b.ilvl:SetText(string.format("|c%s%s%.1f|r",
                                col, (g > 0 and "+" or ""), g))
                        else
                            b.ilvl:SetText("|c" .. col .. (d > 0 and ("+" .. d) or tostring(d)) .. "|r")
                        end
                    end
                    b.ilvlBg:Show(); b.ilvl:Show()
                end
            end

            b:SetScript("OnClick", function(self, button)
                if button == "RightButton" then
                    OpenTierMenu(self, itemID)
                else
                    CycleTier(itemID)
                    UI:Render()
                end
            end)
            b:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

                -- Tooltip auf dem gewaehlten Niveau. Der Link mit angehaengter
                -- Bonus-ID laesst WoW selbst rendern, samt korrekter
                -- Sekundaerstats.
                --
                -- WICHTIG, hier lag der Fehler der ersten Fassung: pcall meldet
                -- nur, dass nichts abgestuerzt ist. Ein Link, den WoW nicht
                -- versteht, stuerzt aber gar nicht ab, er zeigt schlicht nichts.
                -- Der Aufruf galt damit als erfolgreich, der Rueckfall griff
                -- nie und es erschien ueberhaupt kein Tooltip.
                --
                -- Deshalb wird jetzt geprueft, ob wirklich Zeilen im Tooltip
                -- stehen. Das ist der einzige verlaessliche Beleg dafuer, dass
                -- der Link verstanden wurde.
                local lvlInfo = ResolvedForBoss(rowEncounter)
                local shown = false
                if lvlInfo and lvlInfo.bonusId and ns.BuildItemLink then
                    local link = ns.BuildItemLink(itemID, lvlInfo.bonusId)
                    if pcall(GameTooltip.SetHyperlink, GameTooltip, link) then
                        shown = (GameTooltip:NumLines() or 0) > 0
                    end
                end
                if not shown then
                    GameTooltip:ClearLines()
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    GameTooltip:SetItemByID(itemID)
                end

                GameTooltip:AddLine(" ")
                if lvlInfo then
                    local q = CurrentSource()
                    GameTooltip:AddLine(string.format("%s  ·  %s %s  ·  %d",
                        (q and q.label) or "?", lvlInfo.track, lvlInfo.badge, lvlInfo.ilvl),
                        HexToRGB(lvlInfo.color))
                    if SlotMachineDB.bonusRoll and ns.HasBonusRoll(q) then
                        GameTooltip:AddLine("Bonus Roll, entspricht der Großen Schatzkammer dieser Stufe",
                            0.65, 0.63, 0.58, true)
                    end
                end

                local cur = TierOf(itemID)
                if cur then
                    GameTooltip:AddLine("Markiert: " .. TIERS[cur].label, HexToRGB(TIERS[cur].color))
                end
                if Owned(itemID) then
                    GameTooltip:AddLine("Hast du bereits", HexToRGB(GREEN))
                end
                if BonusUsed(itemID) then
                    GameTooltip:AddLine("Bonus Roll dafür verbraucht", HexToRGB(ACCENT))
                end
                GameTooltip:AddLine("Linksklick schaltet die Stufe weiter", 0.65, 0.63, 0.58)
                GameTooltip:AddLine("Rechtsklick für Besitz und Bonus Roll", 0.65, 0.63, 0.58)
                GameTooltip:Show()
            end)
            b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end

        y = y + rowHeight + 2
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

    -- Fensterhoehe an den Inhalt anpassen.
    --
    -- Der Unterschied ist erheblich: Dungeons stehen als acht zusammengefasste
    -- Zeilen da, Raids als gut vierzig Boss-Zeilen. Eine feste Hoehe laesst im
    -- einen Fall die halbe Flaeche leer und erzwingt im anderen staendiges
    -- Scrollen. Nach oben gedeckelt, damit das Fenster nie ueber den
    -- Bildschirm hinauswaechst, nach unten, damit es nicht zum Streifen wird.
    local chrome = PAD + 56 + PAD + 22          -- Kopf, Filterleiste, Fusszeile
    local want   = chrome + y + 6
    frame:SetHeight(math.max(MIN_HEIGHT, math.min(MAX_HEIGHT, want)))
end

-- ----------------------------------------------------------------------------
-- Einstellungen
-- ----------------------------------------------------------------------------

local optFrame = CreateFrame("Frame", nil, frame)
optFrame:SetSize(320, 276)
optFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -PAD, -(PAD + 26))
optFrame:SetFrameStrata("DIALOG")
optFrame:Hide()
local obg = optFrame:CreateTexture(nil, "BACKGROUND")
obg:SetAllPoints()
obg:SetColorTexture(BG[1], BG[2], BG[3], 0.99)
AddEdges(optFrame)

local optTitle = optFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
optTitle:SetPoint("TOPLEFT", optFrame, "TOPLEFT", 10, -8)
optTitle:SetText("|c" .. ACCENT .. "EINSTELLUNGEN|r")

-- Ein Umschalter. Kein Blizzard-Widget, weil deren Checkbox eine feste Optik
-- mitbringt, die neben der flachen Flaeche hier fremd wirkt.
local function MakeToggle(parent, y, label, get, set, hint)
    local b = CreateFrame("Button", nil, parent)
    b:SetSize(280, 22)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, y)

    b.box = b:CreateTexture(nil, "ARTWORK")
    b.box:SetSize(12, 12)
    b.box:SetPoint("LEFT", b, "LEFT", 0, 0)

    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    b.text:SetPoint("LEFT", b, "LEFT", 20, 0)
    b.text:SetText("|c" .. INK .. label .. "|r")

    function b:Refresh()
        local on = get()
        if on then
            local r, g, bl = HexToRGB(ACCENT)
            self.box:SetColorTexture(r, g, bl, 0.95)
        else
            self.box:SetColorTexture(SURFACE[1], SURFACE[2], SURFACE[3], 0.9)
        end
    end

    b:SetScript("OnClick", function(self) set(not get()); self:Refresh(); ns.UI:Render() end)
    b:SetScript("OnEnter", function(self)
        if not hint then return end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(label, 1, 1, 1)
        GameTooltip:AddLine(hint, 0.65, 0.63, 0.58, true)
        GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function() GameTooltip:Hide() end)
    b:Refresh()
    return b
end

local optToggles = {}

optToggles[#optToggles + 1] = MakeToggle(optFrame, -32, "Dungeons: eine Zeile pro Boss",
    function() return (SlotMachineDB.groupBy or "DUNGEON") == "BOSS" end,
    function(v) SlotMachineDB.groupBy = v and "BOSS" or "DUNGEON" end,
    "Standard ist eine Zeile je Dungeon, weil man ihn am Stück durchläuft und die Frage lautet: wo gehe ich hin. Gilt nur für Dungeons. Raids werden immer nach Boss aufgelistet, weil man dort einzelne Bosse ansteuert.")

optToggles[#optToggles + 1] = MakeToggle(optFrame, -58, "Alle Klassen im Spec-Filter",
    function() return SlotMachineDB.allClasses end,
    function(v) SlotMachineDB.allClasses = v or nil end,
    "Zeigt alle 40 Spezialisierungen statt nur die der eigenen Klasse. Nützlich für Twinks oder wenn man für Mitspieler schaut.")

optToggles[#optToggles + 1] = MakeToggle(optFrame, -84, "Zeichen an markierten Items",
    function() return SlotMachineDB.showMarks end,
    function(v) SlotMachineDB.showMarks = v or nil end,
    "Blendet zusätzlich zum farbigen Rahmen ein Zeichen ein. Sinnvoll bei Farbsehschwäche: Orange und Grün liegen bei Deuteranopie dicht beieinander.")

optToggles[#optToggles + 1] = MakeToggle(optFrame, -110, "Item Level absolut statt als Differenz",
    function() return SlotMachineDB.absoluteItemLevel end,
    function(v) SlotMachineDB.absoluteItemLevel = v or nil end,
    "Standard ist die Differenz zu deinem angelegten Teil, also +13 statt 311. Bei Doppelplätzen wie Ringen wird gegen das schwächere der beiden gerechnet, weil du dieses ersetzen würdest.")

optToggles[#optToggles + 1] = MakeToggle(optFrame, -136, "Zugewinn fürs Charakter-Item-Level",
    function() return SlotMachineDB.charGain end,
    function(v) SlotMachineDB.charGain = v or nil end,
    "Rechnet die Differenz auf das gesamte Charakter-Item-Level um. Ein Zugewinn in einem Slot schlägt nur mit einem Sechzehntel durch, aus +26 am Ring werden also +1.6 am Charakter. Das ist die Zahl, die in der Gruppensuche zählt.")

optToggles[#optToggles + 1] = MakeToggle(optFrame, -162, "Item Level ganz ausblenden",
    function() return SlotMachineDB.hideItemLevel end,
    function(v) SlotMachineDB.hideItemLevel = v or nil end,
    "Blendet die Zahl am Icon aus. Der Tooltip zeigt sie weiterhin.")

optToggles[#optToggles + 1] = MakeToggle(optFrame, -188, "Minimap-Knopf anzeigen",
    function() return not (ns.Minimap and ns.Minimap:IsHidden()) end,
    function() if ns.Minimap then ns.Minimap:Toggle() end end,
    "Der Knopf lässt sich per Ziehen um die Minimap bewegen.")

local optLegend = optFrame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
optLegend:SetPoint("TOPLEFT", optFrame, "TOPLEFT", 10, -220)
optLegend:SetWidth(300)
optLegend:SetJustifyH("LEFT")
do
    local parts = {}
    for _, key in ipairs(TIER_ORDER) do
        local t = TIERS[key]
        parts[#parts + 1] = "|c" .. t.color .. t.label .. "|r (" .. t.weight .. ")"
    end
    optLegend:SetText("Gewichtung: " .. table.concat(parts, ", "))
end

-- Echtes Zahnrad statt eines getippten "o". Blizzard liefert die Grafik
-- bereits mit, es braucht also keine eigene Datei im Add-on.
local gearBtn = CreateFrame("Button", nil, frame)
gearBtn:SetSize(18, 18)
gearBtn:SetPoint("RIGHT", closeBtn, "LEFT", -6, 0)

gearBtn.icon = gearBtn:CreateTexture(nil, "ARTWORK")
gearBtn.icon:SetAllPoints()
gearBtn.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
-- Auf INK_DIM eingefaerbt, damit das Zahnrad im Ruhezustand so leise ist wie
-- der Schliessen-Knopf daneben und nicht staendig Aufmerksamkeit zieht.
gearBtn.icon:SetVertexColor(HexToRGB(INK_DIM))

gearBtn:SetScript("OnEnter", function(self)
    self.icon:SetVertexColor(HexToRGB(ACCENT))
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Einstellungen")
    GameTooltip:Show()
end)
gearBtn:SetScript("OnLeave", function(self)
    self.icon:SetVertexColor(HexToRGB(INK_DIM))
    GameTooltip:Hide()
end)
gearBtn:SetScript("OnClick", function() ns.UI:ToggleOptions() end)

function UI:ToggleOptions()
    if optFrame:IsShown() then
        optFrame:Hide()
    else
        if not frame:IsShown() then frame:Show(); UI:Render() end
        for _, t in ipairs(optToggles) do t:Refresh() end
        optFrame:Show()
    end
end

-- Escape schliesst das Fenster.
--
-- WoW erledigt das selbst, sobald der GLOBALE Name des Frames in
-- UISpecialFrames steht. Deshalb muss das Fenster einen Namen haben, ein
-- anonymes Frame liesse sich so nicht ansprechen.
--
-- Wichtig ist der Weg ueber OnHide weiter unten: Escape ruft nicht UI:Toggle
-- auf, sondern versteckt das Frame direkt. Ohne den Handler blieben die
-- Menues offen im Bildschirm stehen, nachdem das Fenster darunter weg ist.
tinsert(UISpecialFrames, "SlotMachine_MainFrame")

frame:HookScript("OnHide", function()
    if optFrame  then optFrame:Hide()  end
    if slotMenu  then slotMenu:Hide()  end
    if specMenu  then specMenu:Hide()  end
    if subMenu   then subMenu:Hide()   end
    if srcMenu   then srcMenu:Hide()   end
    if tierMenu  then tierMenu:Hide()  end
end)

function UI:Toggle()
    if frame:IsShown() then
        frame:Hide()
        tierMenu:Hide()
    else
        MigrateWanted()
        -- Beim ersten Oeffnen einer Sitzung auf die aktive Spezialisierung
        -- vorfiltern. Wer das Fenster aufmacht, will in aller Regel sehen was
        -- er gerade gebrauchen kann, nicht den Loot aller 40 Specs.
        if currentSpec == nil and not UI._specInitDone then
            currentSpec = ActiveSpecID()
            UI._specInitDone = true
        end
        frame:Show()
        UI:Render()
    end
end

function UI:RestorePosition()
    if SlotMachineDB.point then
        frame:ClearAllPoints()
        local ok = pcall(frame.SetPoint, frame, SlotMachineDB.point, UIParent,
            SlotMachineDB.relPoint, SlotMachineDB.x, SlotMachineDB.y)
        if not ok then frame:ClearAllPoints(); frame:SetPoint("CENTER") end
    end
end
