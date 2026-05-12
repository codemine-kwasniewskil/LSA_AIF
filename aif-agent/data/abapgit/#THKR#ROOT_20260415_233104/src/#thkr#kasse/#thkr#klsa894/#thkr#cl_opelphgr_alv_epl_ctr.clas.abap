class /THKR/CL_OPELPHGR_ALV_EPL_CTR definition
  public
  create public .

public section.

  types:
    BEGIN OF ty_oeplhgrcube,
             anzahl TYPE smi_counter.
             INCLUDE TYPE /thkr/cds_oeplhgrbjcube."/thkr/cds_oeplhgrcube.
    TYPES:  END OF  ty_oeplhgrcube .
  types:
    oeplhgrcube TYPE TABLE OF ty_oeplhgrcube .
  types:
    epl_range   TYPE RANGE OF bp_geber .
  types:
    so_bldat   TYPE RANGE OF bldat .

  data SALV type ref to CL_SALV_TABLE .

  methods CONSTRUCTOR
    importing
      !GJAHR type GJAHR
      !EPL type EPL_RANGE
      !BLDAT type SO_BLDAT .
  methods DISPLAY_DATA .
  methods ON_CLOSE
    for event CLOSE of CL_GUI_DIALOGBOX_CONTAINER .
  methods ON_LINK_CLICK
    for event LINK_CLICK of CL_SALV_EVENTS_TABLE
    importing
      !ROW
      !COLUMN
      !SENDER .
protected section.

  data CUBE_WITH_FIPEX type OEPLHGRCUBE .
  data CUBE_WO_FIPEX type OEPLHGRCUBE .
  data CONTAINER type ref to CL_GUI_DIALOGBOX_CONTAINER .
  data OUTPUT_DATATABLE type ref to DATA .
  data GJAHR type GJAHR .
  data EPL type EPL_RANGE .
  data S_BLDAT type SO_BLDAT .

  methods CREATE_DATA_TABLE
    importing
      !CUBEDATA type OEPLHGRCUBE
    returning
      value(DATATABLE) type ref to DATA .
  methods GET_DATA_FROM_CUBE .
  methods GET_HGR_LIST
    importing
      !CUBEDATA type OEPLHGRCUBE
    returning
      value(HAUPTGRUPPEN) type /THKR/PSM_FIPOS_HAUPTGRUPPEN .
  methods SET_SALV_CONFIG
    raising
      CX_SALV_EXISTING
      CX_SALV_NOT_FOUND .
  methods SHOW_FIPOS_POPUP
    importing
      !ROW type BP_GEBER
      !COL type /THKR/PSM_FIPOS_HAUPTGRUPPE .
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_OPELPHGR_ALV_EPL_CTR IMPLEMENTATION.


  METHOD constructor.

    me->gjahr = gjahr.
    me->epl   = epl.
    me->s_bldat = bldat.

  ENDMETHOD.


  METHOD create_data_table.

** Define structure depending on given data:
    DATA header TYPE abap_component_tab.
    DATA(grps) = me->get_hgr_list( cubedata ).
    header = VALUE #( ( name = 'EPL' type = cl_abap_elemdescr=>get_c( 2 ) ) ).
    header = VALUE #( BASE header FOR grp IN grps
                      ( name = |HGR_{ grp }| type = cl_abap_elemdescr=>get_p( p_length = 7 p_decimals = 2 ) ) ).
    header = VALUE #( BASE header ( name = 'Summe' type = cl_abap_elemdescr=>get_p( p_length = 7 p_decimals = 2 ) ) ).
    header = VALUE #( BASE header ( name = 'Anzahl' type = cl_abap_elemdescr=>get_int8( ) ) ).
    header = VALUE #( BASE header ( name = 'I_CELLTYPE' type = CAST #( cl_abap_elemdescr=>describe_by_name( 'SALV_T_INT4_COLUMN' ) ) ) ).

** Create structure and table
    DATA(line_desc)  = cl_abap_structdescr=>create( VALUE cl_abap_structdescr=>component_table( ( LINES OF header ) ) ).
    DATA(table_desc) = cl_abap_tabledescr=>create( p_line_type  = line_desc
                                                   p_table_kind = cl_abap_tabledescr=>tablekind_std
                                                   p_unique     = abap_false
                                                   p_key        = VALUE #( ( name = 'EPL' ) )
                                                   p_key_kind   = cl_abap_tabledescr=>keydefkind_user ).

