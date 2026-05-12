*&---------------------------------------------------------------------*
*& Report /THKR/MIGRATE_partners
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/migrate_partners.

************************************************************************
* Selektion - Screen                                                   *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK part1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_kokrs    TYPE kokrs OBLIGATORY DEFAULT '1000'.
  PARAMETERS: p_bukrs    TYPE bukrs OBLIGATORY DEFAULT 'T999 '. "06.02.2025
  SELECT-OPTIONS: s_bukrs FOR p_bukrs NO INTERVALS.

  PARAMETERS: "p_pathl  TYPE ibipparms-path , "OBLIGATORY.
    p_in_dir TYPE string DEFAULT 'H:\LSA_Migrationsthemen',
    p_logja  TYPE xfeld  DEFAULT 'X',
    p_logsin TYPE xfeld  DEFAULT 'X', "alle erfolgreichen Einzelsätze ins log
    p_lognam TYPE string DEFAULT 'log_geschaeftspartner'.
SELECTION-SCREEN END OF BLOCK part1.

SELECTION-SCREEN BEGIN OF BLOCK part2 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN : BEGIN OF LINE.
    PARAMETERS: p_GP_Kas RADIOBUTTON GROUP rbg2 DEFAULT 'X'.
    SELECTION-SCREEN COMMENT 03(10) TEXT-s13.
    SELECTION-SCREEN POSITION 15.
    PARAMETERS: p_GP_all RADIOBUTTON GROUP rbg2.
    SELECTION-SCREEN COMMENT 17(10) TEXT-s14.
  SELECTION-SCREEN : END OF LINE.

*  SELECTION-SCREEN : BEGIN OF LINE.
*    PARAMETERS: p_kst RADIOBUTTON GROUP rbg DEFAULT 'X'.
*    SELECTION-SCREEN COMMENT 03(10) TEXT-s11.
*    SELECTION-SCREEN POSITION 15.
*    PARAMETERS: p_ua RADIOBUTTON GROUP rbg.
*    SELECTION-SCREEN COMMENT 17(10) TEXT-s12.
*  SELECTION-SCREEN : END OF LINE.
SELECTION-SCREEN END OF BLOCK part2.

SELECTION-SCREEN BEGIN OF BLOCK part3 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_test   TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
  PARAMETERS: p_eonly  TYPE abap_bool AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK part3.
SELECTION-SCREEN BEGIN OF BLOCK part4 WITH FRAME TITLE TEXT-001.
  SELECTION-SCREEN COMMENT /1(75) comm1.
  SELECTION-SCREEN COMMENT /1(75) comm5.
  SELECTION-SCREEN COMMENT /1(75) comm2.
  SELECTION-SCREEN COMMENT /1(75) comm3.
  SELECTION-SCREEN COMMENT /1(75) comm4.
SELECTION-SCREEN END OF BLOCK part4.

************************************************************************
* Globale Variable                                                     *
************************************************************************
DATA: lt_file_table TYPE filetable.
DATA: lv_lin(5) TYPE n."(5)"i.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_pathl.
*  DATA: lv_rc TYPE i.


*  IF lv_rc <> -1.
*
*    TRY.
*        p_pathl = lt_file_table[ 1 ]-filename .
*      CATCH cx_sy_itab_line_not_found.
*        MESSAGE i001(/thkr/fi_init) DISPLAY LIKE 'E'.
*        EXIT.
*    ENDTRY.
*  ENDIF.

*AT SELECTION-SCREEN OUTPUT.
*  comm1 = 'Die Exceldatei sollte folgenden Aufbau haben:'.
*  comm5 = '!! Es wird das erste Tabellenblatt verwendet!!'.
*  comm2 = 'Zeile 1 - Tag: Kostenstellgruppe ODER Auftragsgruppe'.
*  comm3 = 'Zeile 2:  Ebene1  Ebene2 Ebene3 <Wert>  Bezeichnung'.
*  comm4 = 'Zeile 3..x:  Definition'.

