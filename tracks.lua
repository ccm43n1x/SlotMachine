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
-- letter = Kuerzel des Upgrade-Pfads. Wird zusammen mit dem Rang angezeigt,
-- also "H 3/6". Das sagt mehr als eine Wiederholung der Schluesselstein-Stufe,
-- die ohnehin schon danebensteht.
-- FARBEN, korrigiert am 16.08.2026
--
-- Vorher war die Palette um eine Stufe verrutscht: Veteran stand auf
-- ff9d9d9d, und das ist WoWs POOR-Farbe, also die fuer Muell. Ein regulaerer
-- Track in Grautoenen sieht im Fenster aus wie ein nicht erkanntes Item.
--
-- RECHERCHE-STAND: Es gibt keine oeffentlich dokumentierte Blizzard-Palette
-- fuer die Upgrade-Tracks. Belegt sind nur Ampelfarben fuer die CRESTS
-- (Runed gelb, Gilded rot laut Blizzard-Forum), und die betreffen die
-- Waehrung, nicht den Track.
--
-- GEWAEHLTE LOESUNG: Blizzards Qualitaetsfarben, aufsteigend. Dasselbe
-- Prinzip, das in diesem Add-on schon fuer die Wunschliste-Stufen gilt, mit
-- derselben Begruendung: Jeder Spieler liest diese Rangfolge ohne Legende.
--
--   Common weiss  ffffffff  -> Adventurer (sobald der Track dazukommt)
--   Uncommon      ff1eff00  -> Veteran
--   Rare          ff0070dd  -> Champion
--   Epic          ffa335ee  -> Hero
--   Legendary     ffff8000  -> Myth
--
-- Damit ist die oberste Stufe legendaer-orange statt episch-lila, was sie
-- auch verdient, und Grau bleibt reserviert fuer "kein Track erkannt".
ns.TRACKS = {
    veteran   = { name = "Veteran",  letter = "V", color = "ff1eff00",
                  ilvl = { 279, 282, 285, 289, 292, 295 },
                  bonus = { 12825, 12826, 12827, 12828, 12829, 12830 } },
    champion  = { name = "Champion", letter = "C", color = "ff0070dd",
                  ilvl = { 292, 295, 298, 302, 305, 308 },
                  bonus = { 12833, 12834, 12835, 12836, 12837, 12838 } },
    hero      = { name = "Held",     letter = "H", color = "ffa335ee",
                  ilvl = { 305, 308, 311, 315, 318, 321 },
                  bonus = { 12841, 12842, 12843, 12844, 12845, 12846 } },
    myth      = { name = "Mythos",   letter = "M", color = "ffff8000",
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
-- DER BONUS ROLL GIBT DAS GREAT-VAULT-NIVEAU DER JEWEILIGEN STUFE.
--
-- Recherchiert am 14.08.2026. Belegt durch Method und mehrere Guides:
-- "The gear obtained with a Nebulous Voidcore is aligned with the equivalent
-- Great Vault reward level for that content." Ein Voidcore auf einem
-- Schluesselstein 10 oder hoeher gibt ein Myth-Teil, darunter nicht.
--
-- Die vorherige Fassung rechnete "erste Stufe des naechsthoeheren Tracks".
-- Diese Regel steht zwar in der eigenen Master-Notiz, dort aber im Abschnitt
-- ueber RAIDS. Auf Dungeons uebertragen lag sie bei den mittleren Stufen
-- deutlich zu hoch: Schon ein Schluesselstein 6 haette ein mythisches Teil
-- geliefert.
--
-- Eine Korrektur an Methods Tabelle: Dort steht fuer +7 bis +9 "Hero 4/6" mit
-- Itemlevel 311, obwohl Hero 3/6 bereits 311 ist. Die Itemlevel-Spalte hat
-- dort offensichtlich einen Uebertragungsfehler. Uebernommen wird die
-- Track-Angabe, das Itemlevel kommt aus der dreifach geprueften Tabelle oben.
ns.SOURCES_DUNGEON = {
    -- M0 zaehlt nicht fuer die Mythic+-Reihe der Vault, also gibt es dort
    -- auch keinen Bonus Roll. bonusTrack bleibt deshalb leer.
    { key = "m0",  short = "M0",  label = "Mythisch 0",       track = "champion", rank = 1 },
    { key = "m2",  short = "M2",  label = "Schlüsselstein 2", track = "champion", rank = 2,
      bonusTrack = "hero", bonusRank = 1 },
    { key = "m3",  short = "M3",  label = "Schlüsselstein 3", track = "champion", rank = 2,
      bonusTrack = "hero", bonusRank = 1 },
    { key = "m4",  short = "M4",  label = "Schlüsselstein 4", track = "champion", rank = 3,
      bonusTrack = "hero", bonusRank = 2 },
    { key = "m5",  short = "M5",  label = "Schlüsselstein 5", track = "champion", rank = 4,
      bonusTrack = "hero", bonusRank = 2 },
    { key = "m6",  short = "M6",  label = "Schlüsselstein 6", track = "hero", rank = 1,
      bonusTrack = "hero", bonusRank = 3 },
    { key = "m7",  short = "M7",  label = "Schlüsselstein 7", track = "hero", rank = 1,
      bonusTrack = "hero", bonusRank = 4 },
    { key = "m8",  short = "M8",  label = "Schlüsselstein 8", track = "hero", rank = 2,
      bonusTrack = "hero", bonusRank = 4 },
    { key = "m9",  short = "M9",  label = "Schlüsselstein 9", track = "hero", rank = 2,
      bonusTrack = "hero", bonusRank = 4 },
    -- Ab hier lohnt der Voidcore: erst Stufe 10 hebt den Bonus Roll in den
    -- Myth-Track. Genau deshalb spart man Rolls bis hierhin auf.
    { key = "m10", short = "M10", label = "Schlüsselstein 10", track = "hero", rank = 3,
      bonusTrack = "myth", bonusRank = 1 },
    { key = "m12", short = "M12", label = "Schlüsselstein 12+", track = "hero", rank = 3,
      bonusTrack = "myth", bonusRank = 1 },
}

-- Raid-Vault gibt jeweils eine Schwierigkeit hoeher als gespielt. Mythic gibt
-- ein voll aufgewertetes Myth-Teil, was eine Menge Crests spart.
ns.SOURCES_RAID = {
    { key = "lfr",    short = "LFR", label = "Schlachtzugsbrowser", track = "veteran",  rank = 1,
      bonusTrack = "champion", bonusRank = 1 },
    { key = "normal", short = "N",   label = "Normal",              track = "champion", rank = 1,
      bonusTrack = "hero", bonusRank = 1 },
    { key = "heroic", short = "H",   label = "Heroisch",            track = "hero",     rank = 1,
      bonusTrack = "myth", bonusRank = 1 },
    { key = "mythic", short = "M",   label = "Mythisch",            track = "myth",     rank = 1,
      bonusTrack = "myth", bonusRank = 6 },
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
        letter  = t.letter,
        badge   = string.format("%s %d/6", t.letter, rank),   -- z.B. "H 3/6"
    }
end

-- Kennung eines Tracks als fertiger, eingefaerbter Text: "H 3/6".
--
-- Ausgelagert am 16.08.2026, weil das Format jetzt an zwei Stellen gebraucht
-- wird: in der Quellen-Liste (ueber ResolveSource) und im Aufwertungsfenster.
-- Ein drittes Mal dasselbe string.format waere die Stelle, an der die beiden
-- Fenster irgendwann auseinanderlaufen.
--
-- Gibt nil zurueck, wenn der Track unbekannt ist. Der Aufrufer entscheidet,
-- was er dann anzeigt.
function ns.TrackBadge(trackKey, rank, withColor)
    local t = ns.TRACKS[trackKey]
    if not t or not rank then return nil end
    rank = math.max(1, math.min(rank, #t.ilvl))
    local text = string.format("%s %d/6", t.letter, rank)
    if withColor == false then return text end
    return "|c" .. t.color .. text .. "|r"
end

-- Gibt es fuer diese Quelle ueberhaupt einen Bonus Roll?
-- Mythisch 0 zaehlt nicht fuer die Mythic+-Reihe der Great Vault, also nicht.
function ns.HasBonusRoll(source)
    return source and source.bonusTrack ~= nil
end

-- ----------------------------------------------------------------------------
-- Bossabhaengiges Itemlevel im Raid
-- ----------------------------------------------------------------------------
-- Im Raid ist das Itemlevel NICHT einheitlich je Schwierigkeitsgrad. Spaetere
-- Bosse droppen bereits weiter oben im Upgrade-Track, was Crests spart. Method
-- dazu: "later and harder bosses dropping gear that is already further along
-- the upgrade track".
--
-- Recherchierter Stand fuer Mythisch (14.08.2026):
--   Nymrissa Wavecaller, Nek'zali the Soulcoiler ...... Myth 1/6  318
--   Entombed Sentinels, The Lost Explorers ............ Myth 2/6  321
--   Vashnik the Malignant, Sszorak, The Twin Fangs .... Myth 3/6  324
--   The Coiled Altar, Ula'tek ......................... Myth 9/6  344
--
-- Die letzten beiden liegen damit UEBER dem regulaeren Track. Wer sie mit dem
-- Standardwert anzeigt, liegt um 26 Itemlevel daneben.
--
-- ns.BOSS_RANK ordnet einer encounterID den Rang innerhalb des Tracks zu.
-- Steht ein Boss nicht drin, gilt Rang 1, also der Standardwert der Stufe.
--
-- Am 14.08.2026 per /sm bosses im Spiel ausgelesen und damit belegt.
--
-- WICHTIG, weil es die Annahme widerlegt: Naheliegend waere gewesen, dass die
-- encounterIDs in Raid-Reihenfolge vergeben sind und die beiden HOECHSTEN die
-- Endbosse waeren. Falsch. Der Endboss "The Coiled Altar" traegt 2883 und
-- liegt damit mitten im Feld, waehrend 2894 zu "The Lost Explorers" gehoert,
-- einem frueheren Boss. Geraten haette man zwei Bosse um 26 Itemlevel
-- verfehlt.
--
-- rank = Rang innerhalb des Tracks der gewaehlten Schwierigkeit.
-- ilvl  = fester Wert, fuer die Endbosse jenseits des regulaeren Tracks.
ns.BOSS_RANK = {
    -- The Venomous Abyss (1320)
    [2888] = { rank = 1 },                        -- Nek'zali the Soulcoiler
    [2874] = { rank = 2 },                        -- Entombed Sentinels
    [2894] = { rank = 2 },                        -- The Lost Explorers
    [2882] = { rank = 3 },                        -- Vashnik the Malignant
    [2871] = { rank = 3 },                        -- Sszorak
    [2887] = { rank = 3 },                        -- The Twin Fangs
    [2883] = { rank = 3, endBoss = true },        -- The Coiled Altar
    [2895] = { rank = 3, endBoss = true },        -- Ula'tek

    -- The Tidebound Grotto (1317). Laut Method folgt der Lair-Boss denselben
    -- Regeln wie ein regulaerer Raidboss.
    [2849] = { rank = 1 },                        -- Nymrissa Wavecaller
}

-- Spanne der Itemlevel einer Raid-Stufe.
--
-- Im Raid ist ein einzelner Wert schlicht falsch: Spaetere Bosse droppen
-- weiter oben im Track, die letzten beiden auf Mythisch sogar darueber hinaus.
-- Statt eine Zahl vorzutaeuschen, die fuer die meisten Bosse nicht stimmt,
-- wird die Spanne gezeigt.
--
-- Belegt fuer Mythisch: 318 (Myth 1/6) bis 344 (Endbosse). Fuer die anderen
-- Schwierigkeiten ist die Staffelung nicht im Detail recherchiert, deshalb
-- wird dort die Track-Spanne bis zum vierten Rang angesetzt, was der
-- beobachteten Staffelung Myth 1/6 bis 3/6 entspricht.
function ns.SourceRange(source, asBonusRoll)
    local r = ns.ResolveSource(source, asBonusRoll)
    if not r then return nil end

    local trackKey = asBonusRoll and (source.bonusTrack or source.track) or source.track
    local t = ns.TRACKS[trackKey]
    if not t then return nil end

    local low = r.ilvl
    local high
    if trackKey == "myth" and source.key == "mythic" then
        high = 344                       -- die beiden Endbosse
    else
        high = t.ilvl[math.min(r.rank + 2, #t.ilvl)]
    end

    if not high or high <= low then return nil end
    return low, high
end

-- Passt eine aufgeloeste Stufe an den konkreten Boss an.
--
-- trackKey wird mitgegeben, weil der Rang im Track nachgeschlagen werden muss
-- und resolved den Schluessel nicht mehr enthaelt.
function ns.BossAdjust(resolved, encounterID, trackKey)
    if not resolved or not encounterID then return resolved end
    local adj = ns.BOSS_RANK[encounterID]
    if not adj then return resolved end

    local t = ns.TRACKS[trackKey]
    if not t then return resolved end

    local out = {}
    for k, v in pairs(resolved) do out[k] = v end

    -- Die letzten beiden Bosse auf Mythisch droppen JENSEITS des regulaeren
    -- Tracks, laut Method 344 statt der sonst hoechsten 334. Nur dort greift
    -- die Sonderbehandlung, auf niedrigeren Schwierigkeiten nicht.
    -- Die Bezeichnung lautet tatsaechlich "Myth 9/6". Neun von sechs klingt
    -- widersinnig, ist aber Blizzards eigene Schreibweise fuer Stufen jenseits
    -- des regulaeren Tracks. Genau so steht es auch bei Method, deshalb wird
    -- es woertlich uebernommen statt in ein huebscheres "max" uebersetzt.
    if adj.endBoss and trackKey == "myth" then
        out.ilvl  = 344
        out.badge = t.letter .. " 9/6"
        out.rank  = #t.ilvl
        return out
    end

    local rank = math.max(1, math.min(adj.rank or 1, #t.ilvl))
    out.ilvl  = t.ilvl[rank]
    out.bonusId = t.bonus[rank]
    out.rank  = rank
    out.badge = string.format("%s %d/6", t.letter, rank)
    return out
end

-- Welcher Track gilt fuer eine Quelle? Wird fuer BossAdjust gebraucht.
function ns.TrackKeyOf(source, asBonusRoll)
    if not source then return nil end
    return asBonusRoll and (source.bonusTrack or source.track) or source.track
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
