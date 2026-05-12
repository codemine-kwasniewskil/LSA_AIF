class /THKR/CL_B_CASHPOOL_LB_ALV_CTR definition
  public
  inheriting from /THKR/CL_ALV_BASE_CTR
  create public .

public section.

  types:
    so_kapitel     TYPE RANGE OF /thkr/psm_fipos_kapitel .

  methods CONSTRUCTOR
    importing
      !S_KAPITEL type SO_KAPITEL optional .
protected section.

  data S_KAPITEL type SO_KAPITEL .

  methods GET_DATA_FROM_CUBE
    redefinition .
  methods SET_ALV_SORTS
    redefinition .
  methods SET_ALV_HEADER
    redefinition .
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_B_CASHPOOL_LB_ALV_CTR IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    me->s_kapitel = s_kapitel.
  ENDMETHOD.


  METHOD get_data_from_cube.
    SELECT FROM /thkr/cds_cash_lbhs_cube
      FIELDS kapitel
            ,titel
            ,bezeichnung
            , SUM( gezahlt ) +  SUM( solloriginalbetrag ) AS ist_betrag
            , SUM( gezahlt ) AS forderung
            , SUM( solloriginalbetrag ) AS verbindlichk
      WHERE  kapitel IN @me->s_kapitel
      GROUP BY kapitel
              ,titel
              ,bezeichnung
      INTO TABLE @DATA(cube).

** Store data
    DATA(table_desc) = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( p_data = cube ) ).
    CREATE DATA me->datacube TYPE HANDLE table_desc.
    ASSIGN me->datacube TO FIELD-SYMBOL(<datatable>).
    <datatable>->* = cube.
  ENDMETHOD.


  method SET_ALV_HEADER.
    me->salv->get_display_settings( )->set_list_header( 'Cashpool LB/HS' ).

  endmethod.


  METHOD SET_ALV_SORTS.
    me->salv->get_sorts( )->add_sort( columnname = 'KAPITEL' subtotal = abap_true sequence = if_salv_c_sort=>sort_up group = if_salv_c_sort=>group_with_underline ).
    me->salv->get_aggregations( )->add_aggregation( columnname = 'IST_BETRAG' aggregation = if_salv_c_aggregation=>total ).
    me->salv->get_aggregations( )->add_aggregation( columnname = 'FORDERUNG' aggregation = if_salv_c_aggregation=>total ).
    me->salv->get_aggregations( )->add_aggregation( columnname = 'VERBINDLICHK' aggregation = if_salv_c_aggregation=>total ).

*    me->salv->get_sorts( )->add_sort( columnname = 'TITEL' subtotal = abap_true sequence = if_salv_c_sort=>sort_up ).
**    me->salv->get_sorts( )->add_sort( columnname = 'KASSZ_FORD' subtotal = abap_true sequence = if_salv_c_sort=>sort_up group = if_salv_c_sort=>group_with_underline ).
  ENDMETHOD.
ENDCLASS.
