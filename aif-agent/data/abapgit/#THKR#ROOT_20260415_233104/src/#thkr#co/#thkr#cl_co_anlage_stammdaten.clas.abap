class /THKR/CL_CO_ANLAGE_STAMMDATEN definition
  public
  final
  create public .

public section.

  class-methods DATEI_EINLESEN
    importing
      value(I_DATEINAME) type STRING
      value(I_ART) type CHAR3
    exporting
      value(E_DATEN_KST) type /THKR/T_CO_SST_KST
      value(E_DATEN_AUF) type /THKR/T_CO_SST_AUF
      value(E_DATEN_STK) type /THKR/T_CO_SST_STK
      value(E_RC) type CHAR1 .
  class-methods KST_ANLEGEN
    importing
      value(I_DATEN_KST) type /THKR/T_CO_SST_KST
      value(I_SIMU) type CHAR1 .
  class-methods AUFTRAG_ANLEGEN
    importing
      value(I_DATEN_AUF) type /THKR/T_CO_SST_AUF
      value(I_SIMU) type CHAR1 .
  class-methods STK_ANLEGEN
    importing
      value(I_DATEN_STK) type /THKR/T_CO_SST_STK
      value(I_SIMU) type CHAR1 .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_CO_ANLAGE_STAMMDATEN IMPLEMENTATION.


  METHOD auftrag_anlegen.


    DATA: ls_auftrag     TYPE bapi2075_7,
          ls_auftrag_b   TYPE bapi2075_7b,
          ls_daten_auf   TYPE /thkr/co_sst_auftrag,
          lt_return      TYPE TABLE OF bapiret2,
          ls_return      TYPE bapiret2,
          lv_satznr      LIKE sy-tabix,
          lv_angelegt(1) TYPE c,
          ls_aufk        type aufk.

    LOOP AT i_daten_auf INTO ls_daten_auf.

      lv_satznr = sy-tabix.

      clear ls_aufk.

      ls_aufk-aufnr = ls_daten_auf-aufnr.
      ls_aufk-kokrs = ls_daten_auf-kokrs.
      ls_aufk-auart = ls_daten_auf-auftragsart.
      ls_aufk-gsber = ls_daten_auf-gsber.
      ls_aufk-bukrs = ls_daten_auf-bukrs.
      ls_aufk-prctr = ls_daten_auf-profitcenter.

*     prüfen, ob der User Innenaufträge anlegen darf
      CALL FUNCTION 'K_ORDER_AUTHORITY_CHECK'
        EXPORTING
          i_aufk              = ls_aufk
          i_actvt             = '01'
        EXCEPTIONS
          system_error        = 1
          user_not_authorized = 2
          OTHERS              = 3.

      IF sy-subrc <> 0.
        WRITE:/ 'Satz:', lv_satznr, '- Keine Berechtigung den Innenauftrag anzulegen' COLOR 6.
        CONTINUE.
      ENDIF.

      CLEAR: lt_return, ls_auftrag, ls_auftrag_b.

      ls_auftrag-order      = ls_daten_auf-aufnr.
      ls_auftrag-co_area    = ls_daten_auf-kokrs.
      ls_auftrag-order_type = ls_daten_auf-auftragsart.
      ls_auftrag-order_name = ls_daten_auf-beschreibung.
      ls_auftrag-comp_code  = ls_daten_auf-bukrs.
      ls_auftrag-bus_area   = ls_daten_auf-gsber.
      ls_auftrag-profit_ctr = ls_daten_auf-profitcenter.
      ls_auftrag-currency   = ls_daten_auf-waehrung.

