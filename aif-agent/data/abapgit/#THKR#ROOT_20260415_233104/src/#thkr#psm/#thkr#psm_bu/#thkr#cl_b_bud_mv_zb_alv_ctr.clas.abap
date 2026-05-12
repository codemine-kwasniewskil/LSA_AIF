CLASS /thkr/cl_b_bud_mv_zb_alv_ctr DEFINITION
  PUBLIC
  INHERITING FROM /thkr/cl_alv_base_ctr
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      so_budtype  TYPE RANGE OF buku_budtype .
    TYPES:
      so_hhp       TYPE RANGE OF fm_measure .
    TYPES:
      so_fund     TYPE RANGE OF bp_geber .
    TYPES:
      so_funcarea TYPE RANGE OF fm_farea .
    TYPES:
      so_fipos TYPE RANGE OF fm_fipex .
    TYPES:
      so_gjahr TYPE RANGE OF gjahr .

    METHODS constructor
      IMPORTING
        !p_variant  TYPE slis_vari DEFAULT 'DEFAULT'
        !p_fistl    TYPE fistl OPTIONAL
        !s_fipos    TYPE so_fipos OPTIONAL
        !s_hhp      TYPE so_hhp OPTIONAL
        !s_fund     TYPE so_fund OPTIONAL
        !s_funcarea TYPE so_funcarea OPTIONAL
        !s_budtype  TYPE so_budtype OPTIONAL
        !s_gjahr    TYPE so_gjahr OPTIONAL
        !p_budcat   TYPE buku_budcat OPTIONAL .

    METHODS on_link_click
        REDEFINITION .
  PROTECTED SECTION.

    DATA s_fipos TYPE so_fipos .
    DATA p_fistl TYPE fistl .
    DATA s_hhp TYPE so_hhp .
    DATA s_fund TYPE so_fund .
    DATA s_funcarea TYPE so_funcarea .
    DATA s_budtype TYPE so_budtype .
    DATA p_budcat TYPE buku_budcat .
    DATA s_gjahr TYPE so_gjahr .
    METHODS get_data_from_cube
        REDEFINITION .
    METHODS set_alv_sorts
        REDEFINITION .
    METHODS set_alv_header
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_B_BUD_MV_ZB_ALV_CTR IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    me->p_fistl     = p_fistl.
    me->s_fipos     = s_fipos.
    me->s_hhp       = s_hhp.
    me->s_fund      = s_fund.
    me->s_funcarea  = s_funcarea.
    me->s_budtype   = s_budtype.
    me->layout      = p_variant.
    me->p_budcat    = p_budcat.
    me->s_gjahr     = s_gjahr.
  ENDMETHOD.


  METHOD get_data_from_cube.

    SELECT FROM /thkr/cds_bud_mv_zb
      FIELDS senderbudgetdocid AS budgetbeleg,
          senderfiscyear AS budgetjahr,
          senderfond AS fond,
          senderfundscenter AS fi_stl,
          senderfipos AS fi_pos,
          senderfuncarea AS funkt_bereich,
          senderhhp AS h_h_p,
          senderbudgettype AS budget_typ,
          sendermanualcvgrp AS manuelle_deckungsgruppe,
          senderprozess AS vorgang,
          budget ,
          receiverfund AS empf_fond,
          receiverfundscenter AS empf_fi_stl,
          receiverfipos AS empf_fi_pos,
          receiverfuncarea AS empf_funkt_bereich,
          receiverhhp AS empf_h_h_p,
          receiverbudgettype AS empf_budget_typ,
          currency AS waehrung,
          budgeteffectfiscalyear AS jahr_wirksamkeit
      WHERE
         senderfundscenter    = @me->p_fistl
        AND senderfiscyear    IN @me->s_gjahr
        AND senderfipos       IN @me->s_fipos
        AND budgetcategory    = @me->p_budcat
        AND senderfond        IN @me->s_fund
        AND senderhhp         IN @me->s_hhp
        AND senderfuncarea    IN @me->s_funcarea
        AND senderbudgettype  IN @me->s_budtype
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


  METHOD set_alv_sorts.

    DATA: gr_layout TYPE REF TO cl_salv_layout.
    DATA: key TYPE salv_s_layout_key.

    DATA(layout) = me->salv->get_layout( ).
    layout->set_key( VALUE #( report = sy-repid ) ).
    layout->set_save_restriction( if_salv_c_layout=>restrict_none ).


  ENDMETHOD.


  METHOD set_alv_header.
    me->salv->get_display_settings( )->set_list_header( |Mittelverteilung - Finanzstelle { me->p_fistl } - Budgetkategorie { p_budcat }| ).
  ENDMETHOD.
ENDCLASS.
