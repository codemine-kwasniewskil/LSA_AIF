*"----------------------------------------------------------------------
* Gereon Koks  TSI  9.5.2025
*"----------------------------------------------------------------------
* Map PSOFN
*"----------------------------------------------------------------------
* Input
* VALUE_IN  Interface €{EMSA,...)
* VALUE_IN2 28_AKTZ
* VALUE_IN3 29_GRUND
* VALUE_IN4 leer
* VALUE_IN5 leer
*"----------------------------------------------------------------------
* Output
* VALUE_OUT Wert des PSOFN-Feldes
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_psofn.
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
  DATA: lv_29_grund(90).
*"----------------------------------------------------------------------
  CLEAR value_out.
*"----------------------------------------------------------------------
* Interface ?
  CASE value_in.
*"----------------------------------------------------------------------
* Bei SolumSTAR Spezialbehandlung.
    WHEN 'SSTA'.
      IF value_in2 IS INITIAL.
        SEARCH value_in3 FOR 'RE-Nr.'.
        IF sy-subrc = 0.
          lv_29_grund = value_in3.
          SHIFT lv_29_grund LEFT BY sy-fdpos PLACES.
          value_out = lv_29_grund.
        ENDIF.
      ELSE.
        value_out = value_in2.
      ENDIF.
    WHEN OTHERS.
* Bei allen anderen Schnittstellen wird das Aktenzeichen (28_AKTZ) durchgereicht.
      value_out = value_in2.
  ENDCASE.
*"----------------------------------------------------------------------
  IF value_out IS INITIAL.
    value_out = 'not found'.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