*     Wert zum planintegriert Auftrag aus der Customizingeinstellung holen
      SELECT SINGLE plint FROM t003o INTO ls_auftrag_b-planintegrated
        WHERE auart = ls_daten_auf-auftragsart.

      CALL FUNCTION 'BAPI_INTERNALORDER_CREATE'
        EXPORTING
          i_master_data = ls_auftrag
          testrun       = i_simu
          i_master_datb = ls_auftrag_b
        TABLES
          return        = lt_return.


      LOOP AT lt_return INTO ls_return.

        IF ls_return-type = 'E'.
          WRITE:/ 'Satz:', lv_satznr, '-', ls_return-message(72) COLOR 6.
        ENDIF.
        IF ls_return-type = 'S' AND ls_return-id = 'KO' AND ls_return-number = '497'.
          WRITE:/ 'Satz:', lv_satznr, '-', ls_return-message(72) COLOR 5.
        ENDIF.
        IF ls_return-type = 'S' AND ls_return-id = 'KO' AND ls_return-number = '107'.
          WRITE:/ 'Satz:', lv_satznr, '-', ls_return-message(72) COLOR 5.
*          Auftrag wird unter der Nummer .... angelegt
          lv_angelegt = 'J'.
        ENDIF.


      ENDLOOP.

    ENDLOOP.

    IF i_simu = ' ' AND lv_angelegt = 'J'.
      COMMIT WORK AND WAIT.
    ENDIF.

  ENDMETHOD.


  METHOD datei_einlesen.

    DATA: lf_result TYPE c.

    DATA: lt_lines   TYPE string_t,
          lf_line    TYPE string,
          lf_linenum TYPE sy-index,
          lf_colnum  TYPE sy-index,
          lt_columns TYPE string_t,
          lf_column  TYPE string.

    DATA: ls_kst TYPE /thkr/co_sst_kst,
          ls_auf TYPE /thkr/co_sst_auftrag,
          ls_stk TYPE /thkr/co_sst_stk.

    " Check if file exists
    CALL METHOD cl_gui_frontend_services=>file_exist
      EXPORTING
        file                 = i_dateiname
      RECEIVING
        result               = lf_result
      EXCEPTIONS
        cntl_error           = 1
        error_no_gui         = 2
        wrong_parameter      = 3
        not_supported_by_gui = 4
        OTHERS               = 5.

    IF sy-subrc NE 0 OR lf_result NE abap_true.
      e_rc = '1'.
      EXIT.
    ENDIF.

    CALL METHOD cl_gui_frontend_services=>gui_upload
      EXPORTING
        filename = i_dateiname
      CHANGING
        data_tab = lt_lines.

    lf_linenum = 0.
    LOOP AT lt_lines INTO lf_line.

      lf_linenum = sy-tabix.

      CALL FUNCTION 'RSDS_CONVERT_CSV'
        EXPORTING
          i_data_sep       = ';'
          i_esc_char       = '"'
          i_record         = lf_line
          i_field_count    = 9999
        IMPORTING
          e_t_data         = lt_columns
        EXCEPTIONS
          escape_no_close  = 1
          escape_improper  = 2
          conversion_error = 3
          OTHERS           = 4.

      CASE i_art.
        WHEN 'KST'.
          CLEAR ls_kst.
          LOOP AT lt_columns INTO lf_column.
            CASE sy-tabix.
              WHEN 1.
                ls_kst-kokrs = lf_column.
              WHEN 2.
                ls_kst-kostenstelle = lf_column.
              WHEN 3.
                ls_kst-gueltig_von = lf_column.
              WHEN 4.
                ls_kst-gueltig_bis = lf_column.
              WHEN 5.
                ls_kst-bezeichnung = lf_column.
              WHEN 6.
                ls_kst-beschreibung = lf_column.
              WHEN 7.
                ls_kst-verantw = lf_column.
              WHEN 8.
                ls_kst-kst_art = lf_column.
              WHEN 9.
                ls_kst-hierarchie = lf_column.
              WHEN 10.
                ls_kst-bukrs = lf_column.
              WHEN 11.
                ls_kst-gsber = lf_column.
              WHEN 12.
                ls_kst-waehrung = lf_column.
              WHEN 13.
                ls_kst-profitcenter = lf_column.
