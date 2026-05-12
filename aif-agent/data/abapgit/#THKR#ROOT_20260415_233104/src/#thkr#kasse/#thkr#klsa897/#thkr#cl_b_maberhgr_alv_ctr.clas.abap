class /THKR/CL_B_MABERHGR_ALV_CTR definition
  public
  inheriting from /THKR/CL_ALV_BASE_CTR
  create public .

public section.

  types:
    BEGIN OF ty_omaberhgrcube,
             anzahl TYPE smi_counter.
             INCLUDE TYPE /thkr/cds_omaberhgrbjcube."/thkr/cds_oeplhgrcube.
    TYPES:  END OF  ty_omaberhgrcube .
  types:
    SO_BUKRS TYPE RANGE OF BUKRS .
  types:
    SO_BLDAT TYPE RANGE OF BLDAT .
  types:
    omaberhgrcube TYPE TABLE OF ty_omaberhgrcube .

  methods CONSTRUCTOR
    importing
      !GJAHR type GJAHR
      !BUKRS type SO_BUKRS
      !NO_STUNDUNG type ABAP_BOOL
      !NO_NEBENFORDERUNG type ABAP_BOOL
      !BLDAT type SO_BLDAT .

  methods DISPLAY_DATA
    redefinition .
  methods ON_CLOSE
    redefinition .
  methods ON_LINK_CLICK
    redefinition .
protected section.

  data GJAHR type GJAHR .
  data S_BUKRS type SO_BUKRS .
  data CUBE_WO_FIPEX type OMABERHGRCUBE .
  data OUTPUT_DATATABLE type ref to DATA .
  data NO_STUNDUNG type ABAP_BOOL .
  data NO_NEBENFORDERUNG type ABAP_BOOL .
  data S_BLDAT type SO_BLDAT .

  methods SHOW_FIPOS_POPUP
    importing
      !ROW type BP_GEBER
      !COL type /THKR/PSM_FIPOS_HAUPTGRUPPE .
  methods CREATE_DATA_TABLE
    importing
      !CUBEDATA type OMABERHGRCUBE
    returning
      value(DATATABLE) type ref to DATA .
  methods GET_HGR_LIST
    importing
      !CUBEDATA type OMABERHGRCUBE
    returning
      value(HAUPTGRUPPEN) type /THKR/PSM_FIPOS_HAUPTGRUPPEN .
  methods SET_SALV_CONFIG .

  methods GET_DATA_FROM_CUBE
    redefinition .
private section.
ENDCLASS.



CLASS /THKR/CL_B_MABERHGR_ALV_CTR IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    me->gjahr             = gjahr.
    me->s_bukrs           = bukrs.
    me->no_stundung       = no_stundung.
    me->no_nebenforderung = no_nebenforderung.
    me->s_bldat           = bldat.
  ENDMETHOD.


  METHOD create_data_table.
** DEFINE structure depending ON given DATA:
    data header TYPE abap_component_tab.
    DATA(grps) = me->get_hgr_list( cubedata ).
    header = VALUE #( ( name = 'MABER' type = cl_abap_elemdescr=>get_c( 2 ) ) ).
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
                                                   p_key        = VALUE #( ( name = 'MABER' ) )
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
    LOOP AT cubedata ASSIGNING FIELD-SYMBOL(<cubeline>) GROUP BY <cubeline>-maber ASSIGNING FIELD-SYMBOL(<grp>).
      CLEAR: <dataline>, summa, sum_anzahl.
      DATA(celltype) = VALUE salv_t_int4_column( ).
      "" Loop at EPL as group and fill row:
      LOOP AT GROUP <grp> ASSIGNING FIELD-SYMBOL(<hgline>).
        ASSIGN COMPONENT 'MABER' OF STRUCTURE <dataline> TO FIELD-SYMBOL(<field>).
        <field> = <hgline>-maber.
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


  method DISPLAY_DATA.
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
  endmethod.


  METHOD get_data_from_cube.
    "Werte hole ich mir über Zwei Checkboxen
    DATA: ausschluss_nebenforderung TYPE string VALUE 'MG#MO#SG#SN#VK#VO#EL#HB#HO#AH#AN#AW#GK#GO#HA#'.
    DATA: ausschluss_stundung       TYPE string VALUE 'SD'.
    DATA: lt_nebenforderung         TYPE STANDARD TABLE OF string.
    DATA: lt_stundung               TYPE STANDARD TABLE OF string.
    DATA: s_blart                   TYPE RANGE OF blart.
    DATA: ls_blart                  LIKE LINE OF s_blart.
    SPLIT ausschluss_nebenforderung AT '#' INTO TABLE lt_nebenforderung.
    SPLIT ausschluss_stundung AT '#' INTO TABLE lt_stundung.

    IF me->no_nebenforderung IS NOT INITIAL.
      LOOP AT lt_nebenforderung INTO DATA(lv_neben).
        IF lv_neben IS NOT INITIAL.
          CLEAR ls_blart.
          ls_blart-sign   = 'E'.   " Exclude
          ls_blart-option = 'EQ'.  " Equal
          ls_blart-low    = lv_neben.
          APPEND ls_blart TO s_blart.
        ENDIF.
      ENDLOOP.
    ENDIF.

    " Ausschluss für Stundung
    IF me->no_stundung IS NOT INITIAL.
      LOOP AT lt_stundung INTO DATA(lv_stund).
        IF lv_stund IS NOT INITIAL.
          CLEAR ls_blart.
          ls_blart-sign   = 'E'.
          ls_blart-option = 'EQ'.
          ls_blart-low    = lv_stund.
          APPEND ls_blart TO s_blart.
        ENDIF.
      ENDLOOP.
    ENDIF.


    SELECT FROM /thkr/cds_omaberhgrcube( p_gjahr = @me->gjahr )
               FIELDS maber, hg,
                      SUM( anzahl ) AS anzahl,
                      SUM( betrag ) AS betrag
                 WHERE  bukrs    IN @me->s_bukrs
                    AND betrag <> 0
                    AND AccountingDocumentType IN @s_blart
                    AND DocumentDate in @s_bldat
                GROUP BY  maber, hg
                ORDER BY maber
          INTO CORRESPONDING FIELDS OF TABLE @me->cube_wo_fipex.

