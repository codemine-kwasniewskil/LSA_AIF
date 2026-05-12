*&---------------------------------------------------------------------*
*& /thkr/migrate_cash_balance.
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/migrate_cash_balance.

SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_kokrs TYPE kokrs OBLIGATORY DEFAULT '1000'.
  PARAMETERS: p_bukrs TYPE bukrs OBLIGATORY DEFAULT 'T999 '. "06.02.2025
  PARAMETERS p_budat TYPE datum DEFAULT '20241231'.
*  SELECT-OPTIONS: s_bukrs FOR p_bukrs NO INTERVALS.






  PARAMETERS: "p_pathl  TYPE ibipparms-path , "OBLIGATORY.

    p_in_dir TYPE string DEFAULT 'H:\LSA_Migrationsthemen',
    p_logja  TYPE xfeld DEFAULT 'X',
    p_logsin TYPE xfeld DEFAULT 'X', "alle erfolgreichen Einzelsätze ins log
    p_lognam TYPE string DEFAULT 'log_bestandssalden'.
SELECTION-SCREEN END OF BLOCK part1.




SELECTION-SCREEN BEGIN OF BLOCK part3 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_test  TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
  PARAMETERS: p_eonly  TYPE abap_bool AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK part3.
SELECTION-SCREEN BEGIN OF BLOCK part4 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN COMMENT /1(75) comm1.
  SELECTION-SCREEN COMMENT /1(75) comm5.
  SELECTION-SCREEN COMMENT /1(75) comm2.
  SELECTION-SCREEN COMMENT /1(75) comm3.
  SELECTION-SCREEN COMMENT /1(75) comm4.
SELECTION-SCREEN END OF BLOCK part4.
DATA: lt_file_table TYPE filetable.
DATA:lv_lin(5) TYPE n."(5)"i.



AT SELECTION-SCREEN OUTPUT.


START-OF-SELECTION.
*  DATA: sethier TYPE TABLE OF bapiset_hier.
  TYPES: lty_import_line(4096).
  DATA: bapiret TYPE bapiret2.
  DATA: lt_upload_table TYPE STANDARD TABLE OF lty_import_line.
  DATA: ls_upload_table TYPE  lty_import_line.

  DATA: lt_upload_table_conv TYPE TABLE OF /thkr/balance_import_list_raw.
  DATA: lt_upload_table_conv_balance TYPE TABLE OF  /thkr/balance_import_list_raw..
  DATA: ls_upload_table_conv_balance TYPE  /thkr/balance_import_list_raw..


*  beginn GP
  DATA: lt_upload_table_conv_kasse TYPE TABLE OF /thkr/gp_kasse_import_list_raw.
  DATA: ls_upload_table_conv TYPE /thkr/gp_import_list.
  DATA: lt_upload_table_conv_2 TYPE TABLE OF /thkr/gp_import_list.
  DATA: ls_upload_table_conv_2 TYPE /thkr/gp_import_list.


*>ende gp
  DATA: lt_file_table_n TYPE filetable."string.
  DATA: ls_file_table_n TYPE LINE OF filetable."string.
  DATA: lv_pathl TYPE string.
  DATA:   prestring TYPE string.
