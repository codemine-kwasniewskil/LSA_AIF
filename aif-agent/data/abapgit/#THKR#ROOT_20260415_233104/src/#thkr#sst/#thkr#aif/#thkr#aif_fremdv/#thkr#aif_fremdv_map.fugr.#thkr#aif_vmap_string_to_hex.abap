*"----------------------------------------------------------------------
* Gereon Koks  TSI  15.10.2024
*"----------------------------------------------------------------------
* Map AD_STREET
*"----------------------------------------------------------------------
* Housenumber is taken out of the field and returned
* because housenumber belongs to ADDR1_DATA-HOUSE_NUM1 (SAP)
* and not to ADDR1_DATA-STREET (SAP)
*"----------------------------------------------------------------------
* Input
* VALUE_IN  39 inpres5
* VALUE_IN2
* VALUE_IN3
* VALUE_IN4
* VALUE_IN5
*"----------------------------------------------------------------------
* Output
* VALUE_OUT AD_HSNM1
*"----------------------------------------------------------------------
FUNCTION /THKR/AIF_VMAP_STRING_TO_HEX.
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
  CLEAR value_out.
*"----------------------------------------------------------------------
  "VALUE_in = String für HEX Konvertierung

    DATA: lv_ascii TYPE x.
    DATA: lo_ascii_con TYPE REF TO cl_abap_conv_in_ce.

      lv_ascii = value_in.
      lo_ascii_con = cl_abap_conv_in_ce=>create( encoding = 'UTF-8' ).
      lo_ascii_con->convert(
        EXPORTING
          input           =  lv_ascii                " Zu konvertierende Bytefolge
*          n               = -1               " Anzahl einzulesender Einheiten
        IMPORTING
          data            = value_out                 " Zu füllendes Feld
*          len             =                  " Anzahl konvertierter Einheiten
*          input_too_short =                  " Eingabepuffer war zu kurz
      ).
*"----------------------------------------------------------------------
ENDFUNCTION.
