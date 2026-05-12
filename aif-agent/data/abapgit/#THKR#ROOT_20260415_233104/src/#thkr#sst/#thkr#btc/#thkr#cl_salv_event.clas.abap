CLASS /thkr/cl_salv_event DEFINITION
  PUBLIC
  INHERITING FROM /thkr/cl_easy_salv
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor
      IMPORTING
        !it_event TYPE /thkr/t_dto_event OPTIONAL .
  PROTECTED SECTION.

    METHODS fill_data
        REDEFINITION .
    METHODS set_event_handling
        REDEFINITION .
private section.

  data T_EVENT type /THKR/T_DTO_EVENT .
  data APPL type ref to /THKR/CL_BFW_APPL .
  constants C_NAME_FUGR type SYREPID value '/THKR/SAPLGUI' ##NO_TEXT.
  constants C_GUI_STATUS type SYPFKEY value 'SALV_EVENT' ##NO_TEXT.
  constants C_GUI_TITLE type LVC_TITLE value 'Meldungen' ##NO_TEXT.
  constants C_REPORT_NAME type REPID value '/THKR/CL_SALV_EVENT' ##NO_TEXT.

  methods HANDLE_DOUBLE_CLICK
    for event DOUBLE_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN .
ENDCLASS.



CLASS /THKR/CL_SALV_EVENT IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    IF it_event IS NOT INITIAL.
      t_event = it_event.
    ENDIF.

    gui_status  = c_gui_status.
    gui_title   = c_gui_title.
    report_name = c_report_name.
    name_fugr   = c_name_fugr.

    appl = /thkr/cl_bfw_appl=>get_lsa_appl( ).

    APPEND 'T_LN_EVT' TO techfields.
    APPEND 'XSTRING'   TO techfields.

  ENDMETHOD.


  METHOD fill_data.

    FIELD-SYMBOLS <selection> TYPE /thkr/s_event_selection.

    IF selection IS NOT INITIAL.

      ASSIGN selection->* TO <selection>.

      appl->get_tdto_event(
        EXPORTING
          i_selection      = <selection>
        IMPORTING
          e_tdto_event = t_event ).
    ENDIF.

    GET REFERENCE OF t_event INTO t_data_ref.

  ENDMETHOD.


  METHOD handle_double_click.

    DATA: l_oerror   TYPE REF TO cx_root,
          lt_mapping TYPE /thkr/t_gi_mapping_line.

    READ TABLE t_event INDEX row INTO DATA(l_dto).

    IF l_dto-xstring IS INITIAL.
      appl->get_dto_event(
        EXPORTING
          i_event_id = l_dto-id
        IMPORTING
          e_dto      = l_dto ).
    ENDIF.

    IF l_dto-xstring IS NOT INITIAL.

      TRY .
          CALL TRANSFORMATION id
            SOURCE XML l_dto-xstring
            RESULT error = l_oerror.

          IF l_oerror IS NOT INITIAL.

            /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).
          ELSE.
            CALL FUNCTION 'DISPLAY_XML_STRING'
              EXPORTING
                xml_string = l_dto-xstring.
          ENDIF.

        CATCH cx_root.

          ASSERT 1 = 2.

      ENDTRY.

    ENDIF.

  ENDMETHOD.


  METHOD set_event_handling.
    super->set_event_handling( ).

    DATA: l_events         TYPE REF TO cl_salv_events_table.

*   Eventverarbeitung festlegen
    l_events = salv->get_event( ).
    SET HANDLER handle_double_click FOR l_events.

  ENDMETHOD.
ENDCLASS.
