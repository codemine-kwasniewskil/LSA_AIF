FUNCTION /thkr/aif_vmap_pso_xml_bpext .
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
*"     REFERENCE(RAW_LINE) TYPE  ANY
*"     REFERENCE(RAW_STRUCT) TYPE  ANY
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------
  " VALUE_IN = PSOTY von Quelle
  " VALUE_IN2 = KUNNR
  " VALUE_IN3 = LIFNR
  " VALUE_IN4 = EMPFB
* Gereon Koks  4.2.2026  TSI
  " VALUE_IN5 = @BU_NAME1
*"----------------------------------------------------------------------
  DATA(lv_bpext) = COND bu_bpext( WHEN value_in2 IS INITIAL THEN value_in3
                                    ELSE value_in2 ) .
  DATA(lv_is_cpd) = /thkr/cl_pso_xml_processing=>get_instance( )->check_bp_is_cpd(
                                                                 EXPORTING
                                                                   iv_bpex   = lv_bpext                 " Geschäftspartnernummer im externen System
*                                                                IMPORTING
*                                                                  ev_is_cpd =                  " allgemeines flag
                                                               ).
  CASE lv_is_cpd.
    WHEN: abap_true.
      "Es handelt sich um einen CPD-Partner (Einmalzahler)
* Gereon Koks  4.2.2026  tsi

      ASSIGN COMPONENT 'BELNR' OF STRUCTURE raw_line TO FIELD-SYMBOL(<ls_belnr>).

      IF sy-subrc = 0.
        ASSIGN COMPONENT 'GJAHR' OF STRUCTURE raw_line TO FIELD-SYMBOL(<ls_gjahr>).
      ELSE.
* Dann BSEC lesen
        ASSIGN COMPONENT 'BSEC' OF STRUCTURE raw_line TO FIELD-SYMBOL(<ls_bsec>).

        IF sy-subrc = 0.
          ASSIGN COMPONENT 'BELNR' OF STRUCTURE <ls_bsec> TO <ls_belnr>.
          ASSIGN COMPONENT 'GJAHR' OF STRUCTURE <ls_bsec> TO <ls_gjahr>.
        ENDIF.
      ENDIF.

      value_out = /thkr/cl_pso_xml_processing=>get_instance( )->create_cpd_bpext_id(
                                                               iv_belnr = <ls_belnr>                 " Belegnummer eines Buchhaltungsbeleges
                                                               iv_gjahr = <ls_gjahr>                 " Geschäftsjahr
                                                             ).
    WHEN: abap_false.
      "Es handelt sich um einen normalen Geschäftspartner
      IF value_in4 IS INITIAL.
        CASE value_in.
          WHEN: '01'.              "Auszahlungsanordnung
            value_out = value_in3. "LIFNR
          WHEN: '02'.              "Annahmeanordnung
*"----------------------------------------------------------------------
            value_out = value_in2. "KUNNR
*"----------------------------------------------------------------------
          WHEN: '03'.              "Verrechnungsanordnung
            value_out = value_in3. "LIFNR
          WHEN: '04'.              "Auszahlungs-Absetzungsanordnung
            value_out = value_in3. "LIFNR
          WHEN: '05'.              "Annahme-Absetzungsanordnung
            value_out = value_in2. "KUNNR
          WHEN: '06'.              "Stundung
            value_out = value_in2. "KUNNR
          WHEN: OTHERS.
            CLEAR value_out.
        ENDCASE.
      ELSE.
        "abweichender Regulierer.
        value_out = value_in4.
      ENDIF.
  ENDCASE.
*"----------------------------------------------------------------------
ENDFUNCTION.
