class /THKR/CL_SALV_MIG_RK_SAP definition
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
private section.

  data T_DTO_MIG_RK_SAP type /THKR/T_DTO_MIG_RK_SAP .
  data APPL type ref to /THKR/CL_MIG_APPL .
  data MIG_RK type ref to /THKR/CL_MIG_RK .
  constants C_GUI_STATUS type SYPFKEY value 'SALV_MIG_RK' ##NO_TEXT.
  constants C_GUI_TITLE type LVC_TITLE value 'Migration Rückstandskonten' ##NO_TEXT.
  constants C_NAME_FUGR type SYREPID value '/THKR/SAPLMIG_GUI' ##NO_TEXT.
  constants C_REPORT_NAME type REPID value 'CL_SALV_MIG_RK_SAP' ##NO_TEXT.
  constants C_LINE_STRUCTURE type TABNAME value '/THKR/S_DTO_MIG_RK_SAP' ##NO_TEXT.

  methods HANDLE_LINK_CLICK
    for event LINK_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN .
  methods SHOW_MESSAGES
    importing
      !I_SELECTION type /THKR/S_EVENT_SELECTION .
ENDCLASS.



CLASS /THKR/CL_SALV_MIG_RK_SAP IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    report_name = c_report_name.

    gui_status  = c_gui_status.

    gui_title = c_gui_title.

    name_fugr   = c_name_fugr.

    appl   = /thkr/cl_mig_appl=>get_instance( ).
    mig_rk = /thkr/cl_mig_rk=>get_instance( ).

    APPEND 'T_RK_FAELL' TO techfields.
    APPEND 'T_RKN'      TO techfields.
    APPEND 'T_RKV'      TO techfields.
    APPEND 'T_RKA'      TO techfields.
    APPEND 'T_RK_AHE'   TO techfields.
    APPEND 'T_RK_POS'   TO techfields.
    APPEND 'T_BORE'     TO techfields.

    APPEND 'KASS_OP_INITIALIZED' TO checkboxfields.
    CLEAR: checkboxes_as_hotspots.

*    APPEND 'BELNR'   TO hotspots.
*    APPEND 'PARTNER' TO hotspots.

  ENDMETHOD.


  METHOD fill_data.

    FIELD-SYMBOLS <selection> TYPE /thkr/s_mig_rk_sap_selection.

    ASSIGN selection->* TO <selection>.


    mig_rk->get_tdto_mig_rk(
      EXPORTING
        i_selection = <selection>
      IMPORTING
        et_dto      = t_dto_mig_rk_sap ).


*    APPEND 'BELNR_FB' TO hotspots.


    GET REFERENCE OF t_dto_mig_rk_sap INTO t_data_ref.

  ENDMETHOD.


  METHOD handle_added_function.

    super->handle_added_function( e_salv_function = e_salv_function ).

*    MESSAGE 'Handle Function' TYPE 'I'.

    TYPES: BEGIN OF lty_fb_fidoc,
             t_beleg    TYPE /thkr/t_rk_beleg,
             t_bapiret2 TYPE bapiret2_t,
             sy_subrc   LIKE sy-subrc,
           END OF lty_fb_fidoc.

    TYPES: BEGIN OF lty_fb_rkn,
             t_notizen  TYPE /thkr/t_mig_rk_notiz,
             t_bapiret2 TYPE bapiret2_t,
             sy_subrc   LIKE sy-subrc,
           END OF lty_fb_rkn.

    TYPES: BEGIN OF lty_fb_rkv,
             t_rkv      TYPE /thkr/t_mig_avviso_rkv,
             t_rkfa     TYPE /thkr/t_mig_avviso_rkfa,
             t_borh     TYPE /thkr/t_mig_avviso_borh,
             t_bapiret2 TYPE bapiret2_t,
             sy_subrc   LIKE sy-subrc,
           END OF lty_fb_rkv.

    TYPES: BEGIN OF lty_fb_rk,
             rk_allgemein        TYPE  /thkr/s_mig_rk_allg,
             rk_weitereschuldner TYPE  /thkr/s_mig_rk_weit_schuldn,
             rk_t_amtshilfe      TYPE  /thkr/t_mig_rk_ahe_fb,
             rk_t_adress_rk      TYPE	 /thkr/t_mig_rk_adrh,
             rk_t_verkett_rk     TYPE  /thkr/t_mig_rk_kz_verkettet,
             sy_subrc            LIKE  sy-subrc,
           END OF lty_fb_rk.

    DATA: lv_answer         TYPE c,
          l_selections      TYPE REF TO cl_salv_selections,
          l_event_selection TYPE /thkr/s_event_selection,
          l_rows            TYPE salv_t_row,
          l_answer          TYPE c,
          l_row             TYPE i,
          l_xmlstr          TYPE xstring,
          l_mig_rk_file     TYPE /thkr/s_mig_rk_file,
          l_selection       TYPE /thkr/s_mig_rk_sap_selection,
          l_fb_fidoc        TYPE lty_fb_fidoc,
          l_fb_rkn          TYPE lty_fb_rkn,
          l_fb_rkv          TYPE lty_fb_rkv,
          l_fb_rk           TYPE lty_fb_rk.


    l_selections = salv->get_selections( ).
    l_rows       = l_selections->get_selected_rows( ).

    READ TABLE l_rows INDEX 1 INTO l_row.
    IF sy-subrc = 0.
