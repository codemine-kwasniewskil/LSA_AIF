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
FUNCTION /thkr/aif_vmap_txt_prot_kassz .
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
*"     REFERENCE(RAW_LINE) TYPE  /THKR/S_DE_PSO_XML
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  CLEAR value_out.
  TRY.
      value_out = raw_line-lt_pso02[ lotkz = raw_line-key-lotkz belnr = raw_line-key-belnr gjahr = raw_line-key-gjahr ]-xblnr.
    CATCH cx_sy_itab_line_not_found.
      TRY.
          value_out = raw_line-lt_kblk[ lotkz = raw_line-key-lotkz belnr = raw_line-key-belnr ]-xblnr.
        CATCH cx_sy_itab_line_not_found.
          "Es kann weder ein Kassenzeichen zur Anordnung noch zur Mittelbindung gefunden werden.
          "Feld leer lassen.
          CLEAR value_out.
      ENDTRY.
  ENDTRY.
*"----------------------------------------------------------------------
ENDFUNCTION.
