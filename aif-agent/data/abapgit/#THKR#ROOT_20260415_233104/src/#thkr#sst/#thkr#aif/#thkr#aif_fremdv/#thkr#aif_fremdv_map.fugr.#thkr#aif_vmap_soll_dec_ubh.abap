FUNCTION /THKR/AIF_VMAP_SOLL_DEC_UBH.
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
"Reduziere Dezimalstellen.
  if value_in < 0.
    DATA(lv_sign) = '-'.
  else.
    CLEAR lv_sign.
  endif.
find ALL OCCURRENCES OF '.' IN VALUE_In MATCH OFFSET DATA(lv_off).
lv_off = lv_off + 1 + value_in2. "lv_off = die letzte Stelle eines Punktes; 1 = die Stelle des letzen Punktes selbst; value_in2 = Anzahl der gewünschten Dezimalstellen
value_out = |{ value_in(lv_off) }{ lv_sign }|.
*"----------------------------------------------------------------------
ENDFUNCTION.
