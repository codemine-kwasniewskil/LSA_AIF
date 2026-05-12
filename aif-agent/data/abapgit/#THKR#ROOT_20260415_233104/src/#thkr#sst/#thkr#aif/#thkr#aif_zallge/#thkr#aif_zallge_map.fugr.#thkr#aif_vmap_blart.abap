*"----------------------------------------------------------------------
* Gereon Koks  TSI  11.10.2024
*"----------------------------------------------------------------------
* Map BLART
*"----------------------------------------------------------------------
* Input
* VALUE_IN  Interface €{EMSA,...)
* VALUE_IN2 BTYP €{SST,FUA,...}
* VALUE_IN3 Field €{1,2,3,...}
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT BLART
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_blart.
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
  DATA: db_/thkr/map_blart TYPE /thkr/map_blart.
*"----------------------------------------------------------------------
  CLEAR value_out.
*"----------------------------------------------------------------------
  SELECT SINGLE * FROM /thkr/map_blart INTO db_/thkr/map_blart
    WHERE sst  = value_in
      AND btyp = value_in2
      AND nr   = value_in3.

  value_out = db_/thkr/map_blart-blart.

*"----------------------------------------------------------------------
  IF sy-subrc <> 0.
    SELECT SINGLE * FROM /thkr/map_blart INTO db_/thkr/map_blart
      WHERE sst  = value_in
        AND btyp = '*'
        AND nr   = value_in3.

    value_out = db_/thkr/map_blart-blart.

  ENDIF.

*"----------------------------------------------------------------------
ENDFUNCTION.
