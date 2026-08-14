#!/usr/bin/env node
/*
 * Findet Bezeichner, die im Datei-Hauptteil VOR ihrer lokalen Deklaration
 * verwendet werden.
 *
 * Warum das noetig ist: In Lua gilt eine mit "local" deklarierte Variable erst
 * AB der Deklaration. Steht davor derselbe Name, greift er stillschweigend auf
 * eine globale Variable zu, die es meist nicht gibt. Es gibt keine Warnung,
 * keinen Fehler beim Laden, und der Wert ist einfach nil.
 *
 * Am 14.08.2026 hat genau dieser Fehler viermal zugeschlagen:
 *   - ApplyAlpha in Chrissi's Addon: Deckkraft-Knoepfe klickten ins Leere
 *   - MenuEntry in SlotMachine: Menue waere leer geblieben
 *   - rollBtn: Haken blieb beim Umschalten stehen
 *   - currentTab: Raid-Tab zeigte hartnaeckig die Dungeon-Liste
 *
 * Der letzte Fall war der teuerste, weil er wie ein Datenfehler aussah statt
 * wie ein Scope-Fehler.
 */

const fs = require("fs");
const luaparse = require("luaparse");

const file = process.argv[2];
if (!file) {
    console.error("Aufruf: node scope-check.js <datei.lua>");
    process.exit(2);
}

const src = fs.readFileSync(file, "utf8");
const ast = luaparse.parse(src, { luaVersion: "5.1", locations: true, ranges: false });

// Nur die oberste Ebene betrachten. Verschachtelte Bloecke haben eigene
// Sichtbarkeiten, die hier zu Fehlalarmen fuehren wuerden.
const declaredAt = new Map();   // Name -> Zeile der Deklaration
const usedAt = new Map();       // Name -> erste Zeile der Verwendung

function walk(node, insideFunction) {
    if (!node || typeof node !== "object") return;

    if (node.type === "LocalStatement" && !insideFunction) {
        for (const v of node.variables || []) {
            if (v.name && !declaredAt.has(v.name)) {
                declaredAt.set(v.name, node.loc.start.line);
            }
        }
        // Initialisierungen zaehlen als Verwendung, aber erst nach der Zeile
        for (const init of node.init || []) walk(init, insideFunction);
        return;
    }

    // Feldnamen sind keine Variablenzugriffe.
    //
    // Bei ns.Scanner ist "Scanner" nur der Name eines Feldes in ns, nicht der
    // Zugriff auf eine Variable namens Scanner. Ohne diese Unterscheidung
    // meldet der Pruefer das Muster "ns.X = {}" gefolgt von "local X = ns.X"
    // faelschlich als Fehler. Nur die Basis vor dem Punkt wird geprueft.
    if (node.type === "MemberExpression") {
        walk(node.base, insideFunction);
        return;
    }

    if (node.type === "Identifier") {
        if (!usedAt.has(node.name) && node.loc) {
            usedAt.set(node.name, node.loc.start.line);
        }
        return;
    }

    const nested = node.type === "FunctionDeclaration";
    for (const key of Object.keys(node)) {
        if (key === "loc") continue;
        const val = node[key];
        if (Array.isArray(val)) {
            for (const child of val) walk(child, insideFunction || nested);
        } else if (val && typeof val === "object") {
            walk(val, insideFunction || nested);
        }
    }
}

for (const stmt of ast.body) walk(stmt, false);

// Kurze Namen aussortieren.
//
// Ein- und zweibuchstabige Namen sind fast immer Schleifen- oder
// Hilfsvariablen in eigenen Bloecken (for i, local e, local t). Die haben ihre
// eigene Sichtbarkeit, und dieser Pruefer unterscheidet Verschachtelungen noch
// nicht fein genug. Ohne diesen Filter ueberwiegen die Fehlalarme und man
// gewoehnt sich an, die Ausgabe zu ignorieren. Genau das darf ein Pruefwerkzeug
// nicht ausloesen.
const problems = [];
for (const [name, decl] of declaredAt.entries()) {
    if (name.length <= 2) continue;
    const use = usedAt.get(name);
    if (use !== undefined && use < decl) {
        problems.push({ name, use, decl });
    }
}

problems.sort((a, b) => a.use - b.use);

if (problems.length === 0) {
    console.log("SCOPE OK: " + file);
    process.exit(0);
}

console.log("SCOPE-WARNUNGEN in " + file);
for (const p of problems) {
    console.log(`  ${p.name}: benutzt in Zeile ${p.use}, aber erst in Zeile ${p.decl} deklariert`);
}
console.log("");
console.log("Diese Namen greifen vor ihrer Deklaration auf eine GLOBALE Variable zu.");
console.log("Entweder nach oben verschieben oder vorwaerts deklarieren.");
process.exit(1);
