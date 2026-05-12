FUNCTION /thkr/aif_vmap_sepa_val_to_dat.
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
  "VALUE_IN = Endedatum
  "VALUE_IN2 = Mandatsreferenz (75_MDTREFER)
*"----------------------------------------------------------------------
  "aus den Fremdverfahren im BIC Format kommt kein Endedatum für ein Mandat.
  "Daher soll es bis Highdate gehen. Wenn aber das Mandat im SAP mit einem Endedatum versehen wurde,
  "Dann soll es nicht überschrieben werden.
  SELECT SINGLE val_to_date
    FROM sepa_mandate
   WHERE mndid = @value_in2
    AND mvers = '0000'    "immer die aktuelle Version.
    INTO @DATA(lv_val_to_date).
  IF sy-subrc = 0.
    value_out = lv_val_to_date.
  ELSE.
    "Kein Mandat gefunden.
    "Übernehme Datum aus VALUE_IN.
    Value_out = value_in .
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
