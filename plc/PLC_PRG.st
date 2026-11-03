PROGRAM PLC_PRG
VAR
    fbAnlage : FB_Anlagensimulation;
END_VAR

(* ---------- Implementierung ---------- *)

// Reihenfolge: Sensoren erzeugen, Störungen auswerten, Ablauf, Ausgänge schreiben
fbAnlage();
PRG_Stoerung();
PRG_Ablauf();
PRG_Ausgaben();
