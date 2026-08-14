-- ============================================================================
-- SlotMachine - Encounter-Journal-Scanner
-- ============================================================================
--
-- WICHTIG: Dieser Scanner ist ein ENTWICKLER-WERKZEUG, keine Nutzerfunktion.
--
-- Entschieden am 14.08.2026. Der Scan laeuft einmal pro Season bei Chris, das
-- Ergebnis landet in SavedVariables und wird von dort in eine auslieferbare
-- data.lua uebersetzt. Der Nutzer bekommt die fertige Datei und sieht vom
-- Scan nie etwas.
--
-- Begruendung: Zwei produktive Add-ons haben den Scan beim Nutzer verworfen.
-- Keystone Loot liefert eine vorgenerierte Datei aus, AlterEgo hat den Code
-- geschrieben und wieder auskommentiert. Die Gruende:
--   1. Item-Daten kommen ASYNCHRON vom Server. C_Item.GetItemStats liefert
--      nil, solange das Item nicht im Client-Cache liegt.
--   2. Der Scan VERSTELLT das Encounter Journal des Nutzers.
--   3. 13 Klassen mal 3 bis 4 Specs sind rund 40 Filterwechsel je Instanz.
-- Beim Entwickler-Scan ist all das harmlos: zweimal laufen lassen, fertig.

local AddonName, ns = ...

ns.Scanner = {}
local Scanner = ns.Scanner

-- ----------------------------------------------------------------------------
-- Zustand des Encounter Journals sichern und wiederherstellen
-- ----------------------------------------------------------------------------
-- Gleiche Problemklasse wie C_CurrencyInfo.ExpandCurrencyList bei Chrissi's
-- Addon: eine API, die den Zustand des Nutzers veraendert. Auch wenn der Scan
-- nur beim Entwickler laeuft, soll er nichts hinterlassen.

local savedState = nil

function Scanner:SaveState()
    savedState = {}
    -- Alles in pcall, weil einzelne dieser Funktionen je nach Client-Version
    -- fehlen koennen. Ein fehlender Wert soll den Scan nicht verhindern.
    pcall(function() savedState.tier       = EJ_GetCurrentTier and EJ_GetCurrentTier() end)
    pcall(function() savedState.instanceID = EJ_GetCurrentInstance and EJ_GetCurrentInstance() end)
    pcall(function() savedState.difficulty = EJ_GetDifficulty and EJ_GetDifficulty() end)
    return savedState
end

function Scanner:RestoreState()
    if not savedState then return end
    pcall(function() if EJ_ResetLootFilter then EJ_ResetLootFilter() end end)
    pcall(function() if EJ_ClearSearch then EJ_ClearSearch() end end)
    pcall(function() if savedState.tier and EJ_SelectTier then EJ_SelectTier(savedState.tier) end end)
    pcall(function() if savedState.instanceID and EJ_SelectInstance then EJ_SelectInstance(savedState.instanceID) end end)
    pcall(function() if savedState.difficulty and EJ_SetDifficulty then EJ_SetDifficulty(savedState.difficulty) end end)
    savedState = nil
end

-- ----------------------------------------------------------------------------
-- Diagnose: Was liefert die API ueberhaupt?
-- ----------------------------------------------------------------------------
-- Bewusst der erste Schritt. Bevor ein Scan ueber alle Instanzen laeuft, muss
-- klar sein, welche Felder GetLootInfoByIndex tatsaechlich zurueckgibt und ob
-- die encounterID mitkommt. Kommt sie mit, spart das den teuersten Teil des
-- Scans: Dann muss NICHT jeder Boss einzeln angewaehlt werden, sondern die
-- Instanz liefert alles auf einmal und jedes Item weiss, von wem es faellt.

-- ----------------------------------------------------------------------------
-- Ausgabe: Chat-Fenster UND SavedVariables
-- ----------------------------------------------------------------------------
-- Zwei Wege, aus zwei Gruenden.
--
-- 1. Eigenes Chat-Fenster: print() schreibt immer in DEFAULT_CHAT_FRAME, also
--    mitten zwischen Gildenchat und Loot-Meldungen. Wer ein Chat-Fenster mit
--    dem Namen "Dev" anlegt (Rechtsklick auf einen Reiter, Neues Fenster),
--    bekommt die Ausgabe automatisch dorthin. Ohne so ein Fenster bleibt
--    alles beim Standardverhalten.
--
-- 2. SavedVariables: Der eigentliche Grund. Chat-Ausgaben muss man abtippen
--    oder abfotografieren. Was in SavedVariables landet, liegt nach einem
--    /reload als Datei auf der Platte und laesst sich direkt auswerten. Bei
--    einem Scan ueber tausende Eintraege ist das der einzige gangbare Weg.

local devFrame = nil

-- ACHTUNG, hier lag der Fehler der ersten Fassung: Das Ergebnis wurde immer
-- gemerkt, auch der Rueckfall auf das Standardfenster. Der erste Aufruf
-- passiert aber schon bei ADDON_LOADED, wenn die Chat-Fenster noch nicht
-- fertig sind. Damit war die falsche Entscheidung dauerhaft eingefroren und
-- ein spaeter angelegtes Dev-Fenster wurde nie gefunden.
--
-- Jetzt wird NUR ein echter Treffer gemerkt. Solange keiner da ist, sucht die
-- Funktion bei jedem Aufruf erneut. Die Schleife laeuft ueber maximal zehn
-- Fenster und ist billig genug, um das zu vertragen.
local function GetDevFrame()
    if devFrame then return devFrame end
    if not (NUM_CHAT_WINDOWS and GetChatWindowInfo) then
        return DEFAULT_CHAT_FRAME
    end
    for i = 1, NUM_CHAT_WINDOWS do
        local ok, name = pcall(GetChatWindowInfo, i)
        if ok and type(name) == "string" then
            local n = name:lower():gsub("^%s+", ""):gsub("%s+$", "")
            if n == "dev" or n == "slotmachine" then
                local f = _G["ChatFrame" .. i]
                if f then
                    devFrame = f      -- nur echte Treffer merken
                    return f
                end
            end
        end
    end
    return DEFAULT_CHAT_FRAME
