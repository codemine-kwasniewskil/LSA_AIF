FUNCTION /thkr/aif_vmap_pso_xml_psoac .
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
  "VALUE_IN = Anordungsnummer (LOTKZ)
  "VALUE_IN2 = Belegnummer (BELNR)

  DATA: lv_begda TYPE begda.
  DATA: lv_endda TYPE endda.
  DATA: lv_sum   TYPE wrbtr.

  "Gesamtsumme der Ratenstundung
  LOOP AT raw_struct-values-items ASSIGNING FIELD-SYMBOL(<ls_item>) WHERE key-lotkz = value_in
                                                                      AND key-blart = value_in2.
    lv_sum += <ls_item>-lt_pso02[ 1 ]-wrbtr.
  ENDLOOP.

  value_out = lv_sum.
*"----------------------------------------------------------------------
ENDFUNCTION.