*        char1024."

  DATA filename_conv TYPE char256."rlgrap-filename.   "zu kurz

  DATA: lt_bp_deb_create TYPE TABLE OF  /thkr/s_dto_bp."/thkr/s_dto_bp_create.
  DATA: ls_bp_deb_create TYPE  /thkr/s_dto_bp_create.
  DATA: lv_BU_PARTNER_return TYPE bu_partner.
  DATA: lv_BU_PARTNER_export TYPE bu_partner .

  DATA: lt_DOCUMENTHEAD TYPE TABLE OF   bapiache09.
  DATA: ls_DOCUMENTHEAD TYPE   bapiache09.
  DATA: lt_buchungszeilen TYPE TABLE OF bapiacgl09.
  DATA: ls_buchungszeile_1 TYPE bapiacgl09.
  DATA: ls_buchungszeile_2 TYPE bapiacgl09.
  DATA: lt_betragszeilen TYPE TABLE OF  bapiaccr09.
  DATA: ls_betragszeile TYPE   bapiaccr09.

  DATA:lv_OBJ_TYPE LIKE  bapiache09-obj_type,
       lv_OBJ_KEY  LIKE  bapiache09-obj_key,
       lv_OBJ_SYS  LIKE  bapiache09-obj_sys
       .









  DATA: lv_rc TYPE i.
  DATA: lt_return_check TYPE TABLE OF   bapiret2.
  DATA: ls_return_check TYPE   bapiret2.
  FIELD-SYMBOLS  <fs_return_check> TYPE bapiret2.
  DATA: lt_return_post TYPE TABLE OF   bapiret2.
  DATA: ls_return_post TYPE   bapiret2.
  FIELD-SYMBOLS  <fs_return_post> TYPE bapiret2.
  DATA: ls_result TYPE string.
  DATA: lt_result          TYPE TABLE OF string,
        lv_timestring_conv TYPE string.


  ls_file_table_n-filename = p_in_dir.




  cl_gui_frontend_services=>file_open_dialog( EXPORTING window_title = 'Select a file'
                                                       default_filename =   p_in_dir        "value( DEFAULT_FILENAME )  TYPE STRING OPTIONAL  Vorschlagsdateiname
                                              CHANGING  file_table   =  lt_file_table_n
                                                        rc           = lv_rc ).

  TRY.

*      ).
      lv_pathl = lt_file_table_n[ 1 ]-filename.
*      lt_file_table_n-filename = p_pathl.
      filename_conv = lv_pathl.




*
      CALL METHOD cl_gui_frontend_services=>gui_upload
        EXPORTING
          filename = lv_pathl "lt_file_table[ 1 ]-filename "lt_file_table_n
          filetype = 'ASC'
        CHANGING
          data_tab = lt_upload_table
**
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ELSE.

      ENDIF.
*Kassensalden

      CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
        EXPORTING
          i_line_header        = 'X' "p_head
          i_tab_raw_data       = lt_upload_table " WORK TABLE
*         i_filename           = filename_conv
          i_filename_long      = filename_conv
        TABLES
          i_tab_converted_data = lt_upload_table_conv_balance[]  "ACTUAL DATA
        EXCEPTIONS
          conversion_failed    = 1
          OTHERS               = 2.


      BREAK-POINT.


*Protokollvorbereitung
      CASE p_logja.
        WHEN 'X'.
          OPEN DATASET p_lognam FOR APPENDING IN  TEXT MODE ENCODING DEFAULT.
          IF sy-subrc EQ 0.
            GET TIME STAMP FIELD DATA(lv_ts).
            CONVERT TIME STAMP lv_ts TIME ZONE 'CET' INTO TIME lv_timestring_conv .
            IF p_test IS INITIAL.
              CONCATENATE sy-datum lv_timestring_conv sy-uname     filename_conv INTO prestring SEPARATED BY '_'.
              TRANSFER prestring TO p_lognam.
            ELSE.
              CONCATENATE 'TESTmodus'  sy-datum lv_timestring_conv sy-uname     filename_conv INTO prestring SEPARATED BY '_'.
              TRANSFER prestring TO p_lognam.
            ENDIF.
          ENDIF.
      ENDCASE.

*saldenüberträge

      LOOP AT lt_upload_table_conv_balance INTO ls_upload_table_conv_balance.

*felder zuweisen



        ls_documenthead-obj_type = 'BKPFF'.
        ls_documenthead-username = sy-uname.
*         ls_documenthead-obj_key =
        ls_documenthead-obj_sys = sy-mandt.
        ls_documenthead-bus_act = 'RFBU'.
        ls_documenthead-comp_code ='1000'..
