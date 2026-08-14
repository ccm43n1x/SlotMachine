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

    elseif cmd == "chat" then
        ns.Scanner:ListChatWindows()

    elseif cmd == "scan" then
        ns.FullScan:Run()

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

        local n = 0
        for _ in pairs(ns.ITEMS or {}) do n = n + 1 end
        Say("geladen, " .. n .. " Items in der Datenbank. Tippe |cffffd100/sm|r")

        self:UnregisterEvent("ADDON_LOADED")
    end
end)
