CLASS /thkr/cl_b_bp_alv_ctr DEFINITION
  PUBLIC
  INHERITING FROM /thkr/cl_alv_base_ctr
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      s_partner TYPE RANGE OF bu_partner .
    TYPES:
      s_group   TYPE RANGE OF bu_group .
    TYPES:
      s_kind   TYPE RANGE OF bu_bpkind .
    TYPES:
      s_name    TYPE RANGE OF bu_name1tx .
    TYPES:
      s_idtype TYPE RANGE OF bu_id_type .
    TYPES:
      s_idnumber TYPE RANGE OF bu_id_number .
    TYPES:
      s_bank TYPE RANGE OF bu_iban .
    TYPES:
      s_gsber TYPE RANGE OF /thkr/dte_bu_gsber .
    TYPES:
      s_sst TYPE RANGE OF /thkr/dte_bu_sst .
    TYPES:
      s_blk_deb_bukrs TYPE RANGE OF bukrs .
    TYPES:
      s_blk_kred_bukrs TYPE RANGE OF bukrs .
    TYPES:
      s_city TYPE RANGE OF ad_city1.
    TYPES:
      s_plz TYPE RANGE OF ad_pstcd1.
    TYPES:
      s_street TYPE RANGE OF ad_street.

    METHODS constructor
      IMPORTING
        !partner        TYPE s_partner OPTIONAL
        !group          TYPE s_group OPTIONAL
        !kind           TYPE s_kind OPTIONAL
        !name           TYPE s_name OPTIONAL
        !idtype         TYPE s_idtype OPTIONAL
        !idnumber       TYPE s_idnumber OPTIONAL
        !bank           TYPE s_bank OPTIONAL
        !gsber          TYPE s_gsber OPTIONAL
        !sst            TYPE s_sst OPTIONAL
        !blk_deb_bukrs  TYPE s_blk_deb_bukrs OPTIONAL
        !block_deb_all  TYPE boolean OPTIONAL
        !blk_kred_bukrs TYPE s_blk_kred_bukrs OPTIONAL
        !block_kred_all TYPE boolean OPTIONAL
        !city           TYPE s_city OPTIONAL
        !plz            TYPE s_plz OPTIONAL
        !street         TYPE s_street OPTIONAL
        !archived       TYPE boolean OPTIONAL .

    METHODS on_link_click
        REDEFINITION .
  PROTECTED SECTION.

    DATA partner TYPE s_partner .
    DATA group TYPE s_group .
    DATA kind TYPE s_kind .
    DATA name TYPE s_name .
    DATA idtype TYPE s_idtype .
    DATA idnumber TYPE s_idnumber .
    DATA bank TYPE s_bank .
    DATA gsber TYPE s_gsber .
    DATA sst TYPE s_sst .
    DATA blk_deb_bukrs TYPE s_blk_deb_bukrs .
    DATA block_deb_all TYPE boolean .
    DATA blk_kred_bukrs TYPE s_blk_deb_bukrs .
    DATA block_kred_all TYPE boolean .
    DATA archived TYPE boolean .
    DATA city TYPE s_city.
    DATA plz TYPE s_plz.
    DATA street TYPE s_street.

    METHODS get_data_from_cube
        REDEFINITION .
    METHODS set_alv_header
        REDEFINITION .
    METHODS set_alv_hotspot_columns
        REDEFINITION .
    METHODS set_alv_sorts
        REDEFINITION .
  PRIVATE SECTION.
ENDCLASS.



