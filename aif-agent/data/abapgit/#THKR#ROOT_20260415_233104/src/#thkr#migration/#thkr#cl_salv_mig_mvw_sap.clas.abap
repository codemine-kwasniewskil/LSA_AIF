class /THKR/CL_SALV_MIG_MVW_SAP definition
  public
  inheriting from /THKR/CL_EASY_SALV
  final
  create public .

public section.

  data T_DTO_MIG_MVW_SAP type /THKR/T_DTO_MIG_MVW .

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

  data APPL type ref to /THKR/CL_MIG_APPL .
  constants C_GUI_STATUS type SYPFKEY value 'SALV_MIG_MVW_SAP' ##NO_TEXT.
  constants C_GUI_TITLE type LVC_TITLE value 'Migration Mandate' ##NO_TEXT.
  constants C_NAME_FUGR type SYREPID value '/THKR/SAPLMIG_GUI' ##NO_TEXT.
  constants C_REPORT_NAME type REPID value 'CL_SALV_MIG_MVW_SAP' ##NO_TEXT.
  constants C_LINE_STRUCTURE type TABNAME value '/THKR/S_DTO_MIG_MVW' ##NO_TEXT.

  methods SHOW_MESSAGES
    importing
      !I_SELECTION type /THKR/S_EVENT_SELECTION .
  methods HANDLE_LINK_CLICK
    for event LINK_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN .
ENDCLASS.



CLASS /THKR/CL_SALV_MIG_MVW_SAP IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    report_name = c_report_name.

    gui_status  = c_gui_status.

    gui_title = c_gui_title.

    name_fugr   = c_name_fugr.

    appl = /thkr/cl_mig_appl=>get_instance( ).


    APPEND 'PARTNER'  TO hotspots.

    APPEND 'SCHLUESSEL'  TO hotspots.

  ENDMETHOD.


  METHOD fill_data.

    FIELD-SYMBOLS <selection> TYPE /thkr/s_mig_mvw_sap_selection.


    ASSIGN selection->* TO <selection>.

    appl->get_tdto_mig_mvw(
     EXPORTING
       i_selection = <selection>
     IMPORTING
       et_dto      = t_dto_mig_mvw_sap ).

    GET REFERENCE OF t_dto_mig_mvw_sap INTO t_data_ref.

  ENDMETHOD.


  METHOD handle_added_function.

    super->handle_added_function( e_salv_function = e_salv_function ).

    DATA: l_selections      TYPE REF TO cl_salv_selections,
          l_event_selection TYPE /thkr/s_event_selection,
          l_rows            TYPE salv_t_row,
          l_answer          TYPE c,
          l_row             TYPE i,
          l_xmlstr          TYPE xstring,
          l_selection       TYPE /thkr/s_mig_mvw_sap_selection,
          l_ln_key          TYPE /thkr/event_ln_key,
          l_confirm         TYPE string.

    l_selections = salv->get_selections( ).
    l_rows       = l_selections->get_selected_rows( ).



    READ TABLE l_rows INDEX 1 INTO l_row.
    IF sy-subrc = 0.
