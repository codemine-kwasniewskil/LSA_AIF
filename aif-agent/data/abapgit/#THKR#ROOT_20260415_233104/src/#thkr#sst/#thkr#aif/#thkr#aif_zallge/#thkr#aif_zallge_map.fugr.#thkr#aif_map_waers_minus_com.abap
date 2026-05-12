FUNCTION /thkr/aif_map_waers_minus_com .
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
  "VALUE_IN = Betrag
  "VALUE_IN2 = Währung

  if value_in CA '.'.
    DATA(val) = |{ CONV fm_trbtr( value_in ) SIGN = LEFT }|.
    value_out = replace( val = val sub = '.' with = ',' ).
  else.
    DATA: lv_wrbtr(10) TYPE p DECIMALS 2.
    lv_wrbtr = value_in.
    DIVIDE lv_wrbtr BY 100.
    value_out = |{ CONV fm_trbtr( lv_wrbtr ) SIGN = LEFT }|.
    value_out = replace( val = value_out sub = '.' with = ',' ).
  endif.


ENDFUNCTION.
