class /THKR/CL_SALV_MIG_RUNS definition
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
private section.

  data T_DTO_MIG_RUN type /THKR/T_DTO_MIG_IMP .
  constants C_GUI_STATUS type SYPFKEY value 'SALV_MIG_AO_SAP' ##NO_TEXT.
  constants C_GUI_TITLE type LVC_TITLE value 'Migrationimporte' ##NO_TEXT.
  constants C_NAME_FUGR type SYREPID value '/THKR/SAPLMIG_GUI' ##NO_TEXT.
  constants C_REPORT_NAME type REPID value 'CL_SALV_MIG_RUNS' ##NO_TEXT.
  data APPL type ref to /THKR/CL_MIG_APPL .

  methods SHOW_MESSAGES
    importing
      !I_SELECTION type /THKR/S_EVENT_SELECTION .
ENDCLASS.



CLASS /THKR/CL_SALV_MIG_RUNS IMPLEMENTATION.


  METHOD constructor.


    super->constructor( ).

    report_name = c_report_name.

    gui_status  = c_gui_status.

    gui_title = c_gui_title.

    name_fugr   = c_name_fugr.

    appl = /thkr/cl_mig_appl=>get_instance( ).

    APPEND 'FLAG_ERROR'   TO checkboxfields.
    APPEND 'FLAG_WARNING' TO checkboxfields.

    CLEAR: checkboxes_as_hotspots.

  ENDMETHOD.


  METHOD fill_data.

* runs

    FIELD-SYMBOLS <selection> TYPE /THKR/S_MIG_RUN_SELECTION.




    ASSIGN selection->* TO <selection>.

    appl->get_tdto_mig_run(
      EXPORTING
        i_selection = <selection>
      IMPORTING
        et_dto      = t_dto_mig_run ).



    GET REFERENCE OF t_dto_mig_run INTO t_data_ref.



  ENDMETHOD.


  METHOD handle_added_function.
    super->handle_added_function(
      e_salv_function = e_salv_function ).

    DATA: l_selections      TYPE REF TO cl_salv_selections,
          l_event_selection TYPE /thkr/s_event_selection,
          l_rows            TYPE salv_t_row,
          l_row             TYPE i,
          l_xmlstr          TYPE xstring,
          lt_options        TYPE TABLE OF string,
          l_oerror          TYPE REF TO cx_root.


    l_selections = salv->get_selections( ).
    l_rows       = l_selections->get_selected_rows( ).

    READ TABLE l_rows INDEX 1 INTO l_row.
    IF sy-subrc = 0.

      READ TABLE t_dto_mig_run INDEX l_row ASSIGNING FIELD-SYMBOL(<line>).
    ENDIF.

    TRY.
        CASE e_salv_function.

          WHEN 'SHOW_MESS'.

            IF <line> IS ASSIGNED.

              l_event_selection-process_id   = <line>-process_id.
              l_event_selection-process_type = <line>-process_type.
              show_messages( i_selection = l_event_selection ).

            ENDIF.

        ENDCASE.
      CATCH cx_root INTO l_oerror.
        /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).
    ENDTRY.

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
