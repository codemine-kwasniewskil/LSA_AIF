FUNCTION /thkr/aif_vmap_pso_xml_kblart .
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
*"     REFERENCE(RAW_LINE) TYPE  KBLK
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_DE_PSO_XML_FILE
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  "Das Bankland wird benötigt. Das steht aber in der BSEC-Struktur, wo
  "man nicht ohne weiteres rankommt.
  TRY.
      DATA(lv_banks) = raw_struct-values-items[ key-belnr = raw_line-belnr key-blart = raw_line-blart ]-lt_pssec[ 1 ]-bsec-banks.

      value_out = /thkr/cl_pso_xml_processing=>get_instance( )->map_blart_for_mb(
                                                               iv_banks = lv_banks                 " Bank Länder-/Regionenschlüssel
                                                               iv_psoty = ''                 " Belegtypen Zahlungsanordnung Kommunen
                                                               iv_blart = raw_line-blart                 " Belegart
                                                             ).

    CATCH cx_sy_itab_line_not_found.
      "kein Bankland gefunden.
      "Also ohne Bankland Daten ermitteln
      value_out = /thkr/cl_pso_xml_processing=>get_instance( )->map_blart_for_mb(
                                                               iv_banks = lv_banks                 " Bank Länder-/Regionenschlüssel
                                                               iv_psoty = ''                 " Belegtypen Zahlungsanordnung Kommunen
                                                               iv_blart = raw_line-blart                 " Belegart
                                                             ).
  ENDTRY.
ENDFUNCTION.
