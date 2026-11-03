# Testprotokoll

Tests T1–T8 in der CODESYS-Simulation, T9 auf CODESYS Control Win (V3.5 SP22), jeweils über die Visualisierung `Visu_Anlage`, November 2026.

| Nr. | Test | Erwartetes Ergebnis | Ergebnis | Bemerkung |
|---|---|---|---|---|
| T1 | Start, Metallteil | Auswurf in Rutsche A, Metall- und Gesamtzähler +1 | bestanden | |
| T2 | Start, Kunststoffteil | Ankunft in Rutsche B, Kunststoff- und Gesamtzähler +1 | bestanden | |
| T3 | Start-Taster gedrückt halten | Genau ein Start, keine Wiederholung | bestanden | Flankenerkennung mit `R_TRIG` |
| T4 | Stopp während ein Teil läuft | Teil wird fertig bearbeitet, dann Stillstand | bestanden | Stopp am Zyklusende |
| T5 | Not-Halt während des Auswerfens | Sofort alles aus, Störungsleuchte Dauerlicht | bestanden | |
| T6 | Quittieren bei gedrücktem Not-Halt | Wird abgelehnt | bestanden | |
| T7 | Not-Halt entriegeln, quittieren, kein Start | Leuchte blinkt bis zur Quittierung, danach Grundstellung und Stillstand | bestanden | Wiederanlaufsperre; Teil anschließend per „Band leeren“ entfernt |
| T8 | Simulierter klemmender Zylinder | Zeitüberschreitung nach 2 s, Störungstext angezeigt | bestanden | Text: „Auswerfer erreicht vordere Endlage nicht (B6)“ |
| T9 | Python-Logger läuft | CSV füllt sich mit Schritt, Zählern und Status | bestanden | Verbindung vom Mac zur VM, verschlüsselt (Basic256Sha256); 5 Teile, 1 Not-Halt in 1,75 min aufgezeichnet, siehe `python/logs/beispiel_log.csv` |
