class /THKR/CL_B_HL_ZEITRAUM_ALV_CTR definition
  public
  inheriting from /THKR/CL_ALV_BASE_CTR
  create public .

public section.

  types:
    so_titel   TYPE RANGE OF /thkr/psm_fipos_titel .
  types:
    so_kapitel  TYPE RANGE OF /thkr/psm_fipos_kapitel .
  types:
    so_valut  TYPE RANGE OF valut .

  methods CONSTRUCTOR
    importing
      !GJAHR type GJAHR optional
      !FONDS type BP_GEBER
      !S_KAPITEL type SO_KAPITEL
      !S_TITEL type SO_TITEL
      !KOMPLEMENT type ABAP_BOOL
      !S_VALUT type SO_VALUT .

  methods ON_LINK_CLICK
    redefinition .
protected section.

  data GJAHR type GJAHR .
  data FONDS type BP_GEBER .
  data S_KAPITEL type SO_KAPITEL .
  data S_TITEL type SO_TITEL .
  data KOMPLEMENT type ABAP_BOOL .
  data S_VALUT type SO_VALUT .

  methods GET_DATA_FROM_CUBE
    redefinition .
  methods SET_ALV_HEADER
    redefinition .
  methods SET_ALV_HOTSPOT_COLUMNS
    redefinition .
  methods SET_ALV_SORTS
    redefinition .
private section.
ENDCLASS.



CLASS /THKR/CL_B_HL_ZEITRAUM_ALV_CTR IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    me->gjahr       = gjahr.
    me->fonds       = fonds.
    me->s_kapitel   = s_kapitel.
    me->s_titel     = s_titel.
    me->komplement  = komplement.
    me->s_valut     = s_valut.
  ENDMETHOD.


  method GET_DATA_FROM_CUBE.
** Base select statement
    DATA(where) = |fikrs = 1000 AND  epl = @me->fonds AND kapitel IN @me->s_kapitel AND titel IN @me->s_titel AND valutadatum IN @me->s_valut|.

*** Decide to show OPEN or CLOSED cases:
    DATA(having) = COND #( WHEN me->komplement = abap_true THEN |SUM( gezahlt ) = 0 AND SUM( offenessoll ) = 0|
                                                           ELSE |NOT ( SUM( gezahlt ) = 0 AND SUM( offenessoll ) = 0 )|  ).

    SELECT FROM /thkr/cds_hlzcube
      FIELDS
          kassenzeichen
         ,aktenzeichen
         ,STRING_AGG( kundenname,',' ) AS hinterleger
         ,STRING_AGG( verwendungszweck, ',' )  AS verwendungszweck
         ,SUM( gezahlt ) AS gezahlt
         ,SUM( offenessoll ) AS offenes_soll
         ,twaer AS waehrung
         ,fipex AS finanzpos
         ,MIN( valutadatum ) AS valutadatum

    WHERE (where)
    GROUP BY
          kassenzeichen
         ,aktenzeichen
         ,twaer
         ,fipex
    HAVING (having)
    INTO TABLE @DATA(cube).

** Store data
    DATA(table_desc) = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( p_data = cube ) ).
    CREATE DATA me->datacube TYPE HANDLE table_desc.
    ASSIGN me->datacube TO FIELD-SYMBOL(<datatable>).
    <datatable>->* = cube.
  endmethod.


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


  METHOD set_alv_header.
    TRY.
        DATA(title_text) =  COND #( WHEN me->s_titel[ 1 ]-low IS NOT INITIAL THEN me->s_titel[ 1 ]-low ELSE space ).
      CATCH cx_sy_itab_line_not_found.
        title_text = space.
    ENDTRY.
    TRY.
        DATA(kapitel) = COND #( WHEN me->s_kapitel[ 1 ]-low IS NOT INITIAL THEN me->s_kapitel[ 1 ]-low ELSE space ).
      CATCH cx_sy_itab_line_not_found.
        kapitel = space.
    ENDTRY.

    me->salv->get_display_settings( )->set_list_header( |Geldhinterlegung Zeitraum:  { kapitel } { title_text }| ).
  ENDMETHOD.


  method SET_ALV_HOTSPOT_COLUMNS.
    columns = VALUE #( ( 'KASSENZEICHEN' ) ).
  endmethod.


  METHOD set_alv_sorts.
    me->salv->get_aggregations( )->add_aggregation( columnname = 'GEZAHLT' aggregation = if_salv_c_aggregation=>total ).
    me->salv->get_aggregations( )->add_aggregation( columnname = 'OFFENES_SOLL' aggregation = if_salv_c_aggregation=>total ).

  ENDMETHOD.
ENDCLASS.
