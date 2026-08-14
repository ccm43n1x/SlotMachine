-- ============================================================================
-- SlotMachine - Loot-Datenbank
-- ============================================================================
--
-- AUTOMATISCH ERZEUGT. Aenderungen von Hand gehen beim naechsten Lauf verloren.
--
-- Erzeugt von tools/generate-data.js aus den SavedVariables, die /sm scan
-- im Spiel geschrieben hat.
--
-- Stand der Rohdaten: 2026-08-14 18:19
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

-- Item -> Eigenschaften. filterType ist der sprachunabhaengige Slot.
ns.ITEMS = {
    [158366] = { f = 12, icon = 2000812, q = "ff0070dd" },  -- Charged Sandstone Band
    [158367] = { f = 13, icon = 134043, q = "ff0070dd" },  -- Merektha's Fang
    [158368] = { f = 13, icon = 1658496, q = "ff0070dd" },  -- Sethraliss' Defiled Relic
    [158369] = { f = 10, icon = 652954, q = "ff0070dd" },  -- Galvanized Stormcrusher
    [158370] = { f = 10, icon = 1661206, q = "ff0070dd" },  -- Twin-Strike Polearm
    [158373] = { f = 10, icon = 1881362, q = "ff0070dd" },  -- Resonating Crystal Scimitar
    [158374] = { f = 13, icon = 1528676, q = "ff0070dd" },  -- Tiny Electromental in a Jar
    [158714] = { f = 10, icon = 1881362, q = "ff0070dd" },  -- Swarm's Edge
    [159136] = { f = 10, icon = 1851453, q = "ff0070dd" },  -- Jeweled Dagger of Subjugation
    [159137] = { f = 10, icon = 1851453, q = "ff0070dd" },  -- Gilded Serpent's Tooth
    [159234] = { f = 8, icon = 1875084, q = "ff0070dd" },  -- Down-Lined Breeches
    [159243] = { f = 9, icon = 1875079, q = "ff0070dd" },  -- Sandals of Wise Voodoo
    [159247] = { f = 6, icon = 1875082, q = "ff0070dd" },  -- Handwraps of Oscillating Polarity
    [159255] = { f = 7, icon = 1875078, q = "ff0070dd" },  -- Ouroborial Sash
    [159259] = { f = 9, icon = 1875079, q = "ff0070dd" },  -- Sandswept Sandals
    [159263] = { f = 5, icon = 1875080, q = "ff0070dd" },  -- Bindings of the Slithering Current
    [159288] = { f = 3, icon = 2054952, q = "ff0070dd" },  -- Cloak of the Restless Tribes
    [159300] = { f = 5, icon = 1892755, q = "ff0070dd" },  -- Kula's Butchering Wristwraps
    [159301] = { f = 7, icon = 1892753, q = "ff0070dd" },  -- Primal Dinomancer's Belt
    [159304] = { f = 9, icon = 1892754, q = "ff0070dd" },  -- Goldfeather Boots
    [159312] = { f = 6, icon = 1892757, q = "ff0070dd" },  -- Desiccator's Blessed Gloves
    [159313] = { f = 8, icon = 1892759, q = "ff0070dd" },  -- Breeches of the Sacred Hall
    [159317] = { f = 7, icon = 1892753, q = "ff0070dd" },  -- Whirling Dervish Sash
    [159327] = { f = 9, icon = 1892754, q = "ff0070dd" },  -- Sand-Shined Snakeskin Sandals
    [159329] = { f = 8, icon = 1892759, q = "ff0070dd" },  -- Leggings of the Galeforce Viper
    [159337] = { f = 6, icon = 1892757, q = "ff0070dd" },  -- Grips of Electrified Defense
    [159369] = { f = 7, icon = 2054853, q = "ff0070dd" },  -- Belt of the Consecrated Tomb
    [159371] = { f = 9, icon = 2054950, q = "ff0070dd" },  -- Boots of the Headlong Conqueror
    [159375] = { f = 8, icon = 2054956, q = "ff0070dd" },  -- Legguards of the Awakening Brood
    [159380] = { f = 5, icon = 2054951, q = "ff0070dd" },  -- Arc-Glass Bindings
    [159388] = { f = 9, icon = 2054950, q = "ff0070dd" },  -- Sabatons of Coruscating Energy
    [159409] = { f = 5, icon = 2001432, q = "ff0070dd" },  -- Embalmer's Steadying Bracers
    [159412] = { f = 9, icon = 2001429, q = "ff0070dd" },  -- Auric Puddle Stompers
    [159413] = { f = 6, icon = 2019431, q = "ff0070dd" },  -- Gauntlets of the Avian Sentinel
    [159418] = { f = 7, icon = 2001428, q = "ff0070dd" },  -- Girdle of Pestilent Purification
    [159425] = { f = 5, icon = 2001432, q = "ff0070dd" },  -- Shard-Tipped Vambraces
    [159435] = { f = 8, icon = 2019433, q = "ff0070dd" },  -- Legplates of Charged Duality
    [159442] = { f = 7, icon = 2001428, q = "ff0070dd" },  -- Sand-Scoured Greatbelt
    [159459] = { f = 12, icon = 2000813, q = "ff0070dd" },  -- Ritual Binder's Ring
    [159617] = { f = 13, icon = 2103819, q = "ff0070dd" },  -- Lustrous Golden Plumage
    [159618] = { f = 13, icon = 463527, q = "ff0070dd" },  -- Mchimba's Ritual Bandages
    [159636] = { f = 10, icon = 1881363, q = "ff0070dd" },  -- Staff of the Lightning Serpent
    [159637] = { f = 10, icon = 1968573, q = "ff0070dd" },  -- Snakebite Recurve
    [159642] = { f = 10, icon = 1722659, q = "ff0070dd" },  -- Royal Purifier's Spade
    [159643] = { f = 10, icon = 648016, q = "ff0070dd" },  -- Crossbow of Forgotten Majesty
    [159644] = { f = 10, icon = 1848077, q = "ff0070dd" },  -- Geti'ikku, Cut of Death
    [159645] = { f = 10, icon = 1966623, q = "ff0070dd" },  -- Headcracker of Supplication
    [159664] = { f = 11, icon = 1778307, q = "ff0070dd" },  -- Bulwark of Brimming Potential
    [159667] = { f = 11, icon = 1924157, q = "ff0070dd" },  -- Vessel of Last Rites
    [160213] = { f = 6, icon = 2054954, q = "ff0070dd" },  -- Sepulchral Construct's Gloves
    [160216] = { f = 10, icon = 1881362, q = "ff0070dd" },  -- Crackling Jade Kilij
    [162544] = { f = 12, icon = 2000816, q = "ff0070dd" },  -- Jade Ophidian Band
    [193691] = { f = 7, icon = 4182955, q = "ff0070dd" },  -- Sky Saddle Cord
    [193728] = { f = 9, icon = 4633272, q = "ff0070dd" },  -- Scaleguard's Stalwart Greatboots
    [193748] = { f = 13, icon = 4638716, q = "ff0070dd" },  -- Kyrakka's Searing Embers
    [193750] = { f = 8, icon = 4182962, q = "ff0070dd" },  -- Wind Soarer's Breeches
    [193751] = { f = 0, icon = 4095090, q = "ff0070dd" },  -- Crown of Roaring Storms
    [193752] = { f = 6, icon = 4326059, q = "ff0070dd" },  -- Galerattle Gauntlets
    [193753] = { f = 4, icon = 4295886, q = "ff0070dd" },  -- Breastplate of Soaring Terror
    [193754] = { f = 11, icon = 4549844, q = "ff0070dd" },  -- Drake Rider's Stecktarge
    [193755] = { f = 10, icon = 4394687, q = "ff0070dd" },  -- Backdraft Cleaver
    [193756] = { f = 10, icon = 4327583, q = "ff0070dd" },  -- Skyferno Rondel
    [193757] = { f = 13, icon = 4509422, q = "ff0070dd" },  -- Ruby Whelp Shell
    [193758] = { f = 6, icon = 4095089, q = "ff0070dd" },  -- Subjugator's Chilling Grips
    [193759] = { f = 8, icon = 4326061, q = "ff0070dd" },  -- Egg Tender's Leggings
    [193761] = { f = 10, icon = 4420063, q = "ff0070dd" },  -- Chillworn's Infusion Staff
    [193762] = { f = 13, icon = 4638646, q = "ff0070dd" },  -- Blazebinder's Hoof
    [193763] = { f = 3, icon = 4326057, q = "ff0070dd" },  -- Fireproof Drape
    [193764] = { f = 4, icon = 4095088, q = "ff0070dd" },  -- Invader's Firestorm Chestguard
    [193765] = { f = 0, icon = 4326060, q = "ff0070dd" },  -- Blazebound Lieutenant's Helm
    [193766] = { f = 11, icon = 4526077, q = "ff0070dd" },  -- Kokia's Burnout Rod
    [193767] = { f = 10, icon = 4266751, q = "ff0070dd" },  -- Havoc Crusher
    [239031] = { f = 2, icon = 1875085, q = "ff0070dd" },  -- Brood Cleanser's Amice
    [239032] = { f = 4, icon = 1875081, q = "ff0070dd" },  -- Robes of the Reborn Serpent
    [239033] = { f = 0, icon = 1892758, q = "ff0070dd" },  -- Hood of the Slithering Loa
    [239034] = { f = 4, icon = 2054953, q = "ff0070dd" },  -- Corrupted Hexxer's Vestments
    [239035] = { f = 0, icon = 2054955, q = "ff0070dd" },  -- Sethraliss' Fanged Helm
    [239036] = { f = 4, icon = 2001435, q = "ff0070dd" },  -- Desert Guardian's Breastplate
    [239037] = { f = 2, icon = 2001440, q = "ff0070dd" },  -- C'thraxxi Binders Pauldrons
    [239045] = { f = 2, icon = 1875085, q = "ff0070dd" },  -- Mantle of Ceremonial Ascension
    [239046] = { f = 4, icon = 2054953, q = "ff0070dd" },  -- Loa-Blessed Chestguard
    [239047] = { f = 0, icon = 1875083, q = "ff0070dd" },  -- Headdress of the First Empire
    [239048] = { f = 4, icon = 1892756, q = "ff0070dd" },  -- Vest of Reverent Adoration
    [239049] = { f = 2, icon = 2054806, q = "ff0070dd" },  -- Spaulders of Prime Emperor
    [239050] = { f = 0, icon = 2019432, q = "ff0070dd" },  -- Helm of the Raptor King
    [239051] = { f = 2, icon = 2001440, q = "ff0070dd" },  -- Pauldrons of the Great Unifier
    [250214] = { f = 13, icon = 132862, q = "ff0070dd" },  -- Lightspire Core
    [250215] = { f = 13, icon = 3566841, q = "ff0070dd" },  -- Freightrunner's Flask
    [250224] = { f = 13, icon = 1097742, q = "ff0070dd" },  -- Mindpiercer's Sigil
    [250225] = { f = 13, icon = 2178828, q = "ff0070dd" },  -- Void Execution Mandate
    [250228] = { f = 13, icon = 3566862, q = "ff0070dd" },  -- Resonant Bellowstone
    [250229] = { f = 13, icon = 7578259, q = "ff0070dd" },  -- Idol of the War Loa
    [250238] = { f = 13, icon = 7578263, q = "ff0070dd" },  -- Seed of the Devouring Wild
    [250243] = { f = 13, icon = 841218, q = "ff0070dd" },  -- Manaheart's Binding Flame
    [250244] = { f = 13, icon = 7578261, q = "ff0070dd" },  -- Permafrost Essence
    [250245] = { f = 13, icon = 656595, q = "ff0070dd" },  -- Tumor of the Swarm
    [250248] = { f = 13, icon = 1029746, q = "ff0070dd" },  -- Mycolic Medicine
    [250254] = { f = 13, icon = 7578262, q = "ff0070dd" },  -- Seed of Radiant Hope
    [250255] = { f = 13, icon = 1135365, q = "ff0070dd" },  -- Unstable Felheart Crystal
    [250259] = { f = 13, icon = 134218, q = "ff0070dd" },  -- Sapling of the Dawnroot
    [250446] = { f = 11, icon = 7523136, q = "ffa335ee" },  -- Cragtender Bulwark
    [250447] = { f = 11, icon = 7319164, q = "ffa335ee" },  -- Radiant Eversong Scepter
    [250448] = { f = 10, icon = 6994496, q = "ffa335ee" },  -- Voidbender's Spire
    [250449] = { f = 10, icon = 7012521, q = "ffa335ee" },  -- Skulking Nettledirk
    [250450] = { f = 10, icon = 6989930, q = "ffa335ee" },  -- Forest Sentinel's Savage Longbow
    [250451] = { f = 10, icon = 7260419, q = "ffa335ee" },  -- Dawncrazed Beast Cleaver
    [250452] = { f = 10, icon = 7009471, q = "ffa335ee" },  -- Blooming Thornblade
    [250453] = { f = 10, icon = 7281355, q = "ffa335ee" },  -- Scepter of the Unbound Light
    [250454] = { f = 10, icon = 6994475, q = "ffa335ee" },  -- Devouring Vanguard's Soulcleaver
    [250455] = { f = 10, icon = 7117445, q = "ffa335ee" },  -- Beastly Blossombarb
    [250456] = { f = 4, icon = 7444041, q = "ffa335ee" },  -- Wretched Scholar's Gilded Robe
    [250457] = { f = 8, icon = 7388208, q = "ffa335ee" },  -- Devouring Outrider's Chausses
    [250458] = { f = 0, icon = 7382330, q = "ffa335ee" },  -- Host Commander's Casque
    [250459] = { f = 0, icon = 7371093, q = "ffa335ee" },  -- Bramblestalker's Feathered Cowl
    [250460] = { f = 12, icon = 3536116, q = "ffa335ee" },  -- Encroaching Shadow Signet
    [250461] = { f = 1, icon = 1360001, q = "ffa335ee" },  -- Chain of the Ancient Watcher
    [250462] = { f = 13, icon = 255126, q = "ffa335ee" },  -- Forgotten Farstrider's Insignia
    [251123] = { f = 10, icon = 7287363, q = "ff0070dd" },  -- Nibbles' Training Rod
    [251124] = { f = 6, icon = 7232472, q = "ff0070dd" },  -- Gauntlets of Fevered Defense
    [251125] = { f = 9, icon = 7259231, q = "ff0070dd" },  -- Felsoaked Soles
    [251126] = { f = 0, icon = 7135737, q = "ff0070dd" },  -- Greathelm of Temptation
    [251127] = { f = 5, icon = 7252743, q = "ff0070dd" },  -- Nibbling Armbands
    [251128] = { f = 10, icon = 7009181, q = "ff0070dd" },  -- Bladesorrow
    [251129] = { f = 6, icon = 7252746, q = "ff0070dd" },  -- Counterfeit Clutches
    [251130] = { f = 8, icon = 7232474, q = "ff0070dd" },  -- Breeches of Deft Deals
    [251131] = { f = 2, icon = 7259238, q = "ff0070dd" },  -- Jangling Felpaulets
    [251132] = { f = 3, icon = 7278020, q = "ff0070dd" },  -- Speakeasy Shroud
    [251133] = { f = 5, icon = 7135733, q = "ff0070dd" },  -- Overseer's Vambraces
    [251134] = { f = 10, icon = 7231718, q = "ff0070dd" },  -- Xathuux's Cleave
    [251135] = { f = 5, icon = 7232469, q = "ff0070dd" },  -- Fury-fletched Armlets
    [251136] = { f = 12, icon = 7636646, q = "ff0070dd" },  -- Signet of Snarling Servitude
    [251137] = { f = 9, icon = 7252742, q = "ff0070dd" },  -- Tempestuous Sandals
    [251138] = { f = 2, icon = 7135739, q = "ff0070dd" },  -- Cinderfury Shoulderguards
    [251139] = { f = 4, icon = 7252745, q = "ff0070dd" },  -- Summoner's Searing Shirt
    [251140] = { f = 0, icon = 7232473, q = "ff0070dd" },  -- Vilefiend's Guise
    [251141] = { f = 8, icon = 7259237, q = "ff0070dd" },  -- Lithiel's Linked Leggings
    [251142] = { f = 1, icon = 7636611, q = "ff0070dd" },  -- Pendant of Malefic Fury
    [251143] = { f = 10, icon = 7065188, q = "ff0070dd" },  -- Grim Harvest Gloves
    [251144] = { f = 7, icon = 7135731, q = "ff0070dd" },  -- Autumn's Boon Belt
    [251145] = { f = 9, icon = 7259231, q = "ff0070dd" },  -- Forgotten Tribe Footguards
    [251146] = { f = 2, icon = 7232475, q = "ff0070dd" },  -- Scavenger's Spaulders
    [251147] = { f = 4, icon = 7252745, q = "ff0070dd" },  -- Hoarded Harvest Wrap
    [251148] = { f = 12, icon = 7636660, q = "ff0070dd" },  -- Pilfered Precious Band
    [251149] = { f = 10, icon = 6929479, q = "ff0070dd" },  -- Victor's Flashfrozen Blade
    [251150] = { f = 11, icon = 7392266, q = "ff0070dd" },  -- Tempest's Shelter
    [251151] = { f = 4, icon = 7135735, q = "ff0070dd" },  -- Sentinel Challenger's Prize
    [251152] = { f = 6, icon = 7259235, q = "ff0070dd" },  -- Season's Turn Gauntlets
    [251153] = { f = 9, icon = 7232468, q = "ff0070dd" },  -- Arctic Explorer's Legwraps
    [251154] = { f = 5, icon = 7252743, q = "ff0070dd" },  -- Winter's Embrace Bracers
    [251155] = { f = 7, icon = 7259230, q = "ff0070dd" },  -- Tribal Defender's Cord
    [251156] = { f = 10, icon = 6989931, q = "ff0070dd" },  -- Fallen Speaker's Staff
    [251158] = { f = 0, icon = 7259236, q = "ff0070dd" },  -- Nalorakk's Nightmare
    [251159] = { f = 4, icon = 7232471, q = "ff0070dd" },  -- War Trial Vestments
    [251160] = { f = 8, icon = 7252748, q = "ff0070dd" },  -- Forest Dream Leg-guards
    [251165] = { f = 6, icon = 7259235, q = "ff0070dd" },  -- Pulverizing Pads
    [251173] = { f = 1, icon = 7636649, q = "ff0070dd" },  -- Yoke of the Charging Bear
    [251180] = { f = 10, icon = 7012521, q = "ff0070dd" },  -- Thornblade
    [251181] = { f = 10, icon = 7117445, q = "ff0070dd" },  -- Pruning Lance
    [251182] = { f = 8, icon = 7135738, q = "ff0070dd" },  -- Bedrock Breeches
    [251183] = { f = 5, icon = 7232469, q = "ff0070dd" },  -- Rootwarden Wraps
    [251184] = { f = 2, icon = 7259238, q = "ff0070dd" },  -- Ironroot Collar
    [251185] = { f = 7, icon = 7252741, q = "ff0070dd" },  -- Lightblossom Cinch
    [251186] = { f = 10, icon = 7065188, q = "ff0070dd" },  -- Thorntalon Edge
    [251187] = { f = 10, icon = 7355019, q = "ff0070dd" },  -- Amirdrassil's Reach
    [251188] = { f = 10, icon = 7412480, q = "ff0070dd" },  -- Doompetal
    [251189] = { f = 7, icon = 7278019, q = "ff0070dd" },  -- Rootwalker Harness
    [251190] = { f = 3, icon = 7259233, q = "ff0070dd" },  -- Bloodthorn Burnous
    [251191] = { f = 11, icon = 7431122, q = "ff0070dd" },  -- Luminescent Sprout
    [251192] = { f = 10, icon = 6936235, q = "ff0070dd" },  -- Branch of Pride
    [251193] = { f = 4, icon = 7135735, q = "ff0070dd" },  -- Taproot Ribs
    [251194] = { f = 12, icon = 7578284, q = "ff0070dd" },  -- Lightwarden's Bind
    [251195] = { f = 10, icon = 6913914, q = "ff0070dd" },  -- Thorned Reply
    [251196] = { f = 11, icon = 7442214, q = "ff0070dd" },  -- Teldrassil's Sacrifice
    [251197] = { f = 6, icon = 7135736, q = "ff0070dd" },  -- Thornspike Gauntlets
    [251198] = { f = 8, icon = 7232474, q = "ff0070dd" },  -- Lightspore Leggings
    [251199] = { f = 0, icon = 7252747, q = "ff0070dd" },  -- Worldroot Canopy
    [251200] = { f = 5, icon = 7259232, q = "ff0070dd" },  -- Saptorbane Guards
    [251214] = { f = 6, icon = 7135736, q = "ff0070dd" },  -- Bonds of the Hash'ura
    [251218] = { f = 10, icon = 6994479, q = "ff0070dd" },  -- Taz'Rah's Cosmic Edge
    [251219] = { f = 9, icon = 7252742, q = "ff0070dd" },  -- Riftworn Stompers
    [251220] = { f = 0, icon = 7259236, q = "ff0070dd" },  -- Voidscarred Crown
    [251221] = { f = 6, icon = 7135736, q = "ff0070dd" },  -- Despondent's Gauntlets
    [251222] = { f = 7, icon = 7252741, q = "ff0070dd" },  -- Ethereal Netherwrap
    [251223] = { f = 2, icon = 7232475, q = "ff0070dd" },  -- Somber Spaulders
    [251224] = { f = 10, icon = 6981232, q = "ff0070dd" },  -- Hulking Handaxe
    [251225] = { f = 10, icon = 7065189, q = "ff0070dd" },  -- Fang of Contagion
    [251226] = { f = 4, icon = 7232471, q = "ff0070dd" },  -- Hide of Pestilence
    [251227] = { f = 2, icon = 7252749, q = "ff0070dd" },  -- Poisoner's Pauldrons
    [251228] = { f = 7, icon = 7259230, q = "ff0070dd" },  -- Behemoth Waistband
    [251229] = { f = 0, icon = 7383546, q = "ff0070dd" },  -- Visor of the Predator
    [251230] = { f = 10, icon = 6994512, q = "ff0070dd" },  -- Charonic Crescent
    [251231] = { f = 10, icon = 6936237, q = "ff0070dd" },  -- Singularity Slicer
    [251232] = { f = 0, icon = 7252747, q = "ff0070dd" },  -- Overseer's Diadem
    [251233] = { f = 4, icon = 7259234, q = "ff0070dd" },  -- Manipulator's Vest
    [251234] = { f = 1, icon = 7636583, q = "ff0070dd" },  -- Graft of the Domanaar
    [251235] = { f = 7, icon = 7278019, q = "ff0070dd" },  -- Gravitic Girdle
    [252258] = { f = 12, icon = 7636586, q = "ff0070dd" },  -- Sickening Signet of Atroxus
    [258045] = { f = 10, icon = 7151971, q = "ff0070dd" },  -- Dawnblade's Glaives
    [268196] = { f = 11, icon = 7553253, q = "ffa335ee" },  -- Venom-Slashed Scuteward
    [268197] = { f = 11, icon = 7500005, q = "ffa335ee" },  -- Spine of the Hissing Abyss
    [268198] = { f = 10, icon = 7576051, q = "ffa335ee" },  -- Caustic Keeper-Crusher
    [268199] = { f = 10, icon = 7552246, q = "ffa335ee" },  -- Tidepiercer's Bubble Popper
    [268200] = { f = 10, icon = 7476193, q = "ffa335ee" },  -- Gebbo's Backup Blaster
    [268201] = { f = 10, icon = 7499262, q = "ffa335ee" },  -- Venomous Boneglaive
    [268202] = { f = 10, icon = 7723761, q = "ffa335ee" },  -- Jaw of the Shackled Goddess
    [268203] = { f = 10, icon = 7515621, q = "ffa335ee" },  -- Hexing Spiritrender
    [268204] = { f = 10, icon = 7701065, q = "ffa335ee" },  -- Ancient Construct's Venomshiv
    [268205] = { f = 10, icon = 7502501, q = "ffa335ee" },  -- Venomancer's Winged Channeler
    [268206] = { f = 10, icon = 7502390, q = "ffa335ee" },  -- Slithering Savage's Gavel
    [268207] = { f = 10, icon = 7488509, q = "ffa335ee" },  -- Caustic Repose Greatbow
    [268208] = { f = 10, icon = 7736101, q = "ffa335ee" },  -- Strongblood's Ceremonial Cleaver
    [268209] = { f = 10, icon = 7736101, q = "ffa335ee" },  -- Aman'muso, Warlord's Vengeance
    [268210] = { f = 10, icon = 7502390, q = "ffa335ee" },  -- Malevolent Spiritcudgel
    [268211] = { f = 10, icon = 7723761, q = "ffa335ee" },  -- Baleful Hexblade
    [268213] = { f = 10, icon = 7455434, q = "ffa335ee" },  -- Maze-roa, Warlord's Fury
    [268214] = { f = 10, icon = 7506565, q = "ffa335ee" },  -- Malignant Toothed Edge
    [268215] = { f = 10, icon = 7480487, q = "ffa335ee" },  -- Abyssal Broodfiend's Bardiche
    [268216] = { f = 7, icon = 7789852, q = "ffa335ee" },  -- Cursed Reliquary Cincture
    [268217] = { f = 5, icon = 7554475, q = "ffa335ee" },  -- Rising Tide Wristguards
    [268218] = { f = 9, icon = 7667305, q = "ffa335ee" },  -- Nek'zali's Spiritwalkers
    [268219] = { f = 0, icon = 7678400, q = "ffa335ee" },  -- Shadow Hunter's Warmask
    [268220] = { f = 6, icon = 7730302, q = "ffa335ee" },  -- Scaleplate Strangulators
    [268221] = { f = 4, icon = 7520906, q = "ffa335ee" },  -- Tidebound Sorcereress's Robes
    [268222] = { f = 4, icon = 7515795, q = "ffa335ee" },  -- Reckless Spirit Breastplate
    [268223] = { f = 4, icon = 7554477, q = "ffa335ee" },  -- Ophidian Fangmail
    [268224] = { f = 8, icon = 7515798, q = "ffa335ee" },  -- Venom Warden's Greaves
    [268225] = { f = 8, icon = 7487943, q = "ffa335ee" },  -- Coiled Hex Legguards
    [268226] = { f = 2, icon = 7730305, q = "ffa335ee" },  -- Swelling Sea Spaulders
    [268227] = { f = 7, icon = 7678393, q = "ffa335ee" },  -- Unpossessed Skullsash
    [268228] = { f = 5, icon = 7807652, q = "ffa335ee" },  -- Venom-Singed Cuffs
    [268229] = { f = 0, icon = 7739389, q = "ffa335ee" },  -- Skullguard of the Risen Sacrifice
    [268230] = { f = 0, icon = 7705647, q = "ffa335ee" },  -- Crown of the Eternal Fang
    [268231] = { f = 2, icon = 7705650, q = "ffa335ee" },  -- Soulslither Spaulders
    [268232] = { f = 7, icon = 7807649, q = "ffa335ee" },  -- Cincture of the Abyssal Grotto
    [268233] = { f = 9, icon = 7557369, q = "ffa335ee" },  -- Ferocious Scaleboots
    [268234] = { f = 6, icon = 7679654, q = "ffa335ee" },  -- Ruthless Slaughtergrips
    [268235] = { f = 4, icon = 7579166, q = "ffa335ee" },  -- Vestment of the Awakening
    [268236] = { f = 8, icon = 7667310, q = "ffa335ee" },  -- Initiate's Sacrificial Tights
    [268237] = { f = 8, icon = 7789850, q = "ffa335ee" },  -- Cuisses of the Uncoiled Union
    [268238] = { f = 6, icon = 7789857, q = "ffa335ee" },  -- Grips of Swirling Fury
    [268239] = { f = 5, icon = 7739385, q = "ffa335ee" },  -- Shellbound Bracers
    [268240] = { f = 5, icon = 8095063, q = "ffa335ee" },  -- Restless Spirit Shackles
    [268241] = { f = 2, icon = 7807660, q = "ffa335ee" },  -- Ornaments of the Eternal Coil
    [268242] = { f = 0, icon = 7667309, q = "ffa335ee" },  -- Errant Scrollsage's Hood
    [268243] = { f = 6, icon = 7520895, q = "ffa335ee" },  -- Grasps of the Eternal Shadow
    [268244] = { f = 7, icon = 7739383, q = "ffa335ee" },  -- Forgotten Grotto Girdle
    [268245] = { f = 9, icon = 7515792, q = "ffa335ee" },  -- Entombed Cultist's Sabatons
    [268246] = { f = 2, icon = 7679657, q = "ffa335ee" },  -- Frothing Venom Spaulders
    [268247] = { f = 9, icon = 7679650, q = "ffa335ee" },  -- Breakwater Boots
    [268248] = { f = 3, icon = 7487939, q = "ffa335ee" },  -- Amani Summoning Shawl
    [268249] = { f = 12, icon = 7866597, q = "ffa335ee" },  -- Vile Alchemist's Band
    [268250] = { f = 1, icon = 7866585, q = "ffa335ee" },  -- Sentinel's Vitriolic Chain
    [268251] = { f = 1, icon = 7866583, q = "ffa335ee" },  -- Amulet of the Twin Fangs
    [268252] = { f = 12, icon = 7866608, q = "ffa335ee" },  -- Apex Brute's Claw Ring
    [268253] = { f = 3, icon = 7678397, q = "ffa335ee" },  -- Silken Voodoo Drape
    [268254] = { f = 7, icon = 7705642, q = "ffa335ee" },  -- Serpentine Mixing Belt
    [268255] = { f = 9, icon = 7807651, q = "ffa335ee" },  -- Cackling Soultreads
    [268256] = { f = 7, icon = 7579159, q = "ffa335ee" },  -- Sash of the Forlorn Vessel
    [268257] = { f = 7, icon = 7520891, q = "ffa335ee" },  -- Caustic Chain-Wrapped Sash
    [268258] = { f = 9, icon = 7789853, q = "ffa335ee" },  -- Boots of the Reckless Wayfarer
    [268259] = { f = 7, icon = 7730297, q = "ffa335ee" },  -- Girdle of Toxic Regret
    [268260] = { f = 9, icon = 7730298, q = "ffa335ee" },  -- Scaled Fiend's Warboots
    [268261] = { f = 9, icon = 7487936, q = "ffa335ee" },  -- Bespittled Slitherslippers
    [268262] = { f = 11, icon = 7553253, q = "ffa335ee" },  -- Bubblefin Splash Guard
    [268263] = { f = 11, icon = 7500005, q = "ffa335ee" },  -- Frostscale's Mystic Frond
    [268264] = { f = 10, icon = 7515621, q = "ffa335ee" },  -- Ravenous Feaster's Fang
    [268265] = { f = 1, icon = 7866590, q = "ffa335ee" },  -- Aqirbane Reliquary
    [268266] = { f = 12, icon = 1391765, q = "ffa335ee" },  -- Alluring Bubbleband
    [270160] = { f = 13, icon = 6361206, q = "ffa335ee" },  -- First Mate's Shellward
    [270161] = { f = 13, icon = 7956745, q = "ffa335ee" },  -- Fang of Umbral Malignance
    [270162] = { f = 13, icon = 7956752, q = "ffa335ee" },  -- Soulcoiler Ritual Vessel
    [270163] = { f = 13, icon = 7956757, q = "ffa335ee" },  -- Sszorak's Ferocity
    [270164] = { f = 13, icon = 4549224, q = "ffa335ee" },  -- Gebbo's Bottomless Bag
    [270165] = { f = 13, icon = 7956747, q = "ffa335ee" },  -- Keeper's Seething Core
    [270166] = { f = 13, icon = 6011948, q = "ffa335ee" },  -- Vashnik's Sanguine Rancor
    [270167] = { f = 13, icon = 1020350, q = "ffa335ee" },  -- Wavecaller's Seastone
    [270168] = { f = 13, icon = 4638540, q = "ffa335ee" },  -- Font of Venomous Rage
    [270169] = { f = 13, icon = 1001629, q = "ffa335ee" },  -- Hex Lord's Dooming Idol
    [270170] = { f = 13, icon = 6012071, q = "ffa335ee" },  -- Vexhul's Everflowing Gland
    [270171] = { f = 13, icon = 6011929, q = "ffa335ee" },  -- Preternatural Antivenom
    [270173] = { f = 13, icon = 7956755, q = "ffa335ee" },  -- Zul'jin's Guillotine Technique
    [270174] = { f = 13, icon = 237237, q = "ffa335ee" },  -- Idol of the Howling Nexus
    [270175] = { f = 13, icon = 7956750, q = "ffa335ee" },  -- Voracious Heart of Ula'tek
    [270930] = { f = 10, icon = 7530467, q = "ffa335ee" },  -- Tomb-Creeper's Claw
    [271092] = { f = 10, icon = 7850590, q = "ffa335ee" },  -- Jan'thrazet, the Soul Fang
    [271093] = { f = 10, icon = 7578560, q = "ffa335ee" },  -- Zatha'tek, Breath of Corruption
    [271680] = { f = 10, icon = 5342966, q = "ff0070dd" },  -- Sinseared Repeater
    [271681] = { f = 11, icon = 7431122, q = "ff0070dd" },  -- Perennial Frostbound Charm
    [271874] = { f = 0, icon = 7520904, q = "ffa335ee" },  -- Venomkeeper's Horrific Cowl
    [271875] = { f = 0, icon = 7579164, q = "ffa335ee" },  -- Gaze of the Coiled Watcher
    [271876] = { f = 4, icon = 7789856, q = "ffa335ee" },  -- Awoken Dreadfang Cuirass
    [271878] = { f = 8, icon = 7739390, q = "ffa335ee" },  -- Chausses of Unbound Rancor
    [273649] = { f = 13, icon = 1360043, q = "ff0070dd" },  -- Stormbound Emblem of Dazar
    [273773] = { f = 6, icon = 7874490, q = "ff0070dd" },  -- Handwraps of Blasphemous Rites
    [273774] = { f = 2, icon = 7865325, q = "ff0070dd" },  -- Snakeskin Spaulders
    [273775] = { f = 5, icon = 7871827, q = "ff0070dd" },  -- Hydra Scale Wristguards
    [273776] = { f = 8, icon = 7876609, q = "ff0070dd" },  -- Ancient General's Obsidian Pillars
    [273777] = { f = 9, icon = 7876612, q = "ff0070dd" },  -- Poison-Proof Stompers
    [273778] = { f = 10, icon = 7893615, q = "ff0070dd" },  -- Polished Lightwood Channeler
    [273779] = { f = 11, icon = 7651189, q = "ff0070dd" },  -- Nocuous Focal Fang
    [273780] = { f = 10, icon = 7674304, q = "ff0070dd" },  -- Venom-Etched Crescent
    [273781] = { f = 1, icon = 7866594, q = "ff0070dd" },  -- Strand of Warding Fangs
    [273782] = { f = 10, icon = 7651212, q = "ff0070dd" },  -- Vile Writhefang Glaive
    [273783] = { f = 10, icon = 7761089, q = "ff0070dd" },  -- Toxin-Coated Warstaff
    [273784] = { f = 10, icon = 7700598, q = "ff0070dd" },  -- Ancestral Amani Recurve
    [273785] = { f = 4, icon = 7874492, q = "ff0070dd" },  -- Primordial Robe of Rites
    [273786] = { f = 8, icon = 7875759, q = "ff0070dd" },  -- Leggings of Entwined Serpents
    [273787] = { f = 4, icon = 7876615, q = "ff0070dd" },  -- Aged Interwoven Scaleplate
    [273789] = { f = 4, icon = 7871829, q = "ff0070dd" },  -- Chestguard of Corroded Scales
    [273791] = { f = 0, icon = 7865323, q = "ff0070dd" },  -- Spare Speaker's Hood
    [273792] = { f = 12, icon = 7866600, q = "ff0070dd" },  -- Band of the Amani Warlord
    [273793] = { f = 10, icon = 7672957, q = "ff0070dd" },  -- Hydraspine Twinblade
    [273794] = { f = 13, icon = 7956742, q = "ff0070dd" },  -- Knot of Writhing Serpents
    [273795] = { f = 13, icon = 7956734, q = "ff0070dd" },  -- Coiled Fangstone
    [273796] = { f = 13, icon = 7956740, q = "ff0070dd" },  -- Vile Vial of Volatile Venom
    [273797] = { f = 13, icon = 7956733, q = "ff0070dd" },  -- Tattered Amani War Banner
    [275070] = { f = 10, icon = 7893615, q = "ff0070dd" },  -- Sharpened Lightwood Slasher
    [275937] = { f = 0, icon = 7652220, q = "ff0070dd" },  -- Hex Lord's Visage
    [281227] = { f = 0, icon = 7558105, q = "ff0070dd" },  -- Soulcoiler's Rush'kah
}
