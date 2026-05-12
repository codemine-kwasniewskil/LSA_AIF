FUNCTION /thkr/aif_vmap_bankn.
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
  "Value_IN = 65_IBAN / BANKS
  "VALUE_IN2 = BANKN
  DATA: lv_bank_account TYPE bankn35.
  "Ermittlung der kontonumemr aus IBAN (ist für jedes Land anders)
  "Nur für ausländische IBAN relevant.
  "Inländische IBANs werden in der Internen Schnittselle korrekt verarbeitet.
  "WEnn aber BANKK gefüllt wird, müssen die Felder BANKS und BANKN separat gefüllt werden.
  TRY.
      IF value_in IS NOT INITIAL AND value_In(2) <> 'DE'.
*"----------------------------------------------------------------------
        IF /thkr/cl_aif_map=>get_instance( )->check_iban( iv_iban = CONV iban( value_in ) ) = abap_true.
          "VALUE_IN beinhaltet eine IBAN.
          "Ermittlung Kontonummer anhand IBAN
          value_out = /thkr/cl_aif_map=>get_instance( )->get_bankn_via_iban( iv_iban = CONV iban( value_in ) ).
        ELSE.
          "Es wurde keine IBAN übergeben, sondern das Bankland
          "Übergebe Bankkontonummer aus value_in2
          value_out = value_in2.
        ENDIF.
      ELSE.
        "Für inländische IBAN muss das Feld BANKN nicht gefüllt werden.
        CLEAR: value_out.
      ENDIF.
    CATCH cx_sy_range_out_of_bounds.
      CLEAR: value_out.
  ENDTRY.
*"----------------------------------------------------------------------
ENDFUNCTION.
