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
--
-- Die Farbe gehoert an den TRACK, nicht an die Quelle. Sonst stimmt sie nicht
-- mehr, sobald ein Bonus Roll das Ergebnis in einen anderen Track hebt: Ein
-- M0 liefert mit Bonus Roll ein Hero-Teil, wurde aber weiter in
-- Champion-Gruen angezeigt. Genau die Information, die sich aendert, wurde
-- dadurch falsch dargestellt.
ns.TRACKS = {
    veteran   = { name = "Veteran",  color = "ff9d9d9d",
                  ilvl = { 279, 282, 285, 289, 292, 295 },
                  bonus = { 12825, 12826, 12827, 12828, 12829, 12830 } },
    champion  = { name = "Champion", color = "ff1eff00",
                  ilvl = { 292, 295, 298, 302, 305, 308 },
                  bonus = { 12833, 12834, 12835, 12836, 12837, 12838 } },
    hero      = { name = "Held",     color = "ff0070dd",
                  ilvl = { 305, 308, 311, 315, 318, 321 },
                  bonus = { 12841, 12842, 12843, 12844, 12845, 12846 } },
    myth      = { name = "Mythos",   color = "ffa335ee",
                  ilvl = { 318, 321, 324, 328, 331, 334 },
                  bonus = { 12849, 12850, 12851, 12852, 12853, 12854 } },
}

-- Reihenfolge von niedrig nach hoch. Wird fuer den Bonus-Roll-Sprung
-- gebraucht, der auf die erste Stufe des naechsthoeheren Tracks geht.
ns.TRACK_ORDER = { "veteran", "champion", "hero", "myth" }

-- Was faellt wo? rank ist der Rang innerhalb des Tracks, beginnend bei 1.
--
-- Die Zuordnung der Schluesselstein-Stufen stammt aus Keystone Loots
-- Suffix-Angaben ("+0", "+2 +3", "+4" ...), die dort neben jedem Rang stehen.
-- Jede Schluesselstein-Stufe steht einzeln, keine Bereiche. Dass M2 und M3
-- dasselbe Itemlevel geben, sieht man dann an der Zahl statt es raten zu
-- muessen.
--
-- BONUS ROLL wird NICHT mehr berechnet, sondern steht als bonusTrack und
-- bonusRank an jeder Stufe.
--
-- Grund: Die urspruengliche Regel "springt auf die erste Stufe des
-- naechsthoeheren Tracks" stammt aus der eigenen Master-Notiz, dort aber im
-- Abschnitt ueber RAIDS ("Heroic gibt ein Myth-Track-Teil"). Auf Dungeons
-- uebertragen ergab sie Unsinn: Schon ein Schluesselstein 6 haette dann ein
-- mythisches Teil geliefert. Aus Season 1 ist bekannt, dass mythische
-- Belohnungen erst ab Stufe 10 fallen.
--
-- Deshalb steht die Zuordnung jetzt ausgeschrieben da, wo sie sich pruefen und
-- ohne Codeaenderung korrigieren laesst.
ns.SOURCES_DUNGEON = {
    { key = "m0",  short = "M0",  label = "Mythisch 0",       track = "champion", rank = 1,
      bonusTrack = "champion", bonusRank = 5 },
    { key = "m2",  short = "M2",  label = "Schlüsselstein 2", track = "champion", rank = 2,
      bonusTrack = "champion", bonusRank = 6 },
    { key = "m3",  short = "M3",  label = "Schlüsselstein 3", track = "champion", rank = 2,
      bonusTrack = "champion", bonusRank = 6 },
    { key = "m4",  short = "M4",  label = "Schlüsselstein 4", track = "champion", rank = 3,
      bonusTrack = "hero", bonusRank = 1 },
    { key = "m5",  short = "M5",  label = "Schlüsselstein 5", track = "champion", rank = 4,
      bonusTrack = "hero", bonusRank = 1 },
    { key = "m6",  short = "M6",  label = "Schlüsselstein 6", track = "hero", rank = 1,
      bonusTrack = "hero", bonusRank = 2 },
    { key = "m7",  short = "M7",  label = "Schlüsselstein 7", track = "hero", rank = 1,
      bonusTrack = "hero", bonusRank = 3 },
    { key = "m8",  short = "M8",  label = "Schlüsselstein 8", track = "hero", rank = 2,
      bonusTrack = "hero", bonusRank = 4 },
    { key = "m9",  short = "M9",  label = "Schlüsselstein 9", track = "hero", rank = 2,
      bonusTrack = "hero", bonusRank = 5 },
    -- Erst ab Stufe 10 ein mythisches Teil. Das ist der Stand aus Season 1
    -- und der Grund, Bonus Rolls bis hierhin aufzusparen.
    { key = "m10", short = "M10", label = "Schlüsselstein 10", track = "hero", rank = 3,
      bonusTrack = "myth", bonusRank = 1 },
    { key = "vault", short = "GV", label = "Große Schatzkammer", track = "myth", rank = 1,
      bonusTrack = "myth", bonusRank = 2 },
}

ns.SOURCES_RAID = {
    { key = "lfr",    short = "LFR", label = "Schlachtzugsbrowser", track = "veteran",  rank = 1,
      bonusTrack = "champion", bonusRank = 1 },
    { key = "normal", short = "N",   label = "Normal",              track = "champion", rank = 1,
      bonusTrack = "hero", bonusRank = 1 },
    { key = "heroic", short = "H",   label = "Heroisch",            track = "hero",     rank = 1,
      bonusTrack = "myth", bonusRank = 1 },
    { key = "mythic", short = "M",   label = "Mythisch",            track = "myth",     rank = 1,
      bonusTrack = "myth", bonusRank = 2 },
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

    -- Nichts mehr berechnen: Beide Faelle stehen an der Quelle.
    local trackKey = asBonusRoll and (source.bonusTrack or source.track) or source.track
    local rank     = asBonusRoll and (source.bonusRank  or source.rank)  or source.rank

    local t = ns.TRACKS[trackKey]
    if not t then return nil end
    rank = math.max(1, math.min(rank or 1, #t.ilvl))

    return {
        ilvl    = t.ilvl[rank],
        bonusId = t.bonus[rank],
        track   = t.name,
        color   = t.color,     -- Farbe des ERGEBNIS-Tracks, nicht der Quelle
        rank    = rank,
    }
end

-- Farbe der Quelle selbst, also des Schluesselsteins bzw. der Raid-Stufe.
-- Bewusst getrennt von der Ergebnis-Farbe: Das Kuerzel sagt WO man laeuft, das
-- Itemlevel sagt WAS dabei herauskommt. Bei einem Bonus Roll faellt beides
-- auseinander, und genau das soll man sehen.
function ns.SourceColor(source)
    if not source then return "ff9d9d9d" end
    local t = ns.TRACKS[source.track]
    return (t and t.color) or "ff9d9d9d"
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
