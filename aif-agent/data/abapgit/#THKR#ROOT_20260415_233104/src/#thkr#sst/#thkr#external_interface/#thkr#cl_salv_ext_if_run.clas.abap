class /THKR/CL_SALV_EXT_IF_RUN definition
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
  methods SET_EVENT_HANDLING
    redefinition .
private section.

  constants C_GUI_STATUS type SYPFKEY value 'SALV_DE_RUN' ##NO_TEXT.
  constants C_GUI_TITLE type LVC_TITLE value 'IHV-Schnittstelle: Verarbeitungsläufe' ##NO_TEXT.
  constants C_NAME_FUGR type SYREPID value '/THKR/SAPLEXT_IF_GUI' ##NO_TEXT.
  constants C_REPORT_NAME type REPID value 'CL_SALV_EXT_IF_RUN' ##NO_TEXT.
  data APPL type ref to /THKR/CL_EXT_IF_APPL .
  data T_DE_RUN type /THKR/T_DTO_DE_RUN .

  methods SHOW_MESSAGES
    importing
      !I_SELECTION type /THKR/S_EVENT_SELECTION .
  methods HANDLE_DOUBLE_CLICK
    for event DOUBLE_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN .
ENDCLASS.



CLASS /THKR/CL_SALV_EXT_IF_RUN IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    report_name = c_report_name.

    gui_status  = c_gui_status.

    gui_title = c_gui_title.

    name_fugr   = c_name_fugr.

    appl = /thkr/cl_ext_if_appl=>get_instance( ).

    APPEND 'CR_TIME_STAMP' TO techfields.

    APPEND 'FLAG_ERROR'   TO checkboxfields.
    APPEND 'FLAG_WARNING' TO checkboxfields.

    CLEAR checkboxes_as_hotspots.

  ENDMETHOD.


  METHOD fill_data.

    FIELD-SYMBOLS <selection> TYPE /thkr/s_de_run_selection.

    ASSIGN selection->* TO <selection>.

    appl->get_tdto_de_run(
      EXPORTING
        i_selection = <selection>
      IMPORTING
        et_dto      = t_de_run ).

    GET REFERENCE OF t_de_run INTO t_data_ref.

    IF <selection>-process_type IS NOT INITIAL.
      CONCATENATE report_name '_' <selection>-process_type INTO report_name.
    ENDIF.

  ENDMETHOD.


  METHOD handle_added_function.

    super->handle_added_function( e_salv_function = e_salv_function ).

    DATA: l_selections      TYPE REF TO cl_salv_selections,
          l_event_selection TYPE /thkr/s_event_selection,
          l_rows            TYPE salv_t_row,
          l_answer          TYPE c,
          l_row             TYPE i,
          l_xmlstr          TYPE xstring.

    l_selections = salv->get_selections( ).
    l_rows       = l_selections->get_selected_rows( ).

    READ TABLE l_rows INDEX 1 INTO l_row.
    IF sy-subrc = 0.
      READ TABLE t_de_run INDEX l_row ASSIGNING FIELD-SYMBOL(<line>).

    ENDIF.

    TRY.
        CASE e_salv_function.

          WHEN 'REFRESH'.

            refresh( ).

          WHEN 'PROCESS'.

            IF <line> IS ASSIGNED.
              appl->process_run(
                EXPORTING
                  i_process_type = <line>-process_type
                  i_process_id   = <line>-process_id
                  i_fremdverf    = <line>-fremdverf
              ).
            ENDIF.

          WHEN 'SHOW_MESS'.

            IF <line> IS ASSIGNED.

              l_event_selection-process_type = <line>-process_type.
              l_event_selection-process_id   = <line>-process_id.

              show_messages( i_selection = l_event_selection ).

            ENDIF.
          WHEN 'SHOW_XML'.

            IF <line> IS ASSIGNED.

              appl->get_xml_data_by_run(
                EXPORTING
                  i_process_type = <line>-process_type
                  i_process_id   = <line>-process_id
                IMPORTING
                  e_xmlstr       = l_xmlstr ).

              CALL FUNCTION 'DISPLAY_XML_STRING'
                EXPORTING
                  xml_string = l_xmlstr.

            ENDIF.

        ENDCASE.
      CATCH cx_root INTO DATA(l_oerror).
        /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).
    ENDTRY.

  ENDMETHOD.


  METHOD handle_double_click.

    DATA: l_salv_ao1      TYPE REF TO /thkr/cl_salv_ext_if_run1,
          l_salv_hvw      TYPE REF TO /thkr/cl_salv_ext_if_run2,
          l_selection_ao1 TYPE /thkr/s_de_run_ao1_selection,
          l_selection_hvw TYPE /thkr/s_de_run_selection.

    READ TABLE t_de_run INDEX row ASSIGNING FIELD-SYMBOL(<line>).

    CASE <line>-process_type.
      WHEN 'AO_I'.
        l_selection_ao1-process_type = <line>-process_type.
        l_selection_ao1-process_id   = <line>-process_id.
        CREATE OBJECT l_salv_ao1.

        l_salv_ao1->display(
          EXPORTING
            i_selection = l_selection_ao1 ).
      WHEN 'FKT_I' OR 'GRP_I' OR 'EZP_I'.
        l_selection_hvw-process_type = <line>-process_type.
        l_selection_hvw-r_process_id = VALUE #( ( sign = 'I'
                                                 option = 'EQ'
                                                 low   = <line>-process_id ) ).

        CREATE OBJECT l_salv_hvw.

        l_salv_hvw->display(
          EXPORTING
            i_selection = l_selection_hvw ).
      WHEN OTHERS.
    ENDCASE.


  ENDMETHOD.


  method SET_EVENT_HANDLING.

    super->set_event_handling( ).

    DATA: l_events         TYPE REF TO cl_salv_events_table.

*   Eventverarbeitung festlegen
    l_events = salv->get_event( ).
    SET HANDLER handle_double_click FOR l_events.

  endmethod.


  METHOD show_messages.

    DATA: l_salv_event TYPE REF TO /thkr/cl_salv_event.

    CREATE OBJECT l_salv_event.

    l_salv_event->display(
      EXPORTING
        i_selection = i_selection ).

  ENDMETHOD.
ENDCLASS.