CLASS /THKR/CL_B_BP_ALV_CTR IMPLEMENTATION.


  METHOD constructor.
    super->constructor( ).
    me->partner = partner.
    me->group = group.
    me->name = name.
    me->kind = kind.
    me->idtype = idtype.
    me->idnumber = idnumber.
    me->bank = bank.
    me->gsber = gsber.
    me->sst = sst.
    me->blk_deb_bukrs = blk_deb_bukrs.
    me->block_deb_all = block_deb_all.
    me->blk_kred_bukrs = blk_kred_bukrs.
    me->block_kred_all  = block_kred_all.
    me->archived = archived.
    me->city = city.
    me->street = street.
    me->plz = plz.

  ENDMETHOD.


  METHOD get_data_from_cube.
    SELECT FROM /thkr/bpcube
      FIELDS
          bpid            AS partner,
          bpname          AS name,
          bpgroup         AS gruppierung,
          bptype          AS typ,
          archivvormerkung,
          bpaddress       AS adresse,
          bpcountry       AS land,
          id_type         AS id_typ,
          id_num          AS id_nummer,
          bank            AS bankverbindung,
          businessarea    AS gesbereich,
          bpinterface     AS schnittstelle,
          blockedall      AS block_alle_bukrs,
          STRING_AGG( custblockedcompanycode , ' ' ORDER BY custblockedcompanycode  ) AS deb_bukrs_blockiert,
          STRING_AGG( suppblockedcompanycode , ' ' ORDER BY suppblockedcompanycode  ) AS kred_bukrs_blockiert
       WHERE
              bpid       IN @me->partner
        AND bpname       IN @me->name
        AND bpgroup      IN @me->group
        AND bptype       IN @me->kind
        AND id_type      IN @me->idtype
        AND id_num       IN @me->idnumber
        AND bank         IN @me->bank
        AND businessarea IN @me->gsber
        AND bpinterface  IN @me->sst
        AND custblockedcompanycode IN @me->blk_deb_bukrs
        AND suppblockedcompanycode IN @me->blk_kred_bukrs
        AND blockedall   EQ @me->block_deb_all
        AND archivvormerkung EQ @me->archived
*        AND suppblockedall EQ @me->block_kred_all
        AND street       IN @me->street
        AND city         IN @me->city
        AND plz          IN @me->plz
        GROUP BY
          bpid,
          bpname,
          bpgroup,
          bptype    ,
          archivvormerkung,
          bpaddress ,
          bpcountry ,
          id_type,
          id_num ,
          bank  ,
          businessarea,
          bpinterface,
          blockedall
*          suppblockedall
      INTO TABLE @DATA(cube).

** Store data
    DATA(table_desc) = CAST cl_abap_tabledescr( cl_abap_tabledescr=>describe_by_data( p_data = cube ) ).
    CREATE DATA me->datacube TYPE HANDLE table_desc.
    ASSIGN me->datacube TO FIELD-SYMBOL(<datatable>).
    <datatable>->* = cube.
  ENDMETHOD.


  METHOD set_alv_header.

    me->salv->get_display_settings( )->set_list_header( |Business Partner| ).

  ENDMETHOD.


  METHOD set_alv_sorts.
*    me->salv->get_aggregations( )->add_aggregation( columnname = 'BETRAG' aggregation = if_salv_c_aggregation=>total ).
*    me->salv->get_sorts( )->add_sort( columnname = 'KASSENZEICHEN' subtotal = abap_true sequence = if_salv_c_sort=>sort_up ).
  ENDMETHOD.


  METHOD on_link_click.
    " Get required value:
    LOOP AT me->datacube->* ASSIGNING FIELD-SYMBOL(<line>).
      IF sy-tabix = row.
        ASSIGN COMPONENT column OF STRUCTURE <line> TO FIELD-SYMBOL(<value>).
        EXIT.
      ENDIF.
    ENDLOOP.

    SELECT SINGLE partner_guid FROM but000 INTO @DATA(partner_guid) WHERE partner = @<value>.
    IF partner_guid IS NOT INITIAL.
      DATA(bupa_nav) = NEW cl_bupa_navigation_request( ).
      bupa_nav->set_partner_guid( partner_guid ).
      bupa_nav->set_maintenance_id( bupa_nav->gc_maintenance_id_partner ).
      bupa_nav->set_bupa_activity( bupa_nav->gc_activity_display ).

      DATA(bupa_options) = NEW  cl_bupa_dialog_joel_options( ).
      bupa_options->set_locator_visible( space ).
      cl_bupa_dialog_joel=>start_with_navigation(
        iv_request              = bupa_nav
        iv_options              = bupa_options
        iv_in_new_internal_mode = 'X' ).
    ENDIF.

  ENDMETHOD.


  METHOD set_alv_hotspot_columns.
    columns = VALUE #( ( 'PARTNER' ) ).
  ENDMETHOD.
ENDCLASS.