AT SELECTION-SCREEN OUTPUT.
*  Vorbelegung Sel Options Bukrs
  IF s_bukrs IS INITIAL.
    APPEND INITIAL LINE  TO s_bukrs ASSIGNING FIELD-SYMBOL(<fs_bukrs>).
    <fs_bukrs>-sign   = 'I'.
    <fs_bukrs>-option = 'EQ'.
    <fs_bukrs>-low    = 'R010'.
    APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
    <fs_bukrs>-sign   = 'I'.
    <fs_bukrs>-option = 'EQ'.
    <fs_bukrs>-low    = 'R020'.
    APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
    <fs_bukrs>-sign   = 'I'.
    <fs_bukrs>-option = 'EQ'.
    <fs_bukrs>-low    = 'R030'.
    APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
    <fs_bukrs>-sign   = 'I'.
    <fs_bukrs>-option = 'EQ'.
    <fs_bukrs>-low    = 'R040'.
    APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
    <fs_bukrs>-sign   = 'I'.
    <fs_bukrs>-option = 'EQ'.
    <fs_bukrs>-low    = 'R050'.
    APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
    <fs_bukrs>-sign   = 'I'.
    <fs_bukrs>-option = 'EQ'.
    <fs_bukrs>-low    = 'R060'.
    APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
    <fs_bukrs>-sign   = 'I'.
    <fs_bukrs>-option = 'EQ'.
    <fs_bukrs>-low    = 'R070'.
    APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
    <fs_bukrs>-sign   = 'I'.
    <fs_bukrs>-option = 'EQ'.
    <fs_bukrs>-low    = 'R080'.
    APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
    <fs_bukrs>-sign   = 'I'.
    <fs_bukrs>-option = 'EQ'.
    <fs_bukrs>-low    = 'R090'." Justiz
    APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
    <fs_bukrs>-sign   = 'I'.
    <fs_bukrs>-option = 'EQ'.
    <fs_bukrs>-low    = 'R100' . " MID
    APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
    <fs_bukrs>-sign   = 'I'.
    <fs_bukrs>-option = 'EQ'.
    <fs_bukrs>-low    = 'R110'.
    APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
    <fs_bukrs>-sign   = 'I'.
    <fs_bukrs>-option = 'EQ'.
    <fs_bukrs>-low    = 'R120'.
    APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
    <fs_bukrs>-sign   = 'I'.
    <fs_bukrs>-option = 'EQ'.
    <fs_bukrs>-low    = 'T999'. " (LHK)
  ENDIF.

START-OF-SELECTION.
*  DATA: sethier TYPE TABLE OF bapiset_hier.
  TYPES: lty_import_line(4096).
  DATA: bapiret                    TYPE bapiret2.
  DATA: lt_upload_table            TYPE STANDARD TABLE OF lty_import_line.
  DATA: ls_upload_table            TYPE  lty_import_line.

  DATA: lt_upload_table_conv       TYPE TABLE OF /thkr/gp_import_list_raw.
  DATA: lt_upload_table_conv_kasse TYPE TABLE OF /thkr/gp_kasse_import_list_raw.
  DATA: ls_upload_table_conv       TYPE /thkr/gp_import_list.
  DATA: lt_upload_table_conv_2     TYPE TABLE OF /thkr/gp_import_list.
  DATA: ls_upload_table_conv_2     TYPE /thkr/gp_import_list.

  DATA: lt_file_table_n            TYPE filetable."string.
  DATA: ls_file_table_n            TYPE LINE OF filetable."string.
  DATA: lv_pathl                   TYPE string.
  DATA: prestring                  TYPE string.
