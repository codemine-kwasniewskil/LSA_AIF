FUNCTION /thkr/aif_zallge_chk_ausao_ref .
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
*"      DATA_TABLE TYPE  /THKR/T_DTO_PSM_AO_BEL_CREATE
*"  CHANGING
*"     REFERENCE(ERROR) TYPE  CHAR01
*"----------------------------------------------------------------------

  "Aktionsprüfung vor AO-Anlage (/THKR/AIF_ZALLGE_ACT_AO).
  "Prüfung, ob eine Annahmeanordnung mithilfe einer allgeimenen Annnahmeanordnung erstellt werden konnte
  "Wenn eine Annahmeanordnung erzeugt werden konnte, wird in dem Feld XBLNR der Auszahlungsanordnung das
  "neue Kassenzeichen eingetragen.

  "VALUE1 = PSOTY
  "VALUE2 = ZSCHL
  "VALUE3 = XBLNR
  "Value4 = BKTXT
  FIELD-SYMBOLS <ls_data> TYPE /thkr/s_aif_sap.
  FIELD-SYMBOLS <ls_data_line> TYPE /thkr/s_aif_sap_ao.

  ASSIGN data_struct TO <ls_data>.
  ASSIGN data_line TO <ls_data_line>.

  "Datenzeile aus Zielstrukur ermitteln.
  "Datenzeile = Importparameter, darf nicht geändert werden
  "Daher Zeile aus Zielstruktur ermitteln um Fehlermeldung anzuhängen.
  READ TABLE data_table WITH KEY glblid = <ls_data_line>-glblid ASSIGNING FIELD-SYMBOL(<ls_ao>).
  IF sy-subrc = 0.
    CASE value1.
      WHEN: 01. "Auszahlungsanordnung
        IF value2 = 'X'. "Zahlweg -> X = Referenz auf Einnahmesollstellung

          "Prüfen, ob bei der Anlage der Annahmeanordnung Fehler entstanden sind.
          READ TABLE <ls_data>-ao WITH KEY psoty = '02'
                                           xblnr =  value4
                                  ASSIGNING FIELD-SYMBOL(<ls_annao>).
          IF sy-subrc = 0.
            "Wenn die Annahmeanordnung auf Fehler läuft, wird das Feld XBLNR ebenfalls nicht gefüllt.
            "Aber es kann dennoch eine allgeimeine Annahmeanordnung existieren
            "Daher anderen Fehler erzeugen, um Irritationen zu vermeiden.
            IF <ls_annao>-ao_proc_status = 'E'.
              IF 1 = 0. MESSAGE e015(/thkr/sst). ENDIF.
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                       type = 'E'
                                       number = 015 ) TO return_tab[].
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                       type = 'E'
                                       number = 015 ) TO <ls_ao>-msg.


              "Prüfung, ob es eine allg. Annordnung gibt.
              SELECT SINGLE belnr
                FROM kblk
               WHERE xblnr = @<ls_annao>-bktxt
                INTO @DATA(lv_belnr).
              IF sy-subrc = 0.
                "Es wurde keine Annahmeanordung erzeugt. Allerdings gibt es eine Allg. Annahmeanordnung im System.
                IF 1 = 0. MESSAGE e058(/thkr/sst) WITH lv_belnr value4. ENDIF.
                APPEND VALUE bapiret2( id = '/THKR/SST'
                                       type = 'E'
                                       number = 058
                                       message_v1 = lv_belnr
                                       message_v2 = value4 ) TO return_tab[].
                APPEND VALUE bapiret2( id = '/THKR/SST'
                                       type = 'E'
                                       number = 058
                                       message_v1 = lv_belnr
                                       message_v2 = value4 ) TO <ls_ao>-msg.
              ELSE.
                "Es konnte keine Allg. Annahmeanordnung im SAP gefunden werden.
                IF 1 = 0. MESSAGE e014(/thkr/sst). ENDIF.
                APPEND VALUE bapiret2( id = '/THKR/SST'
                                       type = 'E'
                                       number = 014
                                       message_v1 = value4 ) TO return_tab[].
                APPEND VALUE bapiret2( id = '/THKR/SST'
                                       type = 'E'
                                       number = 014
                                       message_v1 = value4 ) TO <ls_ao>-msg.
              ENDIF.
              error = abap_true.
            ELSE.
              error = abap_false.
            ENDIF.
          ELSE.
            "Es gibt zu dem Referenzkassenzeichen keine Annahmeanordnung.
            error = abap_true.
            "Prüfung, ob es eine allg. Annordnung gibt.
            SELECT SINGLE belnr
              FROM kblk
             WHERE xblnr = @value4
              INTO @lv_belnr.
            IF sy-subrc = 0.
              "Es wurde keine Annahmeanordung erzeugt. Allerdings gibt es eine Allg. Annahmeanordnung im System.
              IF 1 = 0. MESSAGE e058(/thkr/sst) WITH lv_belnr value4. ENDIF.
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                     type = 'E'
                                     number = 058
                                     message_v1 = lv_belnr
                                     message_v2 = value4 ) TO return_tab[].
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                     type = 'E'
                                     number = 058
                                     message_v1 = lv_belnr
                                     message_v2 = value4 ) TO <ls_ao>-msg.
            ELSE.
              "Es konnte keine Allg. Annahmeanordnung im SAP gefunden werden.
              IF 1 = 0. MESSAGE e014(/thkr/sst). ENDIF.
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                     type = 'E'
                                     number = 014
                                     message_v1 = value4 ) TO return_tab[].
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                     type = 'E'
                                     number = 014
                                     message_v1 = value4 ) TO <ls_ao>-msg.
            ENDIF.
          ENDIF.
        ELSE.
          error = abap_false.
        ENDIF.
      WHEN: 02. "Annahmeanordnungen (Dreiteilung bei BIENE)
        IF <ls_data_line>-annao_ref_zhlwg_x IS NOT INITIAL.
          "Prüfen, ob bei der Anlage der Annahme- oder Auszahlungsanordnung Fehler entstanden sind.
          READ TABLE <ls_data>-ao WITH KEY xblnr =  value4
                                  ASSIGNING FIELD-SYMBOL(<ls_ref_ao>).
          IF sy-subrc = 0.
            IF <ls_ref_ao>-ao_proc_status = 'E'.
              "Fehler beim Anlegen der referenzierten Anorndung.
              IF 1 = 0. MESSAGE e015(/thkr/sst). ENDIF.
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                       type = 'E'
                                       number = 015 ) TO return_tab[].
              APPEND VALUE bapiret2( id = '/THKR/SST'
                                       type = 'E'
                                       number = 015 ) TO <ls_ao>-msg.


              "Prüfung, ob es eine allg. Annordnung gibt.
              SELECT SINGLE belnr
                FROM kblk
               WHERE xblnr = @<ls_ref_ao>-bktxt
                INTO @lv_belnr.
              IF sy-subrc = 0.
                "Es wurde keine Annahmeanordung erzeugt. Allerdings gibt es eine Allg. Annahmeanordnung im System.
                IF 1 = 0. MESSAGE e058(/thkr/sst) WITH lv_belnr value4. ENDIF.
                APPEND VALUE bapiret2( id = '/THKR/SST'
                                       type = 'E'
                                       number = 058
                                       message_v1 = lv_belnr
                                       message_v2 = value4 ) TO return_tab[].
                APPEND VALUE bapiret2( id = '/THKR/SST'
                                       type = 'E'
                                       number = 058
                                       message_v1 = lv_belnr
                                       message_v2 = value4 ) TO <ls_ao>-msg.
              ENDIF.
            ENDIF.
          ENDIF.
        ELSE.
          error = abap_false.
        ENDIF.
      WHEN: OTHERS.
        error = abap_false.
    ENDCASE.
  ELSE.
    error = abap_false.
  ENDIF.

ENDFUNCTION.