*ls_documenthead-hwaer = 'EUR'.
        ls_documenthead-ref_doc_no = ls_upload_table_conv_balance-referenz.
        ls_documenthead-pstng_date =  p_budat.
        ls_documenthead-doc_date =  p_budat.

        ls_documenthead-fisc_year = p_budat(4).
        ls_documenthead-doc_type = ls_upload_table_conv_balance-belegart.
        ls_documenthead-header_txt = ls_upload_table_conv_balance-text.
        ls_documenthead-comp_code = ls_upload_table_conv_balance-bu_kreis.
        ls_buchungszeile_1-itemno_acc = 1.
        ls_buchungszeile_1-item_text = ls_upload_table_conv_balance-text.
        ls_buchungszeile_1-gl_account = ls_upload_table_conv_balance-sachkonto.
        ls_buchungszeile_1-bus_area = ls_upload_table_conv_balance-ges_bereich.
        ls_buchungszeile_1-comp_code = ls_upload_table_conv_balance-bu_kreis.
        ls_buchungszeile_1-profit_ctr = ls_upload_table_conv_balance-profitcenter.
        ls_buchungszeile_1-segment = ls_upload_table_conv_balance-segment.
        ls_buchungszeile_1-cmmt_item = ls_upload_table_conv_balance-fipos.
        ls_buchungszeile_1-funds_ctr = ls_upload_table_conv_balance-fistl.
        ls_buchungszeile_1-fund = ls_upload_table_conv_balance-fonds.
        ls_buchungszeile_1-func_area = ls_upload_table_conv_balance-fkt_bereich.
        APPEND ls_buchungszeile_1 TO  lt_buchungszeilen.
        ls_buchungszeile_2-itemno_acc = 2.
        ls_buchungszeile_2-comp_code = ls_upload_table_conv_balance-bu_kreis2.
        ls_buchungszeile_2-item_text = ls_upload_table_conv_balance-text.
        ls_buchungszeile_2-GL_Account = ls_upload_table_conv_balance-sachkonto2.
        ls_buchungszeile_2-bus_area = ls_upload_table_conv_balance-ges_bereich2.
        ls_buchungszeile_2-comp_code = ls_upload_table_conv_balance-bu_kreis.
        ls_buchungszeile_2-profit_ctr = ls_upload_table_conv_balance-profitcenter2.
        ls_buchungszeile_2-segment = ls_upload_table_conv_balance-segment2.
        ls_buchungszeile_2-cmmt_item = ls_upload_table_conv_balance-fipos2.
        APPEND ls_buchungszeile_2 TO  lt_buchungszeilen.

        ls_Betragszeile-itemno_acc = 1.
        ls_Betragszeile-currency = 'EUR'.
        ls_Betragszeile-currency_iso = 'EUR'.
        ls_Betragszeile-amt_doccur = ls_upload_table_conv_balance-betrag.
        APPEND ls_betragszeile TO lt_betragszeilen.
        CLEAR ls_betragszeile.
        ls_Betragszeile-itemno_acc = 2.
        ls_Betragszeile-currency = 'EUR'.
        ls_Betragszeile-currency_iso = 'EUR'.
        ls_Betragszeile-amt_doccur = ls_upload_table_conv_balance-betrag2.
        APPEND ls_betragszeile TO lt_betragszeilen..
        CLEAR ls_betragszeile..



        CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
          EXPORTING
            documentheader = ls_documenthead
*           CUSTOMERCPD    =
*           CONTRACTHEADER =
          TABLES
            accountgl      = lt_buchungszeilen
            currencyamount = lt_betragszeilen
            return         = lt_return_check.

        ASSIGN  ls_return_check TO  <fs_return_check> .
        READ TABLE  lt_return_check INDEX 1 INTO <fs_return_check>.
        IF <fs_return_check>-type = 'S' AND <fs_return_check>-number = '614'.
*check ist erfolgreich durch gelaufen
          IF         p_test IS INITIAL. "echtmodus
            CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
              EXPORTING
                documentheader = ls_documenthead
*               CUSTOMERCPD    =
*               CONTRACTHEADER =
              IMPORTING
                obj_type       = lv_obj_type
                obj_key        = lv_obj_key
                obj_sys        = lv_obj_sys
              TABLES
                accountgl      = lt_buchungszeilen
                currencyamount = lt_betragszeilen
                return         = lt_return_post.

            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
              EXPORTING
                wait   = 'X'
              IMPORTING
                return = ls_return_post.

*Protokoll nach Buchung
            ASSIGN  ls_return_post TO  <fs_return_post> .
*            READ TABLE  lt_return_post INDEX 1 INTO <fs_return_post>.
            LOOP AT lt_return_post ASSIGNING <fs_return_post>.

              IF <fs_return_post>-type = 'S' AND <fs_return_post>-number = '605'.

                CONCATENATE'post_erfolgreich:-' ls_documenthead-header_txt <fs_return_post>-type  <fs_return_post>-number  <fs_return_post>-message INTO ls_result SEPARATED BY space.

              ELSE.   "gp <name> fehlerhaft
                CONCATENATE  ':  ' 'post_Fehler:- ' ls_documenthead-header_txt <fs_return_post>-type  <fs_return_post>-number  <fs_return_post>-message INTO ls_result SEPARATED BY space.


              ENDIF.
              APPEND ls_result TO lt_result.
            ENDLOOP.

          ELSE.  "p_test gesetzt Ckeck durchgelaufen

