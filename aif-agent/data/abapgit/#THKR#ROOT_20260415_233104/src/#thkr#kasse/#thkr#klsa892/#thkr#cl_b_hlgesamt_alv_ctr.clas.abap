CLASS /thkr/cl_b_hlgesamt_alv_ctr DEFINITION
  PUBLIC
  INHERITING FROM /thkr/cl_alv_base_ctr
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      so_titel   TYPE RANGE OF /thkr/psm_fipos_titel .
    TYPES:
      so_kapitel  TYPE RANGE OF /thkr/psm_fipos_kapitel .

    METHODS constructor
      IMPORTING
        !gjahr      TYPE gjahr OPTIONAL
        !fonds      TYPE bp_geber
        !s_kapitel  TYPE so_kapitel
        !s_titel    TYPE so_titel
        !komplement TYPE abap_bool.

    METHODS on_link_click
        REDEFINITION .
  PROTECTED SECTION.

    DATA gjahr TYPE gjahr .
    DATA fonds TYPE bp_geber .
    DATA s_kapitel TYPE so_kapitel .
    DATA s_titel TYPE so_titel .
    DATA komplement TYPE abap_bool.

    METHODS get_data_from_cube
        REDEFINITION .
    METHODS set_alv_header
        REDEFINITION .
    METHODS set_alv_sorts
        REDEFINITION .
    METHODS set_alv_hotspot_columns
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_B_HLGESAMT_ALV_CTR IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    me->gjahr       = gjahr.
    me->fonds       = fonds.
    me->s_kapitel   = s_kapitel.
    me->s_titel     = s_titel.
    me->komplement  = komplement.

  ENDMETHOD.


  METHOD get_data_from_cube.

** Base select statement
    DATA(where) = |fikrs = 1000 AND  epl = @me->fonds AND kapitel IN @me->s_kapitel AND titel IN @me->s_titel|.

*** Decide to show OPEN or CLOSED cases:
    DATA(having) = COND #( WHEN me->komplement = abap_true THEN |SUM( gezahlt ) = 0 AND SUM( offenessoll ) = 0|
                                                           ELSE |NOT ( SUM( gezahlt ) = 0 AND SUM( offenessoll ) = 0 )|  ).

    SELECT FROM /thkr/cds_hlgcube
      FIELDS
          kassenzeichen
         ,aktenzeichen
         ,STRING_AGG( kundenname,',' ) AS hinterleger
         ,STRING_AGG( verwendungszweck, ',' )  AS verwendungszweck
         ,SUM( gezahlt ) AS gezahlt
         ,SUM( offenessoll ) AS offenes_soll
         ,twaer AS waehrung,
          fipex AS finanzpos
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

    me->salv->get_display_settings( )->set_list_header( |Geldhinterlegung Gesamt:  { kapitel } { title_text }| ).
  ENDMETHOD.


  METHOD set_alv_hotspot_columns.
    columns = VALUE #( ( 'KASSENZEICHEN' ) ).
  ENDMETHOD.


  METHOD set_alv_sorts.
    me->salv->get_aggregations( )->add_aggregation( columnname = 'GEZAHLT' aggregation = if_salv_c_aggregation=>total ).
    me->salv->get_aggregations( )->add_aggregation( columnname = 'OFFENES_SOLL' aggregation = if_salv_c_aggregation=>total ).

  ENDMETHOD.
ENDCLASS.
