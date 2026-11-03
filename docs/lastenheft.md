# Lastenheft: Förderband-Sortieranlage

## A. Anlage (simuliert)

| Nr. | Anforderung |
|---|---|
| A1 | Förderband mit Motor **M1**, eine Richtung, nur Ein/Aus. |
| A2 | Sensoren: **B1** Teil am Einlauf, **B2** induktiv (TRUE = Metall), **B3** Teil an Auswurfposition, **B4** Teil in Rutsche B angekommen. |
| A3 | Pneumatischer Auswerfer **Y1** (5/2-Wegeventil, ein Ausgang) mit Endlagen **eingefahren** und **ausgefahren**. |
| A4 | Es befindet sich immer nur ein Teil auf dem Band. |

## B. Bedienpult

| Nr. | Anforderung |
|---|---|
| B1 | Taster **Start** (Schließer), **Stopp** (Öffner), **Quittieren** (Schließer), **Not-Halt** (Öffner), **Zähler zurücksetzen** (Schließer). |
| B2 | Leuchten **Betrieb** (grün) und **Störung** (rot): blinkt bei unquittierter Störung, Dauerlicht solange die Ursache ansteht. |

## C. Funktion (Automatikbetrieb)

| Nr. | Anforderung |
|---|---|
| C1 | Nach dem Einschalten Grundstellung: Band aus, Auswerfer eingefahren (ggf. zuerst einfahren). |
| C2 | Start nur mit **steigender Flanke** des Start-Tasters. |
| C3 | Erkennt B1 ein Teil, läuft das Band. Das Material wird beim Passieren von B2 ermittelt und **gespeichert**. |
| C4 | Metall: Band stoppt an B3, Auswerfer fährt aus bis Endlage, fährt wieder ein, Anlage wartet auf das nächste Teil. |
| C5 | Kunststoff: Band läuft weiter bis B4 das Teil in Rutsche B meldet, dann Band aus. |
| C6 | **Stopp** = Stopp am Zyklusende: aktuelles Teil wird fertig bearbeitet, danach Grundstellung. |

## D. Zähler

| Nr. | Anforderung |
|---|---|
| D1 | Zähler für Metall, Kunststoff und Gesamt, **je Teil genau einmal** (flankengesteuert). |
| D2 | Zählerstände bleiben bei Stopp und Not-Halt erhalten; Rücksetzen nur per Taster und nur im Stillstand. |

## E. Sicherheit und Störungen

| Nr. | Anforderung |
|---|---|
| E1 | **Not-Halt** (Öffner, drahtbruchsicher): alle Ausgänge sofort aus, in jedem Schritt. |
| E2 | Quittierung erst nach Entriegeln des Not-Halts; danach Grundstellung und Warten auf eine **neue Start-Flanke** (Wiederanlaufsperre). |
| E3 | **Schrittüberwachung**: Auswerfer-Endlage nicht innerhalb 2 s erreicht oder Teil nicht innerhalb der Sollzeit an B3/B4 → Störung, Verhalten wie E2, Störungstext in der Visualisierung. |
| E4 | Hinweis: funktionale Logik in einer Standard-SPS, keine Sicherheitstechnik. |

## F. Visualisierung (CODESYS, minimal)

| Nr. | Anforderung |
|---|---|
| F1 | Bedientaster, Leuchten Betrieb und Störung. |
| F2 | Anzeige der drei Zähler, des aktuellen Schritts und des Störungstexts. |
| F3 | Taster „Metallteil auflegen“ und „Kunststoffteil auflegen“. |

## G. Anlagensimulation

| Nr. | Anforderung |
|---|---|
| G1 | `FB_Anlagensimulation` erzeugt die Sensorsignale (Teilbewegung bei laufendem M1, Verfahrzeiten des Auswerfers). |
| G2 | Die Steuerung nutzt ausschließlich die Sensorsignale, nicht die Interna des Modells (virtuelle Inbetriebnahme). |
| G3 | Das Modell kann Fehler simulieren (z. B. klemmender Zylinder), um E3 zu testen. |

## H. OPC UA und Python

| Nr. | Anforderung |
|---|---|
| H1 | Per OPC UA bereitgestellt: aktueller Schritt, drei Zähler, Betrieb, Störung, Störungstext (später: Zykluszeit, Not-Halt-Zähler, Stillstandszeit). |
| H2 | Python-Skript (`asyncua`) liest jede Sekunde und schreibt eine CSV mit Zeitstempel. |
| H3 | Nur lesender Zugriff, Python schreibt nicht in die SPS. |
| H4 | Kennzahlen: Durchsatz (Teile/min), Verhältnis Metall/Kunststoff, Anzahl Not-Halt-Ereignisse. |

## I. Codequalität

| Nr. | Anforderung |
|---|---|
| I1 | Nur Structured Text; getrennte POUs für Hauptprogramm, Ablauf, Störungsbehandlung, Anlagenmodell. |
| I2 | Präfixe: `x` BOOL, `i` INT, `t` TIME, `fb` FB-Instanz, `e` ENUM. Schritte als ENUM. |
| I3 | Zeiten und Grenzwerte als benannte Konstanten. |
| I4 | Alle FB-Instanzen (Timer, Flanken, Zähler) werden in jedem Zyklus aufgerufen, nicht innerhalb von IF-Zweigen. |
| I5 | Kommentare erklären das Warum, nicht das Was. |

## Bewusst nicht enthalten

Mehrere Teile gleichzeitig auf dem Band, Hand-/Automatikbetrieb, Drehzahlregelung, reale Hardware, Siemens/TIA Portal, sicherheitsgerichtete Programmierung.
