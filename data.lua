-- ============================================================================
-- SlotMachine - Loot-Datenbank
-- ============================================================================
--
-- AUTOMATISCH ERZEUGT. Aenderungen von Hand gehen beim naechsten Lauf verloren.
--
-- Erzeugt von tools/generate-data.js aus den SavedVariables, die /sm scan
-- im Spiel geschrieben hat.
--
-- Stand der Rohdaten: 2026-08-14 19:06
--
-- Es stehen bewusst nur IDs in dieser Datei, keine Namen. IDs sind
-- sprachunabhaengig, die Namen holt das Add-on zur Laufzeit vom Client.
-- Ein englischer Client zeigt damit englische, ein deutscher deutsche
-- Namen, ohne dass hier uebersetzt werden muss.

local AddonName, ns = ...

-- Instanz -> Boss -> Item-IDs
ns.LOOT = {
    [1030] = {
        [2142] = { 158370, 159259, 159263, 159317, 159329, 159380, 159388, 159425, 159435, 159636 },
        [2143] = { 158367, 158714, 159255, 159327, 159375, 159637, 162544 },
        [2144] = { 158366, 158369, 158374, 159247, 159442, 159664 },
        [2145] = { 158368, 158373, 159337, 239031, 239032, 239033, 239034, 239035, 239036, 239037 },
    },
    [1041] = {
        [2165] = { 159137, 159234, 159304, 159313, 159369, 159412, 159413, 159617 },
        [2170] = { 159136, 159243, 159288, 159300, 159371, 159418, 159643, 160216 },
        [2171] = { 159312, 159409, 159459, 159618, 159642, 159667, 160213 },
        [2172] = { 159301, 159644, 159645, 239045, 239046, 239047, 239048, 239049, 239050, 239051, 273649 },
    },
    [1202] = {
        [2485] = { 193762, 193763, 193764, 193765, 193766, 193767 },
        [2488] = { 193728, 193757, 193758, 193759, 193761 },
        [2503] = { 193691, 193748, 193750, 193751, 193752, 193753, 193754, 193755, 193756 },
    },
    [1304] = {
        [2679] = { 250243, 251123, 251124, 251125, 251126, 251127, 271680 },
        [2680] = { 250215, 251128, 251129, 251130, 251131, 251132, 251133 },
        [2681] = { 250228, 251134, 251135, 251136, 251137 },
        [2682] = { 250255, 251138, 251139, 251140, 251141, 251142, 258045 },
    },
    [1309] = {
        [2769] = { 250254, 251180, 251181, 251182, 251183, 251184, 251185 },
        [2770] = { 250238, 251186, 251187, 251188, 251189, 251190 },
        [2771] = { 250214, 251165, 251191, 251192, 251193, 251194 },
        [2772] = { 250259, 251195, 251196, 251197, 251198, 251199, 251200 },
    },
    [1311] = {
        [2776] = { 250248, 251143, 251144, 251145, 251146, 251147, 251148 },
        [2777] = { 250244, 251149, 251150, 251151, 251152, 251153, 251154, 251155, 271681 },
        [2778] = { 250229, 251156, 251158, 251159, 251160, 251173, 251214 },
    },
    [1312] = {
        [2782] = { 250446, 250450, 250461 },
        [2827] = { 250447, 250451, 250453, 250456, 250457, 250458, 250459, 250462 },
        [2828] = { 250448, 250454, 250460 },
        [2829] = { 250449, 250452, 250455 },
    },
    [1313] = {
        [2791] = { 250225, 251218, 251219, 251220, 251221, 251222, 251223 },
        [2792] = { 250245, 251224, 251225, 251226, 251227, 251228, 251229, 252258 },
        [2793] = { 250224, 251230, 251231, 251232, 251233, 251234, 251235 },
    },
    [1317] = {
        [2849] = { 268199, 268217, 268221, 268226, 268232, 268238, 268244, 268247, 268262, 268263, 268266, 270167 },
    },
    [1320] = {
        [2871] = { 268201, 268206, 268233, 268234, 268252, 268257, 270163, 270174 },
        [2874] = { 268197, 268198, 268204, 268219, 268224, 268228, 268250, 270165 },
        [2882] = { 268205, 268214, 268246, 268249, 268254, 268260, 270161, 270166 },
        [2883] = { 268209, 268211, 268213, 268222, 268225, 268231, 268237, 268243, 268253, 268255, 268256, 268259, 270169, 270173, 275937 },
        [2887] = { 268220, 268223, 268241, 268251, 268261, 268264, 270170, 270171 },
        [2888] = { 268203, 268208, 268216, 268218, 268229, 268230, 268235, 268236, 268240, 268245, 268248, 270162, 270930, 281227 },
        [2894] = { 268196, 268200, 268210, 268227, 268239, 268242, 268258, 270160, 270164 },
        [2895] = { 268202, 268207, 268215, 268265, 270168, 270175, 271092, 271093, 271874, 271875, 271876, 271878 },
    },
    [1322] = {
        [2878] = { 273775, 273777, 273780, 273785, 273793, 273795, 273796 },
        [2879] = { 273774, 273779, 273781, 273782, 273783, 273786, 273787, 273794 },
        [2880] = { 273773, 273776, 273778, 273784, 273789, 273791, 273792, 273797, 275070 },
    },
}

-- Ausruestungsplaetze. In den Item-Zeilen steht nur der Index in diese
-- Tabelle, das haelt die Datei klein.
--
-- Warum equipLoc und nicht filterType: filterType fasst bei Waffen
-- mehrere Typen zusammen, die 10 steht fuer One-Hand, Two-Hand, Ranged
-- und Main Hand gleichzeitig. Der Slot-Text waere eindeutig, ist aber
-- uebersetzt. equipLoc ist beides: eindeutig und sprachunabhaengig.
ns.EQUIP = {
    [1] = "INVTYPE_2HWEAPON",   -- Two-Hand
    [2] = "INVTYPE_CHEST",   -- Chest
    [3] = "INVTYPE_CLOAK",   -- Back
    [4] = "INVTYPE_FEET",   -- Feet
    [5] = "INVTYPE_FINGER",   -- Finger
    [6] = "INVTYPE_HAND",   -- Hands
    [7] = "INVTYPE_HEAD",   -- Head
    [8] = "INVTYPE_HOLDABLE",   -- Held In Off-hand
    [9] = "INVTYPE_LEGS",   -- Legs
    [10] = "INVTYPE_NECK",   -- Neck
    [11] = "INVTYPE_RANGED",   -- Ranged
    [12] = "INVTYPE_RANGEDRIGHT",   -- Ranged
    [13] = "INVTYPE_ROBE",   -- Chest
    [14] = "INVTYPE_SHIELD",   -- Off Hand
    [15] = "INVTYPE_SHOULDER",   -- Shoulder
    [16] = "INVTYPE_TRINKET",   -- Trinket
    [17] = "INVTYPE_WAIST",   -- Waist
    [18] = "INVTYPE_WEAPON",   -- One-Hand
    [19] = "INVTYPE_WEAPONMAINHAND",   -- Main Hand
    [20] = "INVTYPE_WRIST",   -- Wrist
}