* Attribut aus der Klasse (Daten aller Tabellen)
      READ TABLE t_dto_mig_rk_sap INDEX l_row ASSIGNING FIELD-SYMBOL(<line>).
    ENDIF.

    TRY.
        CASE e_salv_function.

          WHEN 'REFRESH'.

            refresh( ).

          WHEN 'PROCESS'.

***            IF <line> IS ASSIGNED.
***              appl->process_mig_ao(
***                EXPORTING
***                  i_satz_id = <line>-satz_id
***              ).
***              refresh( ).  " INS 144
***            ENDIF.

          WHEN 'SHOW_MESS'.

            IF <line> IS ASSIGNED.

              l_event_selection-ln_key = <line>-satz_id.
              l_event_selection-ln_art   = 'MIG_RK'.
              show_messages( i_selection = l_event_selection ).

            ENDIF.

          WHEN 'SHOW_XML'.
            IF <line> IS ASSIGNED.
* Ausgabedaten einlesen
              mig_rk->get_dto_mig_rk(
                EXPORTING
                  i_satz_id = <line>-satz_id
                IMPORTING
                  e_dto     = DATA(l_dto_mig_rk) ).

* Transformation zu XML
              CALL TRANSFORMATION id
                SOURCE dto = l_dto_mig_rk
                RESULT XML l_xmlstr.

* Ausgabe XML
              CALL FUNCTION 'DISPLAY_XML_STRING'
                EXPORTING
                  xml_string = l_xmlstr.

              refresh( ).

            ENDIF.



          WHEN 'DELETE'.

            IF <line> IS ASSIGNED.

              CALL FUNCTION 'POPUP_TO_CONFIRM'
                EXPORTING
                  titlebar       = 'Löschen'
                  text_question  = 'Satz wirklich löschne?'
                  default_button = '2'
                IMPORTING
                  answer         = lv_answer
                EXCEPTIONS
                  text_not_found = 1
                  OTHERS         = 2.
              IF sy-subrc <> 0 OR lv_answer NE '1'.
                RETURN.
              ENDIF.

              appl->delete_mig_rk(
                EXPORTING
                  i_satz_id = <line>-satz_id
              ).
              refresh( ).  "INS 144
            ENDIF.

          WHEN 'FIDOC'.
            IF <line> IS ASSIGNED.

              CALL FUNCTION '/THKR/RK_FI_DOCUMENT_READ'
                EXPORTING
*                 I_BUKRS     =
*                 I_BELNR     =
*                 I_GJAHR     =
                  i_xblnr     = <line>-s_kassenzeichen
*                 I_AUTH_RFC  = ' '
                IMPORTING
                  et_beleg    = l_fb_fidoc-t_beleg
                  et_bapiret2 = l_fb_fidoc-t_bapiret2
                EXCEPTIONS
                  wrong_input = 1
                  not_found   = 2
                  OTHERS      = 3.

              l_fb_fidoc-sy_subrc = sy-subrc.

              CALL TRANSFORMATION id
                SOURCE fb_result = l_fb_fidoc
                RESULT XML l_xmlstr.

              CALL FUNCTION 'DISPLAY_XML_STRING'
                EXPORTING
                  xml_string = l_xmlstr.

            ENDIF.

          WHEN 'RK'.
            IF <line> IS ASSIGNED.

              CALL FUNCTION '/THKR/RK'
                EXPORTING
                  i_xblnr            = <line>-s_kassenzeichen               " Rückstandskonto Kassenzeichen
                IMPORTING
                  e_allgemein        = l_fb_rk-rk_allgemein
                  e_weitereschuldner = l_fb_rk-rk_weitereschuldner
                  et_amtshilfe       = l_fb_rk-rk_t_amtshilfe
                  et_adress_rk       = l_fb_rk-rk_t_adress_rk
                  et_verkett_rk      = l_fb_rk-rk_t_verkett_rk
                EXCEPTIONS
                  wrong_input        = 1
                  not_found          = 2
                  OTHERS             = 3.
              IF sy-subrc <> 0.
                l_fb_rk-sy_subrc = sy-subrc.
              ENDIF.

              CALL TRANSFORMATION id
                SOURCE fb_result = l_fb_rk
                RESULT XML l_xmlstr.

              CALL FUNCTION 'DISPLAY_XML_STRING'
                EXPORTING
                  xml_string = l_xmlstr.

            ENDIF.

          WHEN 'RKN'.
            IF <line> IS ASSIGNED.
              CALL FUNCTION '/THKR/RKN'
                EXPORTING
                  i_xblnr     = <line>-s_kassenzeichen
                IMPORTING
                  et_notizen  = l_fb_rkn-t_notizen
                  et_bapiret2 = l_fb_rkn-t_bapiret2
                EXCEPTIONS
                  wrong_input = 1
                  not_found   = 2
                  OTHERS      = 3.

              IF sy-subrc <> 0.
