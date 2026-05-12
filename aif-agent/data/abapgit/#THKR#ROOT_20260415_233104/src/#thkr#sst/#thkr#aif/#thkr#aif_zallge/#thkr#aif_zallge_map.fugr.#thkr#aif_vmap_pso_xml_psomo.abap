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
FUNCTION /thkr/aif_vmap_pso_xml_psomo .
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
*"     REFERENCE(RAW_LINE)
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  " VALUE_IN = Anordnungsnummer (LOTKZ)
  " VALUE_IN2 = Bankschlüssel (BANKL)
  " VALUE_IN3 = Kontonummer (BANKN)
  DATA: lv_anz TYPE i.
  LOOP AT raw_struct-values-items TRANSPORTING NO FIELDS WHERE key-lotkz = value_in
                                                           AND key-blart = value_in2.
    lv_anz += 1.
  ENDLOOP.
  value_out = lv_anz.
*"----------------------------------------------------------------------
ENDFUNCTION.
