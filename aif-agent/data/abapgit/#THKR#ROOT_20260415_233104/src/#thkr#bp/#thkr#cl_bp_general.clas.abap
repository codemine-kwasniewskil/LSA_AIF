class /THKR/CL_BP_GENERAL definition
  public
  final
  create public .

public section.

  class-methods GET_BP_GROUPPING
    importing
      !TYPE type BU_TYPE
      !ROLE_GROUPING type BU_RLGROUP
    returning
      value(BU_GROUP) type BU_GROUP .
  class-methods GET_AKONTO_FROM_SST
    importing
      !SST type /THKR/DTE_BU_SST
      !KOART type KOART
    returning
      value(AKONT) type AKONT .
  class-methods GET_AKONTO_FROM_BPGROUP
    importing
      !BPGRP type BU_GROUP
      !KOART type KOART
    returning
      value(AKONT) type AKONT .
  class-methods GET_BPAUGRP_FROM_BPGROUP
    importing
      !BPGRP type BU_GROUP
    returning
      value(BPAUGRP) type BU_AUGRP .
  class-methods GET_BPKIND_FORM_BPGROUP
    importing
      !BPGRP type BU_GROUP
    returning
      value(BPKIND) type BU_BPKIND .
  class-methods GET_BPDEFAULT_VALUES
    importing
      !BPGRP type BU_GROUP optional
    returning
      value(BPDEFAULTS) type BUSDEFAULT .
  class-methods READ_BP
    importing
      value(IT_CHECK_PARTNER) type BUP_PARTNER_GUID_T optional
      !IV_USE_GUID type FLAG default ABAP_FALSE
    returning
      value(RT_PARTNER) type /THKR/T_BP_F4 .
  PROTECTED SECTION.
private section.

  types:
    BEGIN OF ty_rolle_grup,
      type     TYPE bu_type,
      rltgr	   TYPE bu_rlgroup,
      bu_group TYPE bu_group,
    END OF ty_rolle_grup .
  types:
    tt_rolle_grup TYPE SORTED TABLE OF ty_rolle_grup WITH UNIQUE KEY type rltgr .
  types:
    BEGIN OF ty_grp2akto,
      bpgrp	TYPE bu_group,
      koart TYPE koart,
      akont TYPE akont,
    END OF ty_grp2akto .
  types:
    tt_grp2akto TYPE SORTED TABLE OF ty_grp2akto WITH UNIQUE KEY bpgrp koart .
  types:
    BEGIN OF ty_grp2kind,
      bu_group TYPE bu_group,
      bu_kind  TYPE bu_bpkind,
    END OF ty_grp2kind .
  types:
    tt_grp2kind TYPE SORTED TABLE OF ty_grp2kind WITH UNIQUE KEY bu_group .
  types:
    BEGIN OF ty_grp2augrp,
      bu_group TYPE bu_group,
      augrp    TYPE bu_augrp,
    END OF ty_grp2augrp .
  types:
    tt_grp2augrp TYPE SORTED TABLE OF ty_grp2augrp WITH UNIQUE KEY bu_group .
  types:
    BEGIN OF ty_gsber2akto,
      sst	  TYPE /thkr/dte_bu_sst,
      koart TYPE koart,
      akont TYPE akont,
    END OF ty_gsber2akto .
  types:
    tt_gsber2akto TYPE SORTED TABLE OF ty_gsber2akto WITH UNIQUE KEY sst koart .

  class-data MT_ROLLE_GRUP type TT_ROLLE_GRUP .
  class-data MAP_GROUP2AKONTO type TT_GRP2AKTO .
  class-data MAP_GROUP2KIND type TT_GRP2KIND .
  class-data MAP_GSBER2KIND type TT_GSBER2AKTO .
  class-data MAP_GROUP2AUGRP type TT_GRP2AUGRP .
ENDCLASS.



CLASS /THKR/CL_BP_GENERAL IMPLEMENTATION.


  METHOD get_akonto_from_bpgroup.
    IF map_group2akonto IS INITIAL.
      SELECT DISTINCT *
        FROM /thkr/cgrp2akto
        INTO CORRESPONDING FIELDS OF TABLE MAP_GROUP2AKONTO .
    ENDIF.

    TRY.
        akont = map_group2akonto[ bpgrp = bpgrp koart = koart ]-akont.
      CATCH cx_sy_itab_line_not_found.
        " nothing to do, just no value found!
    ENDTRY.
  ENDMETHOD.


  METHOD get_bpdefault_values.

