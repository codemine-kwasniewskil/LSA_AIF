class /THKR/CL_SALV_MIG_AO_SAP definition
  public
  inheriting from /THKR/CL_EASY_SALV
  final
  create public .

public section.

  methods CONSTRUCTOR .
protected section.

  methods FILL_DATA
    redefinition .
  methods HANDLE_ADDED_FUNCTION
    redefinition .
  methods HANDLE_COLUMNS
    redefinition .
  methods SET_EVENT_HANDLING
    redefinition .
  methods HANDLE_SALV_FUNCTIONS
    redefinition .
private section.

  data T_DTO_MIG_AO_SAP type /THKR/T_DTO_MIG_AO_SAP .
  data APPL type ref to /THKR/CL_MIG_APPL .
  constants C_GUI_STATUS type SYPFKEY value 'SALV_MIG_AO_SAP' ##NO_TEXT.
  constants C_GUI_TITLE type LVC_TITLE value 'Migration Anordnungen' ##NO_TEXT.
  constants C_NAME_FUGR type SYREPID value '/THKR/SAPLMIG_GUI' ##NO_TEXT.
  constants C_REPORT_NAME type REPID value 'CL_SALV_MIG_AO_SAP' ##NO_TEXT.
  constants C_LINE_STRUCTURE type TABNAME value '/THKR/S_DTO_MIG_AO_SAP' ##NO_TEXT.
  constants C_GUI_STATUS_RO type SYPFKEY value 'SALV_MIG_AO_SAP_RO' ##NO_TEXT.

  methods HANDLE_LINK_CLICK
    for event LINK_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN .
  methods SHOW_MESSAGES
    importing
      !I_SELECTION type /THKR/S_EVENT_SELECTION .
ENDCLASS.



CLASS /THKR/CL_SALV_MIG_AO_SAP IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    report_name = c_report_name.

    gui_status  = c_gui_status_ro.

    gui_title = c_gui_title.

    name_fugr   = c_name_fugr.

    appl = /thkr/cl_mig_appl=>get_instance( ).

    APPEND 'T_RATE' TO techfields.
    APPEND 'T_SVZ' to techfields.
    APPEND 'T_SPLIT' to techfields.

    APPEND 'BELNR'    TO hotspots.
    APPEND 'PARTNER'  TO hotspots.
    APPEND 'LOTKZ'    TO hotspots.
    APPEND 'LOTKZ_FB' TO hotspots.
    APPEND 'BELNR_FB' TO hotspots.

    APPEND 'PARTNER_CREATED' TO checkboxfields.
    CLEAR: checkboxes_as_hotspots.


    " Da die Zeilenbreite des SALV auf 1023 beschränkt ist, müssen Felder als techfields deklariert werden
    APPEND 'EINZELPLAN'          TO techfields.      "2
    APPEND 'KASSENZEICHEN'       TO techfields.   "16
*    APPEND 'SOLLBETRAG'          TO techfields.   "20
*    APPEND 'ISTBETRAG'           TO techfields.   "20
    APPEND 'VERWENDUNGSZWECK'    TO techfields.  "108
    APPEND 'GUELTIGBIS'          TO techfields.      "8
    APPEND 'BUCHUNGSNUMMEREAM'   TO techfields.   "10
    APPEND 'NAMEZEILE2'          TO techfields.    "40
    APPEND 'NAMEZEILE3'          TO techfields.    "40
    APPEND 'PLZ'                 TO techfields. "6
    APPEND 'ORT'                 TO techfields. "27
    APPEND 'STRASSE'             TO techfields. "27
    APPEND 'GEBURTSTAG'          TO techfields.  "8
    APPEND 'TELEFON'             TO techfields. "26
    APPEND 'FAX'                 TO techfields. "26
    APPEND 'EMAIL'               TO techfields. "60
    APPEND 'BIC'                 TO techfields. "11
    APPEND 'BLZ'                 TO techfields. "8
    APPEND 'KONTONUMMER'         TO techfields. "10
    APPEND 'BEI'                 TO techfields. "11
    APPEND 'BANKNAMEZEILE1'      TO techfields.  "35
    APPEND 'BANKNAMEZEILE2'      TO techfields.  "35
    APPEND 'BANKNAMEZEILE3'      TO techfields.  "35
    APPEND 'BANKSTRASSE'         TO techfields. "35
    APPEND 'BANKORT'             TO techfields. "35
    APPEND 'DATUMDRUCKBELVORANK' TO techfields. "8
    APPEND 'USERDRUCKBELVORANK'  TO techfields.  "8

    APPEND 'BESCHREIBUNGVERTRAG' TO techfields. "35
    APPEND 'UNTERSCHRIFTSDATUM'  TO techfields.  "8
    APPEND 'ORTUNTERSCHRIFT'     TO techfields. "35
    APPEND 'MANDATGEBERNAME'     TO techfields. "70
    APPEND 'MANDATGEBERORT'      TO techfields.  "35
    APPEND 'MANDATGEBERLAENDERSCHLUESSEL' TO techfields.  "2
    APPEND 'MANDATGEBERPOSTCODE' TO techfields. "10
    APPEND 'MANDATGEBERSTRASSE'  TO techfields.  "35

    APPEND 'UMRECHNUNGSKURS'     TO techfields. "20
    APPEND 'URSALDOFREMDWAEHRUNG' TO techfields. "20
    APPEND 'URSALDOGEBUEHR'      TO techfields. "20
    APPEND 'FREMDWAEHRUNGGEBUEHR' to techfields. "3