*              WHEN 14.
*                ls_kst-verb_menge = lf_column.
*              WHEN 15.
*                ls_kst-priko_ist = lf_column.
*              WHEN 16.
*                ls_kst-priko_plan = lf_column.
*              WHEN 17.
*                ls_kst-sekko_ist = lf_column.
*              WHEN 18.
*                ls_kst-sekko_plan = lf_column.
*              WHEN 19.
*                ls_kst-erloese_ist = lf_column.
*              WHEN 21.
*                ls_kst-erloese_plan = lf_column.
*              WHEN 22.
*                ls_kst-obligo = lf_column.
              WHEN OTHERS.
            ENDCASE.

          ENDLOOP.

          IF ls_kst-kokrs CO '0123456789'.
            APPEND ls_kst TO e_daten_kst.
          ELSE.
*        Überschriftzeile oder Leerzeilen nicht übernehmen
          ENDIF.

        WHEN 'AUF'.
          CLEAR ls_auf.
          LOOP AT lt_columns INTO lf_column.
            CASE sy-tabix.
              WHEN 1.
                ls_auf-kokrs = lf_column.
              WHEN 2.
                ls_auf-aufnr = lf_column.
              WHEN 3.
                ls_auf-auftragsart = lf_column.
              WHEN 4.
                ls_auf-beschreibung = lf_column.
              WHEN 5.
                ls_auf-bukrs = lf_column.
              WHEN 6.
                ls_auf-gsber = lf_column.
              WHEN 7.
                ls_auf-Profitcenter = lf_column.
              WHEN 8.
                ls_auf-waehrung = lf_column.
              WHEN OTHERS.
            ENDCASE.
          ENDLOOP.

          IF ls_auf-kokrs CO '0123456789'.
            APPEND ls_auf TO e_daten_auf.
          ELSE.
*        Überschriftzeile oder Leerzeilen nicht übernehmen
          ENDIF.

        WHEN 'STK'.
          CLEAR ls_stk.
          LOOP AT lt_columns INTO lf_column.
            CASE sy-tabix.
              WHEN 1.
                ls_stk-kokrs = lf_column.
              WHEN 2.
                ls_stk-stat_kennzahlen = lf_column.
              WHEN 3.
                ls_stk-beschreibung = lf_column.
              WHEN 4.
                ls_stk-einheit = lf_column.
              WHEN 5.
                ls_stk-kennzahlentyp = lf_column.
              WHEN OTHERS.
            ENDCASE.

          ENDLOOP.

          IF ls_stk-kokrs CO '0123456789'.
            APPEND ls_stk TO e_daten_stk.
          ELSE.
*        Überschriftzeile oder Leerzeilen nicht übernehmen
          ENDIF.
        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.



  ENDMETHOD.


  METHOD kst_anlegen.

    DATA: lt_kst         TYPE TABLE OF bapi0012_ccinputlist,
          ls_kst         TYPE bapi0012_ccinputlist,
          ls_daten_kst   TYPE /thkr/co_sst_kst,
          lt_return      TYPE TABLE OF bapiret2,
          ls_return      TYPE bapiret2,
          lv_satznr      LIKE sy-tabix,
          lv_angelegt(1) TYPE c.

    LOOP AT i_daten_kst INTO ls_daten_kst.

      lv_satznr = sy-tabix.

*     prüfen, ob der User Kostenstellen anlegen darf
      CALL FUNCTION 'K_CSKS_AUTHORITY_CHECK'
       EXPORTING
         ACTVT                     = '01'
         KOKRS                     = ls_daten_kst-kokrs
         KOSTL                     = ls_daten_kst-kostenstelle