end

-- Zeigt, welche Fenster gefunden wurden. Hilft bei der Frage, warum die
-- Ausgabe im falschen Fenster landet.
function Scanner:ListChatWindows()
    if not (NUM_CHAT_WINDOWS and GetChatWindowInfo) then
        print("Chat-API nicht verfügbar.")
        return
    end
    print("|cff33ff99SlotMachine|r Chat-Fenster:")
    for i = 1, NUM_CHAT_WINDOWS do
        local ok, name, _, _, _, _, shown = pcall(GetChatWindowInfo, i)
        if ok and name and name ~= "" then
            local mark = ""
            local n = name:lower()
            if n == "dev" or n == "slotmachine" then mark = "   <== wird genutzt" end
            print(string.format("   %d: |cffffd100%s|r%s", i, tostring(name), mark))
        end
    end
    print("Ein Fenster namens |cffffd100Dev|r oder |cffffd100SlotMachine|r bekommt die Ausgaben.")
end

-- Das Log wird bei jedem neuen Probe-Lauf geleert, damit in der Datei immer
-- der letzte Lauf steht und nicht zehn uebereinander.
function Scanner:ResetLog()
    SlotMachineDB = SlotMachineDB or {}
    SlotMachineDB.probeLog = {}
end

local function Say(msg)
    msg = tostring(msg)
    GetDevFrame():AddMessage("|cff33ff99SlotMachine|r " .. msg)
    if SlotMachineDB and SlotMachineDB.probeLog then
        SlotMachineDB.probeLog[#SlotMachineDB.probeLog + 1] = msg
    end
end

-- Auch fuer main.lua verfuegbar machen, damit ALLE Ausgaben im selben Fenster
-- landen und im selben Log stehen.
Scanner.Say = Say

function Scanner:Probe(instanceID)
    self:ResetLog()

    if not (EJ_SelectInstance and EJ_GetNumLoot) then
        Say("Encounter-Journal-API nicht verfügbar. Abbruch.")
        return
    end

    self:SaveState()

    local ok = pcall(EJ_SelectInstance, instanceID)
    if not ok then
        Say("EJ_SelectInstance(" .. tostring(instanceID) .. ") fehlgeschlagen.")
        self:RestoreState()
        return
    end

    pcall(function() if EJ_ResetLootFilter then EJ_ResetLootFilter() end end)

    local instName = "?"
    pcall(function() instName = EJ_GetInstanceInfo(instanceID) or "?" end)

    local num = 0
    pcall(function() num = EJ_GetNumLoot() or 0 end)

    Say("Instanz: " .. tostring(instName) .. " (ID " .. tostring(instanceID) .. ")")
    Say("Loot-Eintraege ohne Filter: " .. tostring(num))

    if num == 0 then
        Say("Keine Eintraege. Entweder ist die Instanz-ID falsch, oder das")
        Say("Journal hat die Daten noch nicht geladen. Einmal das Dungeon-")
        Say("Journal oeffnen und erneut versuchen.")
        self:RestoreState()
        return
    end

    -- Die ersten drei Eintraege vollstaendig ausgeben, damit die Feldnamen
    -- sichtbar werden. Erst danach laesst sich der echte Scan sauber bauen.
    local getLoot = (C_EncounterJournal and C_EncounterJournal.GetLootInfoByIndex)
    if not getLoot then
        Say("C_EncounterJournal.GetLootInfoByIndex fehlt, versuche EJ_GetLootInfoByIndex.")
    end

    for i = 1, math.min(3, num) do
        local info
        if getLoot then
            local ok2, res = pcall(getLoot, i)
            if ok2 then info = res end
        end

        if type(info) == "table" then
            Say("--- Eintrag " .. i .. " ---")
            -- Sortierte Ausgabe, damit die Reihenfolge zwischen Laeufen gleich
            -- bleibt und sich zwei Ausgaben vergleichen lassen.
            local keys = {}
            for k in pairs(info) do keys[#keys + 1] = tostring(k) end
            table.sort(keys)
            for _, k in ipairs(keys) do
                local v = info[k]
                if type(v) ~= "table" and type(v) ~= "function" then
                    Say("   " .. k .. " = " .. tostring(v))
                else
                    Say("   " .. k .. " = <" .. type(v) .. ">")
                end
            end
        else
            Say("Eintrag " .. i .. ": kein Tabellenergebnis (" .. type(info) .. ")")
        end
    end

    -- Kernfrage: Kennt der Client die Anzahl der Bosse, und traegt jedes
    -- Loot-Item seine encounterID?
    local numEnc = 0
    pcall(function()
        local idx = 1
        while EJ_GetEncounterInfoByIndex(idx, instanceID) do
            numEnc = idx
            idx = idx + 1
            if idx > 30 then break end   -- Sicherheitsnetz gegen Endlosschleife
        end
    end)
    Say("Bosse laut Journal: " .. tostring(numEnc))

    self:RestoreState()
    Say("Journal-Zustand wiederhergestellt.")
    Say("Fertig. Jetzt |cffffd100/reload|r eingeben, dann liegt das Log in der")
    Say("SavedVariables-Datei und kann ausgewertet werden.")
end