*    APPEND 'SSTE_UEBERZ_FORDERUNG' to techfields. "1

  ENDMETHOD.


  METHOD fill_data.

    FIELD-SYMBOLS <selection> TYPE /thkr/s_mig_ao_sap_selection.

    ASSIGN selection->* TO <selection>.

    IF <selection>-read_only IS NOT INITIAL.
      gui_status  = c_gui_status_ro.
    ELSE.
      gui_status  = c_gui_status.
    ENDIF.

    /thkr/cl_mig_rk=>get_instance( )->get_tdto_mig_ao(
       EXPORTING
         i_selection = <selection>
       IMPORTING
         et_dto      = t_dto_mig_ao_sap ).

    GET REFERENCE OF t_dto_mig_ao_sap INTO t_data_ref.

    APPEND 'MANDAT' TO hotspots.

  ENDMETHOD.


  METHOD handle_added_function.

    super->handle_added_function( e_salv_function = e_salv_function ).

    TYPES: BEGIN OF lty_param,
             satz_id TYPE /thkr/de_satz_id,
           END OF lty_param.

    DATA: l_selections            TYPE REF TO cl_salv_selections,
          l_event_selection       TYPE /thkr/s_event_selection,
          l_rows                  TYPE salv_t_row,
          l_answer                TYPE c,
          l_row                   TYPE i,
          l_xmlstr                TYPE xstring,
          l_mig_ao_file           TYPE /thkr/s_mig_ao_file,
          l_selection             TYPE /thkr/s_mig_ao_sap_selection,
          l_param                 TYPE lty_param,
          l_dto_bp_create         TYPE /thkr/s_dto_bp_create,
          l_dto_psm_ao_bel_create TYPE /thkr/s_dto_mig_ao_bel_create,
          l_dto_psm_mv_create     TYPE /thkr/s_dto_psm_mv_create,
          l_oerror                TYPE REF TO cx_root.


    l_selections            = salv->get_selections( ).
    l_rows       = l_selections->get_selected_rows( ).

    READ TABLE l_rows INDEX 1 INTO l_row.
    IF sy-subrc = 0.
