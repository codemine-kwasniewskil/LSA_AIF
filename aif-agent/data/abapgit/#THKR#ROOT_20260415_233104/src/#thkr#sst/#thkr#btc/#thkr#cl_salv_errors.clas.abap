class /THKR/CL_SALV_ERRORS definition
  public
  inheriting from /THKR/CL_EASY_SALV
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IT_ERROR type /THKR/T_ERROR
      !I_OERROR type ref to CX_ROOT .
protected section.

  methods FILL_DATA
    redefinition .
  methods HANDLE_ADDED_FUNCTION
    redefinition .
private section.

  data T_ERROR type /THKR/T_ERROR .
  constants C_NAME_FUGR type SYREPID value '/THKR/SAPLGUI' ##NO_TEXT.
  constants C_GUI_STATUS type SYPFKEY value 'SALV_ERRORS' ##NO_TEXT.
  constants C_GUI_TITLE type LVC_TITLE value 'Meldungen' ##NO_TEXT.
  constants C_REPORT_NAME type REPID value '/THKR/CL_SALV_ERRORS' ##NO_TEXT.
  data OERROR type ref to CX_ROOT .
ENDCLASS.



CLASS /THKR/CL_SALV_ERRORS IMPLEMENTATION.


  METHOD CONSTRUCTOR.

    super->constructor( ).

    gui_status  = c_gui_status.
    gui_title   = c_gui_title.
    report_name = c_report_name.
    name_fugr   = c_name_fugr.

    t_error = it_error.
    oerror  = i_oerror.

  ENDMETHOD.


  METHOD FILL_DATA.

    GET REFERENCE OF t_error INTO t_data_ref.

  ENDMETHOD.


  METHOD HANDLE_ADDED_FUNCTION.

    DATA: l_xmlstr TYPE xstring.

    super->handle_added_function(
        e_salv_function = e_salv_function
           ).


    IF e_salv_function = 'SHOW_XML'.
      CALL TRANSFORMATION id
        SOURCE error = oerror
        RESULT XML l_xmlstr.

      CALL FUNCTION 'DISPLAY_XML_STRING'
        EXPORTING
          xml_string = l_xmlstr.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