* Attribut aus der Klasse (Daten aller Tabellen)
      READ TABLE t_dto_mig_mvw_sap INDEX l_row ASSIGNING FIELD-SYMBOL(<line>).
    ENDIF.

    TRY.
        CASE e_salv_function.

          WHEN 'REFRESH'.

            refresh( ).


          WHEN 'PROCESS'.

            IF <line> IS ASSIGNED.

              appl->process_mig_mandat(
             EXPORTING
               i_epl        = <line>-epl
               i_schluessel = <line>-schluessel
               i_uci        = <line>-uci ).

              refresh( ).

            ENDIF.


          WHEN 'SHOW_MESS'.

            IF <line> IS ASSIGNED.

              appl->get_ln_key_mig_mandat(
                EXPORTING
                  i_epl        = <line>-epl
                  i_schluessel = <line>-schluessel
                  i_uci        = <line>-uci
                IMPORTING
                 e_ln_key     = l_ln_key ).

              l_event_selection-ln_key = l_ln_key.
              l_event_selection-ln_art   = 'MIG_MN'.
              show_messages( i_selection = l_event_selection ). "wo soll die Methode am besten angelegt werden und warum?

            ENDIF.


          WHEN 'SHOW_XML'.

            IF <line> IS ASSIGNED.

              DATA: i_selection TYPE /thkr/s_mig_mvw_sap_selection.

              i_selection-epl        = <LINE>-EPL.
              i_selection-schluessel = <line>-schluessel.
              i_selection-uci        = <line>-uci.

              appl->get_dto_mig_mvw_me(
                EXPORTING
                  i_selection  = i_selection
                IMPORTING
                  e_dto     = DATA(l_dto_mig_mvw) ).

              CALL TRANSFORMATION id
                SOURCE dto = l_dto_mig_mvw
                RESULT XML l_xmlstr.

              CALL FUNCTION 'DISPLAY_XML_STRING'
                EXPORTING
                  xml_string = l_xmlstr.

              refresh( ).

            ENDIF.


          WHEN 'XML_LIF'.

            IF <line> IS ASSIGNED.

              appl->get_dto_mig_lif(
                EXPORTING
                  i_zp_nr      = <line>-zp_nummer
                  i_zp_lfd_nr  = <line>-zp_lfd_nummer
                IMPORTING
                  e_dto     = DATA(l_dto_mig_lif) ).

              CALL TRANSFORMATION id
                SOURCE dto = l_dto_mig_lif
                RESULT XML l_xmlstr.

              CALL FUNCTION 'DISPLAY_XML_STRING'
                EXPORTING
                  xml_string = l_xmlstr.

              refresh( ).

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
                  answer        = l_confirm.

              IF l_confirm = '1'. "JA
                appl->delete_mig_mandat(
                 EXPORTING
                   i_epl        = <line>-epl
                   i_schluessel = <line>-schluessel
                   i_uci        = <line>-uci ).

              ELSEIF l_confirm = '2'. "Nein
                MESSAGE 'Löschvorgang abgebrochen.' TYPE 'I'.
              ENDIF.

              refresh( ).

            ENDIF.

        ENDCASE.

      CATCH cx_root INTO DATA(l_oerror).
        /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).

    ENDTRY.

  ENDMETHOD.


  method HANDLE_COLUMNS.

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

  endmethod.


  method HANDLE_LINK_CLICK.

    FIELD-SYMBOLS: <t_data> TYPE STANDARD TABLE,
                   <line>   LIKE LINE OF T_DTO_MIG_MVW_SAP.


    ASSIGN t_data_ref->* TO <t_data>.

    READ TABLE <t_data> INDEX row ASSIGNING <line>.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.


    IF column	 = 'PARTNER'.
* Geschäftspartner anzeiegn
      IF <line>-partner IS NOT INITIAL.
        SET PARAMETER ID 'KUN' FIELD <line>-partner.
        SET PARAMETER ID 'BUK' FIELD <line>-bukrs.
        CALL TRANSACTION 'FD03' AND SKIP FIRST SCREEN.
      ENDIF.
    ENDIF.


    IF column = 'SCHLUESSEL'.
      IF NOT <line>-SCHLUESSEL IS INITIAL.
        appl->display_fsepa_m3( i_mndid = <line>-SCHLUESSEL ).
      ENDIF.
    ENDIF.


  endmethod.


  method SET_EVENT_HANDLING.



    super->set_event_handling( ).

    DATA: l_events         TYPE REF TO cl_salv_events_table.

*   Eventverarbeitung festlegen
    l_events = salv->get_event( ).
*   SET HANDLER handle_double_click FOR l_events.
    SET HANDLER handle_link_click   FOR l_events.


  endmethod.


  METHOD show_messages.

    DATA: l_salv_event TYPE REF TO /thkr/cl_salv_event.

    CREATE OBJECT l_salv_event.

    l_salv_event->display(
      EXPORTING
        i_selection = i_selection ).

  ENDMETHOD.
ENDCLASS.
