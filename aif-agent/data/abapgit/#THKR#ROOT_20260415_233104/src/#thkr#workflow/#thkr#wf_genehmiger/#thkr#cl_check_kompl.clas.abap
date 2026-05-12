class /THKR/CL_CHECK_KOMPL definition
  public
  final
  create public .

public section.

  class-methods BER_OBJ_SPECIAL_PROCEDURE
    importing
      !IV_OBJECT type AGOBJECT
      !IV_FIELD type AGRFIELD
    changing
      !IV_LOW type AGVAL
      !IV_HIGH type AGVAL .
  class-methods CHECK_ATTRIB
    importing
      !IT_T77OMATTOT type /THKR/T_AGR_T77OMATTOT
      !IT_TAB_06XXL type /THKR/T_CHECK_ATTRIB_06XXL
      !IT_TAB_UR13C type /THKR/T_AGR_UR13C
    changing
      !IT_ATTRIB type /THKR/T_STRUC_TYPE_ATTR_ERW_TT .
  class-methods CHECK_ATTRIB_VIA_06XXL
    importing
      !IT_TAB_06XXL type /THKR/T_CHECK_ATTRIB_06XXL
      !IT_TAB_UR13C type /THKR/T_AGR_UR13C
      !IS_ATTRIB type /THKR/S_STRUC_TYPE_ATTR_ERW
      !IT_ZFUNK type /THKR/T_STRUC_TYPE_ATTR_ERW_TT
    returning
      value(RT_ATTRIB) type /THKR/T_STRUC_TYPE_ATTR_ERW_TT .
  class-methods CHECK_BER_DATA
    importing
      !IT_T77OMATTOT type /THKR/T_AGR_T77OMATTOT
      !IT_UR13C type /THKR/T_AGR_UR13C
      !IT_BER_DATA type /THKR/T_OM_AGR_1251_ERW
      !IT_02XXL type /THKR/T_AGR_02XXL
      !IV_INDEX type I
      !IV_OBJID type HROBJID
      !IV_OTYPE type OTYPE
    changing
      !IT_ATTRIB type /THKR/T_STRUC_TYPE_ATTR_ERW_TT .
  class-methods CHECK_ORG_DATA
    importing
      !IT_T77OMATTOT type /THKR/T_AGR_T77OMATTOT
      !IT_ORG_DATA type /THKR/T_OM_AGR_1252_ERW
      !IT_UR13C type /THKR/T_AGR_UR13C
      !IT_05XXL type /THKR/T_OM_AGR_TYP_ORG
      !IV_INDEX type I
      !IV_OBJID type HROBJID
      !IV_OTYPE type OTYPE
    changing
      !IT_ATTRIB type /THKR/T_STRUC_TYPE_ATTR_ERW_TT .
  class-methods CHECK_ZFUNK_TO_AGR
    importing
      !IV_OBJID type HRP1000-OBJID
      !IT_UR12C type /THKR/T_AGR_UR12C
      !IV_NUMMER type I
      !IT_ATTR_ERW type /THKR/T_STRUC_TYPE_ATTR_ERW_TT
      value(IV_DEST) type RFCDEST optional
      !IT_11XXL type /THKR/T_AGR_11XXL
    returning
      value(RT_VALUES) type /THKR/T_OM_STRUC_TEXT .
  class-methods GET_AGR_FROM_OBJID
    importing
      !IV_OBJID type HROBJID
      !IV_OTYPE type OTYPE
    exporting
      !RT_AGRS type /THKR/T_OM_AGR_SOBID .
  class-methods GET_TYP_BER_FROM_AGR_FIELDS
    importing
      !IT_02XXL type /THKR/T_AGR_02XXL
    changing
      !IT_AGR_1251 type /THKR/T_OM_AGR_1251_ERW .
  methods R3_PLAY_GUI_ALV_GRID
    changing
      !IT_TABLE type ANY TABLE .
  class-methods SET_ATTR_GESAMT_ERW
    importing
      !NUMMER type INT4
      !OBJEKTTYP type OTYPE
      !OBJEKTID type HROBJID
      !ATTRIB type OM_ATTRIB optional
      !LOW type OM_ATTRVAL optional
      !HIGH type OM_ATTRVTO optional
      !EXCLUDED type OM_ATTREXC optional
      !DEFAULTVAL type OM_ATTRDEF optional
      !INHERITED type OM_ATTRREF optional
      !INHERIT type FLAG optional
      !INH_LEVEL type NUMC2 optional
      !INH_OTYPE type OTYPE optional
      !INH_OBJID type ACTORID optional
      !ZFUNK_NO_EXIST type KREUZ optional
      !CONDITION type /THKR/DTE_WF_ATTR_COND optional
      !VORHANDEN type KREUZ optional
      !AGR_TEXT type AGR_TITLE optional
      !STATUS type ICON_D optional
      !TEXT type TEXT200 optional
    returning
      value(LS_STRUC_ATTR_GESAMT_ERW) type /THKR/S_STRUC_TYPE_ATTR_ERW .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_CHECK_KOMPL IMPLEMENTATION.


  method BER_OBJ_SPECIAL_PROCEDURE.

        " Sonderlogik RESPAREA

    IF ( iv_object EQ 'K_ORDER'   OR
         iv_object EQ 'Z_NSI_POH' OR
         iv_object EQ 'K_CCA'     OR
         iv_object EQ 'K_PCA' )   AND
         iv_field EQ 'RESPAREA'.

*   Bildungsregel für K_ORDER, Z_NSI_POH, KCCA, K_PCA
*            K_ORDER   1. OR
*                      2. KS1000
*                      3. HI1000
*            Z_NSI_POH 1. OR
*                      2. KS1000
*                      3. HI1000
*            K_CCA     1. KS1000
*                      2. HI1000
*                      3. KN1000
*            K_PCA     1. PC1000
*                      2. PH1000

*   Vorsatz der Objektnummer entfernen
      CASE iv_low(2).
        WHEN 'OR'.
          MOVE: iv_low+2(*)  TO iv_low,
                iv_high+2(*) TO iv_high.
        WHEN 'KS' OR 'HI' OR 'KN' OR 'PC' OR 'PH'.
          MOVE: iv_low+6(*)  TO iv_low,
                iv_high+6(*) TO iv_high.
      ENDCASE.

