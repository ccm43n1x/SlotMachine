#!/usr/bin/env node
/*
 * SlotMachine - Generator fuer data.lua
 * ============================================================================
 *
 * Liest die SavedVariables-Datei, die /sm scan im Spiel erzeugt hat, und baut
 * daraus die auslieferbare data.lua.
 *
 * Warum dieser Umweg ueberhaupt:
 * Der Scan koennte auch beim Nutzer laufen, aber Item-Daten kommen in WoW
 * asynchron vom Server. Im Testlauf vom 14.08.2026 waren nach dem ersten
 * Durchgang 266 von 367 Eintraegen unvollstaendig. Beim Entwickler ist das
 * eine Nachladerunde, beim Nutzer waere es ein Drittel fehlender Daten oder
 * sekundenlanges Warten. Deshalb: einmal hier scannen, fertige Datei
 * ausliefern. Denselben Weg gehen Keystone Loot und andere.
 *
 * Aufruf:
 *   node tools/generate-data.js <pfad-zur-SlotMachine.lua> [ziel]
 *
 * Ohne Argumente sucht das Skript die SavedVariables am Standardort.
 */

const fs = require("fs");
const path = require("path");

// ---------------------------------------------------------------------------
// Lua-Tabelle einlesen
// ---------------------------------------------------------------------------
// Bewusst ueber einen echten Parser statt ueber regulaere Ausdruecke. Im
// Datenbestand steckte ein Item, dessen Name aus einem einzelnen Backslash
// bestand. An solchen Zeichen scheitert jede Regex-Loesung frueher oder
// spaeter, ein Parser nicht.

let luaparse;
try {
    luaparse = require("luaparse");
} catch (e) {
    console.error("luaparse fehlt. Installieren mit:  npm install luaparse");
    process.exit(1);
}

