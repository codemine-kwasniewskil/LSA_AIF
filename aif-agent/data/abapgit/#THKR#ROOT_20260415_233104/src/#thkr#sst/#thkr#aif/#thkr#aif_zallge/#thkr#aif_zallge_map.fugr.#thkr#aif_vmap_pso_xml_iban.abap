*"----------------------------------------------------------------------
* Gereon Koks  TSI  7.11.2024
*"----------------------------------------------------------------------
* Map WRBTR
* Komma-Behandlung
*"----------------------------------------------------------------------
* Input
* VALUE_IN  15_BETR1
* VALUE_IN2
* VALUE_IN3
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT BUDAT
*"----------------------------------------------------------------------
FUNCTION /THKR/AIF_VMAP_PSO_XML_IBAN .
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
*"     REFERENCE(RAW_LINE)
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"--------------------------------------------------------------------
 " VALUE_IN = Bankland (BANKS)
 " VALUE_IN2 = Bankschlüssel (BANKL)
 " VALUE_IN3 = Kontonummer (BANKN)
CALL FUNCTION 'CONVERT_BANK_ACCOUNT_2_IBAN'
  EXPORTING
    i_bank_account           = value_in3
*   I_BANK_CONTROL_KEY       = ' '
    i_bank_country           = value_in
    i_bank_number            = value_in2
    i_bank_key               = value_in2
 IMPORTING
   E_IBAN                   = value_out
 EXCEPTIONS
   NO_CONVERSION            = 1
   OTHERS                   = 2
          .
 if sy-subrc <> 0.
   CLEAR value_out.
 endif.
*"----------------------------------------------------------------------
ENDFUNCTION.