** Create data objects
    DATA dataline   TYPE REF TO data.
    DATA summa      TYPE wrbtr.
    DATA sum_anzahl TYPE smi_counter.
    CREATE DATA dataline  TYPE HANDLE line_desc.
    CREATE DATA datatable TYPE HANDLE table_desc.
    ASSIGN datatable->*   TO FIELD-SYMBOL(<datatable>).
    ASSIGN dataline->*    TO FIELD-SYMBOL(<dataline>).

** Transform Cubedata into generic output table
    LOOP AT cubedata ASSIGNING FIELD-SYMBOL(<cubeline>) GROUP BY <cubeline>-epl ASSIGNING FIELD-SYMBOL(<grp>).
      CLEAR: <dataline>, summa, sum_anzahl.
      DATA(celltype) = VALUE salv_t_int4_column( ).
      "" Loop at EPL as group and fill row:
      LOOP AT GROUP <grp> ASSIGNING FIELD-SYMBOL(<hgline>).
        ASSIGN COMPONENT 'EPL' OF STRUCTURE <dataline> TO FIELD-SYMBOL(<field>).
        <field> = <hgline>-epl.
        ASSIGN COMPONENT |HGR_{ <hgline>-hg }| OF STRUCTURE <dataline> TO <field>.
        <field> = <hgline>-betrag.

        sum_anzahl += <hgline>-anzahl.
        summa      += <hgline>-betrag.
        celltype   = VALUE #( BASE celltype ( columnname = |HGR_{ <hgline>-hg }| value = if_salv_c_cell_type=>hotspot ) ).
      ENDLOOP.
      "" Add sum, hotspot for every row
      ASSIGN COMPONENT 'SUMME' OF STRUCTURE <dataline> TO <field>.
      <field> = summa.
      ASSIGN COMPONENT 'ANZAHL' OF STRUCTURE <dataline> TO <field>.
      <field> = sum_anzahl.
      ASSIGN COMPONENT 'I_CELLTYPE' OF STRUCTURE <dataline> TO <field>.
      <field> = celltype.
      "" Add row to generic table
      INSERT <dataline> INTO TABLE <datatable>.
    ENDLOOP.

  ENDMETHOD.


  METHOD on_close.
    IF me->container IS NOT INITIAL.
      me->container->free( ).
    ENDIF.
  ENDMETHOD.


  METHOD on_link_click.

    LOOP AT me->output_datatable->* ASSIGNING FIELD-SYMBOL(<line>).
      IF sy-tabix = row.
        ASSIGN COMPONENT 'EPL' OF STRUCTURE <line> TO FIELD-SYMBOL(<epl>).
        ASSIGN COMPONENT column OF STRUCTURE <line> TO FIELD-SYMBOL(<betrag>).
        EXIT.
      ENDIF.
    ENDLOOP.
    IF <betrag> IS ASSIGNED AND <betrag> IS NOT INITIAL.
      me->show_fipos_popup( row = CONV #( <epl> ) col = column+4(1) ).
    ENDIF.

  ENDMETHOD.


  METHOD get_hgr_list.
    hauptgruppen = VALUE #( FOR GROUPS grp OF <line> IN cubedata GROUP BY <line>-hg WITHOUT MEMBERS ( grp  ) ).
    SORT hauptgruppen BY table_line.
  ENDMETHOD.


  METHOD set_salv_config.

    TRY.
        SET HANDLER on_link_click FOR me->salv->get_event( ).
        " Set columnname as name for generated table
        LOOP AT me->salv->get_columns( )->get( ) ASSIGNING FIELD-SYMBOL(<col>).
          <col>-r_column->set_short_text( CONV #( to_mixed( <col>-columnname ) ) ).
          <col>-r_column->set_medium_text( CONV #( to_mixed( <col>-columnname ) ) ).
          <col>-r_column->set_long_text( CONV #( to_mixed( <col>-columnname ) ) ).
          " Add row with sum values
          IF <col>-columnname CP 'HGR*'
          OR <col>-columnname = 'ANZAHL'.
            me->salv->get_aggregations( )->add_aggregation( columnname = <col>-columnname aggregation = if_salv_c_aggregation=>total ).
          ENDIF.
        ENDLOOP.

        " Set Hotspot table
        me->salv->get_columns( )->set_cell_type_column( 'I_CELLTYPE' ).

        " Some markups
        me->salv->get_display_settings( )->set_vertical_lines( abap_true ).
        me->salv->get_display_settings( )->set_list_header( |Offenen Forderungen nach Einzelplänen und Hauptgruppen { me->gjahr }| ).
        me->salv->get_functions( )->set_all( abap_true ).
        me->salv->get_columns( )->set_optimize( abap_true ).
        me->salv->get_display_settings( )->set_striped_pattern( abap_true ).

      CATCH cx_salv_error.                              "#EC NO_HANDLER
    ENDTRY.

  ENDMETHOD.


  METHOD get_data_from_cube.
*

    SELECT FROM /thkr/cds_oeplhgrcube( p_gjahr = @me->gjahr )
           FIELDS epl, hg,
                  SUM( anzahl ) AS anzahl,
                  SUM( betrag ) AS betrag
             WHERE  epl    IN @me->epl
                AND betrag <> 0
                AND DocumentDate IN @me->s_bldat
            GROUP BY  epl, hg
            ORDER BY epl
        INTO CORRESPONDING FIELDS OF TABLE @me->cube_wo_fipex.

  ENDMETHOD.


  METHOD show_fipos_popup.

*** Select relevant data:

    SELECT FROM /thkr/cds_oeplhgrcube( p_gjahr = @me->gjahr )
           FIELDS fipex as Finanzposition,
                  SUM( anzahl ) AS anzahl,
                  SUM( betrag ) AS betrag
             WHERE  epl    = @row
                AND hg     = @col
                AND betrag <> 0
            GROUP BY  fipex
      INTO TABLE @DATA(popupdata).

*    DELETE popupdata WHERE erledigt IS NOT INITIAL.

** Prepare Container for PopUp and run ALV Grid!
    TRY.
        DATA(i_style) = cl_gui_control=>ws_minimizebox + cl_gui_control=>ws_maximizebox.
        container = NEW cl_gui_dialogbox_container( no_autodef_progid_dynnr = abap_true
                                                    caption                 = |Finanzposition EPL: { row }|
                                                    top                     = 200
                                                    left                    = 400
                                                    width                   = 350
                                                    height                  = 400
                                                    style                   = i_style
                                                    metric                  = cl_gui_dialogbox_container=>metric_pixel ).

        SET HANDLER on_close FOR container.

        cl_salv_table=>factory( EXPORTING r_container  = container
                                IMPORTING r_salv_table = DATA(popup_salv)
                                CHANGING  t_table      = popupdata ).

        LOOP AT popup_salv->get_columns( )->get( ) ASSIGNING FIELD-SYMBOL(<col>).
          <col>-r_column->set_short_text( CONV #( to_mixed( <col>-columnname ) ) ).
          <col>-r_column->set_medium_text( CONV #( to_mixed( <col>-columnname ) ) ).
          <col>-r_column->set_long_text( CONV #( to_mixed( <col>-columnname ) ) ).
          IF  <col>-columnname = 'BETRAG'
           OR <col>-columnname = 'ANZAHL'.
            popup_salv->get_aggregations( )->add_aggregation( columnname = <col>-columnname aggregation = if_salv_c_aggregation=>total ).
          ENDIF.
        ENDLOOP.

        popup_salv->get_columns( )->set_optimize( abap_true ).
        popup_salv->get_display_settings( )->set_striped_pattern( abap_true ).
        popup_salv->get_functions( )->set_all( abap_false ).
        popup_salv->display( ).

      CATCH cx_root.
    ENDTRY.
  ENDMETHOD.


  METHOD display_data.

** Get all related data from cube!
    me->get_data_from_cube( ).

** Transform cube data to output list and init ALV
    TRY.
        me->output_datatable = me->create_data_table( me->cube_wo_fipex ).
        cl_salv_table=>factory( IMPORTING r_salv_table = me->salv
                                CHANGING  t_table      = me->output_datatable->* ).

** Set configs ( Hotspot, Layout etc )
        me->set_salv_config( ).

** Show ALV
        me->salv->display( ).
      CATCH cx_salv_error.
        " Shouldn't occur!
    ENDTRY.

  ENDMETHOD.
ENDCLASS.
