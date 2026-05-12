FUNCTION /thkr/aif_vmap_bankk.
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
  "VALUE_IN = 63_BIC / BANKK
  "VALUE_IN2 = 65_IBAN / BANKS

  "in der BNKA Tabelle sind die Stammdaten gepflegt
  "für ausländische Banken wird der Bankenschlüssel aus dem
  "Swift-Code ohne die endenen Xs gespeichert. Für Deuschte Banken wird die Bankleitzahl verwendet.
  "Ableitung aus IBAN in interner SChnittstelle.
  "Deshalb ist das Feld nur interessant, wenn eine ausländische oder keine IBAN verwendet wird.
*"----------------------------------------------------------------------
  IF value_in2 IS NOT INITIAL AND value_in2(2) <> 'DE'.

    "es handelt sich um keine IBAN, verwende BANKK
    "ausländische iban -> Verwende Swift-Code ohne XXX am Ende
    Value_out = cond bankk( WHEN /thkr/cl_aif_map=>get_instance( )->check_iban( iv_iban = conv iban( value_in2 ) ) = abap_true then replace( val = value_in sub = 'XXX'  with = ''  )
                            else value_in ).

  ELSE.
    "Feld BANKK wird nicht benötigt. Leeren
    CLEAR: value_out.

  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
