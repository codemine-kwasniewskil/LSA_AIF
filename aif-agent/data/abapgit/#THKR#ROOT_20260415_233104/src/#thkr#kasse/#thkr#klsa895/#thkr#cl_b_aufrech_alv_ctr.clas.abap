CLASS /thkr/cl_b_aufrech_alv_ctr DEFINITION
  PUBLIC
  INHERITING FROM /thkr/cl_alv_base_ctr
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      so_name TYPE RANGE OF bu_name .
    TYPES:
      so_plz     TYPE RANGE OF post_code .
    TYPES:
      so_epl     TYPE RANGE OF fm_fonds .
    METHODS constructor
      IMPORTING
        !s_bpname TYPE so_name OPTIONAL
        !s_plz    TYPE so_plz OPTIONAL
        !s_epl    TYPE so_epl OPTIONAL.

    METHODS on_link_click
        REDEFINITION .
protected section.

  data S_NAME type SO_NAME .
  data S_PLZ type SO_PLZ .
  data S_EPL type SO_EPL .

  methods GET_DATA_FROM_CUBE
    redefinition .
  methods SET_ALV_HOTSPOT_COLUMNS
    redefinition .
  methods SET_ALV_SORTS
    redefinition .
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_B_AUFRECH_ALV_CTR IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    me->s_name = s_bpname.
    me->s_plz  = s_plz.
    me->s_epl  = s_epl.
  ENDMETHOD.


  METHOD get_data_from_cube.
    SELECT FROM /thkr/cds_aufr_cube
      FIELDS
*             debitor,
*             kreditor,
             name,
      epl,
             deb_kassz  AS kassz_ford,
             d_bukrs    AS d_bkr,
             kre_kassz  AS kassz_ausz,
             k_bukrs    AS k_bkr,
             forderung,
             offenezahlung AS offene_zahlung
      WHERE  name IN @me->s_name
         AND plz  IN @me->s_plz
         AND epl  IN @me->s_epl
      INTO TABLE @DATA(cube).

** Store data
    DATA(table_desc) = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( p_data = cube ) ).
    CREATE DATA me->datacube TYPE HANDLE table_desc.
    ASSIGN me->datacube TO FIELD-SYMBOL(<datatable>).
    <datatable>->* = cube.
  ENDMETHOD.


  METHOD on_link_click.
    " Get required value:
    LOOP AT me->datacube->* ASSIGNING FIELD-SYMBOL(<line>).
      IF sy-tabix = row.
        ASSIGN COMPONENT column OF STRUCTURE <line> TO FIELD-SYMBOL(<value>).
        EXIT.
      ENDIF.
    ENDLOOP.

    CHECK <value> IS ASSIGNED.
    SUBMIT /thkr/fi_fk850_k_journal WITH s_xblnr EQ <value> AND RETURN.

  ENDMETHOD.


  METHOD set_alv_hotspot_columns.
    columns = VALUE #( ( 'KASSZ_FORD' )
                       ( 'KASSZ_AUSZ' ) ).

  ENDMETHOD.


  METHOD set_alv_sorts.
    me->salv->get_sorts( )->add_sort( columnname = 'NAME' subtotal = abap_true sequence = if_salv_c_sort=>sort_up ).
    me->salv->get_sorts( )->add_sort( columnname = 'KASSZ_FORD' subtotal = abap_true sequence = if_salv_c_sort=>sort_up group = if_salv_c_sort=>group_with_underline ).
  ENDMETHOD.
ENDCLASS.