*            READ TABLE  lt_return_check INDEX 1 ASSIGNING FIELD-SYMBOL(<fs_return_ckeck>).
*            IF <fs_return_check>-type = 'S' AND <fs_return_check>-number = '614'. "check erfolgreich

            CONCATENATE'post_check_erfolgreich:-' ls_documenthead-header_txt <fs_return_check>-type  <fs_return_check>-number  <fs_return_check>-message INTO ls_result SEPARATED BY space.
            APPEND ls_result TO lt_result.

          ENDIF.
*



        ELSE.   "check nicht erfolgreich fehlerhaft
          LOOP AT lt_return_check ASSIGNING <fs_return_check>.
            CONCATENATE  ':  ' 'post_check_Fehler:- ' ls_documenthead-header_txt <fs_return_check>-type  <fs_return_check>-number  <fs_return_check>-message INTO ls_result SEPARATED BY space.
            APPEND ls_result TO lt_result.
          ENDLOOP.
        ENDIF.


**Ausgabe Testmoduns
*            ELSE. " p_test IS INITIAL.
**          CLEAR lx_root.
**          CONTINUE.
*              LOOP AT lt_return ASSIGNING <fs3_return>.
*                CONCATENATE  ':  ' 'post_check_Fehler:- ' ls_documenthead-header_txt <fs3_return>-type  <fs3_return>-number  <fs3_return>-message INTO ls_result SEPARATED BY space.
*                APPEND ls_result TO lt_result.
*              ENDLOOP.
*              CONTINUE.
*            ENDIF.  " p_test IS INITIAL.
*          ELSE.
**          CLEAR lx_root.
**          CONTINUE.
*            LOOP AT lt_return ASSIGNING <fs3_return>.
*              CONCATENATE  ':  ' 'post_check_Fehler:- ' ls_documenthead-header_txt <fs3_return>-type  <fs3_return>-number  <fs3_return>-message INTO ls_result SEPARATED BY space.
*              APPEND ls_result TO lt_result.
*            ENDLOOP.
*            CONTINUE.
*        ENDIF.

        CLEAR: lt_return_check, lt_return_post, lt_buchungszeilen, lt_betragszeilen .
      ENDLOOP.


      DELETE ADJACENT DUPLICATES FROM LT_result.
*  log fortschreiben

      LOOP AT  lt_result INTO ls_result. "lt_return2 INTO DATA(ls_return2).
        IF ls_result CS 'erfolgreich'.
          ADD 1 TO lv_lin.
          IF p_logsin NE space. " Einzelsätze ins log
            TRANSFER ls_result TO p_lognam."ls_et_return2 TO p_lognam.
          ENDIF.
        ELSE.
          TRANSFER ls_result TO p_lognam."ls_et_return2 TO p_lognam.
        ENDIF.
        CLEAR ls_result.
*      ENDLOOP.
        IF      p_logsin EQ space. " Einzelsätze ins log
          CONCATENATE 'Anzahl erfolgreich; ' lv_lin INTO prestring.
          TRANSFER prestring TO p_lognam.
        ENDIF.
*  log fortschreiben
*              TRANSFER '= = = = = = nächster Beleg = = = = =' TO p_lognam..
      ENDLOOP.
      GET TIME STAMP FIELD lv_ts.
      CONVERT TIME STAMP lv_ts TIME ZONE 'CET' INTO TIME lv_timestring_conv .

      CONCATENATE sy-datum lv_timestring_conv sy-uname filename_conv INTO prestring SEPARATED BY '_'.
      TRANSFER prestring TO p_lognam.

      TRANSFER '= = = = = = nächster L A U F = =  = = = = =  = =  =  = = = = =' TO p_lognam..
*        CATCH /thkr/cx_bp.
*      ENDTRY.


      CLOSE DATASET p_lognam.
      CLEAR lt_result.
  ENDTRY.
