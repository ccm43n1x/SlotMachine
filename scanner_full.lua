-- ============================================================================
-- SlotMachine - Vollscan ueber alle Instanzen des aktuellen Tiers
-- ============================================================================
--
-- ENTWICKLER-WERKZEUG. Laeuft einmal pro Season bei Chris, nicht beim Nutzer.
--
-- Erkenntnisse aus dem Probe-Lauf vom 14.08.2026 (Instanz 1317), auf denen
-- dieser Scan aufbaut:
--
--   1. Jedes Loot-Item traegt seine encounterID mit. Es muss also KEIN Boss
--      einzeln angewaehlt werden. Eine Instanz-Abfrage liefert alles.
--   2. EJ_ResetLootFilter() liefert die Items ALLER Klassen. Fuer den MVP
--      wird die Spec-Zuordnung nicht gebraucht, deshalb entfaellt die teure
--      Schleife ueber 13 Klassen mal 3 bis 4 Specs. Aus rund 1300 Durchlaeufen
--      werden zwoelf.
--   3. Item-Daten kommen ASYNCHRON. Von drei geprueften Eintraegen kam einer
--      ohne name, link und slot zurueck, weil er nicht im Client-Cache lag.
--      Ein Scan ohne Nachladelogik verliert also rund ein Drittel der Daten.
--      Das ist die wahrscheinlichste Ursache dafuer, dass AlterEgo seinen
--      Scan wieder auskommentiert hat.
--
-- Ablauf gegen Punkt 3: erst alle Instanzen abklappern und einsammeln, was da
-- ist. Alles Unvollstaendige kommt auf eine Nachliste, wird per
-- C_Item.RequestLoadItemDataByID angefordert, und nach kurzer Wartezeit
-- erneut abgefragt. Das wiederholt sich, bis nichts mehr fehlt oder die
-- Versuche aufgebraucht sind.

local AddonName, ns = ...

local Full = {}
ns.FullScan = Full

local Say = function(msg) if ns.Scanner and ns.Scanner.Say then ns.Scanner.Say(msg) end end

local MAX_RETRIES   = 6      -- so oft wird nachgeladen
local RETRY_DELAY   = 1.0    -- Sekunden zwischen den Versuchen
local INSTANCE_STEP = 0.15   -- Pause zwischen zwei Instanzen, gegen Ruckler

-- ----------------------------------------------------------------------------
-- Instanzen des aktuellen Tiers sammeln
-- ----------------------------------------------------------------------------

