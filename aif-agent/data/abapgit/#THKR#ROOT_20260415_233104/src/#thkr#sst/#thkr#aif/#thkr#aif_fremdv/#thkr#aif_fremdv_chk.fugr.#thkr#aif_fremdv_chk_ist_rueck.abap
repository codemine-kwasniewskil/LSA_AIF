*"----------------------------------------------------------------------
"Keine Verwendung mehr.
"CDS View hat sich geändert.
"Felder sollbetrag und offenerbetrag sind nicht mehr vorhanden.
"Keine Möglichkeit mehr zu unterscheiden, in welchen Fällen übertragen werden soll
FUNCTION /thkr/aif_fremdv_chk_ist_rueck .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(DATA_STRUCT)
*"     REFERENCE(DATA_LINE)
*"     REFERENCE(DATA_FIELD)
*"     REFERENCE(MSGTY) TYPE  SYMSGTY DEFAULT 'E'
*"     REFERENCE(VALUE1) TYPE  STRING
*"     REFERENCE(VALUE2) TYPE  STRING
*"     REFERENCE(VALUE3) TYPE  STRING
*"     REFERENCE(VALUE4) TYPE  STRING
*"     REFERENCE(VALUE5) TYPE  STRING
*"     REFERENCE(T_IFCHECK) TYPE  /AIF/T_IFCHECK OPTIONAL
*"     REFERENCE(T_IFACT) TYPE  /AIF/T_IFACT OPTIONAL
*"     REFERENCE(T_ACCHECK) TYPE  /AIF/T_ACCHECK OPTIONAL
*"     REFERENCE(T_FUNC) TYPE  /AIF/T_FUNC OPTIONAL
*"     REFERENCE(T_FMAPCOND) TYPE  /AIF/T_FMAPCOND OPTIONAL
*"     REFERENCE(T_CHECK) TYPE  /AIF/T_CHECK
*"     REFERENCE(T_TABCHK) TYPE  /AIF/T_TABCHK
*"     REFERENCE(SENDING_SYSTEM) TYPE  /AIF/AIF_BUSINESS_SYSTEM_KEY
*"       OPTIONAL
*"  TABLES
*"      RETURN_TAB STRUCTURE  BAPIRET2
*"      DATA_TABLE
*"  CHANGING
*"     REFERENCE(ERROR) TYPE  CHAR01
*"----------------------------------------------------------------------
  "VALUE1 = Sollbetrag
  "VALUE2 = gezahlter Betrag
  "VALUE3 = noch offener Betrag
  "VALUE4 = RESEND
  "VALUE5 = SST
  DATA: lc_rueck TYPE REF TO /thkr/cl_aif_rueck.
  DATA: lv_amount   TYPE fm_trbtr.
  DATA: lv_paid    TYPE fm_trbtr.
  DATA: lv_open     TYPE fm_trbtr.

  lv_amount = value1.
  lv_paid = value2.
  lv_open = value3.
  FIELD-SYMBOLS: <ls_data_line> TYPE /thkr/s_aif_raw_rueck.

  lc_rueck = NEW /thkr/cl_aif_rueck( ).
  ASSIGN data_line TO <ls_data_line>.
  TRY.
      "Wert für Art der Ist-Rückmeldung
      "Entweder aus AIF-Mappingtabelle oder wenn nicht vorhanden Standardwert (G)
      DATA(lv_ist_type) = lc_rueck->get_ist_type( iv_sst = CONV /thkr/dte_bu_sst( value5 ) ).
      CASE lv_ist_type.

        WHEN: 'N'.
          "nur nicht gezahlte Anordnungen
          IF lv_paid = '0.00'.
            error = lc_rueck->chk_record_should_be_sent(
                      iv_resend = CONV flag( value4 )                " allgemeines flag
                      iv_bukrs  = <ls_data_line>-bukrs                 " Buchungskreis
                      iv_gjahr  = <ls_data_line>-gjahr                 " Geschäftsjahr
                      iv_lotkz  = <ls_data_line>-lotkz                 " Bündelungskennzeichen für Belege
                      iv_belnr  = <ls_data_line>-belnr                 " Belegnummer eines Buchhaltungsbeleges
                      iv_gezahlt = lv_paid
                    ).
            "Delta-Logik ist in die CDS-View gewandert. Muss nicht mehr durch das AIF erfolgen.
