PROGRAM PRG_Ablauf
VAR
    fbStartFlanke     : R_TRIG;
    fbResetFlanke     : R_TRIG;
    fbSchrittZeit     : TON;                       // misst, wie lange der aktuelle Schritt schon aktiv ist
    eSchrittAlt       : E_Schritt := E_Schritt.INIT;
    xStoppAngefordert : BOOL;                      // Stopp am Zyklusende
    xIstMetall        : BOOL;                      // an B2 erkanntes Material des aktuellen Teils
    tTeilStart        : TIME;
END_VAR

(* ---------- Implementierung ---------- *)

fbStartFlanke(CLK := GVL_IO.xStart);
fbResetFlanke(CLK := GVL_IO.xZaehlerReset);

// Schrittzeit: wird bei jedem Schrittwechsel für einen Zyklus zurückgesetzt
fbSchrittZeit(IN := (GVL_Status.eSchritt = eSchrittAlt), PT := T#24H);
eSchrittAlt := GVL_Status.eSchritt;

// Stopp (Öffner) nur merken, das aktuelle Teil wird fertig bearbeitet
IF NOT GVL_IO.xStoppOk THEN
    xStoppAngefordert := TRUE;
END_IF

// Eine Störung hat Vorrang vor jedem Schritt
IF GVL_Status.xStoerung THEN
    GVL_Status.eSchritt := E_Schritt.STOERUNG;
END_IF

CASE GVL_Status.eSchritt OF

    E_Schritt.INIT:
        GVL_Status.xBandEin := FALSE;
        GVL_Status.xAuswerferEin := FALSE;
        IF GVL_IO.xAuswerferEingefahren THEN
            GVL_Status.eSchritt := E_Schritt.BEREIT;
        ELSIF fbSchrittZeit.ET > GVL_Param.tTimeoutAuswerfer THEN
            GVL_Status.xStoerung := TRUE;
            GVL_Status.sStoerung := 'Grundstellung: Auswerfer faehrt nicht ein (B5)';
            GVL_Status.eSchritt := E_Schritt.STOERUNG;
        END_IF

    E_Schritt.BEREIT:
        GVL_Status.xBandEin := FALSE;
        GVL_Status.xAuswerferEin := FALSE;
        IF fbResetFlanke.Q THEN
            GVL_Status.uiAnzahlMetall := 0;
            GVL_Status.uiAnzahlKunststoff := 0;
            GVL_Status.uiAnzahlGesamt := 0;
        END_IF
        // Wiederanlaufsperre: Start nur mit neuer Flanke
        IF fbStartFlanke.Q AND GVL_IO.xStoppOk THEN
            xStoppAngefordert := FALSE;
            GVL_Status.eSchritt := E_Schritt.WARTEN_AUF_TEIL;
        END_IF

    E_Schritt.WARTEN_AUF_TEIL:
        GVL_Status.xBandEin := FALSE;
        GVL_Status.xAuswerferEin := FALSE;
        IF xStoppAngefordert THEN
            GVL_Status.eSchritt := E_Schritt.BEREIT;
        ELSIF GVL_IO.xTeilEinlauf THEN
            xIstMetall := FALSE;
            tTeilStart := TIME();
            GVL_Status.eSchritt := E_Schritt.TRANSPORT;
        END_IF

    E_Schritt.TRANSPORT:
        GVL_Status.xBandEin := TRUE;
        GVL_Status.xAuswerferEin := FALSE;
        // Das Signal von B2 ist nur kurz da, deshalb wird das Material gespeichert
        IF GVL_IO.xTeilMetall THEN
            xIstMetall := TRUE;
        END_IF
        IF xIstMetall AND GVL_IO.xTeilAuswurfPos THEN
            GVL_Status.xBandEin := FALSE;
            GVL_Status.eSchritt := E_Schritt.AUSWERFER_AUS;
        ELSIF NOT xIstMetall AND GVL_IO.xTeilRutscheB THEN
            GVL_Status.xBandEin := FALSE;
            GVL_Status.uiAnzahlKunststoff := GVL_Status.uiAnzahlKunststoff + 1;
            GVL_Status.uiAnzahlGesamt := GVL_Status.uiAnzahlGesamt + 1;
            GVL_Status.tLetzteZykluszeit := TIME() - tTeilStart;
            IF xStoppAngefordert THEN
                GVL_Status.eSchritt := E_Schritt.BEREIT;
            ELSE
                GVL_Status.eSchritt := E_Schritt.WARTEN_AUF_TEIL;
            END_IF
        ELSIF fbSchrittZeit.ET > GVL_Param.tTimeoutTransport THEN
            GVL_Status.xStoerung := TRUE;
            GVL_Status.sStoerung := 'Transport: Teil erreicht B3 bzw. B4 nicht';
            GVL_Status.eSchritt := E_Schritt.STOERUNG;
        END_IF

    E_Schritt.AUSWERFER_AUS:
        GVL_Status.xBandEin := FALSE;
        GVL_Status.xAuswerferEin := TRUE;
        IF GVL_IO.xAuswerferAusgefahren THEN
            GVL_Status.eSchritt := E_Schritt.AUSWERFER_EIN;
        ELSIF fbSchrittZeit.ET > GVL_Param.tTimeoutAuswerfer THEN
            GVL_Status.xStoerung := TRUE;
            GVL_Status.sStoerung := 'Auswerfer erreicht vordere Endlage nicht (B6)';
            GVL_Status.eSchritt := E_Schritt.STOERUNG;
        END_IF

    E_Schritt.AUSWERFER_EIN:
        GVL_Status.xBandEin := FALSE;
        GVL_Status.xAuswerferEin := FALSE;
        IF GVL_IO.xAuswerferEingefahren THEN
            GVL_Status.uiAnzahlMetall := GVL_Status.uiAnzahlMetall + 1;
            GVL_Status.uiAnzahlGesamt := GVL_Status.uiAnzahlGesamt + 1;
            GVL_Status.tLetzteZykluszeit := TIME() - tTeilStart;
            IF xStoppAngefordert THEN
                GVL_Status.eSchritt := E_Schritt.BEREIT;
            ELSE
                GVL_Status.eSchritt := E_Schritt.WARTEN_AUF_TEIL;
            END_IF
        ELSIF fbSchrittZeit.ET > GVL_Param.tTimeoutAuswerfer THEN
            GVL_Status.xStoerung := TRUE;
            GVL_Status.sStoerung := 'Auswerfer erreicht hintere Endlage nicht (B5)';
            GVL_Status.eSchritt := E_Schritt.STOERUNG;
        END_IF

    E_Schritt.STOERUNG:
        GVL_Status.xBandEin := FALSE;
        GVL_Status.xAuswerferEin := FALSE;
        // Nach dem Quittieren zurück in die Grundstellung, danach ist ein neuer Start nötig
        IF NOT GVL_Status.xStoerung THEN
            GVL_Status.eSchritt := E_Schritt.INIT;
        END_IF

END_CASE

// Anzeige und Betriebsstatus
GVL_Status.xBetrieb := GVL_Status.eSchritt = E_Schritt.WARTEN_AUF_TEIL
                       OR GVL_Status.eSchritt = E_Schritt.TRANSPORT
                       OR GVL_Status.eSchritt = E_Schritt.AUSWERFER_AUS
                       OR GVL_Status.eSchritt = E_Schritt.AUSWERFER_EIN;

CASE GVL_Status.eSchritt OF
    E_Schritt.INIT:            GVL_Status.sSchritt := 'Grundstellung';
    E_Schritt.BEREIT:          GVL_Status.sSchritt := 'Bereit';
    E_Schritt.WARTEN_AUF_TEIL: GVL_Status.sSchritt := 'Warten auf Teil';
    E_Schritt.TRANSPORT:       GVL_Status.sSchritt := 'Transport';
    E_Schritt.AUSWERFER_AUS:   GVL_Status.sSchritt := 'Auswerfer faehrt aus';
    E_Schritt.AUSWERFER_EIN:   GVL_Status.sSchritt := 'Auswerfer faehrt ein';
    E_Schritt.STOERUNG:        GVL_Status.sSchritt := 'Stoerung';
END_CASE