*   führende Nullen entfernen
      SHIFT: iv_low  LEFT DELETING LEADING '0',
             iv_high LEFT DELETING LEADING '0'.


    ENDIF.

  endmethod.


  method CHECK_ATTRIB.


    CONSTANTS: k_icon_green(4) VALUE icon_led_green,  " @5B@
               k_icon_red(4)   VALUE icon_led_red,    " @5C@
               k_icon_yellow   TYPE  icon_d VALUE '@5D@'.

    DATA: lv_mandt      TYPE mandt,
          o_ref         TYPE REF TO cx_root,
          lt_attrib_tmp TYPE /THKR/T_STRUC_TYPE_ATTR_ERW_TT,
          lt_zfunk      TYPE /THKR/T_STRUC_TYPE_ATTR_ERW_TT.


    CLEAR: lt_attrib_tmp, lt_zfunk.

    SELECT *
        FROM @it_attrib AS z_funk
        WHERE attrib = 'ZFUNK'      OR
              attrib = 'ZWRGP_VGST' OR
              attrib = 'ZBTRG_BUGE' OR
              attrib = 'ZBTRG_AO'   OR
              attrib = 'ZFRGVGS'    OR
              attrib = 'ZTITEL'     OR
              attrib = 'ZTITEL_AO'  OR
              attrib = 'ZWRGP_VGST'
        INTO TABLE @lt_zfunk.


    LOOP AT it_attrib ASSIGNING FIELD-SYMBOL(<fs_attrib_c>).

      IF sy-tabix = 2.
        CLEAR lt_zfunk.
      ENDIF.

      READ TABLE it_t77omattot WITH KEY attrib = <fs_attrib_c>-attrib TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.

        " technische Prüfung
        APPEND LINES OF /THKR/cl_check_kompl=>check_attrib_via_06xxl(
           EXPORTING
             it_tab_06xxl  =  it_tab_06xxl
             it_tab_ur13c  =  it_tab_ur13c
             it_zfunk      =  lt_zfunk
             is_attrib     =  <fs_attrib_c>  ) TO lt_attrib_tmp.


        IF <fs_attrib_c>-low CS '*'.
          CONTINUE.
        ENDIF.

        CASE <fs_attrib_c>-attrib.
          WHEN  'ACC_FCENTR'.
            TRY .
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM fmfctr WHERE fictr = @<fs_attrib_c>-low AND datab LE @sy-datum AND datbis GE @sy-datum INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T161 nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T161 nicht vorhanden.|.
            ENDTRY.

          WHEN  'BSART'.
            TRY .
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t161 WHERE bsart = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T161 nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T161 nicht vorhanden.|.
            ENDTRY.

          WHEN  'BUKRS'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t001 WHERE bukrs = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T001 nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T001 nicht vorhanden.|.
            ENDTRY.

          WHEN  'CATALOG'.

          WHEN  'CATVIEW'.


          WHEN  'COSTCENTER'.
            TRY.

                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM csks WHERE kostl = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle CSKS nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle CSKS nicht vorhanden.|.
            ENDTRY.

          WHEN  'DIVISION'. "Sparte
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM tspa WHERE spart = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TSPA nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TSPA nicht vorhanden.|.
            ENDTRY.

          WHEN  'D_CHANNEL'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM tvtw WHERE vtweg = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TVTW nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TVTW nicht vorhanden.|.
            ENDTRY.

          WHEN  'EKORG'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t024e WHERE ekorg = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T024E nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T024E nicht vorhanden.|.
            ENDTRY.

          WHEN  'KNTTP'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t163k WHERE knttp = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T163K nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T163K nicht vorhanden.|.
            ENDTRY.


          WHEN  'R3_SA_OFF'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM tvbur WHERE vkbur = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TVBUR nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TVBUR nicht vorhanden.|.
            ENDTRY.

          WHEN  'R3_SA_ORG'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM tvko WHERE vkorg = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TVKO nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TVKO nicht vorhanden.|.
            ENDTRY.

          WHEN  'RESPPGRP'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t024 WHERE ekgrp = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T024 nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T024 nicht vorhanden.|.
            ENDTRY.


          WHEN  'WAERS'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM tcurc WHERE waers = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TCURC nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TCURC nicht vorhanden.|.
            ENDTRY.

          WHEN  'WERKS'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t001w WHERE werks = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T001W nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T001W nicht vorhanden.|.
            ENDTRY.


          WHEN  'ZAAFRG'.

          WHEN  'ZAAWRGP'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T023 nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T023 nicht vorhanden.|.
            ENDTRY.

          WHEN  'ZBTRG_AO'.

          WHEN  'ZBTRG_BUGE'.

          WHEN  'ZBUKRS_BPC'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t001 WHERE bukrs = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T001 nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T001 nicht vorhanden.|.
            ENDTRY.

          WHEN  'ZDSTUN'.

          WHEN  'ZEINZELPL'.

          WHEN  'ZFRGVGB'.

          WHEN  'ZFRGVGS'.

          WHEN  'ZFUNK'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM /THKR/WF_FUNKT WHERE funktion = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle ZOM_WF_FUNKTION nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle ZOM_WF_FUNKTION nicht vorhanden.|.
            ENDTRY.

          WHEN  'ZKAPITEL'.

          WHEN  'ZKSTL_AO'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM csks WHERE kostl = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle CSKS nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle CSKS nicht vorhanden.|.
            ENDTRY.

          WHEN  'ZLAGERORT'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t001l WHERE lgort = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T001L nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T001L nicht vorhanden.|.
            ENDTRY.

          WHEN  'ZORGRELEV'.

          WHEN  'ZPGSBR'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM tgsb WHERE gsber = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TGSB nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TGSB nicht vorhanden.|.
            ENDTRY.
          WHEN  'ZPLEL_BPC'.

          WHEN  'ZROLLGRP'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM tb001 WHERE bu_group = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TB001 nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle TB001 nicht vorhanden.|.
            ENDTRY.

          WHEN  'ZSTEUER'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t007a WHERE mwskz = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T007A nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T007A nicht vorhanden.|.
            ENDTRY.

          WHEN  'ZTITEL'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM fmci WHERE fipex = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle FMCI nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle FMCI nicht vorhanden.|.
            ENDTRY.


          WHEN  'ZTITEL_AO'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM fmfxpo WHERE fipos = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle FMFXPO nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle FMFXPO nicht vorhanden.|.
                CONTINUE.
            ENDTRY.

          WHEN  'ZVKSTL'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM csks WHERE kostl = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle CSKS nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle CSKS nicht vorhanden.|.
            ENDTRY.

          WHEN  'ZWEWGRP'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T023 nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T023 nicht vorhanden.|.
            ENDTRY.


          WHEN  'ZWFLEVEL'.

          WHEN  'ZWGRPFB'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T023 nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T023 nicht vorhanden.|.
            ENDTRY.


          WHEN  'ZWGRP_DSTL'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T023 nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T023 nicht vorhanden.|.
            ENDTRY.

          WHEN  'ZWRGP_VGST'.
            TRY.
                IF <fs_attrib_c>-high IS INITIAL.
                  SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_attrib_c>-low INTO @lv_mandt.
                  IF sy-subrc NE 0.
                    <fs_attrib_c>-status = k_icon_red.
                    <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T023 nicht vorhanden.|.
                    CONTINUE.
                  ENDIF.
                ENDIF.

              CATCH cx_sy_open_sql_data_error INTO o_ref.
                <fs_attrib_c>-status = k_icon_red.
                <fs_attrib_c>-text = |Attribut { <fs_attrib_c>-attrib } in der Tabelle T023 nicht vorhanden.|.
            ENDTRY.
        ENDCASE.

      ENDIF.



    ENDLOOP.


    APPEND LINES OF lt_attrib_tmp TO it_attrib.
    SORT it_attrib BY nummer objekttyp objektid attrib low high.


  endmethod.


  method CHECK_ATTRIB_VIA_06XXL.

       DATA: lt_err_text TYPE STANDARD TABLE OF string,
          ls_attrib   TYPE /THKR/S_STRUC_TYPE_ATTR_ERW,
          str_reg     TYPE string.

    CONCATENATE '0123456789' 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz' '.*' INTO DATA(lv_regex).


    CHECK is_attrib-attrib IS NOT INITIAL.
    CLEAR: lt_err_text, ls_attrib, str_reg.

    " A) Die Attribute dürfen maximal die Länge haben, die in Tabelle T77OMATTR hinterlegt sind.
    SELECT SINGLE outputlen FROM t77omattr
    WHERE attrib EQ @is_attrib-attrib
    INTO @DATA(lv_laenge).

    IF sy-subrc = 0.
      IF strlen( is_attrib-low ) > lv_laenge.
        APPEND |Attribut { is_attrib-attrib } soll maximal die Länge haben, die in Tabelle T77OMATTR hinterlegt ist. [{ lv_laenge }]| TO lt_err_text.
      ENDIF.

      IF strlen( is_attrib-high ) > lv_laenge.
        APPEND |Attribut { is_attrib-attrib } soll maximal die Länge haben, die in Tabelle T77OMATTR hinterlegt ist. [{ lv_laenge }]| TO lt_err_text.
      ENDIF.
    ENDIF.

