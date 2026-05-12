*"----------------------------------------------------------------------
* Gereon Koks  TSI  28.3.2025
*"----------------------------------------------------------------------
* Map MWSKZ
*"----------------------------------------------------------------------
* Input
* VALUE_IN  01_BTYP
* VALUE_IN2 BLART
* VALUE_IN3 21_BKZ ("B" = Belastung; "E" = Entlastung)
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT MWSKZ
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_mwskz_neu .
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
  DATA: l_/thkr/map_mwskz TYPE /thkr/map_mwskz.
*"----------------------------------------------------------------------
* VALUE_IN  01_BTYP
* VALUE_IN2 BLART
* VALUE_IN3 21_BKZ ("B" = Belastung; "E" = Entlastung)
*"----------------------------------------------------------------------
* Hierarchisch zugreifen
* 1. Exakt
* 2. Allgemein
*"----------------------------------------------------------------------
*  value_out = '??'.

*"----------------------------------------------------------------------
  SELECT SINGLE mwskz FROM /thkr/map_mwskz INTO value_out
    WHERE btyp  = value_in
      AND blart = value_in2
      AND bkz   = value_in3.

  IF sy-subrc <> 0.

* BKZ generisch
    SELECT SINGLE mwskz FROM /thkr/map_mwskz INTO value_out
      WHERE btyp  = value_in
        AND blart = value_in2
        AND bkz   = '*'.

    IF sy-subrc <> 0.

*"----------------------------------------------------------------------
* BTYP generisch
      SELECT SINGLE mwskz FROM /thkr/map_mwskz INTO value_out
       WHERE btyp  = '*'
         AND blart = value_in2
         AND bkz   = value_in3.

      IF sy-subrc <> 0.
*"----------------------------------------------------------------------
* BLART generisch
* Gibt es nicht. BLART ist immer gefüllt.
*"----------------------------------------------------------------------
        SELECT SINGLE mwskz FROM /thkr/map_mwskz INTO value_out
          WHERE btyp = '*'
           AND blart = value_in2
           AND bkz   = '*'.
      ENDIF.
    ENDIF.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
