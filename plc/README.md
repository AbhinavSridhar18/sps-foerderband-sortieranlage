# SPS-Code (CODESYS V3.5 SP22, Structured Text)

| Datei | Objekt in CODESYS | Inhalt |
|---|---|---|
| `E_Schritt.st` | DUT (Enumeration) | Schritte der Schrittkette |
| `GVL_IO.st` | Globale Variablenliste | Ein- und Ausgänge laut Zuordnungsliste |
| `GVL_Param.st` | Globale Variablenliste | Zeitgrenzen als Konstanten |
| `GVL_Status.st` | Globale Variablenliste | Zustand, Zähler, Kennzahlen (OPC UA) |
| `GVL_Sim.st` | Globale Variablenliste | Bedienung und Zustand der Anlagensimulation |
| `FB_Anlagensimulation.st` | Funktionsbaustein | Anlagenmodell: erzeugt die Sensorsignale |
| `PRG_Stoerung.st` | Programm | Not-Halt, Quittierung, Stillstandszeit |
| `PRG_Ablauf.st` | Programm | Schrittkette, Zähler, Zeitüberwachung |
| `PRG_Ausgaben.st` | Programm | Freigabe der Aktoren, Leuchten |
| `PLC_PRG.st` | Programm (MainTask) | Aufrufreihenfolge |

Bei Programmen und Funktionsbausteinen steht der Deklarationsteil oberhalb der Zeile
`(* ---------- Implementierung ---------- *)`, der Anweisungsteil darunter.

`Foerderband_Sortieranlage.project` ist die vollständige CODESYS-Projektdatei.