-- Item -> Eigenschaften.
--   e = Index in ns.EQUIP
--   q = Qualitaetsfarbe
--   s = Spezialisierungen. Ein Sternchen heisst: jede Spec kann es
--       tragen. Ringe, Umhaenge und Schmuck sind fast immer so, und
--       die Liste jedes Mal auszuschreiben blaehte die Datei auf.
ns.ITEMS = {
    [158366] = { e = 5, icon = 2000812, q = "ff0070dd", s = "*" },  -- Charged Sandstone Band
    [158367] = { e = 16, icon = 134043, q = "ff0070dd", s = { 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Merektha's Fang
    [158368] = { e = 16, icon = 1658496, q = "ff0070dd", s = { 62, 63, 64, 102, 258, 262, 265, 266, 267, 1467, 1473, 1480 } },  -- Sethraliss' Defiled Relic
    [158369] = { e = 18, icon = 652954, q = "ff0070dd", s = { 65, 102, 105, 256, 257, 258, 262, 264, 270, 1467, 1468, 1473 } },  -- Galvanized Stormcrusher
    [158370] = { e = 1, icon = 1661206, q = "ff0070dd", s = { 103, 104, 255, 268, 269 } },  -- Twin-Strike Polearm
    [158373] = { e = 18, icon = 1881362, q = "ff0070dd", s = { 66, 73, 251 } },  -- Resonating Crystal Scimitar
    [158374] = { e = 16, icon = 1528676, q = "ff0070dd", s = { 103, 253, 254, 255, 259, 260, 261, 263, 269, 577 } },  -- Tiny Electromental in a Jar
    [158714] = { e = 18, icon = 1881362, q = "ff0070dd", s = { 255, 260, 268, 269, 577, 581 } },  -- Swarm's Edge
    [159136] = { e = 18, icon = 1851453, q = "ff0070dd", s = { 255, 259, 261 } },  -- Jeweled Dagger of Subjugation
    [159137] = { e = 18, icon = 1851453, q = "ff0070dd", s = { 62, 63, 64, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 1467, 1468, 1473, 1480 } },  -- Gilded Serpent's Tooth
    [159234] = { e = 9, icon = 1875084, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Down-Lined Breeches
    [159243] = { e = 4, icon = 1875079, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Sandals of Wise Voodoo
    [159247] = { e = 6, icon = 1875082, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Handwraps of Oscillating Polarity
    [159255] = { e = 17, icon = 1875078, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Ouroborial Sash
    [159259] = { e = 4, icon = 1875079, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Sandswept Sandals
    [159263] = { e = 20, icon = 1875080, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Bindings of the Slithering Current
    [159288] = { e = 3, icon = 2054952, q = "ff0070dd", s = "*" },  -- Cloak of the Restless Tribes
    [159300] = { e = 20, icon = 1892755, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Kula's Butchering Wristwraps
    [159301] = { e = 17, icon = 1892753, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Primal Dinomancer's Belt
    [159304] = { e = 4, icon = 1892754, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Goldfeather Boots
    [159312] = { e = 6, icon = 1892757, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Desiccator's Blessed Gloves
    [159313] = { e = 9, icon = 1892759, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Breeches of the Sacred Hall
    [159317] = { e = 17, icon = 1892753, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Whirling Dervish Sash
    [159327] = { e = 4, icon = 1892754, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Sand-Shined Snakeskin Sandals
    [159329] = { e = 9, icon = 1892759, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Leggings of the Galeforce Viper
    [159337] = { e = 6, icon = 1892757, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Grips of Electrified Defense
    [159369] = { e = 17, icon = 2054853, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Belt of the Consecrated Tomb
    [159371] = { e = 4, icon = 2054950, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Boots of the Headlong Conqueror
    [159375] = { e = 9, icon = 2054956, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Legguards of the Awakening Brood
    [159380] = { e = 20, icon = 2054951, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Arc-Glass Bindings
    [159388] = { e = 4, icon = 2054950, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Sabatons of Coruscating Energy
    [159409] = { e = 20, icon = 2001432, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Embalmer's Steadying Bracers
    [159412] = { e = 4, icon = 2001429, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Auric Puddle Stompers
    [159413] = { e = 6, icon = 2019431, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Gauntlets of the Avian Sentinel
    [159418] = { e = 17, icon = 2001428, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Girdle of Pestilent Purification
    [159425] = { e = 20, icon = 2001432, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Shard-Tipped Vambraces
    [159435] = { e = 9, icon = 2019433, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Legplates of Charged Duality
    [159442] = { e = 17, icon = 2001428, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Sand-Scoured Greatbelt
    [159459] = { e = 5, icon = 2000813, q = "ff0070dd", s = "*" },  -- Ritual Binder's Ring
    [159617] = { e = 16, icon = 2103819, q = "ff0070dd", s = { 103, 104, 253, 254, 255, 259, 260, 261, 263, 268, 269, 577, 581 } },  -- Lustrous Golden Plumage
    [159618] = { e = 16, icon = 463527, q = "ff0070dd", s = { 66, 73, 104, 250, 268, 581 } },  -- Mchimba's Ritual Bandages
    [159636] = { e = 1, icon = 1881363, q = "ff0070dd", s = { 62, 63, 64, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 270, 1467, 1468, 1473 } },  -- Staff of the Lightning Serpent
    [159637] = { e = 11, icon = 1968573, q = "ff0070dd", s = { 253, 254 } },  -- Snakebite Recurve
    [159642] = { e = 1, icon = 1722659, q = "ff0070dd", s = { 103, 104, 255, 268, 269 } },  -- Royal Purifier's Spade
    [159643] = { e = 12, icon = 648016, q = "ff0070dd", s = { 253, 254 } },  -- Crossbow of Forgotten Majesty
    [159644] = { e = 1, icon = 1848077, q = "ff0070dd", s = { 70, 71, 72, 250, 251, 252 } },  -- Geti'ikku, Cut of Death
    [159645] = { e = 18, icon = 1966623, q = "ff0070dd", s = { 260, 263, 268, 269 } },  -- Headcracker of Supplication
    [159664] = { e = 14, icon = 1778307, q = "ff0070dd", s = { 65, 66, 73, 262, 264 } },  -- Bulwark of Brimming Potential
    [159667] = { e = 8, icon = 1924157, q = "ff0070dd", s = { 62, 63, 64, 102, 105, 256, 257, 258, 265, 266, 267, 270, 1467, 1468, 1473 } },  -- Vessel of Last Rites
    [160213] = { e = 6, icon = 2054954, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Sepulchral Construct's Gloves
    [160216] = { e = 18, icon = 1881362, q = "ff0070dd", s = { 62, 63, 64, 65, 265, 266, 267, 270, 1467, 1468, 1473, 1480 } },  -- Crackling Jade Kilij
    [162544] = { e = 5, icon = 2000816, q = "ff0070dd", s = "*" },  -- Jade Ophidian Band
    [193691] = { e = 17, icon = 4182955, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Sky Saddle Cord
    [193728] = { e = 4, icon = 4633272, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Scaleguard's Stalwart Greatboots
    [193748] = { e = 16, icon = 4638716, q = "ff0070dd", s = { 65, 105, 256, 257, 264, 270, 1468 } },  -- Kyrakka's Searing Embers
    [193750] = { e = 9, icon = 4182962, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Wind Soarer's Breeches
    [193751] = { e = 7, icon = 4095090, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Crown of Roaring Storms
    [193752] = { e = 6, icon = 4326059, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Galerattle Gauntlets
    [193753] = { e = 2, icon = 4295886, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Breastplate of Soaring Terror
    [193754] = { e = 14, icon = 4549844, q = "ff0070dd", s = { 65, 66, 73, 262, 264 } },  -- Drake Rider's Stecktarge
    [193755] = { e = 1, icon = 4394687, q = "ff0070dd", s = { 70, 71, 72, 250, 251, 252 } },  -- Backdraft Cleaver
    [193756] = { e = 18, icon = 4327583, q = "ff0070dd", s = { 255, 259, 261 } },  -- Skyferno Rondel
    [193757] = { e = 16, icon = 4509422, q = "ff0070dd", s = "*" },  -- Ruby Whelp Shell
    [193758] = { e = 6, icon = 4095089, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Subjugator's Chilling Grips
    [193759] = { e = 9, icon = 4326061, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Egg Tender's Leggings
    [193761] = { e = 1, icon = 4420063, q = "ff0070dd", s = { 62, 63, 64, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 270, 1467, 1468, 1473 } },  -- Chillworn's Infusion Staff
    [193762] = { e = 16, icon = 4638646, q = "ff0070dd", s = { 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Blazebinder's Hoof
    [193763] = { e = 3, icon = 4326057, q = "ff0070dd", s = "*" },  -- Fireproof Drape
    [193764] = { e = 2, icon = 4095088, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Invader's Firestorm Chestguard
    [193765] = { e = 7, icon = 4326060, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Blazebound Lieutenant's Helm
    [193766] = { e = 8, icon = 4526077, q = "ff0070dd", s = { 62, 63, 64, 102, 105, 256, 257, 258, 265, 266, 267, 270, 1467, 1468, 1473 } },  -- Kokia's Burnout Rod
    [193767] = { e = 18, icon = 4266751, q = "ff0070dd", s = { 260, 263, 268, 269 } },  -- Havoc Crusher
    [239031] = { e = 15, icon = 1875085, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Brood Cleanser's Amice
    [239032] = { e = 13, icon = 1875081, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Robes of the Reborn Serpent
    [239033] = { e = 7, icon = 1892758, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Hood of the Slithering Loa
    [239034] = { e = 2, icon = 2054953, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Corrupted Hexxer's Vestments
    [239035] = { e = 7, icon = 2054955, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Sethraliss' Fanged Helm
    [239036] = { e = 2, icon = 2001435, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Desert Guardian's Breastplate
    [239037] = { e = 15, icon = 2001440, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- C'thraxxi Binders Pauldrons
    [239045] = { e = 15, icon = 1875085, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Mantle of Ceremonial Ascension
    [239046] = { e = 2, icon = 2054953, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Loa-Blessed Chestguard
    [239047] = { e = 7, icon = 1875083, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Headdress of the First Empire
    [239048] = { e = 2, icon = 1892756, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Vest of Reverent Adoration
    [239049] = { e = 15, icon = 2054806, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Spaulders of Prime Emperor
    [239050] = { e = 7, icon = 2019432, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Helm of the Raptor King
    [239051] = { e = 15, icon = 2001440, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Pauldrons of the Great Unifier
    [250214] = { e = 16, icon = 132862, q = "ff0070dd", s = { 62, 63, 64, 65, 102, 103, 104, 105, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 577, 581, 1467, 1468, 1473, 1480 } },  -- Lightspire Core
    [250215] = { e = 16, icon = 3566841, q = "ff0070dd", s = { 62, 63, 64, 65, 102, 103, 104, 105, 253, 254, 255, 256, 257, 258, 259, 260, 261, 262, 263, 264, 265, 266, 267, 268, 269, 270, 577, 581, 1467, 1468, 1473, 1480 } },  -- Freightrunner's Flask
    [250224] = { e = 16, icon = 1097742, q = "ff0070dd", s = { 62, 63, 64, 65, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 270, 1467, 1468, 1473, 1480 } },  -- Mindpiercer's Sigil
    [250225] = { e = 16, icon = 2178828, q = "ff0070dd", s = { 103, 104, 253, 254, 255, 259, 260, 261, 263, 268, 269, 577, 581 } },  -- Void Execution Mandate
    [250228] = { e = 16, icon = 3566862, q = "ff0070dd", s = { 66, 70, 71, 72, 73, 103, 104, 250, 251, 252, 253, 254, 255, 259, 260, 261, 263, 268, 269, 577, 581 } },  -- Resonant Bellowstone
    [250229] = { e = 16, icon = 7578259, q = "ff0070dd", s = { 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Idol of the War Loa
    [250238] = { e = 16, icon = 7578263, q = "ff0070dd", s = { 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Seed of the Devouring Wild
    [250243] = { e = 16, icon = 841218, q = "ff0070dd", s = { 66, 73, 104, 250, 268, 581 } },  -- Manaheart's Binding Flame
    [250244] = { e = 16, icon = 7578261, q = "ff0070dd", s = { 66, 73, 104, 250, 268, 581 } },  -- Permafrost Essence
    [250245] = { e = 16, icon = 656595, q = "ff0070dd", s = { 66, 73, 104, 250, 268, 581 } },  -- Tumor of the Swarm
    [250248] = { e = 16, icon = 1029746, q = "ff0070dd", s = { 65, 105, 256, 257, 264, 270, 1468 } },  -- Mycolic Medicine
    [250254] = { e = 16, icon = 7578262, q = "ff0070dd", s = { 65, 105, 256, 257, 264, 270, 1468 } },  -- Seed of Radiant Hope
    [250255] = { e = 16, icon = 1135365, q = "ff0070dd", s = { 65, 105, 256, 257, 264, 270, 1468 } },  -- Unstable Felheart Crystal
    [250259] = { e = 16, icon = 134218, q = "ff0070dd", s = "*" },  -- Sapling of the Dawnroot
    [250446] = { e = 14, icon = 7523136, q = "ffa335ee", s = { 65, 66, 73, 262, 264 } },  -- Cragtender Bulwark
    [250447] = { e = 8, icon = 7319164, q = "ffa335ee", s = { 62, 63, 64, 102, 105, 256, 257, 258, 265, 266, 267, 270, 1467, 1468, 1473 } },  -- Radiant Eversong Scepter
    [250448] = { e = 1, icon = 6994496, q = "ffa335ee", s = "*" },  -- Voidbender's Spire
    [250449] = { e = 18, icon = 7012521, q = "ffa335ee", s = "*" },  -- Skulking Nettledirk
    [250450] = { e = 11, icon = 6989930, q = "ffa335ee", s = { 253, 254 } },  -- Forest Sentinel's Savage Longbow
    [250451] = { e = 18, icon = 7260419, q = "ffa335ee", s = { 255, 260, 263, 268, 269, 577, 581 } },  -- Dawncrazed Beast Cleaver
    [250452] = { e = 18, icon = 7009471, q = "ffa335ee", s = "*" },  -- Blooming Thornblade
    [250453] = { e = 18, icon = 7281355, q = "ffa335ee", s = { 66, 73, 251 } },  -- Scepter of the Unbound Light
    [250454] = { e = 1, icon = 6994475, q = "ffa335ee", s = "*" },  -- Devouring Vanguard's Soulcleaver
    [250455] = { e = 1, icon = 7117445, q = "ffa335ee", s = { 103, 104, 255, 268, 269 } },  -- Beastly Blossombarb
    [250456] = { e = 13, icon = 7444041, q = "ffa335ee", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Wretched Scholar's Gilded Robe
    [250457] = { e = 9, icon = 7388208, q = "ffa335ee", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Devouring Outrider's Chausses
    [250458] = { e = 7, icon = 7382330, q = "ffa335ee", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Host Commander's Casque
    [250459] = { e = 7, icon = 7371093, q = "ffa335ee", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Bramblestalker's Feathered Cowl
    [250460] = { e = 5, icon = 3536116, q = "ffa335ee", s = "*" },  -- Encroaching Shadow Signet
    [250461] = { e = 10, icon = 1360001, q = "ffa335ee", s = "*" },  -- Chain of the Ancient Watcher
    [250462] = { e = 16, icon = 255126, q = "ffa335ee", s = "*" },  -- Forgotten Farstrider's Insignia
    [251123] = { e = 1, icon = 7287363, q = "ff0070dd", s = { 62, 63, 64, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 270, 1467, 1468, 1473 } },  -- Nibbles' Training Rod
    [251124] = { e = 6, icon = 7232472, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Gauntlets of Fevered Defense
    [251125] = { e = 4, icon = 7259231, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Felsoaked Soles
    [251126] = { e = 7, icon = 7135737, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Greathelm of Temptation
    [251127] = { e = 20, icon = 7252743, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Nibbling Armbands
    [251128] = { e = 18, icon = 7009181, q = "ff0070dd", s = { 255, 259, 261 } },  -- Bladesorrow
    [251129] = { e = 6, icon = 7252746, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Counterfeit Clutches
    [251130] = { e = 9, icon = 7232474, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Breeches of Deft Deals
    [251131] = { e = 15, icon = 7259238, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Jangling Felpaulets
    [251132] = { e = 3, icon = 7278020, q = "ff0070dd", s = "*" },  -- Speakeasy Shroud
    [251133] = { e = 20, icon = 7135733, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Overseer's Vambraces
    [251134] = { e = 1, icon = 7231718, q = "ff0070dd", s = { 70, 71, 72, 250, 251, 252 } },  -- Xathuux's Cleave
    [251135] = { e = 20, icon = 7232469, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Fury-fletched Armlets
    [251136] = { e = 5, icon = 7636646, q = "ff0070dd", s = "*" },  -- Signet of Snarling Servitude
    [251137] = { e = 4, icon = 7252742, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Tempestuous Sandals
    [251138] = { e = 15, icon = 7135739, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Cinderfury Shoulderguards
    [251139] = { e = 2, icon = 7252745, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Summoner's Searing Shirt
    [251140] = { e = 7, icon = 7232473, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Vilefiend's Guise
    [251141] = { e = 9, icon = 7259237, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Lithiel's Linked Leggings
    [251142] = { e = 10, icon = 7636611, q = "ff0070dd", s = "*" },  -- Pendant of Malefic Fury
    [251143] = { e = 18, icon = 7065188, q = "ff0070dd", s = { 260, 263, 268, 269, 577, 581 } },  -- Grim Harvest Gloves
    [251144] = { e = 17, icon = 7135731, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Autumn's Boon Belt
    [251145] = { e = 4, icon = 7259231, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Forgotten Tribe Footguards
    [251146] = { e = 15, icon = 7232475, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Scavenger's Spaulders
    [251147] = { e = 2, icon = 7252745, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Hoarded Harvest Wrap
    [251148] = { e = 5, icon = 7636660, q = "ff0070dd", s = "*" },  -- Pilfered Precious Band
    [251149] = { e = 1, icon = 6929479, q = "ff0070dd", s = { 103, 104, 255, 268, 269 } },  -- Victor's Flashfrozen Blade
    [251150] = { e = 14, icon = 7392266, q = "ff0070dd", s = { 65, 66, 73, 262, 264 } },  -- Tempest's Shelter
    [251151] = { e = 2, icon = 7135735, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Sentinel Challenger's Prize
    [251152] = { e = 6, icon = 7259235, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Season's Turn Gauntlets
    [251153] = { e = 4, icon = 7232468, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Arctic Explorer's Legwraps
    [251154] = { e = 20, icon = 7252743, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Winter's Embrace Bracers
    [251155] = { e = 17, icon = 7259230, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Tribal Defender's Cord
    [251156] = { e = 1, icon = 6989931, q = "ff0070dd", s = { 62, 63, 64, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 270, 1467, 1468, 1473 } },  -- Fallen Speaker's Staff
    [251158] = { e = 7, icon = 7259236, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Nalorakk's Nightmare
    [251159] = { e = 2, icon = 7232471, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- War Trial Vestments
    [251160] = { e = 9, icon = 7252748, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Forest Dream Leg-guards
    [251165] = { e = 6, icon = 7259235, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Pulverizing Pads
    [251173] = { e = 10, icon = 7636649, q = "ff0070dd", s = "*" },  -- Yoke of the Charging Bear
    [251180] = { e = 18, icon = 7012521, q = "ff0070dd", s = { 255, 259, 261 } },  -- Thornblade
    [251181] = { e = 1, icon = 7117445, q = "ff0070dd", s = { 70, 71, 72, 250, 251, 252 } },  -- Pruning Lance
    [251182] = { e = 9, icon = 7135738, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Bedrock Breeches
    [251183] = { e = 20, icon = 7232469, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Rootwarden Wraps
    [251184] = { e = 15, icon = 7259238, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Ironroot Collar
    [251185] = { e = 17, icon = 7252741, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Lightblossom Cinch
    [251186] = { e = 18, icon = 7065188, q = "ff0070dd", s = { 260, 263, 268, 269, 577, 581 } },  -- Thorntalon Edge
    [251187] = { e = 12, icon = 7355019, q = "ff0070dd", s = { 253, 254 } },  -- Amirdrassil's Reach
    [251188] = { e = 12, icon = 7412480, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Doompetal
    [251189] = { e = 17, icon = 7278019, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Rootwalker Harness
    [251190] = { e = 3, icon = 7259233, q = "ff0070dd", s = "*" },  -- Bloodthorn Burnous
    [251191] = { e = 8, icon = 7431122, q = "ff0070dd", s = { 62, 63, 64, 102, 105, 256, 257, 258, 265, 266, 267, 270, 1467, 1468, 1473 } },  -- Luminescent Sprout
    [251192] = { e = 1, icon = 6936235, q = "ff0070dd", s = { 103, 104, 255, 268, 269 } },  -- Branch of Pride
    [251193] = { e = 2, icon = 7135735, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Taproot Ribs
    [251194] = { e = 5, icon = 7578284, q = "ff0070dd", s = "*" },  -- Lightwarden's Bind
    [251195] = { e = 18, icon = 6913914, q = "ff0070dd", s = { 66, 73, 251 } },  -- Thorned Reply
    [251196] = { e = 14, icon = 7442214, q = "ff0070dd", s = { 65, 66, 73, 262, 264 } },  -- Teldrassil's Sacrifice
    [251197] = { e = 6, icon = 7135736, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Thornspike Gauntlets
    [251198] = { e = 9, icon = 7232474, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Lightspore Leggings
    [251199] = { e = 7, icon = 7252747, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Worldroot Canopy
    [251200] = { e = 20, icon = 7259232, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Saptorbane Guards
    [251214] = { e = 6, icon = 7135736, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Bonds of the Hash'ura
    [251218] = { e = 18, icon = 6994479, q = "ff0070dd", s = { 66, 73, 251 } },  -- Taz'Rah's Cosmic Edge
    [251219] = { e = 4, icon = 7252742, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Riftworn Stompers
    [251220] = { e = 7, icon = 7259236, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Voidscarred Crown
    [251221] = { e = 6, icon = 7135736, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Despondent's Gauntlets
    [251222] = { e = 17, icon = 7252741, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Ethereal Netherwrap
    [251223] = { e = 15, icon = 7232475, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Somber Spaulders
    [251224] = { e = 18, icon = 6981232, q = "ff0070dd", s = { 255, 260, 263, 268, 269, 577, 581 } },  -- Hulking Handaxe
    [251225] = { e = 18, icon = 7065189, q = "ff0070dd", s = { 62, 63, 64, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 1467, 1468, 1473, 1480 } },  -- Fang of Contagion
    [251226] = { e = 2, icon = 7232471, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Hide of Pestilence
    [251227] = { e = 15, icon = 7252749, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Poisoner's Pauldrons
    [251228] = { e = 17, icon = 7259230, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Behemoth Waistband
    [251229] = { e = 7, icon = 7383546, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Visor of the Predator
    [251230] = { e = 1, icon = 6994512, q = "ff0070dd", s = { 70, 71, 72, 250, 251, 252 } },  -- Charonic Crescent
    [251231] = { e = 18, icon = 6936237, q = "ff0070dd", s = { 577, 581, 1480 } },  -- Singularity Slicer
    [251232] = { e = 7, icon = 7252747, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Overseer's Diadem
    [251233] = { e = 2, icon = 7259234, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Manipulator's Vest
    [251234] = { e = 10, icon = 7636583, q = "ff0070dd", s = "*" },  -- Graft of the Domanaar
    [251235] = { e = 17, icon = 7278019, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Gravitic Girdle
    [252258] = { e = 5, icon = 7636586, q = "ff0070dd", s = "*" },  -- Sickening Signet of Atroxus
    [258045] = { e = 18, icon = 7151971, q = "ff0070dd", s = "*" },  -- Dawnblade's Glaives
    [268196] = { e = 14, icon = 7553253, q = "ffa335ee", s = { 65, 66, 73, 262, 264 } },  -- Venom-Slashed Scuteward
    [268197] = { e = 8, icon = 7500005, q = "ffa335ee", s = { 62, 63, 64, 102, 105, 256, 257, 258, 265, 266, 267, 270, 1467, 1468, 1473 } },  -- Spine of the Hissing Abyss
    [268198] = { e = 1, icon = 7576051, q = "ffa335ee", s = { 70, 71, 72, 250, 251, 252 } },  -- Caustic Keeper-Crusher
    [268199] = { e = 1, icon = 7552246, q = "ffa335ee", s = { 103, 104, 255, 268, 269 } },  -- Tidepiercer's Bubble Popper
    [268200] = { e = 12, icon = 7476193, q = "ffa335ee", s = { 253, 254 } },  -- Gebbo's Backup Blaster
    [268201] = { e = 18, icon = 7499262, q = "ffa335ee", s = { 577, 581, 1480 } },  -- Venomous Boneglaive
    [268202] = { e = 18, icon = 7723761, q = "ffa335ee", s = { 66, 73, 251 } },  -- Jaw of the Shackled Goddess
    [268203] = { e = 18, icon = 7515621, q = "ffa335ee", s = { 62, 63, 64, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 1467, 1468, 1473, 1480 } },  -- Hexing Spiritrender
    [268204] = { e = 18, icon = 7701065, q = "ffa335ee", s = { 255, 259, 261 } },  -- Ancient Construct's Venomshiv
    [268205] = { e = 1, icon = 7502501, q = "ffa335ee", s = { 62, 63, 64, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 270, 1467, 1468, 1473 } },  -- Venomancer's Winged Channeler
    [268206] = { e = 18, icon = 7502390, q = "ffa335ee", s = { 260, 263, 268, 269 } },  -- Slithering Savage's Gavel
    [268207] = { e = 11, icon = 7488509, q = "ffa335ee", s = { 253, 254 } },  -- Caustic Repose Greatbow
    [268208] = { e = 18, icon = 7736101, q = "ffa335ee", s = { 66, 73, 251 } },  -- Strongblood's Ceremonial Cleaver
    [268209] = { e = 19, icon = 7736101, q = "ffa335ee", s = { 66, 73, 251, 255, 260, 263, 268, 269, 577, 581 } },  -- Aman'muso, Warlord's Vengeance
    [268210] = { e = 18, icon = 7502390, q = "ffa335ee", s = { 65, 102, 105, 256, 257, 258, 262, 264, 270, 1467, 1468, 1473 } },  -- Malevolent Spiritcudgel
    [268211] = { e = 18, icon = 7723761, q = "ffa335ee", s = { 62, 63, 64, 65, 265, 266, 267, 270, 1467, 1468, 1473, 1480 } },  -- Baleful Hexblade
    [268213] = { e = 1, icon = 7455434, q = "ffa335ee", s = { 70, 71, 72, 250, 251, 252 } },  -- Maze-roa, Warlord's Fury
    [268214] = { e = 1, icon = 7506565, q = "ffa335ee", s = { 70, 71, 72, 250, 251, 252 } },  -- Malignant Toothed Edge
    [268215] = { e = 1, icon = 7480487, q = "ffa335ee", s = { 103, 104, 255, 268, 269 } },  -- Abyssal Broodfiend's Bardiche
    [268216] = { e = 17, icon = 7789852, q = "ffa335ee", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Cursed Reliquary Cincture
    [268217] = { e = 20, icon = 7554475, q = "ffa335ee", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Rising Tide Wristguards
    [268218] = { e = 4, icon = 7667305, q = "ffa335ee", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Nek'zali's Spiritwalkers
    [268219] = { e = 7, icon = 7678400, q = "ffa335ee", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Shadow Hunter's Warmask
    [268220] = { e = 6, icon = 7730302, q = "ffa335ee", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Scaleplate Strangulators
    [268221] = { e = 13, icon = 7520906, q = "ffa335ee", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Tidebound Sorcereress's Robes
    [268222] = { e = 2, icon = 7515795, q = "ffa335ee", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Reckless Spirit Breastplate
    [268223] = { e = 2, icon = 7554477, q = "ffa335ee", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Ophidian Fangmail
    [268224] = { e = 9, icon = 7515798, q = "ffa335ee", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Venom Warden's Greaves
    [268225] = { e = 9, icon = 7487943, q = "ffa335ee", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Coiled Hex Legguards
    [268226] = { e = 15, icon = 7730305, q = "ffa335ee", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Swelling Sea Spaulders
    [268227] = { e = 17, icon = 7678393, q = "ffa335ee", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Unpossessed Skullsash
    [268228] = { e = 20, icon = 7807652, q = "ffa335ee", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Venom-Singed Cuffs
    [268229] = { e = 7, icon = 7739389, q = "ffa335ee", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Skullguard of the Risen Sacrifice
    [268230] = { e = 7, icon = 7705647, q = "ffa335ee", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Crown of the Eternal Fang
    [268231] = { e = 15, icon = 7705650, q = "ffa335ee", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Soulslither Spaulders
    [268232] = { e = 17, icon = 7807649, q = "ffa335ee", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Cincture of the Abyssal Grotto
    [268233] = { e = 4, icon = 7557369, q = "ffa335ee", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Ferocious Scaleboots
    [268234] = { e = 6, icon = 7679654, q = "ffa335ee", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Ruthless Slaughtergrips
    [268235] = { e = 13, icon = 7579166, q = "ffa335ee", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Vestment of the Awakening
    [268236] = { e = 9, icon = 7667310, q = "ffa335ee", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Initiate's Sacrificial Tights
    [268237] = { e = 9, icon = 7789850, q = "ffa335ee", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Cuisses of the Uncoiled Union
    [268238] = { e = 6, icon = 7789857, q = "ffa335ee", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Grips of Swirling Fury
    [268239] = { e = 20, icon = 7739385, q = "ffa335ee", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Shellbound Bracers
    [268240] = { e = 20, icon = 8095063, q = "ffa335ee", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Restless Spirit Shackles
    [268241] = { e = 15, icon = 7807660, q = "ffa335ee", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Ornaments of the Eternal Coil
    [268242] = { e = 7, icon = 7667309, q = "ffa335ee", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Errant Scrollsage's Hood
    [268243] = { e = 6, icon = 7520895, q = "ffa335ee", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Grasps of the Eternal Shadow
    [268244] = { e = 17, icon = 7739383, q = "ffa335ee", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Forgotten Grotto Girdle
    [268245] = { e = 4, icon = 7515792, q = "ffa335ee", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Entombed Cultist's Sabatons
    [268246] = { e = 15, icon = 7679657, q = "ffa335ee", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Frothing Venom Spaulders
    [268247] = { e = 4, icon = 7679650, q = "ffa335ee", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Breakwater Boots
    [268248] = { e = 3, icon = 7487939, q = "ffa335ee", s = "*" },  -- Amani Summoning Shawl
    [268249] = { e = 5, icon = 7866597, q = "ffa335ee", s = "*" },  -- Vile Alchemist's Band
    [268250] = { e = 10, icon = 7866585, q = "ffa335ee", s = "*" },  -- Sentinel's Vitriolic Chain
    [268251] = { e = 10, icon = 7866583, q = "ffa335ee", s = "*" },  -- Amulet of the Twin Fangs
    [268252] = { e = 5, icon = 7866608, q = "ffa335ee", s = "*" },  -- Apex Brute's Claw Ring
    [268253] = { e = 3, icon = 7678397, q = "ffa335ee", s = "*" },  -- Silken Voodoo Drape
    [268254] = { e = 17, icon = 7705642, q = "ffa335ee", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Serpentine Mixing Belt
    [268255] = { e = 4, icon = 7807651, q = "ffa335ee", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Cackling Soultreads
    [268256] = { e = 17, icon = 7579159, q = "ffa335ee", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Sash of the Forlorn Vessel
    [268257] = { e = 17, icon = 7520891, q = "ffa335ee", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Caustic Chain-Wrapped Sash
    [268258] = { e = 4, icon = 7789853, q = "ffa335ee", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Boots of the Reckless Wayfarer
    [268259] = { e = 17, icon = 7730297, q = "ffa335ee", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Girdle of Toxic Regret
    [268260] = { e = 4, icon = 7730298, q = "ffa335ee", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Scaled Fiend's Warboots
    [268261] = { e = 4, icon = 7487936, q = "ffa335ee", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Bespittled Slitherslippers
    [268262] = { e = 14, icon = 7553253, q = "ffa335ee", s = { 65, 66, 73, 262, 264 } },  -- Bubblefin Splash Guard
    [268263] = { e = 8, icon = 7500005, q = "ffa335ee", s = { 62, 63, 64, 102, 105, 256, 257, 258, 265, 266, 267, 270, 1467, 1468, 1473 } },  -- Frostscale's Mystic Frond
    [268264] = { e = 18, icon = 7515621, q = "ffa335ee", s = { 255, 259, 261 } },  -- Ravenous Feaster's Fang
    [268265] = { e = 10, icon = 7866590, q = "ffa335ee", s = "*" },  -- Aqirbane Reliquary
    [268266] = { e = 5, icon = 1391765, q = "ffa335ee", s = "*" },  -- Alluring Bubbleband
    [270160] = { e = 16, icon = 6361206, q = "ffa335ee", s = { 66, 73, 104, 250, 268, 581 } },  -- First Mate's Shellward
    [270161] = { e = 16, icon = 7956745, q = "ffa335ee", s = { 62, 63, 64, 102, 258, 262, 265, 266, 267, 1467, 1473, 1480 } },  -- Fang of Umbral Malignance
    [270162] = { e = 16, icon = 7956752, q = "ffa335ee", s = { 65, 105, 256, 257, 264, 270, 1468 } },  -- Soulcoiler Ritual Vessel
    [270163] = { e = 16, icon = 7956757, q = "ffa335ee", s = { 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Sszorak's Ferocity
    [270164] = { e = 16, icon = 4549224, q = "ffa335ee", s = "*" },  -- Gebbo's Bottomless Bag
    [270165] = { e = 16, icon = 7956747, q = "ffa335ee", s = { 66, 70, 71, 72, 73, 103, 104, 250, 251, 252, 253, 254, 255, 259, 260, 261, 263, 268, 269, 577, 581 } },  -- Keeper's Seething Core
    [270166] = { e = 16, icon = 6011948, q = "ffa335ee", s = { 103, 253, 254, 255, 259, 260, 261, 263, 269, 577 } },  -- Vashnik's Sanguine Rancor
    [270167] = { e = 16, icon = 1020350, q = "ffa335ee", s = { 62, 63, 64, 65, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 270, 1467, 1468, 1473, 1480 } },  -- Wavecaller's Seastone
    [270168] = { e = 16, icon = 4638540, q = "ffa335ee", s = { 62, 63, 64, 70, 71, 72, 102, 103, 251, 252, 253, 254, 255, 258, 259, 260, 261, 262, 263, 265, 266, 267, 269, 577, 1467, 1473, 1480 } },  -- Font of Venomous Rage
    [270169] = { e = 16, icon = 1001629, q = "ffa335ee", s = { 62, 63, 64, 65, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 270, 1467, 1468, 1473, 1480 } },  -- Hex Lord's Dooming Idol
    [270170] = { e = 16, icon = 6012071, q = "ffa335ee", s = { 62, 63, 64, 102, 258, 262, 265, 266, 267, 1467, 1473, 1480 } },  -- Vexhul's Everflowing Gland
    [270171] = { e = 16, icon = 6011929, q = "ffa335ee", s = { 65, 105, 256, 257, 264, 270, 1468 } },  -- Preternatural Antivenom
    [270173] = { e = 16, icon = 7956755, q = "ffa335ee", s = { 70, 71, 72, 103, 251, 252, 253, 254, 255, 259, 260, 261, 263, 269, 577 } },  -- Zul'jin's Guillotine Technique
    [270174] = { e = 16, icon = 237237, q = "ffa335ee", s = { 66, 73, 104, 250, 268, 581 } },  -- Idol of the Howling Nexus
    [270175] = { e = 16, icon = 7956750, q = "ffa335ee", s = { 66, 70, 71, 72, 73, 103, 104, 250, 251, 252, 253, 254, 255, 259, 260, 261, 263, 268, 269, 577, 581 } },  -- Voracious Heart of Ula'tek
    [270930] = { e = 18, icon = 7530467, q = "ffa335ee", s = { 260, 263, 268, 269, 577, 581 } },  -- Tomb-Creeper's Claw
    [271092] = { e = 18, icon = 7850590, q = "ffa335ee", s = { 62, 63, 64, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 1467, 1468, 1473, 1480 } },  -- Jan'thrazet, the Soul Fang
    [271093] = { e = 19, icon = 7578560, q = "ffa335ee", s = { 255, 259, 261 } },  -- Zatha'tek, Breath of Corruption
    [271680] = { e = 12, icon = 5342966, q = "ff0070dd", s = { 253, 254 } },  -- Sinseared Repeater
    [271681] = { e = 8, icon = 7431122, q = "ff0070dd", s = { 62, 63, 64, 102, 105, 256, 257, 258, 265, 266, 267, 270, 1467, 1468, 1473 } },  -- Perennial Frostbound Charm
    [271874] = { e = 7, icon = 7520904, q = "ffa335ee", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Venomkeeper's Horrific Cowl
    [271875] = { e = 7, icon = 7579164, q = "ffa335ee", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Gaze of the Coiled Watcher
    [271876] = { e = 2, icon = 7789856, q = "ffa335ee", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Awoken Dreadfang Cuirass
    [271878] = { e = 9, icon = 7739390, q = "ffa335ee", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Chausses of Unbound Rancor
    [273649] = { e = 16, icon = 1360043, q = "ff0070dd", s = { 62, 63, 64, 65, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 270, 1467, 1468, 1473, 1480 } },  -- Stormbound Emblem of Dazar
    [273773] = { e = 6, icon = 7874490, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Handwraps of Blasphemous Rites
    [273774] = { e = 15, icon = 7865325, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Snakeskin Spaulders
    [273775] = { e = 20, icon = 7871827, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Hydra Scale Wristguards
    [273776] = { e = 9, icon = 7876609, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Ancient General's Obsidian Pillars
    [273777] = { e = 4, icon = 7876612, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Poison-Proof Stompers
    [273778] = { e = 18, icon = 7893615, q = "ff0070dd", s = { 62, 63, 64, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 1467, 1468, 1473, 1480 } },  -- Polished Lightwood Channeler
    [273779] = { e = 8, icon = 7651189, q = "ff0070dd", s = { 62, 63, 64, 102, 105, 256, 257, 258, 265, 266, 267, 270, 1467, 1468, 1473 } },  -- Nocuous Focal Fang
    [273780] = { e = 18, icon = 7674304, q = "ff0070dd", s = { 65, 262, 264, 270, 1467, 1468, 1473, 1480 } },  -- Venom-Etched Crescent
    [273781] = { e = 10, icon = 7866594, q = "ff0070dd", s = "*" },  -- Strand of Warding Fangs
    [273782] = { e = 1, icon = 7651212, q = "ff0070dd", s = { 70, 71, 72, 250, 251, 252 } },  -- Vile Writhefang Glaive
    [273783] = { e = 1, icon = 7761089, q = "ff0070dd", s = { 103, 104, 255, 268, 269 } },  -- Toxin-Coated Warstaff
    [273784] = { e = 11, icon = 7700598, q = "ff0070dd", s = { 253, 254 } },  -- Ancestral Amani Recurve
    [273785] = { e = 13, icon = 7874492, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Primordial Robe of Rites
    [273786] = { e = 9, icon = 7875759, q = "ff0070dd", s = { 62, 63, 64, 256, 257, 258, 265, 266, 267 } },  -- Leggings of Entwined Serpents
    [273787] = { e = 2, icon = 7876615, q = "ff0070dd", s = { 65, 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Aged Interwoven Scaleplate
    [273789] = { e = 2, icon = 7871829, q = "ff0070dd", s = { 253, 254, 255, 262, 263, 264, 1467, 1468, 1473 } },  -- Chestguard of Corroded Scales
    [273791] = { e = 7, icon = 7865323, q = "ff0070dd", s = { 102, 103, 104, 105, 259, 260, 261, 268, 269, 270, 577, 581, 1480 } },  -- Spare Speaker's Hood
    [273792] = { e = 5, icon = 7866600, q = "ff0070dd", s = "*" },  -- Band of the Amani Warlord
    [273793] = { e = 18, icon = 7672957, q = "ff0070dd", s = { 577, 581, 1480 } },  -- Hydraspine Twinblade
    [273794] = { e = 16, icon = 7956742, q = "ff0070dd", s = { 62, 63, 64, 65, 102, 105, 256, 257, 258, 262, 264, 265, 266, 267, 270, 1467, 1468, 1473, 1480 } },  -- Knot of Writhing Serpents
    [273795] = { e = 16, icon = 7956734, q = "ff0070dd", s = { 66, 70, 71, 72, 73, 250, 251, 252 } },  -- Coiled Fangstone
    [273796] = { e = 16, icon = 7956740, q = "ff0070dd", s = "*" },  -- Vile Vial of Volatile Venom
    [273797] = { e = 16, icon = 7956733, q = "ff0070dd", s = { 70, 71, 72, 103, 251, 252, 253, 254, 255, 259, 260, 261, 263, 269, 577 } },  -- Tattered Amani War Banner
    [275070] = { e = 18, icon = 7893615, q = "ff0070dd", s = { 255, 259, 261 } },  -- Sharpened Lightwood Slasher
    [275937] = { e = 7, icon = 7652220, q = "ff0070dd", s = "*" },  -- Hex Lord's Visage
    [281227] = { e = 7, icon = 7558105, q = "ff0070dd", s = "*" },  -- Soulcoiler's Rush'kah
}
