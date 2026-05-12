*"----------------------------------------------------------------------
* Gereon Koks  TSI  11.10.2024
*"----------------------------------------------------------------------
* Map BLART
* Nur für Justiz, da hier auf Erst- oder Zweitschuldner geprüft.
* Fallunterscheidung:
* 1. Erstschuldner
* 2. Zweitschuldner
* 3. Geschäftspartner
*"----------------------------------------------------------------------
* Input
* VALUE_IN  Interface €{EMSA,...)
* VALUE_IN2 01 BTYP €{SST,FUA,...}
* VALUE_IN3 Field €{1,2,3,...}
* VALUE_IN4 22_RES1
* VALUE_IN5 29_SGTXT
*"----------------------------------------------------------------------
* Output
* VALUE_OUT BLART
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_blart_erst_zwei.
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
  DATA: db_/thkr/map_blart TYPE /thkr/map_blart,
        lv_fall(16),
        lv_kassz           TYPE string,
        lv_length          TYPE i,
        lv_length_xyz      TYPE i,
        ls_bkpf            TYPE bkpf.
*"----------------------------------------------------------------------
  CLEAR value_out.
*"----------------------------------------------------------------------
  lv_length = strlen( value_in4 ).

  IF lv_length < 11.
    lv_fall = 'Geschäftspartner'.
  ELSE.
    CASE value_in4+10(1).
      WHEN 'N' OR 'n'.
        lv_fall = 'Geschäftspartner'.
      WHEN 'J' OR 'j'.
        lv_length     = strlen( value_in5 ).

        IF lv_length >= 18 AND value_in5+0(18) = 'ZWS: Kassenzeichen'.
          lv_length     = strlen( value_in5 ).
          lv_length_xyz = lv_length - 19.
          lv_kassz = value_in5+19(lv_length_xyz).

          SELECT * FROM bkpf INTO ls_bkpf
            WHERE xblnr = lv_kassz
            AND   blart = 'D2'.

            lv_fall = 'Zweitschuldner'.
          ENDSELECT.

          IF sy-subrc <> 0.
            lv_fall = 'Erstschuldner'.
          ENDIF.
        ELSE.
          lv_fall = 'Geschäftspartner'.
        ENDIF.
      WHEN OTHERS.
        lv_fall = 'Geschäftspartner'.
    ENDCASE.
  ENDIF.
*"----------------------------------------------------------------------
  CASE lv_fall.
*"----------------------------------------------------------------------
    WHEN 'Erstschuldner'.
      value_out = 'D2'.
    WHEN 'Zweitschuldner'.
      value_out = 'D3'.
    WHEN 'Geschäftspartner'.
      CALL FUNCTION '/THKR/AIF_VMAP_BLART'
        EXPORTING
          value_in       = value_in
          value_in2      = value_in2
          value_in3      = value_in3
*         VALUE_IN4      =
*         VALUE_IN5      =
*         SENDING_SYSTEM =
*         VALUE_FOUND    =
*       TABLES
*         RETURN_TAB     =
        CHANGING
          value_out      = value_out
        EXCEPTIONS
          no_value_found = 1
          OTHERS         = 2.
*"----------------------------------------------------------------------
    WHEN OTHERS.
      value_out = '??'.
*"----------------------------------------------------------------------
  ENDCASE.
*"----------------------------------------------------------------------
ENDFUNCTION.