*        char1024."

  DATA filename_conv               TYPE char256."rlgrap-filename.   "zu kurz

  DATA: lt_bp_deb_create           TYPE TABLE OF  /thkr/s_dto_bp."/thkr/s_dto_bp_create.
  DATA: ls_bp_deb_create           TYPE /thkr/s_dto_bp_create.
  DATA: lv_BU_PARTNER_return       TYPE bu_partner.
  DATA: lv_BU_PARTNER_export       TYPE bu_partner .
  DATA: lv_rc                      TYPE i.
  DATA: lt_return                  TYPE TABLE OF   bapiret2.
  DATA: ls_return                  TYPE bapiret2.

  DATA: lt_return2                 TYPE TABLE OF   bapiret2.
  DATA: ls_return2                 TYPE bapiret2.

  DATA: ls_result                  TYPE string.
  DATA: lt_result          TYPE TABLE OF string,
        lv_timestring_conv TYPE string.


  ls_file_table_n-filename = p_in_dir.

  FIELD-SYMBOLS: <customer_comp>   TYPE /thkr/s_dto_bp_cust_company." like ls_bp_deb_create-customer-T_customer_COMPANY,
  FIELD-SYMBOLS: <vendor_comp>     TYPE /thkr/s_dto_bp_vend_company."like ls_bp_deb_create-vendor-T_vendor_COMPANY.

**  Vorbelegung Sel Options Bukrs
*  APPEND INITIAL LINE  TO s_bukrs ASSIGNING FIELD-SYMBOL(<fs_bukrs>).
*  <fs_bukrs>-low = 'R090'." Justiz
*  APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
*  <fs_bukrs>-low = 'R100' . " MID
*  APPEND INITIAL LINE  TO s_bukrs ASSIGNING <fs_bukrs>.
*  <fs_bukrs>-low = 'T999'. " (LHK)



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
        IF p_GP_kas EQ 'X'.
          CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
            EXPORTING
              i_line_header        = 'X' "p_head
              i_tab_raw_data       = lt_upload_table " WORK TABLE
*             i_filename           = filename_conv
              i_filename_long      = filename_conv
            TABLES
              i_tab_converted_data = lt_upload_table_conv_kasse[]  "ACTUAL DATA
            EXCEPTIONS
              conversion_failed    = 1
              OTHERS               = 2.
*        *  Für Geschäftspartner KAsse
          MOVE-CORRESPONDING lt_upload_table_conv_kasse[] TO lt_upload_table_conv_2[].
        ELSE.
*       * excel Daten mappen auf Rohimport
          CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
            EXPORTING
              i_line_header        = 'X' "p_head
              i_tab_raw_data       = lt_upload_table " WORK TABLE
*             i_filename           = filename_conv
              i_filename_long      = filename_conv
            TABLES
              i_tab_converted_data = lt_upload_table_conv[]  "ACTUAL DATA
            EXCEPTIONS
              conversion_failed    = 1
              OTHERS               = 2.

* excel Daten mappen auf Rohimport
          MOVE-CORRESPONDING lt_upload_table_conv[] TO lt_upload_table_conv_2[].
        ENDIF.
      ENDIF.

************************************************************************
*     Dynamische Aktivierung / Deaktivierung eines Break-Points mit    *
*     der TA: SAAB                                                     *
************************************************************************
      BREAK-POINT ID /thkr/migrate_partners.

*Mappen rohimport auf Typgerechten import

*      lt_upload_table_conv_2[] = lt_upload_table_conv[].


*      ELSE. " p_GP_all ne space.
**      für zentrale gP
*
*
*    ENDIF.
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

      LOOP AT lt_upload_table_conv_2 INTO ls_upload_table_conv_2.
        ls_bp_deb_create-bu_type   = ls_upload_table_conv_2-gp_typ(1).
        TRANSLATE ls_bp_deb_create-bu_type USING 'P1O2G3'. "Umschlüsseln von alpha auf numerisch gemäß customizing
        ls_bp_deb_create-bu_group = ls_upload_table_conv_2-gp_gruppierung(4).  "entspricht der  GP_ROLLENGRUPPIERUNG
*ls_bp_deb_create-nv: s. Feldbeschreibung rechts = ls_upload_table_conv_2-GP_ROLLENGRUPPIERUNG. s.o. muss nicht zugewiesen werden

        IF         ls_bp_deb_create-bu_type = 1.
