*"----------------------------------------------------------------------
* Gereon Koks  TSI  16.10.2024
* Stephan Scheithauer TSI 07.05.2025
*"----------------------------------------------------------------------
* Map IBAN
*"----------------------------------------------------------------------
* Input
* VALUE_IN  Bankregion (BANKS)
* VALUE_IN2 Bankschlüssel (BANKL)
* VALUE_IN3 Bankkontonummer (BANKN)

*"----------------------------------------------------------------------
* Output
* VALUE_OUT formatierte IBAN
*"----------------------------------------------------------------------
FUNCTION /thkr/aif_vmap_iban.
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
  DATA: lv_bank_account(12) TYPE c.
  DATA: lv_iban TYPE iban.
  IF value_in IS INITIAL AND value_in2 IS INITIAL AND value_in3 IS INITIAL.
    "Es wurde gar kein Feld geliefert.
    "es muss demnach auch keine IBAN berechent werden.
    "Bearbeitung verlassen.
    CLEAR: value_out.
  ELSE.
    IF value_in IS INITIAL OR value_in2 IS INITIAL OR value_in3 IS INITIAL.
      "Wenn eines der benötigen Felder leer ist, kann die IBAN nicht gebildet werden.
      CLEAR: value_out.
      IF 1 = 0. MESSAGE w071(/thkr/sst) WITH value_in value_in2 value_in3.ENDIF.
      APPEND VALUE bapiret2( type = 'W'
                              id = '/THKR/SST'
                              number = 71
                              message_v1 = value_in
                              message_v2 = value_in2
                              message_v3 = value_in3 ) TO return_tab.
    ELSE.
      lv_bank_account = value_in3.
      SHIFT lv_bank_account LEFT DELETING LEADING space.
      CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
        EXPORTING
          i_bank_account = lv_bank_account
          i_bank_country = CONV knbk_bf-banks( value_in )
          i_bank_number  = CONV bnka-bnklz( value_in2 )
          i_bank_key     = CONV bnka-bnklz( value_in2 )
        IMPORTING
          e_iban         = lv_iban
        EXCEPTIONS
          no_conversion  = 1
          OTHERS         = 2.
      IF sy-subrc = 0.
        IF lv_iban IS INITIAL.
          CLEAR: value_out.
          IF 1 = 0. MESSAGE w072(/thkr/sst) WITH value_in value_in2 value_in3.ENDIF.
          APPEND VALUE bapiret2( type = 'W'
                          id = '/THKR/SST'
                          number = 72
                          message_v1 = value_in
                          message_v2 = value_in2
                          message_v3 = value_in3 ) TO return_tab.
        ELSE.
          value_out = lv_iban.
        ENDIF.
      ELSE.
        CLEAR: value_out.
        IF 1 = 0. MESSAGE w072(/thkr/sst) WITH value_in value_in2 value_in3.ENDIF.
        APPEND VALUE bapiret2( type = 'W'
                        id = '/THKR/SST'
                        number = 72
                        message_v1 = value_in
                        message_v2 = value_in2
                        message_v3 = value_in3 ) TO return_tab.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFUNCTION.
