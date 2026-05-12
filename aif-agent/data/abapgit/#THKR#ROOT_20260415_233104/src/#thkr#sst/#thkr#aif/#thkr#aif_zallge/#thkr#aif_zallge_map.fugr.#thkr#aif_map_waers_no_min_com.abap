FUNCTION /THKR/AIF_MAP_WAERS_NO_MIN_COM .
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
    DATA(val) = conv string( abs( value_in ) ).
    value_out = replace( val = val sub = '.' with = ',' ).
  else.
    DATA: lv_wrbtr(10) TYPE p DECIMALS 2.
    val = conv string( abs( value_in ) ).
    lv_wrbtr = val.
    DIVIDE lv_wrbtr BY 100.
    value_out = abs( lv_wrbtr ).
  endif.

ENDFUNCTION.
