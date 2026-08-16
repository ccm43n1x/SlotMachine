-- ============================================================================
-- SlotMachine - Bestandsaufnahme (Taschen, Bank, angelegte Ausruestung)
-- ============================================================================
--
-- Grundlage fuer die Gratis-Upgrade-Erkennung (Gruppe B der Reihenfolge).
--
-- WORUM ES GEHT: Fuer die Aufwertungskosten eines Slots zaehlt das HOECHSTE
-- Itemlevel, das in diesem Slot je ANGELEGT war. Liegt im Bestand ein Teil mit
-- hoeherem Itemlevel als das getragene, laesst sich durch einmaliges Anlegen
-- der Slot-Wert heben. Danach ist das eigentliche Wunsch-Teil bis zu dieser
-- Marke ohne Crests aufwertbar, es kostet nur noch Gold.
--
-- Hintergrund, Belege und Fallstricke stehen im Vault unter
-- "Crest-Rabatt ueber das Slot-Itemlevel".
--
-- STAND: Diagnose. Diese Datei sammelt und zeigt nur. Die Empfehlungslogik
-- kommt in B3, die Oberflaeche in B4.

local AddonName, ns = ...

ns.Inventory = {}
local Inventory = ns.Inventory

local function Say(msg)
    if ns.Scanner and ns.Scanner.Say then
        ns.Scanner.Say(msg)
    else
        print("|cff33ff99SlotMachine|r " .. tostring(msg))
    end
end