* Attribut aus der Klasse (Daten aller Tabellen)
      READ TABLE t_dto_mig_ao_sap INDEX l_row ASSIGNING FIELD-SYMBOL(<line>).
    ENDIF.

    TRY.
        CASE e_salv_function.

          WHEN 'REFRESH'.

            refresh( ).

          WHEN 'PROCESS'.

            IF <line> IS ASSIGNED.
              appl->process_mig_ao(
                EXPORTING
                  i_satz_id = <line>-satz_id ).

              refresh(
                EXPORTING
                  refresh_mode = if_salv_c_refresh=>full ).  " INS 144
            ENDIF.

          WHEN 'SHOW_MESS'.

            IF <line> IS ASSIGNED.

              l_event_selection-ln_key = <line>-satz_id.
              l_event_selection-ln_art   = 'MIG_AO'.
              show_messages( i_selection = l_event_selection ).

            ENDIF.



          WHEN 'SHOW_XML'.

            IF <line> IS ASSIGNED.

              FIELD-SYMBOLS <selection> TYPE /thkr/s_mig_ao_sap_selection.
              ASSIGN selection->* TO <selection>.

              appl->get_dto_mig_ao(
                EXPORTING
                  i_satz_id = <line>-satz_id
                IMPORTING
                  e_dto     = DATA(l_dto_mig_ao_sap) ).

              CALL TRANSFORMATION id
                SOURCE dto = l_dto_mig_ao_sap
                RESULT XML l_xmlstr.

              CALL FUNCTION 'DISPLAY_XML_STRING'
                EXPORTING
                  xml_string = l_xmlstr.

            ENDIF.


          WHEN 'XML_RK'.

            IF <line> IS ASSIGNED.

              /thkr/cl_mig_rk=>get_instance( )->get_dto_mig_rk(
                 EXPORTING
                  i_xblnr   = <line>-xblnr
                IMPORTING
                  e_dto     = DATA(l_dto_rk) ).

              CALL TRANSFORMATION id
                SOURCE dto = l_dto_rk
                RESULT XML l_xmlstr.

              CALL FUNCTION 'DISPLAY_XML_STRING'
                EXPORTING
                  xml_string = l_xmlstr.

            ENDIF.

          WHEN 'XML_RKP'.

            IF <line> IS ASSIGNED.

              /thkr/cl_mig_rk=>get_instance( )->get_dto_mig_rk_pos(
                 EXPORTING
                  i_xblnr   = <line>-xblnr
                  i_pos_nr  = <line>-rk_pos_nr
                IMPORTING
                  e_dto     = DATA(l_dto_rkp) ).

              CALL TRANSFORMATION id
                SOURCE dto = l_dto_rkp
                RESULT XML l_xmlstr.

              CALL FUNCTION 'DISPLAY_XML_STRING'
                EXPORTING
                  xml_string = l_xmlstr.

            ENDIF.

          WHEN 'DELETE'.

            IF <line> IS ASSIGNED.

              CALL FUNCTION 'POPUP_TO_CONFIRM'
                EXPORTING
                  titlebar      = 'DELETE'
                  text_question = 'Möchten Sie den Datensatz wirklich löschen?'
                  text_button_1 = 'Ja'
                  text_button_2 = 'Nein'
                IMPORTING
                  answer        = l_answer.

              IF l_answer = '1'. "JA

                appl->delete_mig_ao(
                  EXPORTING
                    i_satz_id = <line>-satz_id ).
                refresh( ).
              ENDIF.
            ENDIF.

          WHEN 'RESET'.

            IF <line> IS ASSIGNED.

              CALL FUNCTION 'POPUP_TO_CONFIRM'
                EXPORTING
                  titlebar              = 'Ergebnis zurücksetzen'
*                 DIAGNOSE_OBJECT       = ' '
                  text_question         = 'Migrationsergebnis zurücksetzen?'
                  text_button_1         = 'Nur Anordnung(en)'(001)
*                 ICON_BUTTON_1         = ' '
                  text_button_2         = 'Auch Partner'(002)
*                 ICON_BUTTON_2         = ' '
*                 DEFAULT_BUTTON        = '1'
                  display_cancel_button = 'X'
*                 USERDEFINED_F1_HELP   = ' '
*                 START_COLUMN          = 25
*                 START_ROW             = 6
*                 POPUP_TYPE            =
*                 IV_QUICKINFO_BUTTON_1 = ' '
*                 IV_QUICKINFO_BUTTON_2 = ' '
                IMPORTING
                  answer                = l_answer
