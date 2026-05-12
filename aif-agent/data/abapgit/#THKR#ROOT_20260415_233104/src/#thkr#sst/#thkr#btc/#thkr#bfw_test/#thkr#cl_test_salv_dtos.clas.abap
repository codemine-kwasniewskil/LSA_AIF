CLASS /thkr/cl_test_salv_dtos DEFINITION
  PUBLIC
  INHERITING FROM /thkr/cl_easy_salv
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS constructor .
  PROTECTED SECTION.
    METHODS fill_data
        REDEFINITION .
    METHODS set_event_handling
        REDEFINITION .
  PRIVATE SECTION.

    CONSTANTS c_name_fugr TYPE syrepid VALUE 'SAPL/THKR/GUI' ##NO_TEXT.
    CONSTANTS c_gui_status TYPE sypfkey VALUE 'SALV_ERRORS' ##NO_TEXT.
    CONSTANTS c_report_name TYPE repid VALUE '/THKR/CL_TEST_SALV_DTOS' ##NO_TEXT.
    DATA c_gui_title TYPE lvc_title VALUE 'DTOs' ##NO_TEXT.
    DATA tdto TYPE /thkr/t_dto .

    METHODS handle_double_click
          FOR EVENT double_click OF cl_salv_events_table
      IMPORTING
          !row
          !column .
ENDCLASS.



CLASS /THKR/CL_TEST_SALV_DTOS IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    gui_status  = c_gui_status.
    gui_title   = c_gui_title.
    report_name = c_report_name.
    name_fugr   = c_name_fugr.

    APPEND 'DTO_REF' TO techfields.
    APPEND 'IS_ERROR' TO checkboxfields.

    CLEAR checkboxes_as_hotspots.

  ENDMETHOD.


  METHOD fill_data.

    DATA: l_oerror TYPE REF TO cx_root,
          l_mess   TYPE string.

    FIELD-SYMBOLS <selection> TYPE /thkr/s_dto_selection.

    ASSIGN selection->* TO <selection>.


    /thkr/cl_test_appl=>get_instance( )->get_object_data(
      EXPORTING
        i_object_type     = <selection>-object_type
        i_object_id       = <selection>-object_id
      IMPORTING
        et_dto          = tdto ).

    CONCATENATE 'Object Type/ID :' <selection>-object_type '/' <selection>-object_id
      INTO gui_title SEPARATED BY space.

    GET REFERENCE OF tdto INTO t_data_ref.


  ENDMETHOD.


  METHOD handle_double_click.

    DATA: l_xmlstr    TYPE xstring.

    FIELD-SYMBOLS: <line> LIKE LINE OF tdto,
                   <dto>  TYPE data.

    READ TABLE tdto INDEX row ASSIGNING <line>.
    IF sy-subrc = 0.

      ASSIGN <line>-dto_ref->* TO <dto>.

      CALL TRANSFORMATION id
        SOURCE dto = <dto>
        RESULT XML l_xmlstr.

      CALL FUNCTION 'DISPLAY_XML_STRING'
        EXPORTING
          xml_string = l_xmlstr.

    ENDIF.

  ENDMETHOD.


  METHOD set_event_handling.
    super->set_event_handling( ).

    DATA: l_events         TYPE REF TO cl_salv_events_table.

* Eventverarbeitung festlegen
    l_events = salv->get_event( ).
    SET HANDLER handle_double_click FOR l_events.

  ENDMETHOD.
ENDCLASS.
