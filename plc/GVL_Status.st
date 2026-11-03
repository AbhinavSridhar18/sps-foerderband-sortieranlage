{attribute 'qualified_only'}
VAR_GLOBAL
    // ---------- Zustand (wird per OPC UA bereitgestellt) ----------
    eSchritt            : E_Schritt := E_Schritt.INIT;
    sSchritt            : STRING(30);
    xBetrieb            : BOOL;          // Automatikablauf aktiv
    xStoerung           : BOOL;          // Störung gespeichert, noch nicht quittiert
    xNotHaltAktiv       : BOOL;          // Not-Halt steht aktuell an
    sStoerung           : STRING(80);    // Störungstext

    // ---------- Zähler und Kennzahlen ----------
    uiAnzahlMetall      : UINT;
    uiAnzahlKunststoff  : UINT;
    uiAnzahlGesamt      : UINT;
    uiAnzahlNotHalt     : UINT;
    tLetzteZykluszeit   : TIME;          // Zeit vom Einlauf bis zum Abschluss des letzten Teils
    tStillstandGesamt   : TIME;          // aufsummierte Zeit im Störungszustand

    // ---------- interne Anforderungen Ablauf -> Ausgaben ----------
    xBandEin            : BOOL;
    xAuswerferEin       : BOOL;
END_VAR
