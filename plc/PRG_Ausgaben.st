PROGRAM PRG_Ausgaben
VAR
    fbBlinkTakt : TON;
    xBlink      : BOOL;
    xFreigabe   : BOOL;
END_VAR

(* ---------- Implementierung ---------- *)

// Aktoren nur bei entriegeltem Not-Halt und ohne Störung freigeben
xFreigabe := GVL_IO.xNotHaltOk AND NOT GVL_Status.xStoerung;

GVL_IO.xBandMotor          := GVL_Status.xBandEin AND xFreigabe;
GVL_IO.xAuswerferAusfahren := GVL_Status.xAuswerferEin AND xFreigabe;   // FALSE: Federrückstellung fährt ein
GVL_IO.xLampeBetrieb       := GVL_Status.xBetrieb AND xFreigabe;

// Störungsleuchte: Dauerlicht solange der Not-Halt ansteht, Blinken bis zur Quittierung
fbBlinkTakt(IN := NOT fbBlinkTakt.Q, PT := GVL_Param.tBlinkHalbperiode);
IF fbBlinkTakt.Q THEN
    xBlink := NOT xBlink;
END_IF

IF GVL_Status.xNotHaltAktiv THEN
    GVL_IO.xLampeStoerung := TRUE;
ELSIF GVL_Status.xStoerung THEN
    GVL_IO.xLampeStoerung := xBlink;
ELSE
    GVL_IO.xLampeStoerung := FALSE;
END_IF
