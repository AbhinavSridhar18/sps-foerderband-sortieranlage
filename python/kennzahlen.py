"""
Kennzahlen aus einer Logdatei des OPC-UA-Loggers.

Aufruf:
    python python/kennzahlen.py                 (neueste Datei in python/logs/)
    python python/kennzahlen.py <Pfad zur CSV>
"""

import csv
import datetime
import glob
import os
import sys

LOG_ORDNER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "logs")


def neueste_logdatei():
    dateien = sorted(glob.glob(os.path.join(LOG_ORDNER, "*.csv")))
    if not dateien:
        print("Keine Logdatei gefunden in:", LOG_ORDNER)
        sys.exit(1)
    return dateien[-1]


def als_zahl(wert):
    try:
        return float(wert)
    except (TypeError, ValueError):
        return 0.0


def zeit_in_s(wert):
    """TIME-Werte kommen je nach Server als Millisekunden oder als Text 'h:mm:ss'."""
    if wert is None or wert == "":
        return 0.0
    if ":" in str(wert):
        teile = [float(t) for t in str(wert).split(":")]
        sekunden = 0.0
        for t in teile:
            sekunden = sekunden * 60.0 + t
        return sekunden
    return als_zahl(wert) / 1000.0


def main(pfad):
    with open(pfad, newline="", encoding="utf-8") as datei:
        zeilen = list(csv.DictReader(datei))
    if len(zeilen) < 2:
        print("Zu wenige Messwerte in:", pfad)
        sys.exit(1)

    erste = zeilen[0]
    letzte = zeilen[-1]
    beginn = datetime.datetime.fromisoformat(erste["Zeit"])
    ende = datetime.datetime.fromisoformat(letzte["Zeit"])
    dauer_min = (ende - beginn).total_seconds() / 60.0

    def differenz(spalte):
        return als_zahl(letzte.get(spalte)) - als_zahl(erste.get(spalte))

    teile_gesamt = differenz("uiAnzahlGesamt")
    teile_metall = differenz("uiAnzahlMetall")
    teile_kunststoff = differenz("uiAnzahlKunststoff")
    not_halt = differenz("uiAnzahlNotHalt")
    stillstand_s = zeit_in_s(letzte.get("tStillstandGesamt")) - zeit_in_s(erste.get("tStillstandGesamt"))

    # Zykluszeit je Teil: Wert immer dann übernehmen, wenn der Gesamtzähler steigt
    zykluszeiten = []
    vorher = als_zahl(erste.get("uiAnzahlGesamt"))
    for zeile in zeilen[1:]:
        jetzt = als_zahl(zeile.get("uiAnzahlGesamt"))
        if jetzt > vorher:
            zykluszeiten.append(zeit_in_s(zeile.get("tLetzteZykluszeit")))
        vorher = jetzt

    print("Logdatei:", os.path.basename(pfad))
    print("Messdauer in min:", round(dauer_min, 2))
    print("Teile gesamt:", int(teile_gesamt))
    print("Metallteile:", int(teile_metall))
    print("Kunststoffteile:", int(teile_kunststoff))
    if dauer_min > 0:
        print("Durchsatz in Teile/min:", round(teile_gesamt / dauer_min, 2))
    if teile_gesamt > 0:
        print("Anteil Metall in %:", round(100.0 * teile_metall / teile_gesamt, 1))
    print("Not-Halt-Ereignisse:", int(not_halt))
    print("Stillstand durch Stoerungen in s:", round(stillstand_s, 1))
    if zykluszeiten:
        print("Mittlere Zykluszeit je Teil in s:", round(sum(zykluszeiten) / len(zykluszeiten), 2))


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else neueste_logdatei())
