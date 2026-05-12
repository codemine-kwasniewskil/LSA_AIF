FUNCTION /thkr/aif_vmap_belnr_mb.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(VALUE_IN) TYPE  STRING
*"     REFERENCE(VALUE_IN2) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN3) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN4) TYPE  STRING OPTIONAL
*"     REFERENCE(VALUE_IN5) TYPE  STRING OPTIONAL
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"         OPTIONAL
*"     REFERENCE(VALUE_FOUND) TYPE  C OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"--------------------------------------------------------------------
  CLEAR value_out.
*"----------------------------------------------------------------------
  "Ermittlung der Belegnummer für Mittelbindung anhand des Urkassenzeichens.
  "Kann keine Mittelbindung ermittelt werden, verwende das Urkassenzeichen.
  "Ist hilfreich später für Fehlerausgabe.

  SELECT SINGLE belnr
    FROM kblk
    WHERE ktext = @value_in
    INTO @value_out.
  IF sy-subrc <> 0.
    value_out = value_in.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