*       IMPORTING
*         E_OLD_RC                  =
*         E_NEW_RC                  =
       EXCEPTIONS
         SYSTEM_ERROR              = 1
         USER_NOT_AUTHORIZED       = 2
         OTHERS                    = 3
                .
      IF sy-subrc <> 0.
         WRITE:/ 'Satz:', lv_satznr, '- Keine Berechtigung die Kostenstelle anzulegen' COLOR 6.
         continue.
      ENDIF.

      CLEAR: lt_return, lt_kst, ls_kst.

      ls_kst-costcenter       = ls_daten_kst-kostenstelle.
      ls_kst-name             = ls_daten_kst-bezeichnung.
      ls_kst-descript         = ls_daten_kst-beschreibung.
      ls_kst-person_in_charge = ls_daten_kst-verantw.
      ls_kst-costcenter_type  = ls_daten_kst-kst_art.
      ls_kst-costctr_hier_grp = ls_daten_kst-hierarchie.
      ls_kst-comp_code        = ls_daten_kst-bukrs.
      ls_kst-bus_area         = ls_daten_kst-gsber.
      ls_kst-profit_ctr       = ls_daten_kst-profitcenter.
      ls_kst-currency         = ls_daten_kst-waehrung.

*     Sperren setzen
*      ls_kst-record_quantity               = ls_daten_kst-verb_menge.
*      ls_kst-lock_ind_actual_primary_costs = ls_daten_kst-priko_ist.
*      ls_kst-lock_ind_plan_primary_costs   = ls_daten_kst-priko_plan.
*      ls_kst-lock_ind_act_secondary_costs  = ls_daten_kst-sekko_ist.
*      ls_kst-lock_ind_plan_secondary_costs = ls_daten_kst-sekko_plan.
*      ls_kst-lock_ind_actual_revenues      = ls_daten_kst-erloese_ist.
*      ls_kst-lock_ind_plan_revenues        = ls_daten_kst-erloese_plan.
*      ls_kst-lock_ind_commitment_update    = ls_daten_kst-obligo.


      CONCATENATE ls_daten_kst-gueltig_von+6(4) ls_daten_kst-gueltig_von+3(2)
                  ls_daten_kst-gueltig_von(2)
             INTO ls_kst-valid_from.
      CONCATENATE ls_daten_kst-gueltig_bis+6(4) ls_daten_kst-gueltig_bis+3(2)
                   ls_daten_kst-gueltig_bis(2)
              INTO ls_kst-valid_to.

      APPEND ls_kst TO lt_kst.

      CALL FUNCTION 'BAPI_COSTCENTER_CREATEMULTIPLE'
        EXPORTING
          controllingarea = ls_daten_kst-kokrs
          testrun         = i_simu
        TABLES
          costcenterlist  = lt_kst
          return          = lt_return.

      LOOP AT lt_return INTO ls_return.
        IF ls_return-type = 'E'.
          WRITE:/ 'Satz:', lv_satznr, '-', ls_return-message(72) COLOR 6.
        ELSEIF i_simu       = 'X'  AND ls_return-type = 'S' AND
               ls_return-id = 'KW' AND ls_return-number = '150'.
          WRITE:/ 'Satz:', lv_satznr, '- Kein Fehler in der Simulation' COLOR 5.
        ENDIF.
      ENDLOOP.

      IF sy-subrc <> 0 AND i_simu = ' '.
*        Echtlauf und es ist keine Fehler aufgetreten
        WRITE:/ 'Satz:', lv_satznr, '- Kostenstelle', ls_daten_kst-kostenstelle,
                'wird angelegt' COLOR 5.
        lv_angelegt = 'J'.
      ENDIF.

    ENDLOOP.

    IF i_simu = ' ' AND lv_angelegt = 'J'.
      COMMIT WORK AND WAIT.
    ENDIF.



  ENDMETHOD.


  METHOD stk_anlegen.

    DATA: ls_stk         TYPE bapi1138_kfinputlist,
          lt_stk         TYPE TABLE OF bapi1138_kfinputlist,
          ls_daten_stk   TYPE /thkr/co_sst_stk,
          lt_return      TYPE TABLE OF bapiret2,
          ls_return      TYPE bapiret2,
          lv_satznr      LIKE sy-tabix,
          lv_angelegt(1) TYPE c.

    LOOP AT i_daten_stk INTO ls_daten_stk.

      lv_satznr = sy-tabix.

