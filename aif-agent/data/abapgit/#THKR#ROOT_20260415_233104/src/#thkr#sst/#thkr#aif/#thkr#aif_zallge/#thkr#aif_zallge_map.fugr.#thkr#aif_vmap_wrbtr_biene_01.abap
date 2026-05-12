FUNCTION /thkr/aif_vmap_wrbtr_biene_01 .
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
*"     REFERENCE(RAW_LINE) TYPE  /THKR/S_AIF_BIC_ZEILE
*"     REFERENCE(RAW_STRUCT) TYPE  /THKR/S_AIF_BIC
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2 OPTIONAL
*"  CHANGING
*"     REFERENCE(VALUE_OUT) TYPE  STRING
*"  EXCEPTIONS
*"      NO_VALUE_FOUND
*"----------------------------------------------------------------------

  "Berechnung der Steuern für das Land
  "Abzug von Anteile von Bund und Kommune.
  DATA: lv_wrbtr(10) TYPE p DECIMALS 2.
  lv_wrbtr = abs( raw_line-15_betr1 ).
  IF /thkr/cl_biene_processing=>get_instance( )->check_vr_needed(
                                                iv_kapitel = conv ZNSI_KAPITEL( raw_line-10_kap )                " Haupt-Kapitel
                                                iv_titel   = raw_line-11_titel                 " PSM Fipos Titel ( Stellen 5-9 )
                                              ) = abap_false.
    LOOP AT raw_struct-line ASSIGNING FIELD-SYMBOL(<ls_line>) WHERE 11_titel(3) = raw_line-11_titel(3) .
      IF <ls_line>-11_titel+4(2) = '01'.
        "Betragszeile mit dem 100% Anteil
        CONTINUE.
      ELSE.
        "Andere Anteile -> Abziehen
        lv_wrbtr -= abs( <ls_line>-15_betr1 ).
      ENDIF.
    ENDLOOP.
  else.
    lv_wrbtr = /thkr/cl_biene_processing=>get_instance( )->calc_betr_with_percentage(
                                                          iv_kapitel = conv ZNSI_KAPITEL( raw_line-10_kap )                  " Haupt-Kapitel
                                                          iv_titel   = raw_line-11_titel                 " PSM Fipos Titel ( Stellen 5-9 )
                                                          iv_wrbtrg   = conv wrbtr( lv_wrbtr )                " Währungsbetrag
                                                        ).
  ENDIF.
  DIVIDE lv_wrbtr BY 100.
  value_out = abs( lv_wrbtr ).
*"----------------------------------------------------------------------
ENDFUNCTION.