function luaValue(node) {
    switch (node.type) {
        case "StringLiteral":
            // luaparse liefert je nach Version raw oder value
            if (typeof node.value === "string") return node.value;
            return String(node.raw || "").replace(/^["']|["']$/g, "");
        case "NumericLiteral":
            return node.value;
        case "BooleanLiteral":
            return node.value;
        case "NilLiteral":
            return null;
        case "UnaryExpression":
            if (node.operator === "-") return -luaValue(node.argument);
            return null;
        case "TableConstructorExpression": {
            const out = {};
            let arrayIndex = 1;
            for (const f of node.fields) {
                if (f.type === "TableKey") {
                    out[luaValue(f.key)] = luaValue(f.value);
                } else if (f.type === "TableKeyString") {
                    out[f.key.name] = luaValue(f.value);
                } else if (f.type === "TableValue") {
                    out[arrayIndex++] = luaValue(f.value);
                }
            }
            return out;
        }
        default:
            return null;
    }
}

function readSavedVariables(file) {
    const src = fs.readFileSync(file, "utf8");
    const ast = luaparse.parse(src, { luaVersion: "5.1" });
    const result = {};
    for (const stmt of ast.body) {
        if (stmt.type === "AssignmentStatement") {
            for (let i = 0; i < stmt.variables.length; i++) {
                const v = stmt.variables[i];
                if (v.type === "Identifier" && stmt.init[i]) {
                    result[v.name] = luaValue(stmt.init[i]);
                }
            }
        }
    }
    return result;
}

// ---------------------------------------------------------------------------
// Pfade
// ---------------------------------------------------------------------------

const DEFAULT_SV = "C:\\Program Files\\World of Warcraft\\_retail_\\WTF\\Account\\122313226#1\\SavedVariables\\SlotMachine.lua";

const svPath  = process.argv[2] || DEFAULT_SV;
const outPath = process.argv[3] || path.join(__dirname, "..", "data.lua");

if (!fs.existsSync(svPath)) {
    console.error("SavedVariables nicht gefunden: " + svPath);
    console.error("Erst im Spiel /sm scan und danach /reload ausfuehren.");
    process.exit(1);
}

const db = readSavedVariables(svPath).SlotMachineDB;
if (!db || !db.scanResults) {
    console.error("Keine scanResults in der Datei. Wurde /sm scan ausgefuehrt?");
    process.exit(1);
}

// ---------------------------------------------------------------------------
// Auswerten
// ---------------------------------------------------------------------------

const all = Object.values(db.scanResults).filter(r => r && r.itemID);

// Ausruestung von allem anderen trennen. Was keinen Slot hat, ist Berufsrezept
// oder Housing-Dekoration und fuer einen Loot-Planer ohne Bedeutung.
const gear   = all.filter(r => r.slot && r.slot !== "");
const nonGear = all.filter(r => !r.slot || r.slot === "");

// Gegenprobe: Ist filterType wirklich ein verlaesslicher Ersatz fuer den
// Slot-Text? Wenn eine Zahl auf mehrere Slot-Namen zeigt, waere sie es nicht.
const filterMap = new Map();
for (const r of gear) {
    if (r.filterType === undefined || r.filterType === null) continue;
    if (!filterMap.has(r.filterType)) filterMap.set(r.filterType, new Set());
    filterMap.get(r.filterType).add(r.slot);
}
const ambiguous = [...filterMap.entries()].filter(([, set]) => set.size > 1);

// Nach Instanz und Boss gruppieren
const byInstance = new Map();
for (const r of gear) {
    if (!byInstance.has(r.instanceID)) byInstance.set(r.instanceID, new Map());
    const bosses = byInstance.get(r.instanceID);
    const enc = r.encounterID ?? 0;
    if (!bosses.has(enc)) bosses.set(enc, []);
    bosses.get(enc).push(r.itemID);
}

// ---------------------------------------------------------------------------
// Bericht
// ---------------------------------------------------------------------------

console.log("=== SlotMachine Datengenerator ===");
console.log("Quelle:   " + svPath);
console.log("Stand:    " + (db.scanStamp || "unbekannt"));
console.log("");
console.log("Eintraege gesamt:   " + all.length);
console.log("davon Ausruestung:  " + gear.length);
console.log("aussortiert:        " + nonGear.length + "  (Rezepte, Dekoration)");
console.log("Instanzen:          " + byInstance.size);
console.log("Bosse:              " + [...byInstance.values()].reduce((n, m) => n + m.size, 0));
console.log("");

console.log("filterType -> Slot:");
for (const [ft, set] of [...filterMap.entries()].sort((a, b) => a[0] - b[0])) {
    console.log("   " + String(ft).padStart(3) + " = " + [...set].join(" / "));
}
if (ambiguous.length) {
    console.log("");
    console.log("ACHTUNG: filterType ist NICHT eindeutig, betroffen: "
        + ambiguous.map(([ft]) => ft).join(", "));
    console.log("Dann muss der Slot-Text mitgespeichert werden.");
} else {
    console.log("");
    console.log("filterType ist eindeutig, taugt also als sprachunabhaengiger Slot.");
}

// ---------------------------------------------------------------------------
// data.lua schreiben
// ---------------------------------------------------------------------------

const L = [];
L.push("-- ============================================================================");
L.push("-- SlotMachine - Loot-Datenbank");
L.push("-- ============================================================================");
L.push("--");
L.push("-- AUTOMATISCH ERZEUGT. Aenderungen von Hand gehen beim naechsten Lauf verloren.");
L.push("--");
L.push("-- Erzeugt von tools/generate-data.js aus den SavedVariables, die /sm scan");
L.push("-- im Spiel geschrieben hat.");
L.push("--");
L.push("-- Stand der Rohdaten: " + (db.scanStamp || "unbekannt"));
L.push("--");
L.push("-- Es stehen bewusst nur IDs in dieser Datei, keine Namen. IDs sind");
L.push("-- sprachunabhaengig, die Namen holt das Add-on zur Laufzeit vom Client.");
L.push("-- Ein englischer Client zeigt damit englische, ein deutscher deutsche");
L.push("-- Namen, ohne dass hier uebersetzt werden muss.");
L.push("");
L.push("local AddonName, ns = ...");
L.push("");
L.push("-- Instanz -> Boss -> Item-IDs");
L.push("ns.LOOT = {");

for (const [instID, bosses] of [...byInstance.entries()].sort((a, b) => a[0] - b[0])) {
    L.push("    [" + instID + "] = {");
    for (const [encID, items] of [...bosses.entries()].sort((a, b) => a[0] - b[0])) {
        const sorted = [...new Set(items)].sort((a, b) => a - b);
        L.push("        [" + encID + "] = { " + sorted.join(", ") + " },");
    }
    L.push("    },");
}
L.push("}");
L.push("");
L.push("-- Item -> Eigenschaften. filterType ist der sprachunabhaengige Slot.");
L.push("ns.ITEMS = {");

for (const r of gear.sort((a, b) => a.itemID - b.itemID)) {
    const parts = [];
    if (r.filterType !== undefined && r.filterType !== null) parts.push("f = " + r.filterType);
    if (r.icon)    parts.push("icon = " + r.icon);
    if (r.quality) parts.push('q = "' + r.quality + '"');
    // Name nur als Kommentar, damit die Datei lesbar bleibt
    const comment = r.name ? ("  -- " + String(r.name).replace(/[\r\n]/g, " ")) : "";
    L.push("    [" + r.itemID + "] = { " + parts.join(", ") + " }," + comment);
}
L.push("}");
L.push("");

fs.writeFileSync(outPath, L.join("\n"), "utf8");

console.log("");
console.log("Geschrieben: " + outPath);
console.log("Groesse:     " + Math.round(fs.statSync(outPath).size / 1024) + " KB");