*     prüfen, ob der User stat. Kennzahlen anlegen darf
      CALL FUNCTION 'K_KA03_AUTHORITY_CHECK'
        EXPORTING
          actvt               = '02'
          kokrs               = ls_daten_stk-kokrs
        EXCEPTIONS
          system_error        = 1
          user_not_authorized = 2
          OTHERS              = 3.
      IF sy-subrc <> 0.
         WRITE:/ 'Satz:', lv_satznr, '- Keine Berechtigung die stat.Kennzahl anzulegen' COLOR 6.
         continue.
      ENDIF.

      CLEAR: lt_return, ls_stk, lt_stk.

*     Prüfung auf Kennzahlentyp
      IF ls_daten_stk-kennzahlentyp IS INITIAL.
        WRITE:/ 'Satz:', lv_satznr, '- Feld Kennzahltyp ist leer' COLOR 6.
        CONTINUE.
      ELSEIF ls_daten_stk-kennzahlentyp CN 'FS'.
        WRITE:/ 'Satz:', lv_satznr, '- Feld Kennzahltyp enthält falschen Wert' COLOR 6.
        CONTINUE.
      ENDIF.

*     Prüfung auf Einheit
      IF ls_daten_stk-einheit IS INITIAL.
        WRITE:/ 'Satz:', lv_satznr, '- Feld Einheit ist leer' COLOR 6.
        CONTINUE.
      ELSE.
        SELECT COUNT(*) FROM t006 WHERE msehi = ls_daten_stk-einheit.
        IF sy-subrc <> 0.
          WRITE:/ 'Satz:', lv_satznr, '- Feld Einheit enthält falschen Wert' COLOR 6.
          CONTINUE.
        ENDIF.
      ENDIF.

      ls_stk-statkeyfig = ls_daten_stk-stat_kennzahlen.
      ls_stk-name       = ls_daten_stk-beschreibung.
      ls_stk-unit       = ls_daten_stk-einheit.

      IF ls_daten_stk-Kennzahlentyp = 'F'.        "Festwert
        ls_stk-category = '1'.
      ELSEIF ls_daten_stk-Kennzahlentyp = 'S'.    "Summenwert
        ls_stk-category = '2'.
      ENDIF.

      APPEND ls_stk TO lt_stk.

      CALL FUNCTION 'BAPI_KEYFIGURE_CREATEMULTIPLE'
        EXPORTING
          coarea        = ls_daten_stk-kokrs
          testrun       = i_simu
        TABLES
          keyfigurelist = lt_stk
          return        = lt_return.




      LOOP AT lt_return INTO ls_return.
        IF ls_return-type = 'E'.
          WRITE:/ 'Satz:', lv_satznr, '-', ls_return-message(72) COLOR 6.
        ELSEIF i_simu       = 'X'  AND ls_return-type = 'S' AND
               ls_return-id = 'KW' AND ls_return-number = '150'.
          WRITE:/ 'Satz:', lv_satznr, '- Kein Fehler in der Simulation' COLOR 5.
        ENDIF.
      ENDLOOP.

      IF sy-subrc <> 0 AND i_simu = ' '.
*        Echtlauf und es ist keine Fehler aufgetreten
        WRITE:/ 'Satz:', lv_satznr, '- Stat.Kennzahl', ls_daten_stk-stat_kennzahlen,
                'wird angelegt' COLOR 5.
        lv_angelegt = 'J'.
      ENDIF.

    ENDLOOP.

    IF i_simu = ' ' AND lv_angelegt = 'J'.
      COMMIT WORK AND WAIT.
    ENDIF.




  ENDMETHOD.
ENDCLASS.
