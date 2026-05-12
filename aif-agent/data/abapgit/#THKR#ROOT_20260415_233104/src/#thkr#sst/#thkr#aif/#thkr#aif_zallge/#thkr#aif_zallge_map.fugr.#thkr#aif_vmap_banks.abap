FUNCTION /thkr/aif_vmap_banks.
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
  "Value_IN = 65_IBAN

  "Ermittlung des Banklandes aus IBAN
  "Nur für ausländische IBAN relevant.
  "Inländische IBANs werden in der Internen Schnittselle korrekt verarbeitet.
  "Wenn aber BANKK gefüllt wird, müssen die Felder BANKS und BANKN separat gefüllt werden.
  TRY.
      IF value_in IS NOT INITIAL AND value_In(2) <> 'DE'.
*"----------------------------------------------------------------------
        value_out = value_in(2).
      ELSE.
        CLEAR: value_out.
      ENDIF.
    CATCH cx_sy_range_out_of_bounds.
      CLEAR: value_out.
  ENDTRY.
*"----------------------------------------------------------------------
ENDFUNCTION.
