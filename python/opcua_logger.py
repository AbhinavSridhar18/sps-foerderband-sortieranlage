"""
OPC-UA-Logger für die Förderband-Sortieranlage.

Verbindet sich mit dem OPC-UA-Server von CODESYS Control Win, liest die
Variablen aus GVL_Status einmal pro Sekunde und schreibt sie mit Zeitstempel
in eine CSV-Datei unter python/logs/. Der Zugriff ist rein lesend.

Mit Benutzer und Passwort wird verschlüsselt verbunden (Basic256Sha256,
SignAndEncrypt). Beim ersten Start wird dafür ein selbstsigniertes
Client-Zertifikat unter python/certs/ erzeugt, dem in CODESYS einmalig
vertraut werden muss (Security Screen).

Aufruf:
    python python/opcua_logger.py <IP-Adresse der VM>
    python python/opcua_logger.py <IP-Adresse der VM> <Benutzer> <Passwort>

Beenden mit Ctrl+C.
"""

import asyncio
import csv
import datetime
import os
import socket
import sys
from pathlib import Path

from asyncua import Client, ua
from asyncua.crypto.cert_gen import setup_self_signed_certificate
from asyncua.crypto.security_policies import SecurityPolicyBasic256Sha256
from cryptography.x509.oid import ExtendedKeyUsageOID

PORT = 4840
ABTASTZEIT_S = 1.0
GVL_NAME = "GVL_Status"
VARIABLEN = [
    "sSchritt",
    "xBetrieb",
    "xStoerung",
    "xNotHaltAktiv",
    "sStoerung",
    "uiAnzahlMetall",
    "uiAnzahlKunststoff",
    "uiAnzahlGesamt",
    "uiAnzahlNotHalt",
    "tLetzteZykluszeit",
    "tStillstandGesamt",
]
LOG_ORDNER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "logs")
ZERT_ORDNER = Path(os.path.dirname(os.path.abspath(__file__))) / "certs"
APP_URI = "urn:" + socket.gethostname() + ":sps-sortieranlage:logger"


async def richte_verschluesselung_ein(client):
    """Erzeugt bei Bedarf ein Client-Zertifikat und aktiviert die Verschlüsselung."""
    ZERT_ORDNER.mkdir(exist_ok=True)
    schluessel = ZERT_ORDNER / "client_key.pem"
    zertifikat = ZERT_ORDNER / "client_cert.der"
    if not zertifikat.exists() or not schluessel.exists():
        print("Erzeuge Client-Zertifikat:", zertifikat)
    await setup_self_signed_certificate(
        schluessel,
        zertifikat,
        APP_URI,
        socket.gethostname(),
        [ExtendedKeyUsageOID.CLIENT_AUTH],
        {
            "countryName": "DE",
            "organizationName": "Eigenprojekt",
            "commonName": "SPS-Sortieranlage Logger",
        },
    )
    client.application_uri = APP_URI
    try:
        await client.set_security(
            SecurityPolicyBasic256Sha256,
            certificate=str(zertifikat),
            private_key=str(schluessel),
            mode=ua.MessageSecurityMode.SignAndEncrypt,
        )
    except ua.UaError:
        print("Der Server bietet keinen verschluesselten Endpunkt (Basic256Sha256, SignAndEncrypt) an.")
        print("Angebotene Endpunkte:")
        for endpunkt in await client.connect_and_get_server_endpoints():
            print("  Sicherheit:", endpunkt.SecurityPolicyUri.split("#")[-1],
                  "| Modus:", endpunkt.SecurityMode.name)
        print("Abhilfe: in CODESYS ein Serverzertifikat fuer den OPC-UA-Server erzeugen (Security Screen).")
        raise SystemExit(1)


async def finde_knoten(start, name, tiefe=0, max_tiefe=10):
    """Sucht rekursiv den Knoten mit dem BrowseName 'name' unterhalb von 'start'."""
    if tiefe > max_tiefe:
        return None
    for kind in await start.get_children():
        browse_name = await kind.read_browse_name()
        if browse_name.Name == name:
            return kind
        treffer = await finde_knoten(kind, name, tiefe + 1, max_tiefe)
        if treffer is not None:
            return treffer
    return None


async def lade_variablen(client):
    """Liefert die OPC-UA-Knoten der gewünschten Variablen aus GVL_Status."""
    gvl = await finde_knoten(client.nodes.objects, GVL_NAME)
    if gvl is None:
        raise RuntimeError(GVL_NAME + " nicht gefunden. Ist die Symbolkonfiguration geladen?")
    gefunden = {}
    for kind in await gvl.get_children():
        name = (await kind.read_browse_name()).Name
        if name in VARIABLEN:
            gefunden[name] = kind
    fehlend = [v for v in VARIABLEN if v not in gefunden]
    if fehlend:
        print("Warnung, nicht veroeffentlicht:", ", ".join(fehlend))
    namen = [v for v in VARIABLEN if v in gefunden]
    knoten = [gefunden[v] for v in namen]
    return namen, knoten


async def main(ip, benutzer, passwort):
    url = "opc.tcp://" + ip + ":" + str(PORT)
    client = Client(url=url)
    if benutzer:
        await richte_verschluesselung_ein(client)
        client.set_user(benutzer)
        client.set_password(passwort)

    os.makedirs(LOG_ORDNER, exist_ok=True)
    dateiname = "log_" + datetime.datetime.now().strftime("%Y%m%d_%H%M%S") + ".csv"
    pfad = os.path.join(LOG_ORDNER, dateiname)

    print("Verbinde mit:", url)
    async with client:
        namen, knoten = await lade_variablen(client)
        print("Gefundene Variablen:", len(namen))
        print("Logdatei:", pfad)

        with open(pfad, "w", newline="", encoding="utf-8") as datei:
            writer = csv.writer(datei)
            writer.writerow(["Zeit"] + namen)
            while True:
                werte = await client.read_values(knoten)
                zeit = datetime.datetime.now().isoformat(timespec="seconds")
                writer.writerow([zeit] + werte)
                datei.flush()
                daten = dict(zip(namen, werte))
                print("Zeit:", zeit,
                      "| Schritt:", daten.get("sSchritt"),
                      "| Metall:", daten.get("uiAnzahlMetall"),
                      "| Kunststoff:", daten.get("uiAnzahlKunststoff"),
                      "| Stoerung:", daten.get("xStoerung"))
                await asyncio.sleep(ABTASTZEIT_S)


if __name__ == "__main__":
    if len(sys.argv) not in (2, 4):
        print("Aufruf: python python/opcua_logger.py <IP> [<Benutzer> <Passwort>]")
        sys.exit(1)
    ip_adresse = sys.argv[1]
    user = sys.argv[2] if len(sys.argv) == 4 else None
    pw = sys.argv[3] if len(sys.argv) == 4 else None
    try:
        asyncio.run(main(ip_adresse, user, pw))
    except KeyboardInterrupt:
        print("Logger beendet.")
