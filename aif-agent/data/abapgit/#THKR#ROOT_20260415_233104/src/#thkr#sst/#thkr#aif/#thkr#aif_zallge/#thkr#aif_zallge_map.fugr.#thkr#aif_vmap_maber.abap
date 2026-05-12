FUNCTION /THKR/AIF_VMAP_MABER .
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
  "VALUE_IN = AIF-Namensraum für Wertemapping
  "VALUE_IN2 = AIF-Wertemapping
  "VALUE_IN3 = Mahnbereich

   SELECT single INT_VALUE
     FROM /AIF/T_VMAPVAL
    WHERE ns = @value_in
     AND vmapname = @value_in2
     AND ext_value = @value_in3
     INTO @DATA(lv_maber).
     if sy-subrc = 0.
       value_out = lv_maber.
     else.
       value_out = value_in3.
     endif.

*"----------------------------------------------------------------------
ENDFUNCTION.
