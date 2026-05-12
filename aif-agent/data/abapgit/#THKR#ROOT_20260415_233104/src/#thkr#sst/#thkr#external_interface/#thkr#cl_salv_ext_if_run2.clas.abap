class /THKR/CL_SALV_EXT_IF_RUN2 definition
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

  data APPL type ref to /THKR/CL_EXT_IF_APPL .
  data T_HVW type /THKR/T_DTO_DE_RUN_HVW .
  constants C_GUI_STATUS type SYPFKEY value 'SALV_DE_RUN' ##NO_TEXT.
  constants C_GUI_TITLE type LVC_TITLE value 'IHV-Schnittstelle: Einzelsätze' ##NO_TEXT.
  constants C_NAME_FUGR type SYREPID value '/THKR/SAPLEXT_IF_GUI' ##NO_TEXT.
  constants C_REPORT_NAME type REPID value 'CL_SALV_EXT_IF_RUN2' ##NO_TEXT.

  methods SHOW_MESSAGES
    importing
      !I_SELECTION type /THKR/S_EVENT_SELECTION
    raising
      /THKR/CX_LSA1 .
ENDCLASS.



CLASS /THKR/CL_SALV_EXT_IF_RUN2 IMPLEMENTATION.


  METHOD CONSTRUCTOR.

    super->constructor( ).

    report_name = c_report_name.

    gui_status  = c_gui_status.

    gui_title = c_gui_title.

    name_fugr   = c_name_fugr.

    appl = /thkr/cl_ext_if_appl=>get_instance( ).

  ENDMETHOD.


  method FILL_DATA.


    FIELD-SYMBOLS <selection> TYPE /thkr/s_de_run_selection.

    ASSIGN selection->* TO <selection>.

    appl->get_tdto_de_run_hvw(
      EXPORTING
        i_selection = <selection>
      IMPORTING
        et_dto      = t_hvw ).

    GET REFERENCE OF t_hvw INTO t_data_ref.endmethod.


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
      READ TABLE t_hvw INDEX l_row ASSIGNING FIELD-SYMBOL(<line>).

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
                  i_de_satz_id   = <line>-de_satz_id
                  ).
            ENDIF.

          WHEN 'SHOW_MESS'.

            IF <line> IS ASSIGNED.

              appl->get_key_ln_evt_by_imp_line(
                EXPORTING
                  i_process_type   = <line>-process_type
                  i_process_id     = <line>-process_id
                  i_line_key_value = CONV #( <line>-de_satz_id )
                IMPORTING
                  e_ln_art         = l_event_selection-ln_art
                  e_ln_key         = l_event_selection-ln_key ).

              show_messages( i_selection = l_event_selection ).

            ENDIF.

        ENDCASE.
      CATCH cx_root INTO DATA(l_oerror).
        /thkr/cl_helpers=>get_instance( )->display_exception( l_oerror ).
    ENDTRY.

  ENDMETHOD.


  METHOD SHOW_MESSAGES.

    DATA: l_salv_event TYPE REF TO /thkr/cl_salv_event.

    CREATE OBJECT l_salv_event.

    l_salv_event->display(
      EXPORTING
        i_selection = i_selection ).


  ENDMETHOD.
ENDCLASS.
