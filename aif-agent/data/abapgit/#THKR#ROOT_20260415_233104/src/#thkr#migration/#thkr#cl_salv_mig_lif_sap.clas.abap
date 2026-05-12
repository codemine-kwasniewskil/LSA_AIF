class /THKR/CL_SALV_MIG_LIF_SAP definition
  public
  inheriting from /THKR/CL_EASY_SALV
  final
  create public .

public section.

  data T_DTO_MIG_LIF_SAP type /THKR/T_DTO_MIG_LIF .

  methods CONSTRUCTOR .
protected section.

  methods FILL_DATA
    redefinition .
  methods HANDLE_COLUMNS
    redefinition .
  methods HANDLE_ADDED_FUNCTION
    redefinition .
private section.

  data APPL type ref to /THKR/CL_MIG_APPL .
  constants C_GUI_STATUS type SYPFKEY value 'SALV_MIG_AO_SAP' ##NO_TEXT.
  constants C_GUI_TITLE type LVC_TITLE value 'Migration Zahlungspartner' ##NO_TEXT.
  constants C_NAME_FUGR type SYREPID value '/THKR/SAPLMIG_GUI' ##NO_TEXT.
  constants C_REPORT_NAME type REPID value 'CL_SALV_MIG_LIF_SAP' ##NO_TEXT.
  constants C_LINE_STRUCTURE type TABNAME value '/THKR/S_DTO_MIG_LIF' ##NO_TEXT.
ENDCLASS.



CLASS /THKR/CL_SALV_MIG_LIF_SAP IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    report_name = c_report_name.

    gui_status  = c_gui_status.

    gui_title = c_gui_title.

    name_fugr   = c_name_fugr.

    appl = /thkr/cl_mig_appl=>get_instance( ).

  ENDMETHOD.


  METHOD fill_data.

    FIELD-SYMBOLS <selection> TYPE /thkr/s_mig_lif_sap_selection.

    ASSIGN selection->* TO <selection>.

    appl->get_tdto_mig_lif(
     EXPORTING
       i_selection = <selection>
     IMPORTING
       et_dto      = t_dto_mig_lif_sap ).

    GET REFERENCE OF t_dto_mig_lif_sap INTO t_data_ref.

  ENDMETHOD.


  METHOD handle_added_function.

    super->handle_added_function( e_salv_function = e_salv_function ).

    DATA: l_selections      TYPE REF TO cl_salv_selections,
          l_event_selection TYPE /thkr/s_event_selection,
          l_rows            TYPE salv_t_row,
          l_answer          TYPE c,
          l_row             TYPE i,
          l_xmlstr          TYPE xstring,
          l_mig_lif_file    TYPE /thkr/s_mig_lif_file,
          l_selection       TYPE /thkr/s_mig_lif_sap_selection.

    l_selections = salv->get_selections( ).
    l_rows       = l_selections->get_selected_rows( ).

    READ TABLE l_rows INDEX 1 INTO l_row.
    IF sy-subrc = 0.
      "Attribut aus der Klasse (Daten aller Tabellen)
      READ TABLE t_dto_mig_lif_sap INDEX l_row ASSIGNING FIELD-SYMBOL(<line>).
    ENDIF.

    TRY.
        CASE e_salv_function.

          WHEN 'REFRESH'.

            refresh( ).


*          WHEN 'PROCESS'.
*
*            IF <line> IS ASSIGNED.
*              appl->process_mig_lif(
*                EXPORTING
*                  i_satz_id = <line>-satz_id ). "SCHLUESSEL  UCI
*              refresh(
*                EXPORTING
*                  refresh_mode = if_salv_c_refresh=>full ).
*            ENDIF.

        ENDCASE.

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
      WHERE rollname IS INITIAL.  "Alle Felder ohne Datenelement

      l_scrtext_s = l_field-lfd_nr.
      l_scrtext_m = l_field-scrtext_m.
      l_scrtext_l = l_field-scrtext_l.
      l_tooltip   = l_field-scrtext_l.

      TRY.
          l_column ?= l_columns->get_column(
            EXPORTING
              columnname = CONV #( l_field-fieldname ) ).
          l_column->set_short_text( l_scrtext_s ).
          l_column->set_medium_text( l_scrtext_m ).
          l_column->set_long_text( l_scrtext_l ).
          l_column->set_tooltip( l_tooltip ).

        CATCH cx_root .
      ENDTRY.


    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
