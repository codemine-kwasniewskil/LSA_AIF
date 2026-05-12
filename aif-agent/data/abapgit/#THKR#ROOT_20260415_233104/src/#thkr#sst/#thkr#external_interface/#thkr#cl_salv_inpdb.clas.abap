class /THKR/CL_SALV_INPDB definition
  public
  inheriting from /THKR/CL_EASY_SALV
  final
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IT_INPDB type ref to /THKR/T_DE_INPDB .
protected section.

  methods FILL_DATA
    redefinition .
  methods HANDLE_COLUMNS
    redefinition .
private section.

  constants C_GUI_STATUS type SYPFKEY value 'SALV_DE_RUN1' ##NO_TEXT.
  constants C_GUI_TITLE type LVC_TITLE value 'Daten im Unit4-Import-Format' ##NO_TEXT.
  constants C_NAME_FUGR type SYREPID value '/THKR/SAPLEXT_IF_GUI' ##NO_TEXT.
  constants C_REPORT_NAME type REPID value 'CL_SALV_INPDB' ##NO_TEXT.
  data T_INPDB type ref to /THKR/T_DE_INPDB .
ENDCLASS.



CLASS /THKR/CL_SALV_INPDB IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).

    t_inpdb = it_inpdb.

    report_name = c_report_name.

    gui_status  = c_gui_status.

    gui_title = c_gui_title.

    name_fugr   = c_name_fugr.

  ENDMETHOD.


  METHOD fill_data.

    t_data_ref = t_inpdb.

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
        i_structure  = '/THKR/S_DE_INPDB'
       IMPORTING
        et_fieldlist = DATA(lt_fields) ).

    LOOP AT lt_fields INTO DATA(l_field).
      l_scrtext_s = l_field-lfd_nr.
      l_scrtext_m = l_field-fieldname.
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
*          IF l_field-leading_zero IS NOT INITIAL.
*            l_column->set_leading_zero('X').
*          ENDIF.
        CATCH cx_root .
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.
ENDCLASS.
