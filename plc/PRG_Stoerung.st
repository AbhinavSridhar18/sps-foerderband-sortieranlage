PROGRAM PRG_Stoerung
VAR
    fbNotHaltFlanke : R_TRIG;   // Not-Halt wurde betätigt (für den Ereigniszähler)
    fbQuittFlanke   : R_TRIG;
    tJetzt          : TIME;
    tLetzter        : TIME;
END_VAR

(* ---------- Implementierung ---------- *)

tJetzt := TIME();

// Not-Halt (Öffner): FALSE bedeutet betätigt oder Leitungsbruch
GVL_Status.xNotHaltAktiv := NOT GVL_IO.xNotHaltOk;

fbNotHaltFlanke(CLK := GVL_Status.xNotHaltAktiv);
IF fbNotHaltFlanke.Q THEN
    GVL_Status.uiAnzahlNotHalt := GVL_Status.uiAnzahlNotHalt + 1;
END_IF

// Solange der Not-Halt ansteht, bleibt die Störung gesetzt
IF GVL_Status.xNotHaltAktiv THEN
    GVL_Status.xStoerung := TRUE;
    GVL_Status.sStoerung := 'Not-Halt betaetigt';
END_IF

// Quittieren nur mit neuer Flanke und nur, wenn der Not-Halt entriegelt ist.
// Zeitüberschreitungen setzt PRG_Ablauf direkt in GVL_Status.
fbQuittFlanke(CLK := GVL_IO.xQuittieren);
IF fbQuittFlanke.Q AND GVL_Status.xStoerung AND GVL_IO.xNotHaltOk THEN
    GVL_Status.xStoerung := FALSE;
    GVL_Status.sStoerung := '';
END_IF

// Stillstandszeit für die Kennzahlen aufsummieren
IF GVL_Status.xStoerung THEN
    GVL_Status.tStillstandGesamt := GVL_Status.tStillstandGesamt + (tJetzt - tLetzter);
END_IF
tLetzter := tJetzt;