*    " B) Die nachfolgenden Attribute müssen genau die Min-Länge besintzen, die die in der Tabelle ZNSI_AGR_UR13C haben

    READ TABLE it_tab_ur13c WITH KEY attrib = is_attrib-attrib ASSIGNING FIELD-SYMBOL(<fs_ur13c>).
    IF sy-subrc IS INITIAL AND <fs_ur13c>-min_laenge IS NOT INITIAL.

      IF is_attrib-low NE '*' AND NOT is_attrib-low CS '*'.
        IF strlen( is_attrib-low ) < <fs_ur13c>-min_laenge.
          APPEND |Attribut { is_attrib-attrib } hat unpassende Min.-Länge, Siehe Tabelle *UR13C. [{ <fs_ur13c>-min_laenge }]| TO lt_err_text.
        ELSE.
          IF is_attrib-high NE '*' AND NOT is_attrib-high CS '*' AND is_attrib-high IS NOT INITIAL.
            IF strlen( is_attrib-high ) < <fs_ur13c>-min_laenge.
              APPEND |Attribut { is_attrib-attrib } hat unpassende Min.-Länge, Siehe Tabelle *UR13C. [{ <fs_ur13c>-min_laenge }]| TO lt_err_text.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


    " C) Folgende Zeichen dürfen in keinem Attribut vorkommen:  Alles außer . (Punkt) – (Bindestrich) ; (Semikolon)

    IF is_attrib-low IS NOT INITIAL.
      str_reg = is_attrib-low.
      IF str_reg CN lv_regex.
        APPEND |Attribut { is_attrib-attrib } { is_attrib-low } enthält unerlaubte Zeichen.| TO lt_err_text.
      ENDIF.
    ENDIF.

    IF is_attrib-high IS NOT INITIAL.
      str_reg = is_attrib-high.
      IF str_reg CN lv_regex.
        APPEND |Attribut { is_attrib-attrib } { is_attrib-high } enthält unerlaubte Zeichen.| TO lt_err_text.
      ENDIF.
    ENDIF.


    " D) Attributsscharfe Vorgabe ob Wert numerisch sein muss oder nicht
    READ TABLE it_tab_ur13c WITH KEY attrib = is_attrib-attrib
                            ASSIGNING FIELD-SYMBOL(<fs_mapping>).


    IF sy-subrc = 0 AND <fs_mapping>-numer EQ abap_true.
      IF is_attrib-low IS NOT INITIAL.
        str_reg = is_attrib-low.
        IF str_reg CN '0123456789.*'.
          APPEND |Attribut { is_attrib-attrib } muss numerisch sein.| TO lt_err_text.
        ENDIF.
      ENDIF.

      IF is_attrib-high IS NOT INITIAL.
        str_reg = is_attrib-high.
        IF str_reg CN '0123456789.*'.
          APPEND |Attribut { is_attrib-attrib } muss numerisch sein.| TO lt_err_text.
        ENDIF.
      ENDIF.
    ENDIF.


    " E	Fehlender Wert (ZFUNK)

    " BUGE
    READ TABLE it_zfunk WITH KEY attrib = 'ZFUNK' low = 'BUGE' ASSIGNING FIELD-SYMBOL(<fs_buge>).
    IF sy-subrc = 0.

      READ TABLE it_zfunk WITH KEY attrib = 'ZBTRG_BUGE' TRANSPORTING NO FIELDS.
      IF sy-subrc IS NOT INITIAL.
        ls_attrib = <fs_buge>.
        ls_attrib-status = icon_led_red.
        ls_attrib-text   = |Das Attribut ZBTRG_BUGE mit dem Initialwert 999999999999.00 fehlt.|.
        APPEND ls_attrib TO rt_attrib.
        CLEAR ls_attrib.
      ENDIF.

      READ TABLE it_zfunk WITH KEY attrib = 'ZTITEL' TRANSPORTING NO FIELDS.
      IF sy-subrc IS NOT INITIAL.
        ls_attrib = <fs_buge>.
        ls_attrib-status = icon_led_red.
        ls_attrib-text   = |Das Attribut ZTITEL mit dem Intervall 0000000000000-ZZZZZZZZZZZZZ fehlt.|.
        APPEND ls_attrib TO rt_attrib.
        CLEAR ls_attrib.
      ENDIF.

    ENDIF.


    " AORD
    READ TABLE it_zfunk WITH KEY attrib = 'ZFUNK' low = 'AORD' ASSIGNING FIELD-SYMBOL(<fs_aord>).
    IF sy-subrc = 0.

      READ TABLE it_zfunk WITH KEY attrib = 'ZBTRG_AO' TRANSPORTING NO FIELDS.
      IF sy-subrc IS NOT INITIAL.
        ls_attrib = <fs_aord>.
        ls_attrib-status = icon_led_red.
        ls_attrib-text   = |Das Attribut ZBTRG_AO mit dem Initialwert 999999999999.00 fehlt.|.
        APPEND ls_attrib TO rt_attrib.
        CLEAR ls_attrib.
      ENDIF.

      READ TABLE it_zfunk WITH KEY attrib = 'ZTITEL_AO' TRANSPORTING NO FIELDS.
      IF sy-subrc IS NOT INITIAL.
        ls_attrib = <fs_aord>.
        ls_attrib-status = icon_led_red.
        ls_attrib-text   = |Das Attribut ZTITEL_AO mit dem Intervall 0000000000000-ZZZZZZZZZZZZZ fehlt.|.
        APPEND ls_attrib TO rt_attrib.
        CLEAR ls_attrib.
      ENDIF.
    ENDIF.

    " VGST
    READ TABLE it_zfunk WITH KEY attrib = 'ZFUNK' low = 'VGST' ASSIGNING FIELD-SYMBOL(<fs_vgst>).
    IF sy-subrc = 0.

      READ TABLE it_zfunk WITH KEY attrib = 'ZFRGVGS' TRANSPORTING NO FIELDS.
      IF sy-subrc IS NOT INITIAL.
        ls_attrib = <fs_vgst>.
        ls_attrib-status = icon_led_red.
        ls_attrib-text   = |Das Attribut ZFRGVGS mit dem Initialwert 999999999999.00 fehlt.|.
        APPEND ls_attrib TO rt_attrib.
        CLEAR ls_attrib.

      ENDIF.

      READ TABLE it_zfunk WITH KEY attrib = 'ZWRGP_VGST' TRANSPORTING NO FIELDS.
      IF sy-subrc IS NOT INITIAL.
        ls_attrib = <fs_vgst>.
        ls_attrib-status = icon_led_red.
        ls_attrib-text   = |Das Attribut ZWRGP_VGST mit dem Intervall 000000000-999999999 fehlt.|.
        APPEND ls_attrib TO rt_attrib.
        CLEAR ls_attrib.
      ENDIF.
    ENDIF.

    " F  wenn * Warnung ausgeben
    IF is_attrib-low IS NOT INITIAL.
      str_reg = is_attrib-low.
      IF str_reg CS '*'.
        APPEND |*| TO lt_err_text.
      ENDIF.
    ENDIF.

    IF is_attrib-high IS NOT INITIAL.
      str_reg = is_attrib-high.
      IF str_reg CS '*'.
        APPEND |*| TO lt_err_text.
      ENDIF.
    ENDIF.

    " G  wenn Low-Wert leer ist,  High ist aber vorhanden. PPOME lässt das zu.
    IF is_attrib-low IS INITIAL AND is_attrib-high IS NOT INITIAL.
      APPEND |Attribut { is_attrib-attrib }, falsches Intervall.| TO lt_err_text.
    ENDIF.

    " H  High-Wert <= Low Wert
    IF is_attrib-low IS NOT INITIAL AND is_attrib-high IS NOT INITIAL.
      IF is_attrib-low >= is_attrib-high.
        APPEND |Attribut { is_attrib-attrib }, falsches Intervall.| TO lt_err_text.
      ENDIF.
    ENDIF.

    " Returning
    ls_attrib = is_attrib.
    LOOP AT lt_err_text ASSIGNING FIELD-SYMBOL(<fs_err_text>).

      IF <fs_err_text> EQ '*'.
        ls_attrib-status = icon_led_yellow.
        ls_attrib-text   = |Eventuell ein falsches Intervall entdeckt. Prüfe, ob ein '*' erlaubt ist.|.
        APPEND ls_attrib TO rt_attrib.

      ELSE.
        ls_attrib-status = icon_led_red.
        ls_attrib-text   = <fs_err_text>.
        APPEND ls_attrib TO rt_attrib.
      ENDIF.
    ENDLOOP.
    CLEAR ls_attrib.

  endmethod.


  method CHECK_BER_DATA.

    CONSTANTS: k_icon_green(4) VALUE icon_led_green,  " @5B@
               k_icon_red(4)   VALUE icon_led_red,    " @5C@
               k_icon_yellow   TYPE  icon_d VALUE '@5D@'.

    DATA: lv_mandt TYPE mandt,
          o_ref    TYPE REF TO cx_root.


    LOOP AT it_ber_data ASSIGNING FIELD-SYMBOL(<fs_ber_data>).

      CHECK <fs_ber_data>-low NE '*'      AND
            NOT <fs_ber_data>-low CS '*'  AND
            NOT <fs_ber_data>-low CS '$'  AND
            NOT <fs_ber_data>-low CS ''''.


      CHECK <fs_ber_data>-typ_berecht IS NOT INITIAL.

      IF <fs_ber_data>-typ_berecht = 'FISTL' OR <fs_ber_data>-typ_berecht = 'FIPEX'.
        IF <fs_ber_data>-low EQ '9999' OR <fs_ber_data>-low EQ 'TECH*'.
          CONTINUE.
        ENDIF.
      ENDIF.

      SELECT *
         FROM @it_ur13c AS t_13c_ber
         WHERE typ_berecht = @<fs_ber_data>-typ_berecht
         INTO TABLE @DATA(lt_org_13c_ber) ##db_feature_mode[itabs_in_from_clause] ##ITAB_KEY_IN_SELECT.

      LOOP AT lt_org_13c_ber ASSIGNING FIELD-SYMBOL(<fs_ber_13c>).

        READ TABLE it_t77omattot WITH KEY attrib = <fs_ber_13c>-attrib TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.



          CASE <fs_ber_13c>-attrib.
            WHEN  'ACC_FCENTR'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM fmfctr WHERE fictr = @<fs_ber_data>-low AND datab LE @sy-datum AND datbis GE @sy-datum INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                              text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in FMFCTR nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                              TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in FMFCTR nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'BSART'.
              TRY.
                  IF <fs_ber_data>-high IS  INITIAL.
                    SELECT SINGLE mandt FROM t161 WHERE bsart = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T161 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.


                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T161 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'BUKRS'.
              TRY.
                  IF <fs_ber_data>-high IS  INITIAL.
                    SELECT SINGLE mandt FROM t001 WHERE bukrs = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T001 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T001 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'CATALOG'.

            WHEN  'CATVIEW'.


            WHEN  'COSTCENTER'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM csks WHERE kostl = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in CSKS nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in CSKS nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'DIVISION'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM tspa WHERE spart = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TSPA nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TSPA nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'D_CHANNEL'.
              TRY.
                  IF <fs_ber_data>-high IS  INITIAL.
                    SELECT SINGLE mandt FROM tvtw WHERE vtweg = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TVTW nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TVTW nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'EKORG'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t024e WHERE ekorg = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T024E nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T024E nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'KNTTP'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t163k WHERE knttp = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T163K nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T163K nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'R3_SA_OFF'.
              TRY.
                  IF <fs_ber_data>-high IS  INITIAL.
                    SELECT SINGLE mandt FROM tvbur WHERE vkbur = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TVBUR nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TVBUR nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'R3_SA_ORG'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM tvko WHERE vkorg = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TVKO nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TVKO nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'RESPPGRP'.
              TRY.
                  IF <fs_ber_data>-high IS  INITIAL.
                    SELECT SINGLE mandt FROM t024 WHERE ekgrp = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T024 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T024 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'WAERS'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM tcurc WHERE waers = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TCURC nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TCURC nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'WERKS'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t001w WHERE werks = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T001W nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T001W nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'ZAAFRG'.

            WHEN  'ZAAWRGP'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T023 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T023 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZBTRG_AO'.

            WHEN  'ZBTRG_BUGE'.

            WHEN  'ZBUKRS_BPC'.
              TRY.
                  IF <fs_ber_data>-high IS  INITIAL.
                    SELECT SINGLE mandt FROM t001 WHERE bukrs = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T001 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T001 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZDSTUN'.

            WHEN  'ZEINZELPL'.

            WHEN  'ZFRGVGB'.

            WHEN  'ZFRGVGS'.

            WHEN  'ZFUNK'.
              TRY.
                  IF <fs_ber_data>-high IS  INITIAL.
                    SELECT SINGLE mandt FROM /THKR/WF_FUNKT WHERE funktion = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in ZOM_WF_FUNKTION nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in ZOM_WF_FUNKTION nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'ZKAPITEL'.

            WHEN  'ZKSTL_AO'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM csks WHERE kostl = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in CSKS nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in CSKS nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZLAGERORT'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t001l WHERE lgort = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T0011 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T0011 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZORGRELEV'.

            WHEN  'ZPGSBR'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM tgsb WHERE gsber = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TGSB nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TGSB nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZPLEL_BPC'.

            WHEN  'ZROLLGRP'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM tb001 WHERE bu_group = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TB001 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in TB001 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'ZSTEUER'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t007a WHERE mwskz = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T007A nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T007A nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'ZTITEL'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM fmci WHERE augrp = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in FMCI nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in FMCI nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'ZTITEL_AO'.
              TRY.
                  IF <fs_ber_data>-high IS  INITIAL.
                    SELECT SINGLE mandt FROM fmci WHERE augrp = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in FMCI nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in FMCI nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZVKSTL'.
              TRY.
                  IF <fs_ber_data>-high IS  INITIAL.
                    SELECT SINGLE mandt FROM csks WHERE kostl = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in CSKS nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in CSKS nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZWEWGRP'.
              TRY.
                  IF <fs_ber_data>-high IS  INITIAL.
                    SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T023 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T023 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZWFLEVEL'.

            WHEN  'ZWGRPFB'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T023 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T023 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'ZWGRP_DSTL'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T023 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T023 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZWRGP_VGST'.
              TRY.
                  IF <fs_ber_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_ber_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T023 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Ber.-Ebene { <fs_ber_data>-typ_berecht }: [{ <fs_ber_13c>-attrib } { <fs_ber_data>-low }] in T023 nicht gefunden. { <fs_ber_data>-agr_name }[{ <fs_ber_data>-typ_rolle }{ <fs_ber_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.
          ENDCASE.

        ENDIF.
      ENDLOOP.

    ENDLOOP.

  endmethod.


  method CHECK_ORG_DATA.

     CONSTANTS: k_icon_green(4) VALUE icon_led_green,  " @5B@
               k_icon_red(4)   VALUE icon_led_red,    " @5C@
               k_icon_yellow   TYPE  icon_d VALUE '@5D@'.

    DATA: lv_mandt TYPE mandt,
          o_ref    TYPE REF TO cx_root.


    LOOP AT it_org_data ASSIGNING FIELD-SYMBOL(<fs_org_data>).

      CHECK <fs_org_data>-low NE '*' AND
            <fs_org_data>-low NE ''.

      SELECT *
               FROM @it_ur13c AS ur13c
               WHERE typ_orgebene = @<fs_org_data>-varbl
               INTO TABLE @DATA(lt_org_data_13c) ##db_feature_mode[itabs_in_from_clause] ##ITAB_KEY_IN_SELECT.

      LOOP AT lt_org_data_13c ASSIGNING FIELD-SYMBOL(<fs_data_13c>).

        READ TABLE it_t77omattot WITH KEY attrib = <fs_data_13c>-attrib TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.


          CASE <fs_data_13c>-attrib.

            WHEN  'ACC_FCENTR'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM fmfctr WHERE fictr = @<fs_org_data>-low AND datab LE @sy-datum AND datbis GE @sy-datum INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                              text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in FMFCTR nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                              TO it_attrib.
                      CONTINUE.

                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in FMFCTR nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'BSART'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t161 WHERE bsart = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T161 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T161 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'BUKRS'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t001 WHERE bukrs = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T001 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T001 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'CATALOG'.

            WHEN  'CATVIEW'.


            WHEN  'COSTCENTER'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM csks WHERE kostl = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in CSKS nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in CSKS nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'DIVISION'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM tspa WHERE spart = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TSPA nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TSPA nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'D_CHANNEL'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM tvtw WHERE vtweg = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TVTW nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TVTW nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'EKORG'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t024e WHERE ekorg = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T024E nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T024E nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'KNTTP'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t163k WHERE knttp = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T163K nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T163K nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'R3_SA_OFF'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM tvbur WHERE vkbur = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TVBUR nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TVBUR nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'R3_SA_ORG'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM tvko WHERE vkorg = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TVKO nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TVKO nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'RESPPGRP'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t024 WHERE ekgrp = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T024 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T024 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'WAERS'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM tcurc WHERE waers = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TCURC nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TCURC nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'WERKS'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t001w WHERE werks = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T001W nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T001W nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZAAFRG'.

            WHEN  'ZAAWRGP'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T023 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] nicht in nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'ZBTRG_AO'.

            WHEN  'ZBTRG_BUGE'.

            WHEN  'ZBUKRS_BPC'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t001 WHERE bukrs = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T001 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T001 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZDSTUN'.

            WHEN  'ZEINZELPL'.

            WHEN  'ZFRGVGB'.

            WHEN  'ZFRGVGS'.

            WHEN  'ZFUNK'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM /THKR/WF_FUNKT WHERE funktion = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in ZOM_WF_FUNKTION nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in ZOM_WF_FUNKTION nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZKAPITEL'.

            WHEN  'ZKSTL_AO'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM csks WHERE kostl = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in CSKS nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in CSKS nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZLAGERORT'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t001l WHERE lgort = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T0011 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T0011 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZORGRELEV'.

            WHEN  'ZPGSBR'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM tgsb WHERE gsber = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TGSB nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TGSB nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.

              ENDTRY.


            WHEN  'ZPLEL_BPC'.

            WHEN  'ZROLLGRP'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM tb001 WHERE bu_group = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TB001 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in TB001 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'ZSTEUER'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t007a WHERE mwskz = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T0007 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T0007 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZTITEL'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM fmci WHERE augrp = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in FMCI nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                           text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in FMCI nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                           TO it_attrib.
              ENDTRY.


            WHEN  'ZTITEL_AO'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM fmci WHERE augrp = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                                            text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in FMCI nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                                            TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                                          text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in FMCI nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                                          TO it_attrib.
              ENDTRY.

            WHEN  'ZVKSTL'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM csks WHERE kostl = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in CSKS nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in CSKS nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZWEWGRP'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T023 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T023 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZWFLEVEL'.

            WHEN  'ZWGRPFB'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T023 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T023 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.


            WHEN  'ZWGRP_DSTL'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype  objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T023 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype  objektid = iv_objid status = k_icon_red
                         text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T023 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                         TO it_attrib.
              ENDTRY.

            WHEN  'ZWRGP_VGST'.
              TRY.
                  IF <fs_org_data>-high IS INITIAL.
                    SELECT SINGLE mandt FROM t023 WHERE matkl = @<fs_org_data>-low INTO @lv_mandt.
                    IF sy-subrc NE 0.
                      APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype  objektid = iv_objid status = k_icon_red
                             text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T023 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                             TO it_attrib.
                      CONTINUE.
                    ENDIF.
                  ENDIF.

                CATCH cx_sy_open_sql_data_error INTO o_ref.
                  APPEND /THKR/CL_CHECK_KOMPL=>set_attr_gesamt_erw( nummer = iv_index objekttyp = iv_otype  objektid = iv_objid status = k_icon_red
                           text = |Org.-Ebene { <fs_org_data>-varbl }: [{ <fs_data_13c>-attrib } { <fs_org_data>-low }] in T023 nicht gefunden. { <fs_org_data>-agr_name }[{ <fs_org_data>-typ_rolle }{ <fs_org_data>-rolle_nr }]| )
                           TO it_attrib.
              ENDTRY.

*            WHEN  'KOKRS'.  " Kostenrechnungskreis ?
*            WHEN  'BUKRS'.
*              SELECT SINGLE mandt FROM t001 WHERE bukrs = @<fs_org_data>-low INTO @lv_mandt.
*            WHEN  ''. "FIKRS  Finanzkreis
*            WHEN  ''. " EKORG  Einkaufsorganisation
*            WHEN 'EKGRP'. " Einkäufergruppe
*              SELECT SINGLE mandt FROM t024 WHERE ekgrp = @<fs_org_data>-low INTO @lv_mandt.
*            WHEN 'SPART'. " Sparte
*              SELECT SINGLE mandt FROM tspa WHERE spart = @<fs_org_data>-low INTO @lv_mandt.
*            WHEN 'VKORG'. " Verkaufsorganisation
*            WHEN 'VTWEG'. " Vertriebsweg
*            WHEN  'WERKS'.
*              SELECT SINGLE mandt FROM t001w WHERE werks = @<fs_org_data>-low INTO @lv_mandt.
*            WHEN 'GSBER'. " Geschäftsbereich
*              SELECT SINGLE mandt FROM tgsb WHERE gsber = @<fs_org_data>-low INTO @lv_mandt.
*            WHEN 'PRCTR'. " Profit-Center
*            WHEN 'SWERK'. " Standortwerk
*            WHEN 'IWERK'. " Instandhaltungsplanungswerk
*            WHEN 'VSTEL'. " Versandstelle

          ENDCASE.

        ENDIF.
      ENDLOOP.


    ENDLOOP.


  endmethod.


  method CHECK_ZFUNK_TO_AGR.

     DATA: lt_rolle          TYPE TABLE OF znsi_agr_ur12c,
          lv_rolle_typ      TYPE znsi_agr_typ_rolle,
          lv_rolle_nr       TYPE znsi_agr_rolle_nr,
          lt_function_ur12c TYPE TABLE OF znsi_agr_ur12c-funktion,
          ls_value          TYPE /THKR/S_OM_struc_text,
          lt_agr_tables     TYPE STANDARD TABLE OF hrp1001-sobid,
          lt_rolle_exist    TYPE STANDARD TABLE OF hrp1001-sobid.

    CLEAR: lv_rolle_typ, lv_rolle_nr, lt_function_ur12c, ls_value, lt_rolle_exist, lt_agr_tables.

    " Alle Rollen lesen
    SELECT sobid
           FROM hrp1001
           WHERE objid = @iv_objid AND otype = 'S' AND sclas = 'AG' AND begda <= @sy-datum AND endda >= @sy-datum AND plvar = '01'
           INTO TABLE @lt_rolle_exist.

    " nur für virt S
    SELECT SINGLE plsty
           FROM hrp9808
           WHERE plvar = '01' AND otype = 'S' AND objid = @iv_objid AND begda <= @sy-datum AND endda >= @sy-datum
           INTO @DATA(lv_virtuell_v).                   "#EC CI_NOORDER

    IF sy-subrc = 0 AND lv_virtuell_v = 'V'.

      LOOP AT it_11xxl ASSIGNING FIELD-SYMBOL(<fs_11xxl_d>).

        CALL FUNCTION 'Z_NSI_AGR_READ'
          DESTINATION <fs_11xxl_d>-rfcdest
          EXPORTING
            plans      = iv_objid
          IMPORTING
            agr_tables = lt_agr_tables.

        IF lt_agr_tables IS NOT INITIAL.
          "lt_rolle_exist = CORRESPONDING #( lt_agr_tables MAPPING sobid = table_line ).
          MOVE-CORRESPONDING lt_agr_tables TO lt_rolle_exist KEEPING TARGET LINES.
        ENDIF.

      ENDLOOP.
    ENDIF.

    CLEAR lv_virtuell_v.

    """""""""""""

    IF lt_rolle_exist IS NOT INITIAL.

      SORT  lt_rolle_exist.
      DELETE ADJACENT DUPLICATES FROM lt_rolle_exist.

      " obligatorische Funktionen holen
      LOOP AT lt_rolle_exist ASSIGNING FIELD-SYMBOL(<fs_lt_rolle_exist>).

        lv_rolle_typ = <fs_lt_rolle_exist>+0(2).
        lv_rolle_nr  = <fs_lt_rolle_exist>+2(2).

        SELECT funktion FROM @it_ur12c AS r
                      WHERE typ_rolle = @lv_rolle_typ AND rolle_nr = @lv_rolle_nr
                      INTO TABLE @DATA(lt_tmp_funktion) ##ITAB_KEY_IN_SELECT ##ITAB_DB_SELECT.

        IF sy-subrc = 0.
          APPEND LINES OF lt_tmp_funktion TO lt_function_ur12c.
          CLEAR lt_tmp_funktion.
        ENDIF.

      ENDLOOP.
    ENDIF.

    SORT lt_function_ur12c.
    DELETE ADJACENT DUPLICATES FROM lt_function_ur12c.

    " vorhandene Funktionen lesen
    SELECT *
        FROM @it_attr_erw AS er
        WHERE nummer = @iv_nummer AND objektid = @iv_objid AND  attrib = 'ZFUNK' AND low IS NOT INITIAL
        INTO TABLE @DATA(result_table_zfunk) ##db_feature_mode[itabs_in_from_clause] ##ITAB_KEY_IN_SELECT.

    "überflüssige Funktionen
    IF result_table_zfunk IS NOT INITIAL.
      LOOP AT result_table_zfunk ASSIGNING FIELD-SYMBOL(<fs_function_no>).
        IF NOT line_exists( lt_function_ur12c[ table_line = <fs_function_no>-low ] ).

          SELECT typ_rolle, rolle_nr FROM @it_ur12c AS ra
                      WHERE funktion = @<fs_function_no>-low
                      INTO TABLE @DATA(lt_tmp_funktion_np) ##ITAB_KEY_IN_SELECT ##ITAB_DB_SELECT.

          IF sy-subrc NE 0.
            ls_value-rolle = ' '.
            ls_value-text = |ZFUNK { <fs_function_no>-low } gem. den Rollen ist uberflüssig.|.
            APPEND ls_value TO rt_values.
            CLEAR ls_value.
          ELSE.
            SORT lt_tmp_funktion_np BY typ_rolle rolle_nr.
            DELETE ADJACENT DUPLICATES FROM lt_tmp_funktion_np COMPARING ALL FIELDS.
            LOOP AT lt_tmp_funktion_np ASSIGNING FIELD-SYMBOL(<fs_funktion_np>).
              CONCATENATE <fs_funktion_np>-typ_rolle <fs_funktion_np>-rolle_nr INTO DATA(lv_rolle_nt).
              ls_value-rolle = lv_rolle_nt.
              ls_value-text = |ZFUNK { <fs_function_no>-low } löschen oder Rolle { <fs_funktion_np>-typ_rolle }{ <fs_funktion_np>-rolle_nr } hinzufügen.|.
              APPEND ls_value TO rt_values.
              CLEAR ls_value.
            ENDLOOP.
          ENDIF.

        ENDIF.
      ENDLOOP.
    ENDIF.


*    "fehlende Funktionen
*    IF lt_function_ur12c IS NOT INITIAL.
*      LOOP AT lt_function_ur12c ASSIGNING FIELD-SYMBOL(<fs_function_muss>).
*        IF NOT line_exists( result_table_zfunk[ low = <fs_function_muss> ] ).
*          APPEND |ZFUNK { <fs_function_muss> } gem. den Rollen nicht vorhanden.| TO rt_values.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.


    " obligatorische Funktionen holen
    LOOP AT lt_rolle_exist ASSIGNING FIELD-SYMBOL(<fs_lt_rolle_exist2>).
      lv_rolle_typ = <fs_lt_rolle_exist2>+0(2).
      lv_rolle_nr  = <fs_lt_rolle_exist2>+2(2).

      SELECT funktion FROM @it_ur12c AS rs
                 WHERE typ_rolle = @lv_rolle_typ AND rolle_nr = @lv_rolle_nr
                 INTO TABLE @DATA(lt_tmp_funktion2) ##ITAB_KEY_IN_SELECT ##ITAB_DB_SELECT.

      IF sy-subrc = 0 AND lt_tmp_funktion2 IS NOT INITIAL.

        SORT lt_tmp_funktion2 BY funktion.
        DELETE ADJACENT DUPLICATES FROM lt_tmp_funktion2 COMPARING funktion.

        LOOP AT lt_tmp_funktion2  ASSIGNING FIELD-SYMBOL(<fs_tmp_funktion2>).

          IF NOT line_exists( result_table_zfunk[ low = <fs_tmp_funktion2>-funktion ] ).
            CONCATENATE lv_rolle_typ lv_rolle_nr INTO DATA(lv_rolle_nt1).
            ls_value-rolle = lv_rolle_nt1.
            ls_value-text = |ZFUNK { <fs_tmp_funktion2>-funktion } zu Rolle { lv_rolle_typ }{ lv_rolle_nr } nicht vorhanden.|.
            APPEND ls_value TO rt_values.
            CLEAR ls_value.
          ENDIF.

        ENDLOOP.
      ENDIF.
    ENDLOOP.


  endmethod.


  method GET_AGR_FROM_OBJID.

        SELECT sobid
         INTO TABLE @rt_agrs
         FROM hrp1001
         WHERE otype = @iv_otype   AND
               objid = @iv_objid   AND
               plvar = '01'        AND
               rsign EQ 'B'        AND
               relat EQ '007'      AND
               istat EQ '1'        AND
               begda LE @sy-datum  AND
               endda GE @sy-datum  AND
               infty EQ '1001'     AND
               subty EQ 'B007'     AND
               sclas EQ 'AG'.

    IF sy-subrc IS INITIAL.
      SORT rt_agrs.
      DELETE ADJACENT DUPLICATES FROM rt_agrs.
    ENDIF.

  endmethod.


  method GET_TYP_BER_FROM_AGR_FIELDS.

      LOOP AT it_agr_1251 ASSIGNING FIELD-SYMBOL(<fs_agr_1251>).

      READ TABLE it_02xxl WITH KEY typ_rolle = <fs_agr_1251>-agr_name+0(2)
                                   rolle_nr = <fs_agr_1251>-agr_name+2(2)
                                   objekt = <fs_agr_1251>-object
                                   feld =  <fs_agr_1251>-field
                                   ASSIGNING FIELD-SYMBOL(<fs_02xxl_r>).

      CHECK sy-subrc = 0 AND <fs_02xxl_r>-typ_berecht IS NOT INITIAL.

      /THKR/cl_check_kompl=>ber_obj_special_procedure(
        EXPORTING
          iv_object = <fs_agr_1251>-object
          iv_field  = <fs_agr_1251>-field
        CHANGING
          iv_low    =  <fs_agr_1251>-low
          iv_high   =  <fs_agr_1251>-high
      ).

      <fs_agr_1251>-typ_berecht = <fs_02xxl_r>-typ_berecht.

    ENDLOOP.

  endmethod.


  method R3_PLAY_GUI_ALV_GRID.


     DATA: o_alv            TYPE REF TO cl_salv_table,
          lo_functions     TYPE REF TO cl_salv_functions_list,
          lo_columns       TYPE REF TO cl_salv_columns_table,
          lo_column        TYPE REF TO cl_salv_column,
          display_settings TYPE REF TO cl_salv_display_settings.


* SALV-Table mit automatisch generiertem Dynpro erzeugen
    TRY.
        cl_salv_table=>factory( IMPORTING
                                  r_salv_table = o_alv      " Referenz auf das SAP ALV Grid
                                CHANGING
                                  t_table = it_table ).
      CATCH cx_salv_msg.
        MESSAGE |Factory-Methode für ALV-Objekt ist fehlerhaft.| TYPE 'E'.
    ENDTRY.


    " Feldkatalog
    DATA(it_fcat) = cl_salv_controller_metadata=>get_lvc_fieldcatalog( r_columns      =  o_alv->get_columns( )
                                                                       r_aggregations =  o_alv->get_aggregations( ) ).

* Layout des ALV setzen
    DATA(lv_layout) = VALUE lvc_s_layo( zebra      = abap_true
                                        cwidth_opt = 'A'
                                        grid_title = 'Prüfung von Stammdaten' ).

    " Funktionsobjekt holen
    lo_functions = o_alv->get_functions( ).

* Sämtliche generischen ALV-Funktionen aktivieren
    lo_functions->set_all( if_salv_c_bool_sap=>true ).

* Spaltenobjekt holen
    lo_columns = o_alv->get_columns( ).

    TRY.
        lo_column = lo_columns->get_column( 'NUMMER' ).
        lo_column->set_long_text( 'Nummer' ).               "#EC NOTEXT
        lo_column->set_medium_text( 'Nummer' ).             "#EC NOTEXT
        lo_column->set_short_text( 'Nr.' ).                 "#EC NOTEXT

        lo_column = lo_columns->get_column( 'STATUS' ).
        lo_column->set_long_text( 'Status' ).               "#EC NOTEXT
        lo_column->set_medium_text( 'Status' ).             "#EC NOTEXT
        lo_column->set_short_text( 'St.' ).                 "#EC NOTEXT

        lo_column = lo_columns->get_column( 'INHERIT' ).
        lo_column->set_long_text( 'Attribut geerbt' ).      "#EC NOTEXT
        lo_column->set_medium_text( 'geerbt' ).             "#EC NOTEXT
        lo_column->set_short_text( 'geerbt.' ).             "#EC NOTEXT

        lo_column = lo_columns->get_column( 'CONDITION' ).
        lo_column->set_long_text( 'Condition' ).            "#EC NOTEXT
        lo_column->set_medium_text( 'Condition' ).          "#EC NOTEXT
        lo_column->set_short_text( 'Cond.' ).               "#EC NOTEXT

        lo_column = lo_columns->get_column( 'VORHANDEN' ).
        lo_column->set_long_text( 'Vorhanden' ).            "#EC NOTEXT
        lo_column->set_medium_text( 'Vorhanden' ).          "#EC NOTEXT
        lo_column->set_short_text( 'V' ).                   "#EC NOTEXT

        lo_column = lo_columns->get_column( 'ATEXT' ).
        lo_columns->set_column_position(
          EXPORTING
            columnname =  'ATEXT'
            position   =  '5'
        ).

        lo_column = lo_columns->get_column( 'ZFUNK_NO_EXIST' ).
        lo_column->set_visible( abap_false ).
        lo_column = lo_columns->get_column( 'DEFAULTVAL' ).
        lo_column->set_visible( abap_false ).
        lo_column = lo_columns->get_column( 'INH_LEVEL' ).
        lo_column->set_visible( abap_false ).
        lo_column = lo_columns->get_column( 'AGR_TEXT' ).
        lo_column->set_visible( abap_false ).
        lo_column = lo_columns->get_column( 'EXCLUDED' ).
        lo_column->set_visible( abap_false ).
        lo_column = lo_columns->get_column( 'INHERITED' ).
        lo_column->set_visible( abap_false ).


      CATCH cx_salv_not_found.                          "#EC NO_HANDLER
    ENDTRY.

    display_settings = o_alv->get_display_settings( ).
    display_settings->set_list_header( 'Stammdaten prüfen' ) ##NO_TEXT.
* Spalten optimieren.
    lo_columns->set_optimize( ).

* SALV-Table anzeigen
    o_alv->display( ).


  endmethod.


  method SET_ATTR_GESAMT_ERW.

    CLEAR ls_struc_attr_gesamt_erw.

    ls_struc_attr_gesamt_erw-nummer   = nummer.
    ls_struc_attr_gesamt_erw-objekttyp = objekttyp.
    ls_struc_attr_gesamt_erw-objektid  = objektid.
    ls_struc_attr_gesamt_erw-attrib = attrib.
    ls_struc_attr_gesamt_erw-low = low.
    ls_struc_attr_gesamt_erw-high = high.
    ls_struc_attr_gesamt_erw-excluded = excluded.
    ls_struc_attr_gesamt_erw-defaultval = defaultval.
    ls_struc_attr_gesamt_erw-inherited = inherited.
    ls_struc_attr_gesamt_erw-inherit = inherit.
    ls_struc_attr_gesamt_erw-inh_level = inh_level.
    ls_struc_attr_gesamt_erw-inh_otype = inh_otype.
    ls_struc_attr_gesamt_erw-inh_objid = inh_objid.

    SELECT SINGLE atext INTO @DATA(lv_attr_txt2) FROM t77omattrt WHERE attrib = @attrib AND langu = 'D' . "#EC CI_NOORDER
    ls_struc_attr_gesamt_erw-atext = lv_attr_txt2.
    CLEAR lv_attr_txt2.

    ls_struc_attr_gesamt_erw-agr_text = agr_text.
    ls_struc_attr_gesamt_erw-zfunk_no_exist = zfunk_no_exist.
    ls_struc_attr_gesamt_erw-condition = condition.
    ls_struc_attr_gesamt_erw-vorhanden = vorhanden.
    ls_struc_attr_gesamt_erw-status = status.
    ls_struc_attr_gesamt_erw-text = text.

  endmethod.
ENDCLASS.
