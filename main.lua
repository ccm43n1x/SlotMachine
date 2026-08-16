-- ============================================================================
-- SlotMachine - Loot & Farm Planner
-- ============================================================================
--
-- Schwester-Add-on zu Chrissi's Addon. Waehrend das den Wochenplan und das
-- Gearing abbildet, kuemmert sich SlotMachine um Loot: Wunsch-Items markieren,
-- Quellen nach Anzahl der Wunsch-Items priorisieren, Rest-Runs zaehlen.
--
-- Stand 0.1.0: nur das Geruest und der Entwickler-Scanner. Noch keine
-- Nutzeroberflaeche.

local AddonName, ns = ...

SlotMachineDB     = SlotMachineDB or {}
SlotMachineCharDB = SlotMachineCharDB or {}

local DEFAULTS = {
    scanResults = {},   -- Rohdaten des Entwickler-Scans
    scanStamp   = nil,  -- wann zuletzt gescannt
    point = "CENTER", relPoint = "CENTER", x = 0, y = 0,
    groupBy      = "DUNGEON",  -- eine Zeile je Dungeon, alternativ "BOSS"
    allClasses   = nil,        -- alle 40 Specs im Filter statt nur eigene Klasse
    showMarks    = nil,        -- Zeichen zusaetzlich zum farbigen Rahmen
    minimapAngle = 200,        -- Position des Minimap-Knopfes als Winkel
    hideMinimap  = nil,
    -- Track-Waehler. Getrennt fuer Dungeon und Raid, weil die Stufen nichts
    -- miteinander zu tun haben. Standard ist der aktuelle Pre-Season-Stand:
    -- M0 gibt Champion 1/6, im Raid ist Normal der uebliche Einstieg.
    dungeonSource = "m0",
    raidSource    = "normal",
    bonusRoll     = nil,
}

local CHAR_DEFAULTS = {
    wanted = {},        -- Wunschliste, pro Charakter
}

local function ApplyDefaults()
    for k, v in pairs(DEFAULTS) do
        if SlotMachineDB[k] == nil then
            SlotMachineDB[k] = (type(v) == "table") and {} or v
        end
    end
    for k, v in pairs(CHAR_DEFAULTS) do
        if SlotMachineCharDB[k] == nil then
            SlotMachineCharDB[k] = (type(v) == "table") and {} or v
        end
    end
end

-- Geht ueber den Scanner, damit alle Ausgaben im selben Dev-Fenster landen
-- und mit im SavedVariables-Log stehen.
local function Say(msg)
    if ns.Scanner and ns.Scanner.Say then
        ns.Scanner.Say(msg)
    else
        print("|cff33ff99SlotMachine|r " .. tostring(msg))
    end
end

-- ----------------------------------------------------------------------------
-- Instanzen des aktuellen Tiers auflisten
-- ----------------------------------------------------------------------------
-- Damit ueberhaupt eine ID zum Testen zur Hand ist. Das Journal ordnet
-- Instanzen in Tiers (Erweiterungen). EJ_GetInstanceByIndex laeuft sie ab,
-- getrennt nach Dungeons und Raids.

