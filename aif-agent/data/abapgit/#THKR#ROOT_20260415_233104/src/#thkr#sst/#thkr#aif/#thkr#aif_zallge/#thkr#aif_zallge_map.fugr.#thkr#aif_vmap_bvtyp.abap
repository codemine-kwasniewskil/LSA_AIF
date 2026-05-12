FUNCTION /thkr/aif_vmap_bvtyp.
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
  " Value_in = partner-ID
  " value_in2 = IBAN / BANKS
  " value_in3 = BANKL / 25_BVNR
  " value_in4 = BANKN / AO_BU_TYPE Geschäftspartnertyp
  " value_in5 = AO_BPEXT externe Parnternummer
  " value_out = BKVID

  CONSTANTS lc_bkvid_0001 TYPE bu_bkvid VALUE '0001'.

  CLEAR value_out.

  "Prüfung ob IBAN oder BANKS im VALUE_IN3 Feld
  IF value_in2 IS NOT INITIAL AND strlen( value_in2 ) > 3.
    "IBAN

    "IBAN prüfen,
    "Wenn die IBAN korrekt ist, den Bankverbindungstyp ermitteln
    "IBAN wird in diesem Fall auch beim Geschäfspartner hinterlegt.
    CALL FUNCTION 'CHECK_IBAN'
      EXPORTING
        i_iban        = CONV iban( value_in2 )
*       I_MOD97_CHECK_ONLY       =
        i_accept_gaps = 'X'
      EXCEPTIONS
        not_valid     = 1
        OTHERS        = 2.
    IF sy-subrc = 0.
      value_out = /thkr/cl_aif_map=>get_instance( )->get_bvtyp_by_iban(
                                                    iv_partner = CONV bu_partner( value_in )               " Geschäftspartnernummer
                                                    iv_bpext   = conv bu_bpext( value_in5 )                " Geschäftspartnernummer im externen System
                                                    iv_iban    = CONV iban( value_in2 )                    " IBAN (International Bank Account Number)
                                                  ).
    ELSE.
      IF 1 = 0. MESSAGE w009(bf00) WITH value_in2.ENDIF.
      APPEND VALUE bapiret2( id = 'BF00'
                             number = 009
                             type = 'W'
                             message_v1 = value_in2 ) TO return_tab[].
    ENDIF.
  ELSEIF value_in2 IS NOT INITIAL AND value_in3 IS NOT INITIAL AND value_in4 IS NOT INITIAL.
    " Es wurde keine IBAN übergeben
    "Aber Bankregion, Bankschlüssel und Kontonummer
    value_out = /thkr/cl_aif_map=>get_instance( )->get_bvtyp_by_banks_bankn_bankk(
                                                  iv_partner = CONV bu_partner( value_in )                 " Geschäftspartnernummer
                                                  iv_banks   = CONV banks( value_in2 )                " Bank Länder-/Regionenschlüssel
                                                  iv_bankl   = CONV bankk( value_in3 )                 " Bankschlüssel
                                                  iv_bankn   = CONV bankn35( value_in4 )                 " Bankkontonummer
                                                  iv_bpext   = conv bu_bpext( value_in5 )
                                                ).
  elseif value_in is not INITIAL and value_in2 is INITIAL.
    "Geschäftspartner bekannt, keine IBAN in der Datei
    "verwende Bankverbindungstyp aus Datei.
    value_out = /thkr/cl_aif_map=>get_instance( )->get_bvtyp_from_partner( iv_partner = conv BU_PARTNER( value_in )
                                                                           iv_bvnr = conv BVTYP( |{ value_in3 ALPHA = In WIDTH = 4 }| ) ).
  ENDIF.
  ENDFUNCTION.
