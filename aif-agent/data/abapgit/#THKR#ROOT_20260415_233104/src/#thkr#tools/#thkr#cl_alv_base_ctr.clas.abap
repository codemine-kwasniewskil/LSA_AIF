class /THKR/CL_ALV_BASE_CTR definition
  public
  abstract
  create public .

public section.

  methods DISPLAY_DATA
    raising
      CX_SALV_ERROR .
  methods ON_CLOSE
    for event CLOSE of CL_GUI_DIALOGBOX_CONTAINER .
  methods ON_LINK_CLICK
    for event LINK_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN
      !SENDER .
protected section.

  data SALV type ref to CL_SALV_TABLE .
  data CONTAINER type ref to CL_GUI_DIALOGBOX_CONTAINER .
  data DATACUBE type ref to DATA .
  data LAYOUT type SLIS_VARI value 'DEFAULT' ##NO_TEXT.

  methods GET_DATA_FROM_CUBE .
  methods SET_ALV_COLUMNS
    raising
      CX_SALV_ERROR .
  methods SET_ALV_DISPLAY
    raising
      CX_SALV_ERROR .
  methods SET_ALV_HEADER
    raising
      CX_SALV_ERROR .
  methods SET_ALV_HOTSPOT .
  methods SET_ALV_HOTSPOT_COLUMNS
    returning
      value(COLUMNS) type SALV_T_COLUMN .
  methods SET_ALV_LAYOUT .
  methods SET_ALV_SORTS
    raising
      CX_SALV_ERROR .
  methods SET_DATA_ENHANCEMENT .
  methods SHOW_POPUP
    importing
      !ROW type CHAR20
      !COL type CHAR20 .
private section.
ENDCLASS.



CLASS /THKR/CL_ALV_BASE_CTR IMPLEMENTATION.


  METHOD display_data.
** Get all related data from cube!
    me->get_data_from_cube( ).
    me->set_data_enhancement( ).

** Transform cube data to output list and init ALV
    cl_salv_table=>factory( IMPORTING r_salv_table = me->salv
                            CHANGING  t_table      = me->datacube->* ).

    SET HANDLER on_link_click FOR me->salv->get_event( ).

    me->set_alv_columns( ).
    me->set_alv_header( ).
    me->set_alv_sorts( ).
    me->set_alv_display( ).
    me->set_alv_hotspot( ).
    me->set_alv_layout( ).
** Show ALV
    me->salv->display( ).

  ENDMETHOD.


  METHOD get_data_from_cube.
*    SELECT FROM <table>
*      FIELDS
**            <fields>
*      INTO TABLE @DATA(cubedata).

** Keep this lines
** Add this after your select to store data
*    DATA(table_desc) = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( cubedata ) ).
*    CREATE DATA me->datacube TYPE HANDLE table_desc.
*    ASSIGN me->datacube TO FIELD-SYMBOL(<datatable>).
*    <datatable>->* = cubedata.

  ENDMETHOD.


  METHOD ON_CLOSE.
** Demo Coding
*    IF me->container IS NOT INITIAL.
*      me->container->free( ).
*    ENDIF.
  ENDMETHOD.


  METHOD on_link_click.
    "" Get required value:
*    LOOP AT me->datacube->* ASSIGNING FIELD-SYMBOL(<line>).
*      IF sy-tabix = row.
*        ASSIGN COMPONENT column OF STRUCTURE <line> TO FIELD-SYMBOL(<value>).
*        EXIT.
*      ENDIF.
*    ENDLOOP.
    "" Do something with <value> for example
*    me->show_popup(
*      row = <value> " Characterfeld der Länge 10
*      col = column " Characterfeld der Länge 10
*    ).
  ENDMETHOD.


  METHOD show_popup.
