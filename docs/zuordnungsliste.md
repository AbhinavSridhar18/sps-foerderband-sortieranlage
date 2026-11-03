# Zuordnungsliste

Die Anlage ist simuliert. Alle Signale liegen in der globalen Variablenliste `GVL_IO`.
Die Spalte „Adresse“ zeigt, wo das Signal auf einer realen SPS liegen würde.

## Eingänge

| Betriebsmittel | Symbolname | Datentyp | E/A | Adresse | Öffner/Schließer | Bedeutung bei TRUE |
|---|---|---|---|---|---|---|
| S0 | `xNotHaltOk` | BOOL | E | %IX0.0 | Öffner | Not-Halt nicht betätigt und Leitung intakt |
| S1 | `xStart` | BOOL | E | %IX0.1 | Schließer | Start-Taster gedrückt |
| S2 | `xStoppOk` | BOOL | E | %IX0.2 | Öffner | Stopp-Taster nicht gedrückt und Leitung intakt |
| S3 | `xQuittieren` | BOOL | E | %IX0.3 | Schließer | Quittier-Taster gedrückt |
| S4 | `xZaehlerReset` | BOOL | E | %IX0.4 | Schließer | Taster „Zähler zurücksetzen“ gedrückt |
| B1 | `xTeilEinlauf` | BOOL | E | %IX0.5 | Schließer | Teil am Einlauf erkannt |
| B2 | `xTeilMetall` | BOOL | E | %IX0.6 | Schließer | Metallteil vor dem induktiven Sensor |
| B3 | `xTeilAuswurfPos` | BOOL | E | %IX0.7 | Schließer | Teil an der Auswurfposition |
| B4 | `xTeilRutscheB` | BOOL | E | %IX1.0 | Schließer | Teil in Rutsche B angekommen |
| B5 | `xAuswerferEingefahren` | BOOL | E | %IX1.1 | Schließer | Auswerfer Y1 in hinterer Endlage |
| B6 | `xAuswerferAusgefahren` | BOOL | E | %IX1.2 | Schließer | Auswerfer Y1 in vorderer Endlage |

## Ausgänge

| Betriebsmittel | Symbolname | Datentyp | E/A | Adresse | Bedeutung bei TRUE |
|---|---|---|---|---|---|
| K1 / M1 | `xBandMotor` | BOOL | A | %QX0.0 | Bandmotor läuft |
| Y1 | `xAuswerferAusfahren` | BOOL | A | %QX0.1 | Ventil angesteuert, Auswerfer fährt aus (FALSE: fährt ein) |
| H1 | `xLampeBetrieb` | BOOL | A | %QX0.2 | Leuchte „Betrieb“ (grün) an |
| H2 | `xLampeStoerung` | BOOL | A | %QX0.3 | Leuchte „Störung“ (rot) an |

## Hinweise

- **Not-Halt und Stopp als Öffner (drahtbruchsicher):** Ein Leitungsbruch führt zu FALSE und damit wie ein Betätigen zum Stillstand.
  Die Symbolnamen beschreiben deshalb den Zustand bei TRUE (`...Ok`).
- **Y1 mit 5/2-Wegeventil (monostabil, Federrückstellung):** Fällt der Ausgang weg, fährt der Auswerfer ein. Das ist der sichere Zustand bei Not-Halt.
- **Nicht in der Liste:** Die Taster „Metallteil auflegen“ und „Kunststoffteil auflegen“ in der Visualisierung gehören zur Anlagensimulation, nicht zur realen Peripherie.
