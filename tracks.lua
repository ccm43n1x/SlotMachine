-- ============================================================================
-- SlotMachine - Upgrade-Tracks
-- ============================================================================
--
-- Welches Itemlevel faellt aus welchem Content, und mit welcher Bonus-ID laesst
-- sich ein Item-Link auf dieses Niveau heben.
--
-- HERKUNFT DER DATEN: Die Itemlevel-Stufen stammen aus der eigenen Recherche
-- in [[WoW 12.1 Season 2 - Gearing und Charakterwahl]], gegengeprueft an
-- keystoneloot.io und an der Tabelle in Keystone Loots data/upgrade_tracks.lua.
-- Alle drei Quellen stimmen ueberein: Veteran 279, Champion 292, Hero 305,
-- Myth 318 als Startwerte, je sechs Raenge.
--
-- Die Bonus-IDs sind Blizzards eigene Spieldaten, also Fakten ueber das Spiel
-- wie Item- oder Waehrungs-IDs, kein fremder Quelltext. Abgelesen aus der
-- genannten Datei, weil sie sich nicht sinnvoll selbst ermitteln lassen.
--
-- WOZU: Ein Item-Link mit angehaengter Bonus-ID laesst WoW den Tooltip selbst
-- auf dem Zielniveau rendern, samt korrekter Sekundaerstats. Nichts davon
-- muss nachgerechnet werden, und bei einem Patch stimmt es automatisch.

local AddonName, ns = ...

-- Vier Track-Familien, je sechs Raenge. bonus = Bonus-ID fuer diesen Rang.
ns.TRACKS = {
    veteran   = { name = "Veteran",  ilvl = { 279, 282, 285, 289, 292, 295 },
                  bonus = { 12825, 12826, 12827, 12828, 12829, 12830 } },
    champion  = { name = "Champion", ilvl = { 292, 295, 298, 302, 305, 308 },
                  bonus = { 12833, 12834, 12835, 12836, 12837, 12838 } },
    hero      = { name = "Held",     ilvl = { 305, 308, 311, 315, 318, 321 },
                  bonus = { 12841, 12842, 12843, 12844, 12845, 12846 } },
    myth      = { name = "Mythos",   ilvl = { 318, 321, 324, 328, 331, 334 },
                  bonus = { 12849, 12850, 12851, 12852, 12853, 12854 } },
}

-- Reihenfolge von niedrig nach hoch. Wird fuer den Bonus-Roll-Sprung
-- gebraucht, der auf die erste Stufe des naechsthoeheren Tracks geht.
ns.TRACK_ORDER = { "veteran", "champion", "hero", "myth" }

-- Was faellt wo? rank ist der Rang innerhalb des Tracks, beginnend bei 1.
--
-- Die Zuordnung der Schluesselstein-Stufen stammt aus Keystone Loots
-- Suffix-Angaben ("+0", "+2 +3", "+4" ...), die dort neben jedem Rang stehen.
ns.SOURCES_DUNGEON = {
    { key = "m0",   label = "Mythisch 0",       track = "champion", rank = 1 },
    { key = "m2",   label = "Schlüsselstein 2-3", track = "champion", rank = 2 },
    { key = "m4",   label = "Schlüsselstein 4",   track = "champion", rank = 3 },
    { key = "m5",   label = "Schlüsselstein 5",   track = "champion", rank = 4 },
    { key = "m6",   label = "Schlüsselstein 6-7", track = "hero",     rank = 1 },
    { key = "m8",   label = "Schlüsselstein 8-9", track = "hero",     rank = 2 },
    { key = "m10",  label = "Schlüsselstein 10",  track = "hero",     rank = 3 },
    { key = "vault",label = "Große Schatzkammer", track = "myth",     rank = 1 },
}

ns.SOURCES_RAID = {
    { key = "lfr",    label = "Schlachtzugsbrowser", track = "veteran",  rank = 1 },
    { key = "normal", label = "Normal",              track = "champion", rank = 1 },
    { key = "heroic", label = "Heroisch",            track = "hero",     rank = 1 },
    { key = "mythic", label = "Mythisch",            track = "myth",     rank = 1 },
}

-- Bonus Roll: springt auf die erste Stufe des naechsthoeheren Tracks.
--
-- Diese Regel stammt aus Chris' eigener Recherche in der Master-Notiz
-- ("Der Bonus Roll springt auf die erste Stufe des naechsthoeheren Tracks.
-- Heroic gibt ein Myth-Track-Teil"). Keystone Loot loest das voellig anders,
-- naemlich ueber eine Datenbank der Bonus-Truhen samt Scan ihres Inhalts.
-- Das dient dort aber dem Zweck zu verfolgen, was man bereits gezogen hat,
-- und beantwortet die Itemlevel-Frage gar nicht.
function ns.NextTrack(trackKey)
    for i, k in ipairs(ns.TRACK_ORDER) do
        if k == trackKey then return ns.TRACK_ORDER[i + 1] end
    end
    return nil
end

-- Liefert Itemlevel und Bonus-ID fuer eine Quelle, wahlweise als Bonus Roll.
function ns.ResolveSource(source, asBonusRoll)
    if not source then return nil end
    local trackKey, rank = source.track, source.rank

    if asBonusRoll then
        local nextKey = ns.NextTrack(trackKey)
        if not nextKey then
            -- Ueber Mythos gibt es nichts mehr. Dann bleibt es beim Track,
            -- aber auf dem hoechsten Rang, den ein Drop erreichen kann.
            rank = math.min(rank + 1, 6)
        else
            trackKey, rank = nextKey, 1
        end
    end

    local t = ns.TRACKS[trackKey]
    if not t then return nil end
    return {
        ilvl    = t.ilvl[rank],
        bonusId = t.bonus[rank],
        track   = t.name,
        rank    = rank,
    }
end

-- Item-Link mit Bonus-ID.
--
-- Feldreihenfolge nach itemID:
--   enchant, gem1, gem2, gem3, gem4, suffix, unique, linkLevel,
--   specID, modifiersMask, itemContext, numBonusIDs, dann die Bonus-IDs
--
-- Die Felder werden mit ausgeschriebenen Nullen gefuellt statt leer gelassen.
-- Leere Felder sind zwar erlaubt, aber beim Zaehlen von zwoelf Doppelpunkten
-- verzaehlt man sich lautlos, und ein um eine Position verschobener Link wird
-- von WoW kommentarlos ignoriert statt einen Fehler zu werfen.
function ns.BuildItemLink(itemID, bonusId)
    if not bonusId then return "item:" .. itemID end
    return string.format("item:%d:0:0:0:0:0:0:0:0:0:0:0:1:%d", itemID, bonusId)
end
