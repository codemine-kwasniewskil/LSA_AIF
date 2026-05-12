FUNCTION /thkr/aif_vmap_ad_pstcd1 .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(VALUE_IN) TYPE  STRING
*"     REFERENCE(VALUE_IN2) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN3) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN4) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN5) TYPE  STRING OPTIONAL
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"     REFERENCE(VALUE_FOUND) TYPE  C OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  "Ermittlung des Zahlweges

  "VALUE_IN = PLZ
  "VALUE_IN2 = Land

  "Lesen der konfigurierten Länge der Postleitzahl pro Land
  SELECT SINGLE lnplz, prplz
    FROM t005
    WHERE land1 = @VALUE_in2
   INTO (@DATA(lv_lnplz), @DATA(lv_prlz) ).
  IF sy-subrc = 0.
    "Land gefunden.
    "gelieferten Wert mit Nullen füllen
    IF lv_lnplz IS INITIAL.
      value_out = value_in.
    ELSE.
      IF lv_prlz BETWEEN 1 and 8.
        "Prüfungen bei Postleitzahlen
        "1  Länge Maximalwert, lückenlos
        "2  Länge Maximalwert, numerisch, lückenlos
        "3  Länge exakt einzuhalten, lückenlos
        "4  Länge exakt einzuhalten, numerisch, lückenlos
        "5  Länge Maximalwert
        "6  Länge Maximalwert, numerisch
        "7  Länge exakt einzuhalten
        "8  Länge exakt einzuhalten, numerisch
        "9  Prüfung gegen landesspezifische Schablone
        "0  Deaktivierung der PLZ-Prüfung für  USA
        value_out = |{ value_in ALPHA = IN WIDTH = lv_lnplz }|.
      ELSE.
        "Keine Prüfung der Länge für Postleitzahlen
        "Oder gegen Schablone.
        value_out = value_in.
      ENDIF.
    ENDIF.
  ELSE.
    "Keine Konfigruation gefunden
    "Rückgabe Eingangswert
    value_out = value_in.
  ENDIF.

ENDFUNCTION.
