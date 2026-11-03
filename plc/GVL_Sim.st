{attribute 'qualified_only'}
VAR_GLOBAL
    // ---------- Bedienung der Simulation (Visualisierung) ----------
    xMetallteilAuflegen     : BOOL;
    xKunststoffteilAuflegen : BOOL;
    xBandLeeren             : BOOL;      // Bediener nimmt ein Teil vom Band (z. B. nach Not-Halt)
    xZylinderKlemmt         : BOOL;      // Fehlersimulation: Auswerfer bewegt sich nicht

    // ---------- Zustand der Simulation (nur Anzeige) ----------
    xTeilAufBand            : BOOL;
    rTeilPosition           : REAL;      // mm ab Bandanfang
    rAuswerferPosition      : REAL;      // 0 = eingefahren, 100 = ausgefahren
END_VAR