** Store data
*    DATA(table_desc) = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( p_data = cube ) ).
*    CREATE DATA me->datacube TYPE HANDLE table_desc.
*    ASSIGN me->datacube TO FIELD-SYMBOL(<datatable>).
*    <datatable>->* = cube.
  ENDMETHOD.


  METHOD get_hgr_list.
    hauptgruppen = VALUE #( FOR GROUPS grp OF <line> IN cubedata GROUP BY <line>-hg WITHOUT MEMBERS ( grp  ) ).
    SORT hauptgruppen BY table_line.
  ENDMETHOD.


  METHOD on_close.
    IF me->container IS NOT INITIAL.
      me->container->free( ).
    ENDIF.
  ENDMETHOD.


  METHOD on_link_click.
    LOOP AT me->output_datatable->* ASSIGNING FIELD-SYMBOL(<line>).
      IF sy-tabix = row.
        ASSIGN COMPONENT 'MABER' OF STRUCTURE <line> TO FIELD-SYMBOL(<maber>).
        ASSIGN COMPONENT column OF STRUCTURE <line> TO FIELD-SYMBOL(<betrag>).
        EXIT.
      ENDIF.
    ENDLOOP.
    IF <betrag> IS ASSIGNED AND <betrag> IS NOT INITIAL.
      me->show_fipos_popup( row = CONV #( <maber> ) col = column+4(1) ).
    ENDIF.
  ENDMETHOD.


  METHOD set_salv_config.
    TRY.
        SET HANDLER on_link_click FOR me->salv->get_event( ).
        " Set columnname as name for generated table
        LOOP AT me->salv->get_columns( )->get( ) ASSIGNING FIELD-SYMBOL(<col>).

          " Add row with sum values
          IF <col>-columnname = 'MABER'.
            <col>-r_column->set_short_text( CONV #( to_mixed( 'Mahnbereich' ) ) ).
            <col>-r_column->set_medium_text( CONV #( to_mixed( 'Mahnbereich' ) ) ).
            <col>-r_column->set_long_text( CONV #( to_mixed( 'Mahnbereich' ) ) ).
          ELSE.
            <col>-r_column->set_short_text( CONV #( to_mixed( <col>-columnname ) ) ).
            <col>-r_column->set_medium_text( CONV #( to_mixed( <col>-columnname ) ) ).
            <col>-r_column->set_long_text( CONV #( to_mixed( <col>-columnname ) ) ).
          ENDIF.
          IF <col>-columnname CP 'HGR*'
          OR <col>-columnname = 'ANZAHL'.
            me->salv->get_aggregations( )->add_aggregation( columnname = <col>-columnname aggregation = if_salv_c_aggregation=>total ).
          ENDIF.
        ENDLOOP.

        " Set Hotspot table
        me->salv->get_columns( )->set_cell_type_column( 'I_CELLTYPE' ).

        " Some markups
        me->salv->get_display_settings( )->set_vertical_lines( abap_true ).
        me->salv->get_display_settings( )->set_list_header( |Offene Forderungen nach Mahnbereichen und Hauptgruppen { me->gjahr }| ).
        me->salv->get_functions( )->set_all( abap_true ).
        me->salv->get_columns( )->set_optimize( abap_true ).
        me->salv->get_display_settings( )->set_striped_pattern( abap_true ).

      CATCH cx_salv_error.                              "#EC NO_HANDLER
    ENDTRY.
  ENDMETHOD.


  METHOD show_fipos_popup.
*** Select relevant data:

    SELECT FROM /thkr/cds_omaberhgrcube( p_gjahr = @me->gjahr )
           FIELDS fipex as finanzposition,
                  SUM( anzahl ) AS anzahl,
                  SUM( betrag ) AS betrag
             WHERE  maber    = @row
                AND hg     = @col
                AND betrag <> 0
            GROUP BY  fipex
      INTO TABLE @DATA(popupdata).

*    DELETE popupdata WHERE erledigt IS NOT INITIAL.

** Prepare Container for PopUp and run ALV Grid!
    TRY.
        DATA(i_style) = cl_gui_control=>ws_minimizebox + cl_gui_control=>ws_maximizebox.
        container = NEW cl_gui_dialogbox_container( no_autodef_progid_dynnr = abap_true
                                                    caption                 = |Finanzposition Mahnbereich: { row }|
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
ENDCLASS.
