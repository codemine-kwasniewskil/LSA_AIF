FUNCTION /thkr/aif_vmap_pso_xml_psoin .
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
  DATA: lv_begda TYPE begda.
  DATA: lv_endda TYPE endda.

  "Fälligkeit der ersten beiden Datensätze ermitteln, um die Differenz zu berechnen.
  "Anordnungnummer und Belegart werden dazu herangezogen.
  LOOP AT raw_struct-values-items ASSIGNING FIELD-SYMBOL(<ls_item>) WHERE key-lotkz = value_in
                                                                      AND key-blart = value_in2.
    CASE sy-tabix.
      WHEN: 1.
        lv_begda = <ls_item>-lt_pso02[ 1 ]-zfbdt.
      WHEN: 2.
        lv_endda = <ls_item>-lt_pso02[ 1 ]-zfbdt.
      WHEN: OTHERS.
        EXIT.
    ENDCASE.
  ENDLOOP.

  IF lv_endda IS INITIAL.
    "es gibt nur eine Rate.
    value_out = '1'.
  ELSE.
    "Differenz berechnen
    CALL FUNCTION 'MONTHS_BETWEEN_TWO_DATES'
      EXPORTING
        i_datum_bis = lv_endda
        i_datum_von = lv_begda
*       I_KZ_INCL_BIS       = ' '
      IMPORTING
        e_monate    = value_out.
  ENDIF.
*"----------------------------------------------------------------------
ENDFUNCTION.