local function ListInstances(isRaid)
    local out, idx = {}, 1
    while true do
        local ok, id, name = pcall(EJ_GetInstanceByIndex, idx, isRaid)
        if not ok or not id then break end
        out[#out + 1] = { id = id, name = name }
        idx = idx + 1
        if idx > 60 then break end   -- Sicherheitsnetz
    end
    return out
end

local function PrintInstances()
    -- Log leeren, damit die Instanzliste vollstaendig in der Datei landet
    if ns.Scanner and ns.Scanner.ResetLog then ns.Scanner:ResetLog() end

    if not EJ_GetInstanceByIndex then
        Say("Encounter-Journal-API nicht verfügbar.")
        return
    end

    local tier
    pcall(function() tier = EJ_GetCurrentTier and EJ_GetCurrentTier() end)
    Say("Aktueller Tier: " .. tostring(tier))

    for _, mode in ipairs({ { false, "Dungeons" }, { true, "Raids" } }) do
        local list = ListInstances(mode[1])
        Say("|cffffd100" .. mode[2] .. "|r (" .. #list .. ")")
        for _, e in ipairs(list) do
            Say(string.format("   ID |cffffd100%s|r  %s", tostring(e.id), tostring(e.name)))
        end
    end

    Say("Diagnose einer Instanz: |cffffd100/sm probe <ID>|r")
end

-- ----------------------------------------------------------------------------
-- Slash-Commands
-- ----------------------------------------------------------------------------

SLASH_SLOTMACHINE1 = "/sm"
SLASH_SLOTMACHINE2 = "/slotmachine"

SlashCmdList["SLOTMACHINE"] = function(msg)
    msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    local cmd, rest = msg:match("^(%S+)%s*(.*)$")
    cmd = cmd or ""

    if cmd == "instances" then
        PrintInstances()

    elseif cmd == "probe" then
        local id = tonumber(rest)
        if not id then
            Say("Nutzung: |cffffd100/sm probe <InstanzID>|r. IDs zeigt |cffffd100/sm instances|r.")
        else
            ns.Scanner:Probe(id)
        end

    elseif cmd == "bosses" then
        -- Bossnamen zu ihren IDs. Gebraucht fuer die bossabhaengigen
        -- Itemlevel im Raid: Spaetere Bosse droppen weiter oben im
        -- Upgrade-Track, die letzten beiden auf Mythisch sogar darueber
        -- hinaus. Ohne diese Zuordnung waere jede Angabe geraten.
        ns.Scanner:ResetLog()
        local Say = ns.Scanner.Say
        Say("Bosse je Instanz:")
        for _, isRaid in ipairs({ true, false }) do
            local idx = 1
            while true do
                local ok, instID, instName = pcall(EJ_GetInstanceByIndex, idx, isRaid)
                if not ok or not instID then break end
                if ns.LOOT and ns.LOOT[instID] then
                    Say(string.format("--- %s (%d) ---", tostring(instName), instID))
                    -- Reihenfolge wie im Journal, das ist die Reihenfolge im Raid
                    local j = 1
                    while true do
                        local ok2, encName, _, encID = pcall(EJ_GetEncounterInfoByIndex, j, instID)
                        if not ok2 or not encName then break end
                        Say(string.format("   %d  %s", tonumber(encID) or -1, tostring(encName)))
                        j = j + 1
                        if j > 30 then break end
                    end
                end
                idx = idx + 1
                if idx > 60 then break end
            end
        end
        Say("Fertig. Jetzt |cffffd100/reload|r, dann liegt die Liste in der Datei.")

    elseif cmd == "minimap" then
        if not ns.Minimap then
            Say("Minimap-Modul nicht geladen.")
        elseif rest == "debug" then
            ns.Scanner:ResetLog()
            ns.Minimap:Debug()
        elseif rest == "reset" then
            ns.Minimap:Reset()
            Say("Minimap-Knopf zurückgesetzt und eingeblendet.")
        else
            ns.Minimap:Toggle()
            Say("Minimap-Knopf: " .. (ns.Minimap:IsHidden() and "aus" or "an"))
        end

    elseif cmd == "chat" then
        ns.Scanner:ListChatWindows()

    elseif cmd == "scan" then
        ns.FullScan:Run()

    elseif cmd == "upgrade" or cmd == "up" then
        -- Aufwertungsfenster (B4). Steht vorerst allein; die Einbettung als
        -- Reiter neben Dungeon und Raid ist C3.
        if not ns.UpgradeView then
            Say("Aufwertungs-Modul nicht geladen.")
        else
            ns.UpgradeView:Toggle()
        end

    elseif cmd == "state" then
        if not ns.Inventory then
            Say("Bestands-Modul nicht geladen.")
        else
            ns.Inventory:DumpState()
        end

    elseif cmd == "bag" then
        -- Diagnose fuer die Gratis-Upgrade-Erkennung (Gruppe B).
        -- Zeigt angelegte Ausruestung und anlegbare Teile im Bestand mit
        -- Itemlevel, erkanntem Track und den rohen Bonus-IDs. Zweck ist die
        -- Frage, ob sich Track und Rang ueber die Bonus-IDs aus tracks.lua
        -- zuverlaessig bestimmen lassen.
        if not ns.Inventory then
            Say("Bestands-Modul nicht geladen.")
        else
            ns.Inventory:Report()
        end

    elseif cmd == "" then
        ns.UI:Toggle()

    else
        -- GetAddOnMetadata ist in aktuellen Clients nach C_AddOns umgezogen.
        -- Die globale Fassung existiert nicht mehr, deshalb stand hier "?".
        local ver = "?"
        local getMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
        if getMeta then
            local ok, v = pcall(getMeta, AddonName, "Version")
            if ok and v then ver = v end
        end

        Say("Loot- und Farm-Planer, Version " .. ver)
        Say("  |cffffd100/sm instances|r   Instanzen des aktuellen Tiers mit IDs")
        Say("  |cffffd100/sm probe <ID>|r  Diagnose: was liefert das Journal für diese Instanz")
        Say("  |cffffd100/sm scan|r        Vollscan über alle Instanzen des Tiers")
        Say("  |cffffd100/sm upgrade|r     Aufwertungsfenster: je Slot angelegt vs. Bestand")
        Say("  |cffffd100/sm bag|r         Bestand als Textausgabe, mit Track-Erkennung")
        Say("  |cffffd100/sm bosses|r      Bossnamen mit ihren IDs, je Instanz")
        Say("  |cffffd100/sm chat|r        Welche Chat-Fenster gibt es, welches wird genutzt")
        Say("|cff808080  Alles Entwickler-Werkzeuge. Die Nutzeroberfläche kommt später.|r")
    end
end

-- ----------------------------------------------------------------------------
-- Start
-- ----------------------------------------------------------------------------

local init = CreateFrame("Frame")
init:RegisterEvent("ADDON_LOADED")
init:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == AddonName then
        ApplyDefaults()
        if ns.UI and ns.UI.RestorePosition then ns.UI:RestorePosition() end
        if ns.Minimap then ns.Minimap:Init() end
        -- Bestandsaufnahme laeuft ab hier still im Hintergrund. Sie liest
        -- Nutzerdaten (Taschen, Ausruestung, Waehrungen) und kann deshalb
        -- nicht vorgeneriert werden wie der Journal-Scan.
        -- Jeder Start einzeln abgesichert. Faellt ein Modul aus, laufen die
        -- anderen trotzdem an. Ohne pcall reisst ein Fehler in einem frueheren
        -- Init alle folgenden mit, und man sucht den Fehler dann an der
        -- falschen Stelle.
        if ns.Inventory then pcall(function() ns.Inventory:Init() end) end
        -- Muss NACH Inventory:Init laufen, weil es sich dort anmeldet.
        if ns.UpgradeView and ns.UpgradeView.Init then
            pcall(function() ns.UpgradeView:Init() end)
        end

        local n = 0
        for _ in pairs(ns.ITEMS or {}) do n = n + 1 end
        Say("geladen, " .. n .. " Items in der Datenbank. Tippe |cffffd100/sm|r")

        self:UnregisterEvent("ADDON_LOADED")
    end
end)
