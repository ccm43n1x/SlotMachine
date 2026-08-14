# SlotMachine

**Hinweis: Die Oberfläche ist auf Deutsch.** Das Add-on funktioniert auf jedem Client, aber alle Beschriftungen sind deutschsprachig.

Loot- und Farm-Planer für World of Warcraft, Midnight Season 2 (Patch 12.1).

Beantwortet eine Frage, die andere Add-ons offen lassen: **Wo lohnt sich der nächste Run für mich?**

## Was es tut

Du markierst, welche Items du haben willst. SlotMachine sortiert daraufhin die Quellen so, dass oben steht, wo für dich am meisten drin ist.

- **Fünf Wunsch-Stufen** statt Ja/Nein: Best in Slot, Muss ich haben, Wäre ganz nett, Für den Off-Spec, Nur Transmog
- **Gewichtete Sortierung.** Ein Best-in-Slot zählt vier, ein „wäre nett" eins. Ein Boss mit drei Kleinigkeiten steht damit nicht über einem mit dem einen Teil, das du wirklich brauchst
- **Echte Bonus-Roll-Chance.** Weil erhaltene Items aus dem Pool fallen, ist die Zahl berechenbar: offene Wünsche geteilt durch verbleibenden Pool
- **Item Level als Differenz** zu dem, was du gerade trägst, wahlweise umgerechnet auf das gesamte Charakter-Item-Level
- **Tooltip auf der gewählten Stufe.** Der Item-Link trägt die passende Bonus-ID, WoW rendert also selbst mit korrekten Sekundärstats

## Bedienung

| | |
|---|---|
| `/sm` | Fenster auf und zu |
| Linksklick auf ein Icon | Wunsch-Stufe weiterschalten |
| Rechtsklick auf ein Icon | Stufe direkt wählen, Besitz und Bonus Roll markieren |
| Minimap-Knopf | links öffnen, rechts Einstellungen, ziehen verschiebt |

Filter für Slot, Spezialisierung und Quelle sitzen in der Kopfzeile. Der Haken **Bonus Roll** rechnet sofort um, was ein Voidcore auf dieser Stufe brächte.

## Stufen und Farben

Die Farben sind Blizzards Qualitätsfarben, damit die Rangfolge ohne Legende lesbar ist.

| Stufe | Farbe | Gewicht |
|---|---|---:|
| Best in Slot | Legendär orange | 4 |
| Muss ich haben | Episch lila | 2 |
| Wäre ganz nett | Selten blau | 1 |
| Für den Off-Spec | Ungewöhnlich grün | 1 |
| Nur Transmog | Weiß | 0 |

Transmog zählt bewusst null. Es ist ein Sammelziel, kein Fortschritt, und soll die Farm-Priorität nicht verzerren.

Bereits erhaltene Items werden abgedunkelt, verbrauchte Bonus Rolls durchgestrichen. Beides gleichzeitig ist möglich, denn ein Wurf kann auch ins Leere gehen.

Wer Farben schlecht unterscheidet, schaltet in den Einstellungen zusätzliche Zeichen an. Orange und Grün liegen bei Deuteranopie dicht beieinander.

## Woher die Daten kommen

Die Loot-Tabellen stammen aus Blizzards eigenem Encounter Journal. Sie werden **nicht beim Spieler** ausgelesen, sondern vorab erzeugt und als fertige `data.lua` ausgeliefert.

Der Grund: Item-Daten kommen in WoW asynchron vom Server. Ein Scan beim Nutzer bekäme beim ersten Durchlauf massenhaft leere Ergebnisse, und die rund vierzig Filterwechsel je Instanz würden den Client spürbar bremsen. Beim Entwickler ist beides harmlos.

Aktueller Stand: **319 Ausrüstungsteile, 41 Bosse, 11 Instanzen**, Spec-Zuordnung über alle 40 Spezialisierungen.

## Item Level und Upgrade-Tracks

Die Track-Werte sind gegen drei unabhängige Quellen geprüft: eigene Recherche, keystoneloot.io und Method.

| Track | Spanne |
|---|---|
| Veteran | 279 → 295 |
| Champion | 292 → 308 |
| Held | 305 → 321 |
| Mythos | 318 → 334 |

**Der Bonus Roll liefert das Great-Vault-Niveau** der jeweiligen Stufe, nicht einfach einen Track höher. Myth-Gear gibt es per Roll also erst ab Schlüsselstein 10.

**Im Raid ist das Item Level bossabhängig.** Spätere Bosse droppen weiter oben im Track, die beiden letzten auf Mythisch mit 344 sogar jenseits davon. SlotMachine rechnet das je Boss aus.

## Für Entwickler

| Befehl | Zweck |
|---|---|
| `/sm scan` | Encounter Journal auslesen, Ergebnis in SavedVariables |
| `/sm bosses` | Bossnamen mit ihren IDs |
| `/sm instances` | Instanzen des aktuellen Tiers |
| `/sm probe <ID>` | Rohdaten einer Instanz |
| `/sm chat` | Welches Chat-Fenster die Ausgaben bekommt |

Ein Chat-Fenster namens `Dev` bekommt automatisch alle Ausgaben.

Neue Daten bauen: `/sm scan`, dann `/reload`, dann `node tools/generate-data.js`.

Vor jedem Release:

```
node tools/syntax-check.js <datei>
node tools/scope-check.js <datei>
```

Der zweite prüft auf Bezeichner, die vor ihrer lokalen Deklaration verwendet werden. In Lua greifen die stillschweigend auf eine Globale zu, ohne Warnung und ohne Ladefehler. Dieser Fehler ist beim Bau viermal aufgetreten.

## Abgrenzung

**Keystone Loot** ist das große Vorbild und in vielem weiter: eigene Website, BiS-Listen für alle Spezialisierungen, Millionen Downloads. SlotMachine tritt nicht gegen deren Datenpflege an.

Der eigene Beitrag liegt woanders: **Priorisierung der Quellen nach dem Gewicht deiner Wünsche**, die **berechnete Bonus-Roll-Chance** und die **Trennung von Besitz und verbrauchtem Roll**.

Struktur und mehrere Verfahren sind an Keystone Loot und EllesmereUI abgeschaut, Maßzahlen und Farbwerte ebenso. Übernommen wurde kein Code.

## Lizenz

MIT, siehe `LICENSE`.