*          BU_NAME1 Type  BU_NAME1  CHAR  40  0 0 Namensfeld 1 (Name1/Nachname)
*BU_NAME2 Type  BU_NAME2  CHAR  40  0 0 Namensfeld 2 (Name2/Vorname)
          ls_bp_deb_create-bu_name1 = ls_upload_table_conv_2-name.
          ls_bp_deb_create-bu_name2 = ls_upload_table_conv_2-vorname.
        ELSE.
          ls_bp_deb_create-bu_name1 = ls_upload_table_conv_2-name.
        ENDIF.
        ls_bp_deb_create-bu_name4   = ls_upload_table_conv_2-ap_jur_pers.
        ls_bp_deb_create-bu_sort1   = ls_upload_table_conv_2-suchbegriff.
        ls_bp_deb_create-ad_name_co = ls_upload_table_conv_2-co.
*ls_bp_deb_create-nv = ls_upload_table_conv_2-HANDELSREGISTERNR.
        ls_bp_deb_create-ad_street = ls_upload_table_conv_2-strasse.
        ls_bp_deb_create-ad_hsnm1  = ls_upload_table_conv_2-hausnummer.
        ls_bp_deb_create-ad_pstcd1 = ls_upload_table_conv_2-plz.
        ls_bp_deb_create-ad_city1  = ls_upload_table_conv_2-ort.
        IF ls_upload_table_conv_2-land EQ 'D'. "kommt manchmal einstellig
          MOVE 'DE' TO ls_upload_table_conv_2-land.
        ENDIF.
        ls_bp_deb_create-land1 = ls_upload_table_conv_2-land.
        TRANSLATE ls_upload_table_conv_2-sprache TO UPPER CASE .
        ls_bp_deb_create-bu_langu = ls_upload_table_conv_2-sprache.
*ls_bp_deb_create-nv = ls_upload_table_conv_2-TELEFON.
*ls_bp_deb_create-nv = ls_upload_table_conv_2-E_MAIL.
        ls_bp_deb_create-banks     = ls_upload_table_conv_2-iban(2).
        ls_bp_deb_create-bankk     = ls_upload_table_conv_2-bic.   "für ausländische Banken istdie BIC erforerlich
        ls_bp_deb_create-iban      = ls_upload_table_conv_2-iban.
        ls_bp_deb_create-bu_bpext  = ls_upload_table_conv_2-ext_partnernummer.
        ls_bp_deb_create-bu_bpkind = ls_upload_table_conv_2-geschaeftspartnerart.

*email telephone
        IF ls_upload_table_conv_2-telefon IS NOT INITIAL OR ls_upload_table_conv_2-e_mail IS NOT INITIAL.
          ls_bp_deb_create-mig_tel_number = ls_upload_table_conv_2-telefon.
          ls_bp_deb_create-mig_smtp_addr = ls_upload_table_conv_2-e_mail.
        ENDIF.

* Handelsregister-Nr eintragen: nur für GP_all(?)
        IF  ls_upload_table_conv_2-handelsregisternr NE space.
          APPEND INITIAL LINE TO  ls_bp_deb_create-t_ident_number ASSIGNING FIELD-SYMBOL(<Ident_number>).
          <ident_number>-bu_id_category = 'BUP002'.
          <ident_number>-bu_id_number  = ls_upload_table_conv_2-handelsregisternr.
        ENDIF.
        IF p_gp_all NE space.
          LOOP AT s_bukrs ASSIGNING FIELD-SYMBOL(<fs_bukrs>).


            APPEND INITIAL LINE TO  ls_bp_deb_create-customer-t_customer_company ASSIGNING <customer_comp>.
*            <customer_comp>-bukrs = ls_upload_table_conv-geschaeftsbereich. .
            <customer_comp>-bukrs  = <fs_bukrs>-low."'T111'."ls_upload_table_conv_2-geschaeftsbereich.
            <customer_comp>-akont  = ls_upload_table_conv_2-abstimmkonto_debitor.
            <customer_comp>-zuawa  = ls_upload_table_conv_2-sortierschluessel.