*            error = abap_false.
          ELSE.
            error = abap_true.
          ENDIF.
        WHEN: 'T'.
          "teilweise gezahlte Anordnugnen
          "auch vollständig gezahlte Anordnungen
          IF ( lv_amount <> lv_paid AND lv_paid <> '0.00' ) OR          "Der Sollbetrag ist ungleich gezalter Betrag (Teilzahlung), Aber gezahlter Betrag darf nicht 0.00 sein.
          ( ( lv_amount = lv_paid AND lv_open = '0.00' ) AND                "Vollständig ausgeglichen
          ( lv_amount <> '0.00' AND  lv_paid <> '0.00' AND lv_open = '0.00' ) ). "alle Beträge sind leer. Uninteressant für Rückmeldung
            error = lc_rueck->chk_record_should_be_sent(
                              iv_resend = CONV flag( value4 )                " allgemeines flag
                              iv_bukrs  = <ls_data_line>-bukrs                 " Buchungskreis
                              iv_gjahr  = <ls_data_line>-gjahr                 " Geschäftsjahr
                              iv_lotkz  = <ls_data_line>-lotkz                 " Bündelungskennzeichen für Belege
                              iv_belnr  = <ls_data_line>-belnr                 " Belegnummer eines Buchhaltungsbeleges
                              iv_gezahlt = lv_paid
                            ).
            "Delta-Logik ist in die CDS-View gewandert. Muss nicht mehr durch das AIF erfolgen.
*            error = abap_false.
          ELSE.
            error = abap_true.
          ENDIF.
        WHEN: 'G'.
          "nur vollständig gezahlte Anordnungen
          IF lv_amount = lv_paid AND lv_open = '0.00'.
            error = lc_rueck->chk_record_should_be_sent(
                              iv_resend = CONV flag( value4 )                " allgemeines flag
                              iv_bukrs  = <ls_data_line>-bukrs                 " Buchungskreis
                              iv_gjahr  = <ls_data_line>-gjahr                 " Geschäftsjahr
                              iv_lotkz  = <ls_data_line>-lotkz                 " Bündelungskennzeichen für Belege
                              iv_belnr  = <ls_data_line>-belnr                 " Belegnummer eines Buchhaltungsbeleges
                              iv_gezahlt = lv_paid
                            ).
            "Delta-Logik ist in die CDS-View gewandert. Muss nicht mehr durch das AIF erfolgen.
*            error = abap_false.
          ELSE.
            error = abap_true.
          ENDIF.
        WHEN: 'A'.
          "Jegliche Form der Rückmeldung
          "nicht gezahlte Anordnungen
          "teilweise gezahlte Anordnungen
          "vollständig gezahlte Anordnungen
          error = lc_rueck->chk_record_should_be_sent(
                iv_resend = CONV flag( value4 )                " allgemeines flag
                iv_bukrs  = <ls_data_line>-bukrs                 " Buchungskreis
                iv_gjahr  = <ls_data_line>-gjahr                 " Geschäftsjahr
                iv_lotkz  = <ls_data_line>-lotkz                 " Bündelungskennzeichen für Belege
                iv_belnr  = <ls_data_line>-belnr                 " Belegnummer eines Buchhaltungsbeleges
                iv_gezahlt = lv_paid
              ).
          "Delta-Logik ist in die CDS-View gewandert. Muss nicht mehr durch das AIF erfolgen.
*          error = abap_false.
      ENDCASE.
    CATCH /thkr/cx_aif INTO DATA(lx_aif).
      error = abap_true.
  ENDTRY.

ENDFUNCTION.