*               TABLES
*                 PARAMETER             =
*               EXCEPTIONS
*                 TEXT_NOT_FOUND        = 1
*                 OTHERS                = 2
                .

              IF l_answer = '1'.
                appl->reset_mig_ao(
                  EXPORTING
                    i_satz_id = <line>-satz_id
                    i_only_ao = 'X' ).
                refresh( ).
              ELSEIF l_answer = '2'.
                appl->reset_mig_ao(
                  EXPORTING
                    i_satz_id = <line>-satz_id ).
                refresh( ).
              ENDIF.
            ENDIF.

          WHEN 'MAPPING'.
            IF <line> IS ASSIGNED.
              READ TABLE appl->t_mig_gi WITH KEY mig_obj = <line>-migrationsobjekt INTO DATA(l_mig_gi).
              IF sy-subrc = 0.
                l_param-satz_id = <line>-satz_id.

                IF l_mig_gi-gi_id_bp IS NOT INITIAL.

                  TRY.
                      /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                         EXPORTING
                           i_gi_id = l_mig_gi-gi_id_bp
                           i_para  = l_param
                         CHANGING
                           c_data  = l_dto_bp_create ).

                      CALL TRANSFORMATION id
                        SOURCE bp_create = l_dto_bp_create
                        RESULT XML l_xmlstr.

                      CALL FUNCTION 'DISPLAY_XML_STRING'
                        EXPORTING
                          xml_string = l_xmlstr.
                    CATCH cx_root INTO l_oerror.
                      /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).
                  ENDTRY.

                ENDIF.

                IF l_mig_gi-gi_id_ao1 IS NOT INITIAL.
                  TRY.
                      IF l_mig_gi-ao_type = 'AO'.
                        /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                           EXPORTING
                             i_gi_id = l_mig_gi-gi_id_ao1
                             i_para  = l_param
                           CHANGING
                             c_data  = l_dto_psm_ao_bel_create ).

                        CALL TRANSFORMATION id
                          SOURCE bel_create = l_dto_psm_ao_bel_create
                          RESULT XML l_xmlstr.

                      ELSEIF  l_mig_gi-ao_type = 'MV'.
                        /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                       EXPORTING
                         i_gi_id = l_mig_gi-gi_id_ao1
                         i_para  = l_param
                       CHANGING
                         c_data  = l_dto_psm_mv_create ).

                        CALL TRANSFORMATION id
                          SOURCE mv_create = l_dto_psm_mv_create
                          RESULT XML l_xmlstr.

                      ELSE.
                        /thkr/cl_gi_appl=>get_instance( )->get_data_by_gi(
                          EXPORTING
                            i_gi_id = l_mig_gi-gi_id_ao1
                            i_para  = l_param
                          CHANGING
                            c_data  = l_dto_psm_mv_create ).

                        CALL TRANSFORMATION id
                          SOURCE mv_create = l_dto_psm_mv_create
                          RESULT XML l_xmlstr.

                      ENDIF.

                      CALL FUNCTION 'DISPLAY_XML_STRING'
                        EXPORTING
                          xml_string = l_xmlstr.
                    CATCH cx_root INTO l_oerror.
                      /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).
                  ENDTRY.

                ENDIF.
              ENDIF.
            ENDIF.

        ENDCASE.
      CATCH cx_root INTO l_oerror.
        /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).
    ENDTRY.


  ENDMETHOD.


  METHOD handle_columns.

    DATA: l_columns   TYPE REF TO cl_salv_columns_table,
          l_column    TYPE REF TO cl_salv_column_table,
          l_scrtext_s TYPE scrtext_s,
          l_scrtext_m TYPE scrtext_m,
          l_scrtext_l TYPE scrtext_l,
          l_tooltip   TYPE lvc_tip.

    super->handle_columns( ).

