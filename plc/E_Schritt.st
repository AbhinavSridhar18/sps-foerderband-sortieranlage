{attribute 'qualified_only'}
{attribute 'strict'}
TYPE E_Schritt :
(
    INIT            := 0,   // Grundstellung herstellen
    BEREIT          := 1,   // Stillstand, wartet auf Start
    WARTEN_AUF_TEIL := 2,   // Automatik, wartet auf Teil an B1
    TRANSPORT       := 3,   // Band läuft, Material wird an B2 erkannt
    AUSWERFER_AUS   := 4,   // Metallteil: Auswerfer fährt aus
    AUSWERFER_EIN   := 5,   // Auswerfer fährt zurück
    STOERUNG        := 9    // Not-Halt oder Zeitüberschreitung
);
END_TYPE
