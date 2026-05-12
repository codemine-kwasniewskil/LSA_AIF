FUNCTION /THKR/AIF_VMAP_SKNW_IS_PAID.
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
  CLEAR value_out.
*"----------------------------------------------------------------------
  "VALUE_in  = Sollbetrag
  "VALUE_IN2 = gezahlt
  "VALUE_IN3 = offen



if value_in = value_in2 and value_in3 = '0.00'. "vollständig gezahlt
  value_out = 'true'.
elseif value_in <> value_in2 and value_in2 <> '0.00'. "teilweise gezahlt
  value_out = 'true'.
elseif value_in = value_in3 and value_in2 = '0.00'. "nicht gezahlt
  value_out = 'false'.
endif.
*"----------------------------------------------------------------------
ENDFUNCTION.