local function CollectInstances()
    local out = {}
    for _, isRaid in ipairs({ false, true }) do
        local idx = 1
        while true do
            local ok, id, name = pcall(EJ_GetInstanceByIndex, idx, isRaid)
            if not ok or not id then break end
            out[#out + 1] = { id = id, name = name, isRaid = isRaid }
            idx = idx + 1
            if idx > 60 then break end
        end
    end
    return out
end

-- ----------------------------------------------------------------------------
-- Eine Instanz auslesen
-- ----------------------------------------------------------------------------

local function ReadInstance(inst, store)
    local ok = pcall(EJ_SelectInstance, inst.id)
    if not ok then return 0, 0 end

    pcall(function() if EJ_ResetLootFilter then EJ_ResetLootFilter() end end)

    local num = 0
    pcall(function() num = EJ_GetNumLoot() or 0 end)
    if num == 0 then return 0, 0 end

    local getLoot = C_EncounterJournal and C_EncounterJournal.GetLootInfoByIndex
    if not getLoot then return 0, 0 end

    local complete, incomplete = 0, 0

    for i = 1, num do
        local ok2, info = pcall(getLoot, i)
        if ok2 and type(info) == "table" and info.itemID then
            local rec = store.items[info.itemID] or {}
            rec.itemID      = info.itemID
            rec.encounterID = info.encounterID
            rec.instanceID  = inst.id

            -- Nur uebernehmen was da ist. Ein spaeterer Nachladelauf fuellt
            -- die Luecken, darf aber bereits Vorhandenes nicht ueberschreiben.
            if info.name  and info.name  ~= "" then rec.name  = info.name  end
            if info.slot  and info.slot  ~= "" then rec.slot  = info.slot  end
            if info.icon                       then rec.icon  = info.icon  end
            if info.armorType                  then rec.armorType  = info.armorType  end
            if info.filterType                 then rec.filterType = info.filterType end
            if info.itemQuality                then rec.quality    = info.itemQuality end

            store.items[info.itemID] = rec

            -- Vollstaendigkeit haengt am NAMEN, nicht am Slot.
            --
            -- Erste Fassung verlangte beides. Ergebnis im Lauf vom 14.08.2026:
            -- 48 Eintraege galten dauerhaft als unvollstaendig und wurden
            -- fuenfmal vergeblich nachgeladen. Es waren Berufs-Rezepte
            -- (Pattern, Formula, Plans, Design) und Housing-Dekoration
            -- (Briefkasten, Lampe, Tisch). Die haben schlicht keinen
            -- Ausruestungsslot. Voellig korrekte Daten also, nur eben kein Gear.
            --
            -- Wer kein Gear ist, wird trotzdem gespeichert. Aussortiert wird
            -- erst im Generator, damit die Rohdaten vollstaendig bleiben.
            if rec.name then
                complete = complete + 1
            else
                incomplete = incomplete + 1
                store.pending[info.itemID] = true
                -- Anstossen, damit der Client die Daten nachlaedt
                if C_Item and C_Item.RequestLoadItemDataByID then
                    pcall(C_Item.RequestLoadItemDataByID, info.itemID)
                end
            end
        end
    end

    return complete, incomplete
end

-- ----------------------------------------------------------------------------
-- Nachladen der unvollstaendigen Eintraege
-- ----------------------------------------------------------------------------
-- Die Item-Daten liegen nach dem Request irgendwann im Cache. Statt auf das
-- Event zu warten und Buch zu fuehren, wird schlicht erneut ueber die
-- betroffenen Instanzen gelesen. Das ist robuster: Es ist egal, welches Item
-- wann ankommt, und ein verpasstes Event kann nichts blockieren.

local function Retry(store, instances, round, onDone)
    local missing = 0
    for _ in pairs(store.pending) do missing = missing + 1 end

    if missing == 0 then
        Say("Alle Item-Daten vollständig.")
        onDone()
        return
    end

    if round > MAX_RETRIES then
        Say("Nach " .. MAX_RETRIES .. " Versuchen fehlen noch " .. missing .. " Einträge.")
        Say("Die stehen mit ID und Boss in den Daten, nur ohne Namen.")
        onDone()
        return
    end

    Say("Nachladen, Versuch " .. round .. ": noch " .. missing .. " unvollständig.")

    C_Timer.After(RETRY_DELAY, function()
        -- Vor dem erneuten Lesen die Nachliste leeren, ReadInstance fuellt sie
        -- mit dem neu bestimmt was noch fehlt.
        store.pending = {}
        for _, inst in ipairs(instances) do
            ReadInstance(inst, store)
        end
        Retry(store, instances, round + 1, onDone)
    end)
end

-- ----------------------------------------------------------------------------
-- Einstieg
-- ----------------------------------------------------------------------------

function Full:Run()
    if not (EJ_GetInstanceByIndex and EJ_SelectInstance) then
        Say("Encounter-Journal-API nicht verfügbar.")
        return
    end

    ns.Scanner:ResetLog()
    ns.Scanner:SaveState()

    local instances = CollectInstances()
    Say("Instanzen gefunden: " .. #instances)

    local store = { items = {}, pending = {} }
    local startTime = GetTime and GetTime() or 0

    -- Instanzen zeitverteilt abarbeiten, damit der Client nicht stockt.
    local i = 0
    local function Step()
        i = i + 1
        if i > #instances then
            Retry(store, instances, 1, function()
                ns.Scanner:RestoreState()

                local total, withName, gear = 0, 0, 0
                for _, rec in pairs(store.items) do
                    total = total + 1
                    if rec.name then withName = withName + 1 end
                    -- Nur was einen Slot hat, ist Ausruestung und damit fuer
                    -- einen Loot-Planer ueberhaupt interessant.
                    if rec.slot and rec.slot ~= "" then gear = gear + 1 end
                end

                SlotMachineDB.scanResults = store.items
                SlotMachineDB.scanStamp   = date and date("%Y-%m-%d %H:%M") or nil

                local dur = (GetTime and GetTime() or 0) - startTime
                Say("--- Fertig ---")
                Say(string.format("Items gesamt: %d, mit Namen: %d", total, withName))
                Say(string.format("davon Ausrüstung: %d, Rest (Rezepte, Deko): %d", gear, total - gear))
                Say(string.format("Dauer: %.1f Sekunden", dur))
                Say("Journal-Zustand wiederhergestellt.")
                Say("Jetzt |cffffd100/reload|r, dann liegen die Daten in der Datei.")
            end)
            return
        end

        local inst = instances[i]
        local c, ic = ReadInstance(inst, store)
        Say(string.format("%d/%d  %s (%d): %d vollständig, %d offen",
            i, #instances, tostring(inst.name), inst.id, c, ic))

        C_Timer.After(INSTANCE_STEP, Step)
    end

    Step()
end
