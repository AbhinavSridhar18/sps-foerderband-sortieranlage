{attribute 'qualified_only'}
VAR_GLOBAL
    // ---------- Eingänge ----------
    // Öffner: TRUE = in Ordnung. Startwert TRUE nur für die Simulation,
    // weil es keinen realen Taster gibt, der den Kontakt geschlossen hält.
    xNotHaltOk            : BOOL := TRUE;   // S0  %IX0.0  Öffner
    xStart                : BOOL;           // S1  %IX0.1  Schließer
    xStoppOk              : BOOL := TRUE;   // S2  %IX0.2  Öffner
    xQuittieren           : BOOL;           // S3  %IX0.3  Schließer
    xZaehlerReset         : BOOL;           // S4  %IX0.4  Schließer
    xTeilEinlauf          : BOOL;           // B1  %IX0.5
    xTeilMetall           : BOOL;           // B2  %IX0.6  induktiv
    xTeilAuswurfPos       : BOOL;           // B3  %IX0.7
    xTeilRutscheB         : BOOL;           // B4  %IX1.0
    xAuswerferEingefahren : BOOL := TRUE;   // B5  %IX1.1
    xAuswerferAusgefahren : BOOL;           // B6  %IX1.2

    // ---------- Ausgänge ----------
    xBandMotor            : BOOL;           // K1/M1 %QX0.0
    xAuswerferAusfahren   : BOOL;           // Y1    %QX0.1
    xLampeBetrieb         : BOOL;           // H1    %QX0.2
    xLampeStoerung        : BOOL;           // H2    %QX0.3
END_VAR