-- ----------------------------------------------------------------------------
-- equipLoc auf die Ausruestungsplaetze der Spielfigur
-- ----------------------------------------------------------------------------
-- Bewusst hier und auf ns gelegt, nicht in ui.lua. Dort liegt dieselbe Tabelle
-- als local, also fuer andere Dateien unerreichbar. Wenn ui.lua irgendwann
-- angefasst wird, kann die dortige Fassung durch ns.EQUIP_SLOTS ersetzt werden.
-- Bis dahin bleiben es zwei Kopien, das ist bekannt und in Kauf genommen.
--
-- Ringe, Schmuck und Waffen haben zwei Plaetze, deshalb Listen. Fuer den
-- Vergleich zaehlt bei Doppel-Plaetzen der SCHWAECHERE, weil genau der ersetzt
-- wuerde.
ns.EQUIP_SLOTS = {
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

local SLOT_NAME = {
    [1] = "Kopf", [2] = "Hals", [3] = "Schultern", [5] = "Brust",
    [6] = "Taille", [7] = "Beine", [8] = "Fuesse", [9] = "Handgelenke",
    [10] = "Haende", [11] = "Ring 1", [12] = "Ring 2",
    [13] = "Schmuck 1", [14] = "Schmuck 2", [15] = "Ruecken",
    [16] = "Waffe", [17] = "Nebenhand",
}

-- ----------------------------------------------------------------------------
-- Slot-Gruppen (B3a)
-- ----------------------------------------------------------------------------
-- Der Vergleich laeuft nicht pro Ausruestungsplatz, sondern pro GRUPPE. Ringe,
-- Schmuck und Waffen haben zwei Plaetze; ein Ring aus der Tasche konkurriert
-- mit beiden angelegten Ringen.
--
-- Fuer die Frage "ist das ein Hebel" zaehlt bei Doppel-Plaetzen der
-- SCHWAECHERE der beiden, weil genau der ersetzt wuerde. Ein 300er Ring neben
-- einem 290er und einem 310er ist ein Upgrade, auch wenn er unter dem besseren
-- liegt.
local GROUP_OF = {
    INVTYPE_HEAD = "HEAD", INVTYPE_NECK = "NECK", INVTYPE_SHOULDER = "SHOULDER",
    INVTYPE_CLOAK = "BACK", INVTYPE_CHEST = "CHEST", INVTYPE_ROBE = "CHEST",
    INVTYPE_WRIST = "WRIST", INVTYPE_HAND = "HANDS", INVTYPE_WAIST = "WAIST",
    INVTYPE_LEGS = "LEGS", INVTYPE_FEET = "FEET",
    INVTYPE_FINGER = "FINGER", INVTYPE_TRINKET = "TRINKET",
    INVTYPE_WEAPON = "WEAPON", INVTYPE_2HWEAPON = "WEAPON",
    INVTYPE_WEAPONMAINHAND = "WEAPON",
    INVTYPE_RANGED = "WEAPON", INVTYPE_RANGEDRIGHT = "WEAPON",
    INVTYPE_SHIELD = "OFFHAND", INVTYPE_HOLDABLE = "OFFHAND",
}

-- Reihenfolge wie am Charakter, damit die Ausgabe lesbar bleibt.
local GROUP_ORDER = {
    { key = "HEAD",     label = "Kopf",        slots = { 1 } },
    { key = "NECK",     label = "Hals",        slots = { 2 } },
    { key = "SHOULDER", label = "Schultern",   slots = { 3 } },
    { key = "BACK",     label = "Ruecken",     slots = { 15 } },
    { key = "CHEST",    label = "Brust",       slots = { 5 } },
    { key = "WRIST",    label = "Handgelenke", slots = { 9 } },
    { key = "HANDS",    label = "Haende",      slots = { 10 } },
    { key = "WAIST",    label = "Taille",      slots = { 6 } },
    { key = "LEGS",     label = "Beine",       slots = { 7 } },
    { key = "FEET",     label = "Fuesse",      slots = { 8 } },
    { key = "FINGER",   label = "Ringe",       slots = { 11, 12 } },
    { key = "TRINKET",  label = "Schmuck",     slots = { 13, 14 } },
    { key = "WEAPON",   label = "Waffe",       slots = { 16 } },
    { key = "OFFHAND",  label = "Nebenhand",   slots = { 17 } },
}

-- Zugriff fuer andere Dateien. GROUP_ORDER und GROUP_OF bleiben local, damit
-- niemand sie versehentlich veraendert; gelesen wird ueber diese beiden.
--
-- Genau der Fehler, der in ui.lua steckt: Dort liegt dieselbe Slot-Zuordnung
-- als local und ist deshalb fuer keine andere Datei erreichbar. Sie musste
-- hier neu geschrieben werden.
function Inventory:GroupOrder()
    return GROUP_ORDER
end

function Inventory:GroupOf(equipLoc)
    return GROUP_OF[equipLoc or ""]
end

-- ----------------------------------------------------------------------------
-- Crest-Bestaende (B3b)
-- ----------------------------------------------------------------------------
-- KEINE ABHAENGIGKEIT ZU CHRISSI'S ADDON. Die Tabelle steht hier vollstaendig
-- und mit eigenen Zahlen. SlotMachine laeuft allein, ohne dass das andere
-- Add-on installiert sein muss. Es gibt keinen Aufruf, kein gemeinsames
-- Namespace und keine geteilte Datei.
--
-- Was uebernommen wurde, ist WISSEN, nicht CODE: Die IDs sind Blizzards eigene
-- Spieldaten, also Fakten wie Item- oder Quest-IDs. Sie wurden einmal per Scan
-- ermittelt und im Vault dokumentiert, statt sie hier ein zweites Mal zu
-- suchen. Genau wie die Bonus-IDs in tracks.lua.
--
-- Falls sich eine ID als falsch herausstellt, muss sie an beiden Stellen
-- korrigiert werden. Das ist der bewusst in Kauf genommene Preis fuer die
-- Unabhaengigkeit der beiden Add-ons.
--
-- Adventurer steht mit in der Liste, obwohl tracks.lua diesen Track nicht
-- fuehrt. Fuer den Reihenfolge-Trick zaehlt aber genau die naechstniedrigere
-- Sorte, und die kann Adventurer sein.
ns.CREST_CURRENCY = {
    { key = "adventurer", id = 3442, name = "Adventurer" },
    { key = "veteran",    id = 3443, name = "Veteran"    },
    { key = "champion",   id = 3444, name = "Champion"   },
    { key = "hero",       id = 3445, name = "Hero"       },
    { key = "myth",       id = 3446, name = "Myth"       },
}

function Inventory:ReadCrests()
    local out = {}
    if not (C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo) then return out end
    for _, c in ipairs(ns.CREST_CURRENCY) do
        local ok, info = pcall(C_CurrencyInfo.GetCurrencyInfo, c.id)
        if ok and info then
            out[c.key] = {
                amount = info.quantity or 0,
                name   = info.name or c.name,
                max    = info.maxQuantity,
            }
        end
    end
    return out
end

-- ----------------------------------------------------------------------------
-- Umkehrtabelle: Bonus-ID -> Track und Rang
-- ----------------------------------------------------------------------------
-- tracks.lua fuehrt je Track sechs Bonus-IDs, bisher nur zum ERZEUGEN von
-- Links benutzt. Hier laufen sie rueckwaerts: aus der Bonus-ID eines echten
-- Items auf Track und Rang schliessen.
--
-- WARUM NICHT UEBER DAS ITEMLEVEL: Das Itemlevel ist mehrdeutig. 292 ist
-- gleichzeitig Veteran 5/6 und Champion 1/6, 305 gleichzeitig Champion 5/6 und
-- Hero 1/6. Genau diese Ueberlappung von drei Stufen ist die Grundlage des
-- Crest-Rabatts, also ist sie kein Randfall, sondern der Normalfall.
--
-- UNGEPRUEFT: Die Bonus-IDs stammen aus Keystone Loots Tabelle. Ob echte
-- Items im Bestand exakt dieselben tragen, ist der Zweck dieser Diagnose.
-- Wenn die Trefferquote schlecht ist, brauchen wir einen anderen Weg.
local BONUS_TO_TRACK = {}
local bonusMapBuilt = false

-- WICHTIG: Diese Tabelle muss stehen, BEVOR das erste Item gelesen wird.
--
-- Am 16.08.2026 wurde sie nur von der Ausgabe aufgebaut. Ein Aufruf von
-- /sm bag baute sie und scannte danach, also stimmte dort alles. Die
-- automatische Erfassung beim Login lief dagegen ohne sie: leere Tabelle,
-- IdentifyTrack lieferte fuer JEDES Item nil, und weil ein Teil ohne
-- erkannten Track als "nicht aufwertbar" gilt, blieb das Aufwertungsfenster
-- komplett leer. Der Fehler sah aus wie ein Anzeigefehler und war einer der
-- Reihenfolge.
--
-- Deshalb doppelt abgesichert: einmal beim Start ueber Init, und zusaetzlich
-- traege beim ersten Zugriff. Eine Nachschlagetabelle darf nie davon
-- abhaengen, dass vorher jemand die Anzeige geoeffnet hat.
local function BuildBonusMap()
    if not ns.TRACKS then return 0 end
    wipe(BONUS_TO_TRACK)
    local n = 0
    for key, track in pairs(ns.TRACKS) do
        for rank, bonusId in ipairs(track.bonus or {}) do
            BONUS_TO_TRACK[bonusId] = { track = key, rank = rank }
            n = n + 1
        end
    end
    bonusMapBuilt = (n > 0)
    return n
end

-- Bonus-IDs aus einem Item-Link ziehen.
--
-- Aufbau, Feldnummern ab 1:
--   1 itemID   2 enchant   3-6 Sockel   7 suffix   8 unique
--   9 linkLevel   10 specID   11 modifiersMask   12 itemContext
--   13 numBonusIDs   14.. die Bonus-IDs   danach Modifier
--
-- ZWEI FALLSTRICKE, die hier am 16.08.2026 beide zugeschlagen haben:
--
-- 1. Das Feld mit der ANZAHL ist die 13, nicht die 14. Wer sich um eins
--    vertut, liest die erste Bonus-ID als Anzahl und danach Unsinn.
--
-- 2. gmatch mit "([^:]*)" ist in Lua unbrauchbar zum Zerlegen. Das Muster
--    kann die leere Zeichenkette treffen und liefert zwischen den echten
--    Feldern zusaetzliche Leertreffer. Damit verschieben sich alle Indizes.
--    Richtig ist ein Durchlauf mit string.find, der die Trennzeichen sucht
--    und die Stuecke dazwischen nimmt, auch wenn sie leer sind.
local function Split(s, sep)
    local out, pos = {}, 1
    while true do
        local a, b = s:find(sep, pos, true)
        if not a then out[#out + 1] = s:sub(pos) break end
        out[#out + 1] = s:sub(pos, a - 1)
        pos = b + 1
    end
    return out
end

local function BonusIDsOf(link)
    if not link then return {} end
    local payload = link:match("|Hitem:([%-%d:]*)")
    if not payload then return {} end

    local parts = Split(payload, ":")

    local numBonus = tonumber(parts[13]) or 0
    local out = {}
    for i = 1, numBonus do
        local id = tonumber(parts[13 + i])
        if id then out[#out + 1] = id end
    end
    return out
end

-- Track und Rang eines Items bestimmen. Gibt nil zurueck, wenn keine bekannte
-- Aufwertungs-Bonus-ID dranhaengt (etwa bei Craft-Items oder Altcontent).
function Inventory:IdentifyTrack(link)
    -- Traeges Nachziehen als Netz. Greift nur, wenn Init aus irgendeinem
    -- Grund nicht gelaufen ist.
    if not bonusMapBuilt then BuildBonusMap() end

    for _, id in ipairs(BonusIDsOf(link)) do
        local hit = BONUS_TO_TRACK[id]
        if hit then return hit.track, hit.rank end
    end
    return nil, nil
end

-- ----------------------------------------------------------------------------
-- Ein einzelnes Item einlesen
-- ----------------------------------------------------------------------------

local function ReadItem(link, where)
    if not link then return nil end

    local ok, itemID, _, _, equipLoc = pcall(C_Item.GetItemInfoInstant, link)
    if not ok or not itemID then return nil end

    -- Nicht anlegbar, also fuer uns uninteressant (Trank, Rezept, Muell).
    local slots = ns.EQUIP_SLOTS[equipLoc or ""]
    if not slots then return nil end

    local ilvl
    local ok2, lvl = pcall(C_Item.GetDetailedItemLevelInfo, link)
    if ok2 then ilvl = lvl end

    local track, rank = Inventory:IdentifyTrack(link)

    return {
        link = link, itemID = itemID, equipLoc = equipLoc,
        slots = slots, ilvl = ilvl, track = track, rank = rank,
        where = where, bonus = BonusIDsOf(link),
    }
end

-- ----------------------------------------------------------------------------
-- Angelegte Ausruestung
-- ----------------------------------------------------------------------------

function Inventory:ScanEquipped()
    local out = {}
    for slotID = 1, 17 do
        if slotID ~= 4 then   -- 4 ist das Hemd, zaehlt nicht
            local ok, link = pcall(GetInventoryItemLink, "player", slotID)
            if ok and link then
                local item = ReadItem(link, "angelegt")
                if item then
                    item.equippedSlot = slotID
                    out[slotID] = item
                end
            end
        end
    end
    return out
end

-- ----------------------------------------------------------------------------
-- Taschen und Bank
-- ----------------------------------------------------------------------------
-- Defensiv gebaut: Es wird eine Liste moeglicher Behaelter-IDs abgelaufen und
-- alles uebersprungen, was der Client nicht kennt. So faellt nichts um, wenn
-- Blizzard die Nummerierung wieder aendert (Reagenzientasche, Warband-Bank).
--
-- Die Bank liefert nur dann Inhalte, wenn sie offen ist. Void Storage ebenso.
-- Das ist keine Einschraenkung des Codes, sondern eine des Spiels.

local CONTAINERS = {
    { id = 0, label = "Rucksack" },
    { id = 1, label = "Tasche 1" }, { id = 2, label = "Tasche 2" },
    { id = 3, label = "Tasche 3" }, { id = 4, label = "Tasche 4" },
    { id = 5, label = "Reagenzien" },
    { id = -1, label = "Bank" },
    { id = 6, label = "Bank 1" }, { id = 7, label = "Bank 2" },
    { id = 8, label = "Bank 3" }, { id = 9, label = "Bank 4" },
    { id = 10, label = "Bank 5" }, { id = 11, label = "Bank 6" },
    { id = 12, label = "Bank 7" },
}

function Inventory:ScanContainers()
    local out = {}
    if not C_Container then return out end

    for _, c in ipairs(CONTAINERS) do
        local ok, slots = pcall(C_Container.GetContainerNumSlots, c.id)
        if ok and slots and slots > 0 then
            for i = 1, slots do
                local ok2, link = pcall(C_Container.GetContainerItemLink, c.id, i)
                if ok2 and link then
                    local item = ReadItem(link, c.label)
                    if item then
                        -- Behaelter und Platz merken, damit der Link beim
                        -- Nachladen erneut geholt werden kann.
                        item.bag, item.slot = c.id, i
                        out[#out + 1] = item
                    end
                end
            end
        end
    end
    return out
end

-- ----------------------------------------------------------------------------
-- Diagnose-Ausgabe
-- ----------------------------------------------------------------------------

local function Describe(item)
    local t = "|cff808080kein Track erkannt|r"
    if item.track then
        local tr = ns.TRACKS[item.track]
        t = string.format("|c%s%s %d/6|r", tr.color, tr.letter, item.rank)
    end
    local bonus = (#item.bonus > 0) and table.concat(item.bonus, ",") or "-"
    return string.format("%s  ilvl |cffffd100%s|r  %s  |cff606060[%s]|r",
        item.link or "?", tostring(item.ilvl or "?"), t, bonus)
end

-- ----------------------------------------------------------------------------
-- Zum Nachladen: Item-Daten kommen asynchron
-- ----------------------------------------------------------------------------
-- Dasselbe Problem wie beim Journal-Scan. Was nicht im Client-Cache liegt, hat
-- keinen Namen und kein Itemlevel. Am 16.08.2026 betraf das JEDES Teil in den
-- Taschen, waehrend die angelegten Teile vollstaendig waren. Angelegtes ist
-- immer geladen, Taschenware nicht.
--
-- Hier gab es zwischenzeitlich einen eigenen Nachlade-Apparat mit Runden und
-- Zaehlern, wie in scanner_full.lua. Der ist beim Umbau auf die
-- ereignisgesteuerte Aktualisierung ueberfluessig geworden und wurde entfernt:
--
-- Update() scannt jedes Mal von vorn, holt also auch die Links frisch. Ein
-- unvollstaendiger Durchlauf fordert die fehlenden Daten an und plant genau
-- EINEN weiteren Durchlauf ein. Der liest dann automatisch die inzwischen
-- geladenen Namen und Itemlevel mit. Kein zweiter Mechanismus noetig.
--
-- Die Felder bag und slot am Item bleiben trotzdem gesetzt. Sie kosten nichts
-- und werden fuer eine spaetere Funktion "zeig mir wo es liegt" gebraucht.

-- ============================================================================
-- Stiller Zustand, ereignisgesteuert (16.08.2026)
-- ============================================================================
--
-- WARUM DAS ANDERS IST ALS DER JOURNAL-SCAN: /sm scan liest das Encounter
-- Journal. Das Ergebnis ist fuer alle Spieler gleich, laeuft einmal pro Season
-- beim Entwickler und wird als data.lua ausgeliefert. Nutzer fuehren es nie aus.
--
-- Die Bestandsaufnahme kann das grundsaetzlich nicht. Sie liest die Taschen,
-- die Ausruestung und die Waehrungen DES NUTZERS. Das ist bei jedem anders und
-- aendert sich bei jedem Drop. Also muss sie beim Nutzer laufen, automatisch
-- und ohne dass er ein Kommando kennt.
--
-- AUFTEILUNG: Update() schreibt still in ns.Inventory.state. Die Ausgabe
-- (Report) und spaeter die Oberflaeche LESEN diese Tabelle und scannen nicht
-- selbst. Ein Fenster, das beim Oeffnen erst 40 Items scannt und auf das
-- Nachladen wartet, fuehlt sich kaputt an.

Inventory.state = {
    equipped = {},   -- [slotID] = item
    bag      = {},   -- Liste
    crests   = {},   -- [key] = { amount = n }
    stamp    = nil,  -- Zeitpunkt der letzten Aktualisierung
    complete = true, -- false, solange Item-Daten fehlen
}

-- Drossel. BAG_UPDATE_DELAYED feuert beim Leeren einer Tasche mehrfach, und
-- PLAYER_EQUIPMENT_CHANGED bei einem Ausruestungswechsel pro Slot. Ohne
-- Drossel wird derselbe Durchlauf ein Dutzend Mal gerechnet.
local THROTTLE = 0.5
local dirty, pending = false, false

-- Anzahl der Nachfass-Runden. Ohne Grenze ruft Update() sich selbst endlos
-- auf, solange auch nur ein Item nie in den Cache kommt. Der Kommentar sagte
-- vorher "kein Dauerlauf", der Code machte aber genau das.
local MAX_RETRIES = 5
local retries = 0

-- ----------------------------------------------------------------------------
-- Zuhoerer
-- ----------------------------------------------------------------------------
-- Wer den Bestand anzeigt, muss mitbekommen, wenn er sich aendert. Ohne das
-- rendert ein Fenster den Stand vom Oeffnungszeitpunkt und bleibt darauf
-- stehen. Am 16.08.2026 genau so passiert: Das Aufwertungsfenster zeigte
-- keinen einzigen Kandidaten, obwohl einer in der Tasche lag, weil es beim
-- Oeffnen einen unvollstaendigen Stand erwischt hatte und nie neu zeichnete.
local listeners = {}

function Inventory:Subscribe(fn)
    listeners[#listeners + 1] = fn
end

local function Notify()
    for _, fn in ipairs(listeners) do
        pcall(fn)
    end
end

function Inventory:Update()
    local bag      = self:ScanContainers()
    local equipped = self:ScanEquipped()
    local crests   = self:ReadCrests()

    -- Fehlende Item-Daten anfordern. Der naechste Durchlauf holt sie ab,
    -- ausgeloest entweder vom naechsten Ereignis oder vom Nachfassen unten.
    local missing = 0
    for _, it in ipairs(bag) do
        if not it.ilvl then
            missing = missing + 1
            if C_Item and C_Item.RequestLoadItemDataByID then
                pcall(C_Item.RequestLoadItemDataByID, it.itemID)
            end
        end
    end

    self.state.bag      = bag
    self.state.equipped = equipped
    self.state.crests   = crests
    self.state.stamp    = GetTime and GetTime() or nil
    self.state.complete = (missing == 0)

    -- Jede Aktualisierung meldet sich, auch die unvollstaendige. Ein Fenster
    -- soll den Zwischenstand zeigen duerfen und danach den vollstaendigen.
    Notify()

    -- Solange etwas fehlt, in einer Sekunde noch einmal, aber hoechstens
    -- MAX_RETRIES mal. Danach bleibt der Stand unvollstaendig und wird als
    -- solcher gekennzeichnet.
    if missing > 0 and not pending and retries < MAX_RETRIES then
        pending = true
        retries = retries + 1
        C_Timer.After(1.0, function()
            pending = false
            Inventory:Update()
        end)
    elseif missing == 0 then
        retries = 0
    end

    return self.state
end

local function MarkDirty()
    if dirty then return end
    dirty = true
    -- Neues Ereignis heisst neuer Anlauf: Der Zaehler wird zurueckgesetzt,
    -- sonst blockiert eine frueher aufgebrauchte Runde alle spaeteren.
    retries = 0
    C_Timer.After(THROTTLE, function()
        dirty = false
        Inventory:Update()
    end)
end

function Inventory:Init()
    -- Zuerst die Nachschlagetabelle, dann alles andere. Ohne sie liefert
    -- jede Track-Erkennung nil.
    BuildBonusMap()

    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")     -- Erststand nach Login/Reload
    f:RegisterEvent("BAG_UPDATE_DELAYED")        -- gesammelt nach Taschenaenderungen
    f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")  -- an- oder abgelegt
    f:RegisterEvent("CURRENCY_DISPLAY_UPDATE")   -- Crests geaendert
    f:RegisterEvent("BANKFRAME_OPENED")          -- Bank wird erst jetzt lesbar
    f:SetScript("OnEvent", function() MarkDirty() end)
    self.eventFrame = f

    -- Erster Durchlauf nicht sofort. Beim Login ist praktisch nichts im Cache,
    -- ein Scan in derselben Sekunde liefert nur Luecken.
    C_Timer.After(2.0, function() Inventory:Update() end)
end

-- ============================================================================
-- B3c: Reihenfolge ueber zwei benachbarte Tracks
-- ============================================================================
--
-- DER ZUG: Wer fuer denselben Slot ein Teil im hoeheren und eines im
-- niedrigeren Track hat, wertet ZUERST das niedrigere auf. Wegen der
-- Ueberlappung von drei Itemleveln hebt das den Slot-Wert so weit, dass der
-- naechste Rang des hoeheren Teils gratis wird.
--
-- Gespart wird nicht die MENGE an Crests, sondern die SORTE: 20 Veteran statt
-- 20 Champion. Das ist der Punkt, den man beim Erklaeren leicht verwischt.
--
-- WICHTIGE EINSCHRAENKUNG, ehrlich benannt: Das Add-on kann den echten
-- Slot-Wert (hoechstes je angelegtes Itemlevel) nicht auslesen. Es gibt dafuer
-- keine offene Schnittstelle. Hier wird deshalb mit dem HOECHSTEN AKTUELL
-- angelegten Teil gerechnet. Lag frueher einmal etwas Besseres im Slot, ist
-- der echte Wert hoeher und die Empfehlung zu vorsichtig. Sie schlaegt also
-- nie etwas vor, das teurer ist als noetig, hoechstens etwas Ueberfluessiges.

local UPGRADE_COST = 20   -- Crests je Rang, aus der Recherche

-- Hoechster Rang eines Tracks, der mit dem gegebenen Slot-Wert gratis
-- erreichbar ist. Gibt 0 zurueck, wenn nicht einmal Rang 1 gedeckt ist.
local function FreeRank(trackKey, watermark)
    local t = ns.TRACKS[trackKey]
    if not t then return 0 end
    local best = 0
    for rank, ilvl in ipairs(t.ilvl) do
        if ilvl <= watermark then best = rank end
    end
    return best
end

function Inventory:PrintOrderPlays(equipped, byGroup)
    Say("|cffffd100Reihenfolge: erst den niedrigeren Track|r")

    local crests = self.state.crests or {}
    local found  = 0

    for _, grp in ipairs(GROUP_ORDER) do
        -- Alle Teile dieses Slots mit erkanntem Track sammeln, angelegt wie
        -- im Bestand. Nur die nehmen an der Aufwertung teil.
        local tracked = {}
        for _, slotID in ipairs(grp.slots) do
            local it = equipped[slotID]
            if it and it.track then tracked[#tracked + 1] = it end
        end
        for _, it in ipairs(byGroup[grp.key] or {}) do
            if it.track then tracked[#tracked + 1] = it end
        end

        if #tracked >= 2 then
            -- Slot-Wert naeherungsweise: hoechstes aktuell angelegtes Teil.
            local watermark = 0
            for _, slotID in ipairs(grp.slots) do
                local it = equipped[slotID]
                if it and it.ilvl and it.ilvl > watermark then watermark = it.ilvl end
            end

            -- Paare benachbarter Tracks suchen
            for i, lowKey in ipairs(ns.TRACK_ORDER) do
                local upKey = ns.TRACK_ORDER[i + 1]
                if upKey then
                    local low, up
                    for _, it in ipairs(tracked) do
                        if it.track == lowKey then low = it end
                        if it.track == upKey  then up  = it end
                    end

                    if low and up then
                        local lowT, upT = ns.TRACKS[lowKey], ns.TRACKS[upKey]
                        local wm = math.max(watermark, up.ilvl or 0)

                        local freeLow = FreeRank(lowKey, wm)
                        local nextLow = freeLow + 1

                        if nextLow <= #lowT.ilvl then
                            local newWm    = lowT.ilvl[nextLow]
                            local freeUp   = FreeRank(upKey, newWm)
                            local gain     = freeUp - (up.rank or 0)

                            if gain > 0 then
                                found = found + 1
                                local have = (crests[lowKey] and crests[lowKey].amount) or 0
                                local ok   = have >= UPGRADE_COST

                                Say(string.format("  |cffffd100%s|r", grp.label))
                                Say(string.format("    1. %s auf %s %d/6 (%d) hochziehen  |cff808080kostet %d %s-Crests, du hast %s%d|r",
                                    low.link or "?", lowT.letter, nextLow, newWm,
                                    UPGRADE_COST, lowT.name,
                                    ok and "|cff00ff00" or "|cffff5555", have))
                                Say(string.format("    2. %s wird dadurch gratis bis %s %d/6 (%d)",
                                    up.link or "?", upT.letter, freeUp, upT.ilvl[freeUp]))
                                Say(string.format("    |cff00ff00Spart %d %s-Crests|r |cff808080(%d Raenge)|r",
                                    gain * UPGRADE_COST, upT.name, gain))
                                if not ok then
                                    Say(string.format("    |cffff5555Noch nicht machbar: %d %s-Crests fehlen.|r",
                                        UPGRADE_COST - have, lowT.name))
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    if found == 0 then
        Say("  |cff808080Kein Slot hat zwei Teile in benachbarten Tracks.|r")
        Say("  |cff808080Der Zug lohnt sich erst, wenn im selben Slot z.B. ein|r")
        Say("  |cff808080Veteran- UND ein Champion-Teil liegen.|r")
    end
    Say(" ")
end

-- ----------------------------------------------------------------------------
-- Diagnose des Zustands (/sm state)
-- ----------------------------------------------------------------------------
-- Zeigt genau das, was die Ansicht sieht, Schritt fuer Schritt: Ist der
-- Zustand gefuellt, kommen die Items durch die Gruppen-Zuordnung, ueberleben
-- sie den Track-Filter, und was landet am Ende je Slot als Kandidat.
--
-- Gebaut am 16.08.2026, weil das Aufwertungsfenster leer blieb, obwohl ein
-- Kandidat nachweislich in der Tasche lag, und weder ein Lua-Fehler noch ein
-- Blick in den Code die Ursache zeigte. Raten ist an dem Punkt teurer als
-- messen.
function Inventory:DumpState()
    if ns.Scanner and ns.Scanner.ResetLog then ns.Scanner:ResetLog() end
    local st = self.state or {}

    Say("|cffffd100Zustand der Bestandsaufnahme|r")
    Say(string.format("  stamp:    %s", tostring(st.stamp)))
    Say(string.format("  complete: %s", tostring(st.complete)))
    Say(string.format("  bag:      %d Eintraege", #(st.bag or {})))

    local eqN = 0
    for _ in pairs(st.equipped or {}) do eqN = eqN + 1 end
    Say(string.format("  equipped: %d Eintraege", eqN))
    Say(" ")

    Say("|cffffd100Bestand einzeln|r")
    for _, it in ipairs(st.bag or {}) do
        local g = self:GroupOf(it.equipLoc)
        Say(string.format("  %-22s grp=%-8s ilvl=%-5s track=%-9s %s",
            tostring(it.equipLoc), tostring(g), tostring(it.ilvl),
            tostring(it.track), it.link or "?"))
    end
    Say(" ")

    Say("|cffffd100Je Gruppe: was die Ansicht bilden wuerde|r")
    for _, grp in ipairs(GROUP_ORDER) do
        local eq
        for _, slotID in ipairs(grp.slots) do
            local it = (st.equipped or {})[slotID]
            if it and it.ilvl then
                if not eq or it.ilvl < eq.ilvl then eq = it end
            end
        end

        local cand, hi, lo = 0, 0, 0
        for _, it in ipairs(st.bag or {}) do
            if self:GroupOf(it.equipLoc) == grp.key then
                cand = cand + 1
                if it.track and it.ilvl and eq and eq.ilvl then
                    if it.ilvl > eq.ilvl then hi = hi + 1
                    elseif it.ilvl < eq.ilvl then lo = lo + 1 end
                end
            end
        end

        if cand > 0 or eq then
            Say(string.format("  %-12s eq=%-5s  im Slot=%d  hoeher=%d  niedriger=%d",
                grp.label, eq and tostring(eq.ilvl) or "-", cand, hi, lo))
        end
    end
    Say(" ")
    Say("Danach |cffffd100/reload|r, dann steht alles in der Datei.")
end

-- Diagnose-Ausgabe. Scannt NICHT selbst, sondern zeigt den Zustand, den die
-- ereignisgesteuerte Aktualisierung ohnehin schon gepflegt hat. Genau so soll
-- spaeter auch die Oberflaeche arbeiten.
function Inventory:Report()
    if ns.Scanner and ns.Scanner.ResetLog then ns.Scanner:ResetLog() end

    local mapped = BuildBonusMap()
    Say("|cffffd100Bestandsaufnahme|r")
    Say(string.format("Umkehrtabelle: %d Bonus-IDs aus tracks.lua", mapped))

    local st = self.state

    -- Noch nie gelaufen? Dann anstossen und kurz warten. Passiert nur, wenn
    -- man das Kommando in den ersten zwei Sekunden nach dem Login tippt.
    if not st.stamp then
        Say("Noch kein Bestand erfasst, hole ihn jetzt ...")
        self:Update()
        C_Timer.After(2.0, function() Inventory:Print() end)
        return
    end

    if not st.complete then
        Say("|cffffaa00Item-Daten noch nicht vollständig, warte kurz ...|r")
        C_Timer.After(1.5, function() Inventory:Print() end)
        return
    end

    self:Print()
end

function Inventory:Print()
    local mapped = BuildBonusMap()
    local st       = self.state
    local bag      = st.bag or {}
    local equipped = st.equipped or {}

    if not st.complete then
        Say("|cffffaa00Hinweis: einzelne Item-Daten fehlen weiterhin.|r")
    end
    Say(" ")

    -- Angelegt. Kommt aus dem Zustand, wird hier nicht neu gescannt.
    local eq, eqTracked = 0, 0
    Say("|cffffd100Angelegt|r")
    for slotID = 1, 17 do
        local it = equipped[slotID]
        if it then
            eq = eq + 1
            if it.track then eqTracked = eqTracked + 1 end
            Say(string.format("  %-12s %s", SLOT_NAME[slotID] or slotID, Describe(it)))
        end
    end
    Say(" ")

    -- Bestand: Trefferquote
    local bagTracked = 0
    for _, it in ipairs(bag) do
        if it.track then bagTracked = bagTracked + 1 end
    end
    Say(string.format("|cffffd100Im Bestand|r: %d anlegbare Teile, davon %d mit erkanntem Track",
        #bag, bagTracked))
    Say(string.format("|cffffd100Angelegt|r:   %d Teile, davon %d mit erkanntem Track", eq, eqTracked))
    Say(" ")

    -- ------------------------------------------------------------------
    -- Crest-Bestaende (B3b)
    -- ------------------------------------------------------------------
    local crests = st.crests or {}
    Say("|cffffd100Crests|r")
    local anyCrest = false
    for _, c in ipairs(ns.CREST_CURRENCY) do
        local info = crests[c.key]
        if info then
            anyCrest = true
            Say(string.format("  %-11s %s", c.name, tostring(info.amount)))
        end
    end
    if not anyCrest then
        Say("  |cff808080keine der fuenf Waehrungen gefunden. Vor Season-Start normal.|r")
    end
    Say(" ")

    -- ------------------------------------------------------------------
    -- Nach Slot gruppiert (B3a)
    -- ------------------------------------------------------------------
    -- Das ist die eigentliche Arbeitsansicht. Pro Gruppe: was ist angelegt,
    -- was liegt im Bestand, und ist etwas davon hoeher.
    --
    -- WICHTIG: Nur Teile mit erkanntem Track nehmen an der Upgrade-Logik teil.
    -- Season-1-Ware ist nicht mehr aufwertbar und kann deshalb weder Ziel noch
    -- sinnvoller Hebel sein. Sie taucht hier nur als Referenz auf, wenn sie
    -- angelegt ist.
    local byGroup = {}
    for _, it in ipairs(bag) do
        local g = GROUP_OF[it.equipLoc or ""]
        if g then
            byGroup[g] = byGroup[g] or {}
            table.insert(byGroup[g], it)
        end
    end

    Say("|cffffd100Nach Slot|r")
    local levers = 0

    for _, grp in ipairs(GROUP_ORDER) do
        -- Referenz: bei Doppel-Plaetzen das SCHWAECHERE angelegte Teil
        local refIlvl, refItem
        for _, slotID in ipairs(grp.slots) do
            local it = equipped[slotID]
            if it and it.ilvl then
                if not refIlvl or it.ilvl < refIlvl then
                    refIlvl, refItem = it.ilvl, it
                end
            end
        end

        local candidates = byGroup[grp.key] or {}
        table.sort(candidates, function(a, b) return (a.ilvl or 0) > (b.ilvl or 0) end)

        -- Kandidaten sind NUR Teile mit erkanntem aktuellem Track.
        --
        -- Ohne diesen Filter landet Altcontent in der Liste. Am 16.08.2026
        -- meldete die erste Fassung einen Hals mit "ilvl 518" und eine Waffe
        -- mit "ilvl 528" als Kandidaten. Das sind uralte Gegenstaende, deren
        -- Itemlevel auf einer voellig anderen Skala liegt. Sie sind weder
        -- aufwertbar noch tragbar und damit reines Rauschen.
        --
        -- Was nicht aufwertbar ist, kann kein Ziel sein. Genau Christophers
        -- Punkt zu Season-1-Ware, hier noch deutlicher.
        local higher, skipped = {}, 0
        for _, c in ipairs(candidates) do
            if c.ilvl and refIlvl and c.ilvl > refIlvl then
                if c.track then
                    higher[#higher + 1] = c
                else
                    skipped = skipped + 1
                end
            end
        end

        if refItem or #candidates > 0 then
            local head = string.format("  |cffffd100%-12s|r angelegt %s",
                grp.label,
                refItem and string.format("ilvl %d%s", refIlvl,
                    refItem.track and string.format(" (%s %d/6)",
                        ns.TRACKS[refItem.track].letter, refItem.rank) or "")
                    or "|cff808080leer|r")
            if #grp.slots > 1 and refItem then
                head = head .. " |cff808080(schwaecheres der beiden)|r"
            end
            Say(head)

            for _, c in ipairs(higher) do
                levers = levers + 1
                local tr = ns.TRACKS[c.track]
                Say(string.format("      |cff00ff00+%d|r auf %d  |c%s%s %d/6|r  %s",
                    c.ilvl - refIlvl, c.ilvl, tr.color, tr.letter, c.rank, c.link or "?"))
            end
            -- Ausgeblendetes benennen statt stillschweigend schlucken.
            if skipped > 0 then
                Say(string.format("      |cff606060%d hoehere ausgeblendet (nicht aufwertbar)|r", skipped))
            end
        end
    end

    Say(" ")
    if levers == 0 then
        Say("|cff808080Kein aufwertbares Teil im Bestand liegt ueber dem angelegten.|r")
    else
        Say(string.format("|cffffd100%d Kandidaten ueber dem angelegten Stand.|r", levers))
        Say("|cff808080Anlegen hebt den Slot-Wert, kostet aber bei frischem Loot|r")
        Say("|cff808080das Handelsfenster. Bei Altbestand ist das ohnehin zu.|r")
    end
    Say(" ")

    self:PrintOrderPlays(equipped, byGroup)

    -- ------------------------------------------------------------------
    -- Unbekannte IDs sammeln, damit sich tracks.lua ergaenzen laesst
    -- ------------------------------------------------------------------
    -- Der eigentliche Nutzen dieser Diagnose. Statt nur zu melden "nicht
    -- erkannt", wird jede unbekannte Bonus-ID zusammen mit den Itemleveln
    -- gezeigt, auf denen sie vorkommt. Taucht eine ID immer beim selben
    -- Itemlevel auf, ist sie sehr wahrscheinlich der Rang-Marker dieses
    -- Tracks und kann in tracks.lua nachgetragen werden.
    local unknown = {}
    local function Collect(it)
        if it.track then return end
        for _, id in ipairs(it.bonus) do
            if not BONUS_TO_TRACK[id] then
                unknown[id] = unknown[id] or {}
                local lv = tostring(it.ilvl or "?")
                unknown[id][lv] = (unknown[id][lv] or 0) + 1
            end
        end
    end
    for _, it in pairs(equipped) do Collect(it) end
    for _, it in ipairs(bag) do Collect(it) end

    local ids = {}
    for id in pairs(unknown) do ids[#ids + 1] = id end
    table.sort(ids)

    Say("|cffffd100Unbekannte Bonus-IDs mit ihren Itemleveln|r")
    Say("|cff808080Eine ID, die immer beim selben Itemlevel steht, ist ein Rang-Marker.|r")
    for _, id in ipairs(ids) do
        local parts = {}
        for lv, cnt in pairs(unknown[id]) do
            parts[#parts + 1] = string.format("%s x%d", lv, cnt)
        end
        table.sort(parts)
        Say(string.format("  %-7d %s", id, table.concat(parts, "  ")))
    end
    Say(" ")
    Say("Bank und Void Storage liefern nur Inhalte, wenn sie geoeffnet sind.")
    Say("Danach |cffffd100/reload|r, dann steht alles in der SavedVariables-Datei.")
end