************************************************************************
*   Vorbelegung Berechtigungsgruppe AUGRP                              *
************************************************************************
    bpdefaults-augrp  = get_bpaugrp_from_bpgroup( bpgrp ).

    bpdefaults-bpkind = get_bpkind_form_bpgroup( bpgrp ).
*    bpdefaults-country = 'DE'.
    "Sprache muss für alle GP vorbelegt werden, da unsere Amtssprache Deutsch ist
    bpdefaults-langu = 'D'.

    "Vorbelegung Land mit DE
    "genau dann, wenn die GP-Gruppierung nicht in der Ausnahmetabelle steht
    IF bpgrp IS NOT INITIAL.
      SELECT SINGLE *
      FROM /thkr/cbpdefctry
      INTO @DATA(lt_defctry)
        WHERE bpgrp = @bpgrp.
      IF sy-subrc <> 0.
        bpdefaults-country = 'DE'.
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD get_bpkind_form_bpgroup.
    IF map_group2kind IS INITIAL.
      SELECT  *
       FROM /thkr/cgrp2kind
       INTO CORRESPONDING FIELDS OF TABLE map_group2kind.
    ENDIF.

    TRY.
        bpkind = map_group2kind[ bu_group = bpgrp ]-bu_kind.
      CATCH cx_sy_itab_line_not_found.
        " nothing to do, just no value found!
    ENDTRY.
  ENDMETHOD.


  METHOD get_bp_groupping.
    IF mt_rolle_grup IS INITIAL.
      SELECT DISTINCT type, rltgr, bu_group
        FROM /thkr/crolle_grp
        INTO CORRESPONDING FIELDS OF TABLE @mt_rolle_grup.
    ENDIF.
    CHECK type          IS NOT INITIAL AND
          role_grouping IS NOT INITIAL AND
          mt_rolle_grup IS NOT INITIAL.
    READ TABLE mt_rolle_grup INTO DATA(rolle_group) WITH TABLE KEY  type  = type
                                                                    rltgr = role_grouping.
    IF sy-subrc = 0.
      bu_group = rolle_group-bu_group.
    ENDIF.
  ENDMETHOD.


  METHOD GET_AKONTO_FROM_SST.
    IF map_gsber2kind IS INITIAL.
      SELECT DISTINCT *
        FROM /thkr/cgeb2akto
        INTO CORRESPONDING FIELDS OF TABLE map_gsber2kind.
    ENDIF.

    TRY.
        akont = map_gsber2kind[ sst = sst koart = koart ]-akont.
      CATCH cx_sy_itab_line_not_found.
        " nothing to do, just no value found!
    ENDTRY.
  ENDMETHOD.


  METHOD GET_BPAUGRP_FROM_BPGROUP.
    IF map_group2augrp IS INITIAL.
      SELECT  *
       FROM /thkr/cgrp2augrp
       INTO CORRESPONDING FIELDS OF TABLE map_group2augrp.
    ENDIF.

    TRY.
        bpaugrp = map_group2augrp[ bu_group = bpgrp ]-augrp.
      CATCH cx_sy_itab_line_not_found.
        " nothing to do, just no value found!
    ENDTRY.
  ENDMETHOD.


  METHOD read_bp.

    " Fülle Prüftabelle wenn nicht gegeben -> sollte immer übergeben werden
    IF it_check_partner IS INITIAL.
      SELECT DISTINCT partner, partner_guid
        FROM but000
        INTO TABLE @it_check_partner.
    ENDIF.
    " Lese aktuellen Zeitpunkt
    GET TIME STAMP FIELD DATA(lv_timestamp).
    " Lese alle Partner mit allen Informationen aus
    SELECT
      FROM but000 AS but
      INNER JOIN @it_check_partner
      AS check
      ON ( ( @iv_use_guid = @abap_true AND but~partner_guid = check~partner_guid )
      OR ( @iv_use_guid = @abap_false AND but~partner = check~partner ) )
      FIELDS but~partner        AS partner,
             but~partner_guid   AS partner_guid,
             but~augrp          AS augrp,
             but~/thkr/gsber    AS gsber
        WHERE but~valid_from  <= @lv_timestamp
      AND   but~valid_to    >= @lv_timestamp
      INTO TABLE @rt_partner.


  ENDMETHOD.
ENDCLASS.
