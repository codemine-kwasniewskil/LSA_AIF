FUNCTION /THKR/AIF_VMAP_GENNR.
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
" VALUE_IN = Verfahren
  CLEAR value_out.
*"----------------------------------------------------------------------
DATA(lo_rueck) = new /THKR/CL_IF_INITIAL_CHECK( ).

"Generationsnummer aus Single-Index-Tabelle ermitteln
"In Single Index Tabelle werden AIF Nachrichten gespeichert.
value_out = |{ lo_rueck->gen_gen( i_verfahren = conv #( value_in ) ) ALPHA = IN WIDTH = 4 }| .
*"----------------------------------------------------------------------
ENDFUNCTION.
