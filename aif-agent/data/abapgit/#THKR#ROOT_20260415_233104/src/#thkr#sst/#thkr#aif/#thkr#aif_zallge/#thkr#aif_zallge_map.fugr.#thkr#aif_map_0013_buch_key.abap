FUNCTION /THKR/AIF_MAP_0013_BUCH_KEY .
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
  "VALUE_IN = Kassenzeichen
  CLEAR value_out.
  CHECK strlen( value_in ) > 11.
  "** Need to declare afterwards
  "*10- Isteingang ; 20- Isteingang per Umbuchung ; 30- Umbuchung Nebenforderung ; 40- Sonstiges
  "** Setting 10 fixed
  data(val) = '10'.

  CASE value_in+11(1).
    WHEN '-'.
      value_out = '210'.
    WHEN 'S'.
      value_out = '220'.
    WHEN 'Z'.
      value_out = '230'.
    WHEN OTHERS.
  ENDCASE.

  value_out = value_out && val.

ENDFUNCTION.