*GP daten versorgen Lieferant.
            APPEND INITIAL LINE TO  ls_bp_deb_create-vendor-T_vendor_COMPANY ASSIGNING <vendor_comp>.
            <vendor_comp>-bukrs  = <fs_bukrs>-low."'T111'."ls_upload_table_conv_2-geschaeftsbereich.
            <vendor_comp>-akont  = ls_upload_table_conv_2-abstimmkonto_kreditor.
            <vendor_comp>-zuawa  = ls_upload_table_conv_2-sortierschluessel.
            <vendor_comp>-reprf  = 'X'. "ls_upload_table_conv_2-.
          ENDLOOP.
*        ENDIF.
        ELSE.
* gp-daten versorgen Kunde
          APPEND INITIAL LINE TO  ls_bp_deb_create-customer-t_customer_company ASSIGNING <customer_comp>.
*<customer_comp>-bukrs = ls_upload_table_conv-GESCHAEFTSBEREICH. .
          <customer_comp>-bukrs  = p_bukrs."'T111'."ls_upload_table_conv_2-geschaeftsbereich.
          <customer_comp>-akont  = ls_upload_table_conv_2-abstimmkonto_debitor.
          <customer_comp>-zuawa  = ls_upload_table_conv_2-sortierschluessel.

*GP daten versorgen Lieferant.
          APPEND INITIAL LINE TO  ls_bp_deb_create-vendor-T_vendor_COMPANY ASSIGNING <vendor_comp>.
          <vendor_comp>-bukrs    = p_bukrs."'T111'."ls_upload_table_conv_2-geschaeftsbereich.
          <vendor_comp>-akont    = ls_upload_table_conv_2-abstimmkonto_kreditor.
          <vendor_comp>-zuawa    = ls_upload_table_conv_2-sortierschluessel.
          <vendor_comp>-reprf    = 'X'. "ls_upload_table_conv_2-.
        ENDIF.

        ls_bp_deb_create-/thkr/gsber =   ls_upload_table_conv_2-geschaeftsbereich.
        ls_bp_deb_create-test_run = p_test.
        TRY.

* 2. GP anlegen (Debitor und  kreditor)
            /thkr/cl_bp_appl=>get_instance( )->create_partner(
              EXPORTING
                i_dto_bp_create = ls_bp_deb_create
              IMPORTING
                e_partner       = lv_BU_PARTNER_export ).

          CATCH cx_root INTO DATA(lx_root) .
*            ls_return = lx_root->get_text( ).
*wie kann ich die gecatchten message wegspeichern?
        ENDTRY.
        IF lx_root IS NOT INITIAL. "kein Fehler beim GP anlegen
          ls_result = lx_root->get_text( ).
          CONCATENATE ls_upload_table_conv_2-name ':  ' ls_result INTO ls_result.
        ELSE.   "gp <name> fehlerhaft
          CONCATENATE ls_upload_table_conv_2-name ':  ' 'erfolgreich' INTO ls_result.
        ENDIF.
        APPEND ls_result TO lt_result.

        CLEAR ls_result.
        CLEAR  ls_bp_deb_create.

        IF lx_root IS INITIAL AND
         p_test IS INITIAL.

          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait   = 'X'
            IMPORTING
              return = ls_return.
        ELSE.
          CLEAR lx_root.
          CONTINUE.
        ENDIF.
      ENDLOOP.

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
      ENDLOOP.
      IF      p_logsin EQ space. " Einzelsätze ins log
        CONCATENATE 'Anzahl erfolgreich; ' lv_lin INTO prestring.
        TRANSFER prestring TO p_lognam.
      ENDIF.
*  log fortschreiben

      GET TIME STAMP FIELD lv_ts.
      CONVERT TIME STAMP lv_ts TIME ZONE 'CET' INTO TIME lv_timestring_conv .

      CONCATENATE sy-datum lv_timestring_conv sy-uname filename_conv INTO prestring SEPARATED BY '_'.
      TRANSFER prestring TO p_lognam.
      CLOSE DATASET p_lognam.
*        CATCH /thkr/cx_bp.
*      ENDTRY.
  ENDTRY.


END-OF-SELECTION.
  MESSAGE TEXT-end TYPE 'I'.
