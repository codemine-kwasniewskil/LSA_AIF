class /THKR/CL_B_JVAABRECH_ALV_CTR definition
  public
  inheriting from /THKR/CL_ALV_BASE_CTR
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !GJAHR type GJAHR optional
      !KAPITEL type /THKR/PSM_FIPOS_KAPITEL
      !TITEL type /THKR/PSM_FIPOS_TITEL .
protected section.

  data GJAHR type GJAHR .
  data FONDS type BP_GEBER .
  data KAPITEL type /THKR/PSM_FIPOS_KAPITEL .
  data TITEL type /THKR/PSM_FIPOS_TITEL .

  methods GET_DATA_FROM_CUBE
    redefinition .
  methods SET_ALV_HEADER
    redefinition .
  methods SET_ALV_SORTS
    redefinition .
private section.
ENDCLASS.



CLASS /THKR/CL_B_JVAABRECH_ALV_CTR IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    me->gjahr   = gjahr.
    me->kapitel = kapitel.
    me->titel   = titel.

  ENDMETHOD.


  METHOD get_data_from_cube.

    SELECT FROM /thkr/cds_jvaabrcube
      FIELDS
          kassenzeichen
         ,belegart
         ,SUM( betrag ) AS betrag
         ,twaer AS wa
*         ,fipex
      WHERE
            fikrs   = 1000
        AND gjahr   = @me->gjahr
        AND kapitel = @me->kapitel
        AND titel   = @me->titel
      GROUP BY  kassenzeichen
               ,belegart
               ,twaer
*               ,fipex
    INTO TABLE @DATA(cube).

** Store data
    DATA(table_desc) = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( p_data = cube ) ).
    CREATE DATA me->datacube TYPE HANDLE table_desc.
    ASSIGN me->datacube TO FIELD-SYMBOL(<datatable>).
    <datatable>->* = cube.
  ENDMETHOD.


  METHOD set_alv_header.

    me->salv->get_display_settings( )->set_list_header( |JVA Abrechnung  { me->kapitel } { me->titel }| ).

  ENDMETHOD.


  METHOD set_alv_sorts.
    me->salv->get_aggregations( )->add_aggregation( columnname = 'BETRAG' aggregation = if_salv_c_aggregation=>total ).
    me->salv->get_sorts( )->add_sort( columnname = 'KASSENZEICHEN' subtotal = abap_true sequence = if_salv_c_sort=>sort_up ).
  ENDMETHOD.
ENDCLASS.