*   Spalteneinstellungen anpassen
    l_columns = salv->get_columns( ).

    /thkr/cl_helpers=>get_instance( )->get_fieldlist_from_struct(
       EXPORTING
         i_structure = c_line_structure
       IMPORTING
        et_fieldlist = DATA(lt_fields) ).



    LOOP AT lt_fields INTO DATA(l_field)
      WHERE rollname is INITIAL.  "Alle Felder ohne Datenelement

      l_scrtext_s = l_field-lfd_nr.
      l_scrtext_m = l_field-scrtext_m.
      l_scrtext_l = l_field-scrtext_l.
      l_tooltip   = l_field-scrtext_l.

      TRY.
          l_column ?= l_columns->get_column(
            EXPORTING
              columnname = conv #( l_field-fieldname ) ).
          l_column->set_short_text( l_scrtext_s ).
          l_column->set_medium_text( l_scrtext_m ).
          l_column->set_long_text( l_scrtext_l ).
          l_column->set_tooltip( l_tooltip ).

        CATCH cx_root .
      ENDTRY.


    ENDLOOP.











  ENDMETHOD.


  METHOD handle_link_click.

    FIELD-SYMBOLS: <t_data> TYPE STANDARD TABLE,
                   <line>   LIKE LINE OF t_dto_mig_ao_sap.


    ASSIGN t_data_ref->* TO <t_data>.

    READ TABLE <t_data> INDEX row ASSIGNING <line>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

* Selektierte Spalte column

    IF column	 =  'BELNR'.
* FI Beleg anzeigen
      IF <line>-belnr IS NOT INITIAL.
        CALL FUNCTION 'FI_DOCUMENT_DISPLAY_RFC'
          EXPORTING
            i_belnr = <line>-belnr
            i_bukrs = <line>-bukrs
            i_gjahr = <line>-gjahr.
      ENDIF.

    ENDIF.

    IF column	 = 'PARTNER'.
* Geschäftspartner anzeiegn
      IF <line>-partner IS NOT INITIAL.
        SET PARAMETER ID 'KUN' FIELD <line>-partner.
        SET PARAMETER ID 'BUK' FIELD <line>-bukrs.
        CALL TRANSACTION 'FD03' AND SKIP FIRST SCREEN.
      ENDIF.
    ENDIF.

    IF column   =  'LOTKZ'.
* Anordnung anzeigen, je Migrationstyp die entsprechende Transaktion
      IF <line>-lotkz IS NOT INITIAL.
        IF <line>-migrationsobjekt EQ 'SSTW' OR <line>-migrationsobjekt EQ 'AWD'.

          SET PARAMETER ID 'LOT' FIELD <line>-lotkz.
          SET PARAMETER ID 'BUK' FIELD <line>-bukrs.
          CALL TRANSACTION 'F8Q4' AND SKIP FIRST SCREEN.
        ENDIF.

        IF <line>-migrationsobjekt EQ 'SSTE'
          OR <line>-migrationsobjekt EQ 'NF'.

          SET PARAMETER ID 'LOT' FIELD <line>-lotkz.
          SET PARAMETER ID 'BUK' FIELD <line>-bukrs.
          CALL TRANSACTION 'F883' AND SKIP FIRST SCREEN.
        ENDIF.

        IF <line>-migrationsobjekt EQ 'SSTA'.
          appl->display_ssta( i_belnr = <line>-lotkz ).
        ENDIF.

        IF <line>-migrationsobjekt EQ 'ALL'.
          appl->display_mb( i_belnr = <line>-lotkz ).
        ENDIF.

        IF <line>-migrationsobjekt EQ 'IOS'.
          SET PARAMETER ID 'LOT' FIELD <line>-lotkz.
          SET PARAMETER ID 'BUK' FIELD <line>-bukrs.
          CALL TRANSACTION 'F883' AND SKIP FIRST SCREEN.
        ENDIF.

        IF <line>-migrationsobjekt EQ 'VSA'.
          SET PARAMETER ID 'LOT' FIELD <line>-lotkz.
          SET PARAMETER ID 'BUK' FIELD <line>-bukrs.
          CALL TRANSACTION 'F873' AND SKIP FIRST SCREEN.
        ENDIF.
      ENDIF.

    ENDIF.

* Anordnung Folgebeleg
    IF column   =  'LOTKZ_FB' AND <line>-lotkz_fb IS NOT INITIAL.
      SET PARAMETER ID 'LOT' FIELD <line>-lotkz_fb.
      SET PARAMETER ID 'BUK' FIELD <line>-bukrs.
      CALL TRANSACTION 'F883' AND SKIP FIRST SCREEN.
    ENDIF.

* FI Folgebeleg
    IF column   =  'BELNR_FB' AND <line>-belnr_fb IS NOT INITIAL.
      CALL FUNCTION 'FI_DOCUMENT_DISPLAY_RFC'
        EXPORTING
          i_belnr = <line>-belnr_fb
          i_bukrs = <line>-bukrs
          i_gjahr = <line>-gjahr.
    ENDIF.

* SEPA Mandat
    IF column = 'MANDAT'.
      IF NOT <line>-mandat IS INITIAL.
        appl->display_fsepa_m3( i_mndid = <line>-mandat ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD handle_salv_functions.
    CALL METHOD super->handle_salv_functions.


*    salv->get_functions( )->set_export_spreadsheet( ).




  ENDMETHOD.


  METHOD set_event_handling.

* INS 144 Start
    super->set_event_handling( ).

    DATA: l_events         TYPE REF TO cl_salv_events_table.

*   Eventverarbeitung festlegen
    l_events = salv->get_event( ).
*   SET HANDLER handle_double_click FOR l_events.
    SET HANDLER handle_link_click   FOR l_events.

* INS 144 ENDE


  ENDMETHOD.


  method SHOW_MESSAGES.

* Report /THKR/MIG_AO

    DATA: l_salv_event TYPE REF TO /thkr/cl_salv_event.

    CREATE OBJECT l_salv_event.

    l_salv_event->display(
      EXPORTING
        i_selection = i_selection ).

  endmethod.
ENDCLASS.
