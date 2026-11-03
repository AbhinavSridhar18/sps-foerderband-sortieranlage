FUNCTION_BLOCK FB_Anlagensimulation
VAR
    fbMetallFlanke     : R_TRIG;
    fbKunststoffFlanke : R_TRIG;
    fbLeerenFlanke     : R_TRIG;
    fbRutscheBImpuls   : TP;
    xTeilIstMetall     : BOOL;
    xTeilFaelltInB     : BOOL;
    xErsterZyklus      : BOOL := TRUE;
    tJetzt             : TIME;
    tLetzter           : TIME;
    rDt                : REAL;          // Zeit seit dem letzten Zyklus in s
END_VAR
VAR CONSTANT
    rBandGeschw        : REAL := 200.0;  // mm/s
    rBandLaenge        : REAL := 1000.0; // mm
    rB1Start           : REAL := 0.0;
    rB1Ende            : REAL := 80.0;
    rB2Start           : REAL := 350.0;
    rB2Ende            : REAL := 420.0;
    rB3Start           : REAL := 650.0;
    rB3Ende            : REAL := 720.0;
    rAuswerferGeschw   : REAL := 200.0;  // %/s, ein Hub dauert 0,5 s
    rAuswurfSchwelle   : REAL := 50.0;   // ab hier ist das Teil vom Band geschoben
END_VAR

(* ---------- Implementierung ---------- *)

// Zeitschritt bestimmen (begrenzt, damit Pausen im Debugger keine Sprünge erzeugen)
tJetzt := TIME();
IF xErsterZyklus THEN
    tLetzter := tJetzt;
    xErsterZyklus := FALSE;
END_IF
rDt := MIN(TIME_TO_REAL(tJetzt - tLetzter) / 1000.0, 0.1);
tLetzter := tJetzt;

// Teile auflegen und entfernen
fbMetallFlanke(CLK := GVL_Sim.xMetallteilAuflegen);
fbKunststoffFlanke(CLK := GVL_Sim.xKunststoffteilAuflegen);
fbLeerenFlanke(CLK := GVL_Sim.xBandLeeren);

IF NOT GVL_Sim.xTeilAufBand THEN
    IF fbMetallFlanke.Q THEN
        GVL_Sim.xTeilAufBand := TRUE;
        GVL_Sim.rTeilPosition := 0.0;
        xTeilIstMetall := TRUE;
    ELSIF fbKunststoffFlanke.Q THEN
        GVL_Sim.xTeilAufBand := TRUE;
        GVL_Sim.rTeilPosition := 0.0;
        xTeilIstMetall := FALSE;
    END_IF
END_IF

IF fbLeerenFlanke.Q THEN
    GVL_Sim.xTeilAufBand := FALSE;
END_IF

// Bandbewegung
xTeilFaelltInB := FALSE;
IF GVL_Sim.xTeilAufBand AND GVL_IO.xBandMotor THEN
    GVL_Sim.rTeilPosition := GVL_Sim.rTeilPosition + rBandGeschw * rDt;
    IF GVL_Sim.rTeilPosition >= rBandLaenge THEN
        GVL_Sim.xTeilAufBand := FALSE;
        xTeilFaelltInB := TRUE;
    END_IF
END_IF
fbRutscheBImpuls(IN := xTeilFaelltInB, PT := T#500MS);

// Auswerfer (bei Fehlersimulation bleibt er stehen)
IF NOT GVL_Sim.xZylinderKlemmt THEN
    IF GVL_IO.xAuswerferAusfahren THEN
        GVL_Sim.rAuswerferPosition := MIN(GVL_Sim.rAuswerferPosition + rAuswerferGeschw * rDt, 100.0);
    ELSE
        GVL_Sim.rAuswerferPosition := MAX(GVL_Sim.rAuswerferPosition - rAuswerferGeschw * rDt, 0.0);
    END_IF
END_IF

// Auswurf in Rutsche A
IF GVL_Sim.xTeilAufBand
   AND GVL_Sim.rAuswerferPosition >= rAuswurfSchwelle
   AND GVL_Sim.rTeilPosition >= rB3Start
   AND GVL_Sim.rTeilPosition <= rB3Ende THEN
    GVL_Sim.xTeilAufBand := FALSE;
END_IF

// Sensorsignale
GVL_IO.xTeilEinlauf := GVL_Sim.xTeilAufBand
                       AND GVL_Sim.rTeilPosition >= rB1Start
                       AND GVL_Sim.rTeilPosition <= rB1Ende;
GVL_IO.xTeilMetall := GVL_Sim.xTeilAufBand AND xTeilIstMetall
                      AND GVL_Sim.rTeilPosition >= rB2Start
                      AND GVL_Sim.rTeilPosition <= rB2Ende;
GVL_IO.xTeilAuswurfPos := GVL_Sim.xTeilAufBand
                          AND GVL_Sim.rTeilPosition >= rB3Start
                          AND GVL_Sim.rTeilPosition <= rB3Ende;
GVL_IO.xTeilRutscheB := fbRutscheBImpuls.Q;
GVL_IO.xAuswerferEingefahren := GVL_Sim.rAuswerferPosition <= 0.5;
GVL_IO.xAuswerferAusgefahren := GVL_Sim.rAuswerferPosition >= 99.5;