* Implement suitable error handling here
              ENDIF.

              IF sy-subrc <> 0.
                l_fb_rkn-sy_subrc = sy-subrc.
              ENDIF.

              CALL TRANSFORMATION id
                SOURCE fb_result = l_fb_rkn
                RESULT XML l_xmlstr.

              CALL FUNCTION 'DISPLAY_XML_STRING'
                EXPORTING
                  xml_string = l_xmlstr.

            ENDIF.


          WHEN 'RKV'.
            IF <line> IS ASSIGNED.

              CALL FUNCTION '/THKR/RKV'
                EXPORTING
                  i_xblnr     = <line>-s_kassenzeichen
                IMPORTING
                  et_rkv      = l_fb_rkv-t_rkv
                  et_rkfa     = l_fb_rkv-t_rkfa
                  et_borh     = l_fb_rkv-t_borh
                  et_bapiret2 = l_fb_rkv-t_bapiret2
                EXCEPTIONS
                  wrong_input = 1
                  not_found   = 2
                  OTHERS      = 3.

              IF sy-subrc <> 0.
* Implement suitable error handling here
              ENDIF.

              IF sy-subrc <> 0.
                l_fb_rkv-sy_subrc = sy-subrc.
              ENDIF.

              CALL TRANSFORMATION id
                SOURCE fb_result = l_fb_rkv
                RESULT XML l_xmlstr.

              CALL FUNCTION 'DISPLAY_XML_STRING'
                EXPORTING
                  xml_string = l_xmlstr.

            ENDIF.

          WHEN 'INIT_NF'.
            IF <line> IS ASSIGNED.
              mig_rk->init_kass_op( i_satz_id = <line>-satz_id ).
              MESSAGE 'Erledigt!' TYPE 'I'.
            ENDIF.

        ENDCASE.
      CATCH cx_root INTO DATA(l_oerror).
        /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).
    ENDTRY.


  ENDMETHOD.


  METHOD HANDLE_COLUMNS.

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


  METHOD HANDLE_LINK_CLICK.

    DATA: l_line_ref     TYPE REF TO data,
          l_dto_rk_join  TYPE /thkr/mig_rk_sap,
          l_data_changed TYPE xfeld.

    FIELD-SYMBOLS: <t_data> TYPE STANDARD TABLE,
                   <line>   TYPE any.

    ASSIGN t_data_ref->* TO <t_data>.

    READ TABLE <t_data> INDEX row ASSIGNING <line>.

    MOVE-CORRESPONDING <line> TO l_dto_rk_join.

*    IF column   =  'BELNR'.
** FI Beleg anzeigen
*      CALL FUNCTION 'FI_DOCUMENT_DISPLAY_RFC'
*        EXPORTING
*          i_belnr = l_dto_ao_join-belnr
*          i_bukrs = l_dto_ao_join-bukrs
*          i_gjahr = l_dto_ao_join-gjahr.
*    ENDIF.


*    IF column   = 'PARTNER'.
** Geschäftspartner anzeiegn
*      SET PARAMETER ID 'KUN' FIELD l_dto_ao_join-partner.
*      SET PARAMETER ID 'BUK' FIELD l_dto_ao_join-bukrs.
*      CALL TRANSACTION 'FD03' AND SKIP FIRST SCREEN.
*    ENDIF.


  ENDMETHOD.


  METHOD SET_EVENT_HANDLING.

* INS 144 Start
    super->set_event_handling( ).

    DATA: l_events         TYPE REF TO cl_salv_events_table.

*   Eventverarbeitung festlegen
    l_events = salv->get_event( ).
*   SET HANDLER handle_double_click FOR l_events.
    SET HANDLER handle_link_click   FOR l_events.

* INS 144 ENDE


  ENDMETHOD.


  METHOD show_messages.

* Report /THKR/MIG_AO

    DATA: l_salv_event TYPE REF TO /thkr/cl_salv_event.

    CREATE OBJECT l_salv_event.

    TRY.
        l_salv_event->display(
           EXPORTING
             i_selection = i_selection ).
      CATCH /thkr/cx_lsa1.

    ENDTRY.


  ENDMETHOD.
ENDCLASS.