*    "" Demo Coding for popup
*    TRY.
*        DATA(i_style) = cl_gui_control=>ws_minimizebox + cl_gui_control=>ws_maximizebox.
*        container = NEW cl_gui_dialogbox_container( no_autodef_progid_dynnr = abap_true
*                                                    caption                 = |Finanzposition EPL: { row }|
*                                                    top                     = 200
*                                                    left                    = 400
*                                                    width                   = 300
*                                                    height                  = 400
*                                                    style                   = i_style
*                                                    metric                  = cl_gui_dialogbox_container=>metric_pixel ).
*
*        SET HANDLER on_close FOR container.
*
*        cl_salv_table=>factory( EXPORTING r_container  = container
*                                IMPORTING r_salv_table = DATA(popup_salv)
*                                CHANGING  t_table      = <popop_data> ).
*
*        LOOP AT popup_salv->get_columns( )->get( ) ASSIGNING FIELD-SYMBOL(<col>).
*          <col>-r_column->set_short_text( CONV #( to_mixed( <col>-columnname ) ) ).
*          <col>-r_column->set_medium_text( CONV #( to_mixed( <col>-columnname ) ) ).
*          <col>-r_column->set_long_text( CONV #( to_mixed( <col>-columnname ) ) ).
*        ENDLOOP.
*
*        popup_salv->get_columns( )->set_optimize( abap_true ).
*        popup_salv->get_display_settings( )->set_striped_pattern( abap_true ).
*        popup_salv->get_functions( )->set_all( abap_false ).
*        popup_salv->display( ).
*
*      CATCH cx_root.
*    ENDTRY.
  ENDMETHOD.


  method SET_ALV_HEADER.

    me->salv->get_display_settings( )->set_list_header( 'Beschreibung' ).

  endmethod.


  METHOD set_alv_sorts.
** Demo:
*    me->salv->get_sorts( )->add_sort( columnname = 'BUKRS' subtotal = abap_true sequence = if_salv_c_sort=>sort_up ).

  ENDMETHOD.


  METHOD set_alv_display.
    " Set default config
    me->salv->get_functions( )->set_all( abap_true ).
    me->salv->get_columns( )->set_optimize( abap_true ).
    me->salv->get_display_settings( )->set_striped_pattern( abap_true ).
    " Set Hotspot table
    me->salv->get_columns( )->set_cell_type_column( 'I_CELLTYPE' ).
  ENDMETHOD.


  METHOD set_alv_columns.

    " Set columnname as name for generated table
    LOOP AT me->salv->get_columns( )->get( ) ASSIGNING FIELD-SYMBOL(<col>).
      <col>-r_column->set_short_text( CONV #( to_mixed( <col>-columnname ) ) ).
      <col>-r_column->set_medium_text( CONV #( to_mixed( <col>-columnname ) ) ).
      <col>-r_column->set_long_text( CONV #( to_mixed( <col>-columnname ) ) ).
    ENDLOOP.

  ENDMETHOD.


  METHOD set_alv_hotspot.
  "" Set HOTSPOT Fields defined in SET_ALV_HOTSPOT_COLUMNS
    LOOP AT me->datacube->* ASSIGNING FIELD-SYMBOL(<line>).
      ASSIGN COMPONENT 'I_CELLTYPE' OF STRUCTURE <line> TO FIELD-SYMBOL(<field>).
      IF <field> IS ASSIGNED.
        <field> = VALUE salv_t_int4_column( FOR item IN me->set_alv_hotspot_columns( ) ( columnname = item value = if_salv_c_cell_type=>hotspot ) ).
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD SET_DATA_ENHANCEMENT.
** This method adds the column I_CELLTYPE to the generic table structure to set hotspots explicity.
    TRY.
        "" Get columns from current table and add CELLTYPE
        DATA(table_desc) = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data_ref( me->datacube ) ).
        DATA(header) = CAST cl_abap_structdescr( table_desc->get_table_line_type( ) )->get_components( ).
        header = VALUE #( BASE header ( name = 'I_CELLTYPE' type = CAST #( cl_abap_elemdescr=>describe_by_name( 'SALV_T_INT4_COLUMN' ) ) ) ).
        "" Create new table and replace datacube with added CELLTYPE
        DATA(line_desc)  = cl_abap_structdescr=>create( VALUE cl_abap_structdescr=>component_table( ( LINES OF header ) ) ).
        DATA(table_desc_new) = cl_abap_tabledescr=>create( p_line_type  = line_desc
                                                           p_table_kind = cl_abap_tabledescr=>tablekind_std
                                                           p_unique     = abap_false
                                                           p_key        = VALUE #( ( name = header[ 1 ]-name ) )
                                                           p_key_kind   = cl_abap_tabledescr=>keydefkind_user ).
        "" Create data objects
        DATA l_dataline TYPE REF TO data.
        DATA l_datatable TYPE REF TO data.
        CREATE DATA l_dataline  TYPE HANDLE line_desc.
        CREATE DATA l_datatable TYPE HANDLE table_desc_new.
        ASSIGN l_datatable->* TO FIELD-SYMBOL(<datatable>).
        ASSIGN l_dataline->*  TO FIELD-SYMBOL(<dataline>).
        "" Transfer old to new structure
        LOOP AT me->datacube->* ASSIGNING FIELD-SYMBOL(<line>).
          <dataline> = CORRESPONDING #( <line> ).
          INSERT <dataline> INTO TABLE <datatable>.
        ENDLOOP.
        "" Reassign datacube to new table
        CREATE DATA me->datacube TYPE HANDLE table_desc_new.
        ASSIGN me->datacube TO FIELD-SYMBOL(<datacube>).
        <datacube>->* = <datatable>.
      CATCH cx_root.
        "
    ENDTRY.
  ENDMETHOD.


  METHOD set_alv_hotspot_columns.
*    columns = VALUE #( ( '<field1>' )
*                       ( '<field2>' ) ).
  ENDMETHOD.


  method SET_ALV_LAYOUT.
    me->salv->get_layout( )->set_initial_layout( me->layout ).
  endmethod.
ENDCLASS.
