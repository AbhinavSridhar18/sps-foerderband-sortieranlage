{attribute 'qualified_only'}
VAR_GLOBAL CONSTANT
    tTimeoutTransport : TIME := T#8S;     // Teil muss B3 bzw. B4 innerhalb dieser Zeit erreichen
    tTimeoutAuswerfer : TIME := T#2S;     // Auswerfer muss seine Endlage innerhalb dieser Zeit erreichen
    tBlinkHalbperiode : TIME := T#500MS;  // Blinktakt der Störungsleuchte
END_VAR
