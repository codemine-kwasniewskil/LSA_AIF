class /THKR/CL_IM_FM_AUTH_CHECK definition
  public
  final
  create public .

public section.

  interfaces IF_EX_FM_AUTHORITY_CHECK .

  data G_FIPEX_AUTH_GRP type FMCI-AUGRP .
  data G_FICTR_AUTH_GRP type FMFCTR-AUGRP .
  data G_FUND_AUTH_GRP type FMFINCODE-AUGRP .
  data G_FUNCTION_AREA_AUTH_GRP type FM_AUTHGRP .
  data G_FUNDED_PROGRAM_AUTH_GRP type FM_AUTHGRP .
  data G_OK type CHAR1 .
  class-data G_MAX type I .
  class-data L_COUNTER type COUNT .
  class-data G_FISTL_OLD type FISTL .
  class-data G_FIPEX_OLD type FM_FIPEX .
protected section.
private section.
ENDCLASS.



CLASS /THKR/CL_IM_FM_AUTH_CHECK IMPLEMENTATION.


  method IF_EX_FM_AUTHORITY_CHECK~BUDGET_PERIOD_CHECK.
  endmethod.


  method IF_EX_FM_AUTHORITY_CHECK~COMMITMENT_ITEM_CHECK.

    " Parameter setzen für Z_FICA_TRG
    G_FIPEX_AUTH_GRP = I_AUTH_GROUP.
    SET PARAMETER ID 'FPS' FIELD I_CMMT_ITEM.

  endmethod.


  method IF_EX_FM_AUTHORITY_CHECK~FUNCTION_AREA_CHECK.

    G_FUNCTION_AREA_AUTH_GRP = I_FUNCTION_AREA.

  endmethod.


  METHOD if_ex_fm_authority_check~funded_program_check.

    " Prüfe auf Spezialtransaktion zum manuellen Abbau von Obligos
    IF sy-tcode = 'ZMM_DEL_OBLIGO' OR sy-cprog CS 'ZMM_DELETE_COMMITMENT'.
      RETURN.
    ENDIF.

*    G_FUNDED_PROGRAM_AUTH_GRP = I_FUNDED_PROGRAM.

    DATA:
      l_subrc         TYPE subrc,
      l_banfn         TYPE banfn,
      ls_act          TYPE fm_authact,
      ls_fincode_auth TYPE fm_authgrf,
      ls_fmfctr_auth  TYPE fm_authgrc,
      ls_fipex_auth   TYPE fm_authgrp,
      l_fistl         TYPE fistl,
      l_bp_geber      TYPE bp_geber,
      l_fipex         TYPE fm_fipex,
      l_gjahr         TYPE gjahr,
      l_fipos         TYPE fipos.

    IF l_counter IS INITIAL.
      GET PARAMETER ID 'BAN' FIELD l_banfn.
      SELECT COUNT( * ) FROM ebkn WHERE banfn EQ @l_banfn INTO @g_max.
      IF g_max IS INITIAL.
        SELECT COUNT( * ) FROM eban WHERE banfn EQ @l_banfn INTO @g_max.
      ENDIF.
    ENDIF.

    ADD 1 TO l_counter.

*     IF sy-cprog <> '/THKR/BCS_RFFMREP_LDB_PT01_V02'.
*      ls_act = i_activity.
*    ELSE.
*      ls_act = 'ZS'.
*    ENDIF.
    IF ls_act IS INITIAL.

      ls_act = i_activity.

    ENDIF.

    "Ist falsch, 1 mal berechtigt -> immer berechtigt
*    IF g_ok EQ 'X'.
*      RETURN.
*    ENDIF.

    GET PARAMETER ID 'FIS' FIELD l_fistl.     "Finanzstelle
    GET PARAMETER ID 'FIC' FIELD l_bp_geber.  "Fond
    GET PARAMETER ID 'FPS' FIELD l_fipex.     "Finanzpostion
    GET PARAMETER ID 'GJR' FIELD l_gjahr.     "Geschäftsjahr

*Berechtigungsgruppen selektieren
    SELECT SINGLE augrp FROM fmfincode INTO ls_fincode_auth WHERE fincode EQ l_bp_geber AND fikrs EQ i_fm_area AND datbis GE sy-datum. "#EC CI_NOORDER

    SELECT SINGLE augrp FROM fmfctr INTO ls_fmfctr_auth WHERE fictr EQ l_fistl AND fikrs EQ i_fm_area AND datbis GE sy-datum. "#EC CI_NOORDER

    IF l_gjahr IS NOT INITIAL.
      SELECT SINGLE augrp FROM fmci INTO ls_fipex_auth WHERE fipos EQ l_fipos AND fikrs EQ i_fm_area AND gjahr EQ l_gjahr. "#EC CI_NOORDER
    ELSE.
      SELECT SINGLE augrp FROM fmci INTO ls_fipex_auth WHERE fipos EQ l_fipos AND fikrs EQ i_fm_area. "#EC CI_NOORDER
    ENDIF.

    IF g_function_area_auth_grp IS NOT INITIAL AND l_bp_geber IS NOT INITIAL.

      SELECT SINGLE * FROM payac01
       INTO @DATA(ls_payac)
        WHERE
        geber = @l_bp_geber
        AND fkber = @g_function_area_auth_grp.
      IF sy-subrc <> 0.
        CLEAR: g_function_area_auth_grp, l_bp_geber, ls_fincode_auth.
      ENDIF.

    ELSE.
      CLEAR: g_function_area_auth_grp, l_bp_geber, ls_fincode_auth.

    ENDIF.

    SELECT SINGLE * FROM /thkr/c_tpbr_par
      INTO @DATA(ls_tpbr_par)
      WHERE Programm = 'Z_FICA'
      AND Fieldname = 'OBJEKT'.
    IF sy-subrc <> 0 OR ls_tpbr_par-low = 'TRG'.
      "Prüfung auf Berechtigungsgruppe der FIPOS
      CALL FUNCTION 'Z_CHECK_FICA_TRG'
        EXPORTING
          activity           = ls_act
          fm_area            = i_fm_area
          fm_fincode_authgrp = ls_fincode_auth
          fm_fmfctr_authgrp  = ls_fmfctr_auth
          fm_fipex_authgrp   = ls_fipex_auth
          fm_measure_authgrp = i_auth_group
          fm_farea_authgrp   = g_function_area_auth_grp
        IMPORTING
          ex_subrc           = l_subrc.

      IF l_subrc EQ 0.
        g_ok = 'X'.
      ELSE.
        g_ok = space.
      ENDIF.

      IF g_ok IS INITIAL AND l_counter GE g_max.
        "Sonderfall Berichte
        IF sy-tcode EQ 'START_REPORT'.
          SET PARAMETER ID 'Z_FICA_REPORT_AUTH' FIELD 'X'.
        ELSE.
          CASE l_subrc.
            WHEN 0.
            WHEN 4.
              c_f_message-msgid = '/THKR/RUB_MESSG'.
              c_f_message-msgty = 'E'.
              c_f_message-msgno = '21'.
            WHEN 6.
              c_f_message-msgid = '/THKR/RUB_MESSG'.
              c_f_message-msgty = 'E'.
              c_f_message-msgno = '22'.
            WHEN OTHERS.
              c_f_message-msgid = '/THKR/RUB_MESSG'.
              c_f_message-msgty = 'E'.
              c_f_message-msgno = '21'.
          ENDCASE.
        ENDIF.
      ENDIF.

      "Prüfung Berechtigung auf Unterkonten
    ELSEIF ls_tpbr_par-low = 'UTK'.

      CLEAR l_fipex.
      SELECT SINGLE fipex FROM fmfxpo
            INTO l_fipex
            WHERE fipos = l_fipos.
      IF l_fipex IS INITIAL.
        l_fipex = l_fipos.
      ENDIF.

      CALL FUNCTION '/THKR/CHECK_FICA_UTK'
        EXPORTING
          activity           = ls_act
          fm_area            = i_fm_area
          fm_fincode_authgrp = ls_fincode_auth
          fm_fmfctr_authgrp  = ls_fmfctr_auth
          fm_fipex           = l_fipex
          fm_measure_authgrp = i_auth_group
          fm_farea_authgrp   = g_function_area_auth_grp
        IMPORTING
          ex_subrc           = l_subrc.

      IF l_subrc EQ 0.
        g_ok = 'X'.
      ELSE.
        g_ok = space.
      ENDIF.

      IF g_ok IS INITIAL AND l_counter GE g_max.
        "Sonderfall Berichte
        IF sy-tcode EQ 'START_REPORT'.
          SET PARAMETER ID 'Z_FICA_REPORT_AUTH' FIELD 'X'.
        ELSE.
          CASE l_subrc.
            WHEN 0.
            WHEN 4.
              c_f_message-msgid = '/THKR/RUB_MESSG'.
              c_f_message-msgty = 'E'.
              c_f_message-msgno = '23'.
            WHEN 6.
              c_f_message-msgid = '/THKR/RUB_MESSG'.
              c_f_message-msgty = 'E'.
              c_f_message-msgno = '22'.
            WHEN OTHERS.
              c_f_message-msgid = '/THKR/RUB_MESSG'.
              c_f_message-msgty = 'E'.
              c_f_message-msgno = '23'.
          ENDCASE.
        ENDIF.
      ENDIF.


    ENDIF.

  ENDMETHOD.


  method IF_EX_FM_AUTHORITY_CHECK~FUNDS_CENTER_CHECK.

* Parameter setzen für Z_FICA_TRG
*   G_FICTR_AUTH_GRP = I_AUTH_GROUP.
    Set PARAMETER ID 'FIS' FIELD I_FUNDS_CENTER.

  endmethod.


  METHOD if_ex_fm_authority_check~fund_check.

    " Prüfe auf Spezialtransaktion zum manuellen Abbau von Obligos
    IF sy-tcode = 'ZMM_DEL_OBLIGO' OR sy-cprog CS 'ZMM_DELETE_COMMITMENT'.
      RETURN.
    ENDIF.


* Parameter setzen für Z_FICA_TRG
*    G_FUND_AUTH_GRP = I_AUTH_GROUP.
    SET PARAMETER ID 'FIC' FIELD i_fund.

    DATA:
      l_cobl          TYPE cobl,
      lt_uname        TYPE TABLE OF uname,
      l_subrc         TYPE subrc,
      l_fipex         TYPE fm_fipex,
      l_fipos         TYPE fipos,
      l_fistl         TYPE fistl,
      l_geber         TYPE bp_geber,
      l_measure       TYPE fm_measure,
      l_aufkv         TYPE aufkv,
      l_aufnr         TYPE aufnr,
      l_fm_measure    TYPE fm_measure,
      l_bnfpo         TYPE bnfpo,
      l_bes           TYPE ebeln,
      lt_banfn        TYPE TABLE OF eban,
      l_banfn         TYPE banfn,
      ls_fincode_auth TYPE fm_authgrf,
      ls_fmfctr_auth  TYPE fm_authgrc,
      ls_fipex_auth   TYPE fm_authgrp,
      ls_measure_auth TYPE fm_authgr_measure,
      ls_ekkn         TYPE ekkn,
      ls_act          TYPE fm_authact,
      lt_ekkn         TYPE TABLE OF ekkn,
      l_ebkn          TYPE ebkn,
      lt_ebkn         TYPE TABLE OF ebkn,
      l_data          TYPE mepoaccounting,
      l_gjahr         TYPE gjahr.

    GET PARAMETER ID 'FIS' FIELD l_fistl.     "Finanzstelle
    GET PARAMETER ID 'FIC' FIELD l_geber.     "Fond
    GET PARAMETER ID 'FPS' FIELD l_fipos.     "Finanzpostion
    GET PARAMETER ID 'GJR' FIELD l_gjahr.     "Geschäftsjahr

    ls_act = i_activity.


    IF sy-tcode IS INITIAL.
* Fiori Aufrufe
      GET PARAMETER ID 'BAN' FIELD l_banfn.
      IF l_banfn IS NOT INITIAL.
        SELECT aufnr FROM ebkn INTO CORRESPONDING FIELDS OF TABLE lt_ebkn WHERE banfn EQ l_banfn.
        LOOP AT lt_ebkn INTO l_ebkn.


          IF l_counter IS INITIAL.
            SELECT COUNT( * ) FROM ebkn WHERE banfn EQ @l_banfn INTO @g_max.
            IF g_max IS INITIAL.
              SELECT COUNT( * ) FROM eban WHERE banfn EQ @l_banfn INTO @g_max.
            ENDIF.
          ENDIF.

          ADD 1 TO l_counter.

          CALL FUNCTION 'K_ORDER_READ'
            EXPORTING
              aufnr            = l_ebkn-aufnr
              no_message_store = 'X'
            IMPORTING
              i_aufkv          = l_aufkv
            EXCEPTIONS
              not_found        = 1.
          .
          IF sy-subrc <> 0.
            MESSAGE ID '/THKR/RUB_MESSG' TYPE 'W' NUMBER '18'.
          ENDIF.

*          l_measure = l_aufkv-zzmeasure.

        ENDLOOP.
      ENDIF.
      GET PARAMETER ID 'BES' FIELD l_bes.
      IF l_bes IS NOT INITIAL.
        SELECT ebelp zekkn FROM ekkn INTO CORRESPONDING FIELDS OF TABLE lt_ekkn WHERE ebeln EQ l_bes.
        LOOP AT lt_ekkn INTO ls_ekkn.


          IF l_counter IS INITIAL.
            SELECT COUNT( * ) FROM ekkn WHERE  ebeln EQ @l_bes INTO @g_max.
          ENDIF.

          ADD 1 TO l_counter.

          CALL FUNCTION 'MEPO_DOC_ACCOUNTING_GET'
            EXPORTING
              im_ebelp      = ls_ekkn-ebelp
              im_zekkn      = ls_ekkn-zekkn
            IMPORTING
              ex_accounting = l_data
            EXCEPTIONS
              failure       = 1
              OTHERS        = 2.
          IF sy-subrc <> 0.
            CASE sy-subrc.
              WHEN 1.
                MESSAGE ID '/THKR/RUB_MESSG' TYPE 'W' NUMBER '19'.
              WHEN 2.
                MESSAGE ID '/THKR/RUB_MESSG' TYPE 'W' NUMBER '20'.
            ENDCASE.
          ENDIF.

          l_measure = l_data-measure.

        ENDLOOP.

      ENDIF.

    ELSE.
* ERP Aufrufe

      CASE sy-tcode.
        WHEN 'ME23N'.
*    Anzeigen
          ls_act = '11'.
        WHEN 'ME22N'.
*    Ändern
          ls_act = '12'.
        WHEN 'ME21N'.
*    Erstellen
          ls_act = '10'.
        WHEN OTHERS.

          ls_act = i_activity.
      ENDCASE.
      IF sy-tcode EQ 'ME52N' OR sy-tcode EQ 'ME53N' OR sy-tcode EQ 'ME51N'.
        GET PARAMETER ID 'BAN' FIELD l_banfn.
        SELECT fistl fipos aufnr geber FROM ebkn INTO CORRESPONDING FIELDS OF TABLE lt_ebkn WHERE banfn EQ l_banfn.
        LOOP AT lt_ebkn INTO l_ebkn.

          IF l_counter IS INITIAL.
            SELECT COUNT( * ) FROM ebkn WHERE banfn EQ @l_banfn INTO @g_max.
            IF g_max IS INITIAL.
              SELECT COUNT( * ) FROM eban WHERE banfn EQ @l_banfn INTO @g_max.
            ENDIF.
          ENDIF.

          ADD 1 TO l_counter.

          CALL FUNCTION 'K_ORDER_READ'
            EXPORTING
              aufnr            = l_ebkn-aufnr
              no_message_store = 'X'
            IMPORTING
              i_aufkv          = l_aufkv
            EXCEPTIONS
              not_found        = 1.
          .
          IF sy-subrc <> 0.
            MESSAGE ID '/THKR/RUB_MESSG' TYPE 'W' NUMBER '18'.
          ENDIF.

          l_fipos = l_ebkn-fipos.
          l_fistl = l_ebkn-fistl.
          l_geber = l_ebkn-geber.
*          l_measure = l_aufkv-zzmeasure.

        ENDLOOP.
      ELSE.

        CALL FUNCTION 'COBL_EX_RECEIVE'
          IMPORTING
            ecobl_int = l_cobl.

        l_measure = l_cobl-measure.

      ENDIF.

    ENDIF.

    IF sy-cprog = '/THKR/BCS_RFFMREP_LDB_PT01_V02'.
      ls_act = 'ZS'.
    ENDIF.

    IF sy-tcode EQ 'START_REPORT'.
      GET PARAMETER ID 'FM_MEASURE' FIELD l_measure.
    ENDIF.

*Berechtigungsgruppen selektieren
    SELECT SINGLE augrp FROM fmfincode INTO ls_fincode_auth WHERE fincode EQ l_geber AND fikrs EQ i_fm_area.

    SELECT SINGLE augrp FROM fmfctr INTO ls_fmfctr_auth WHERE fictr EQ l_fistl AND fikrs EQ i_fm_area AND datbis GE sy-datum. "#EC CI_NOORDER

    IF l_gjahr IS NOT INITIAL.
      SELECT SINGLE augrp FROM fmci INTO ls_fipex_auth WHERE fipos EQ l_fipos AND fikrs EQ i_fm_area AND gjahr EQ l_gjahr. "#EC CI_NOORDER
    ELSE.
      SELECT SINGLE augrp FROM fmci INTO ls_fipex_auth WHERE fipos EQ l_fipos AND fikrs EQ i_fm_area. "#EC CI_NOORDER
    ENDIF.

    IF ls_measure_auth IS INITIAL.
      SELECT SINGLE authgrp FROM fmmeasure INTO ls_measure_auth WHERE measure EQ l_measure AND fmarea EQ i_fm_area.
    ENDIF.

    DATA(lv_object_fica) = /thkr/cl_auth_check=>get_fica_object( ).
    CASE lv_object_fica.
      WHEN /THKR/CL_AUTH_CHECK=>GC_FICA_UTK.

        "Berechtigungsprüfung auf Unterkonten
        CLEAR l_fipex.
        SELECT SINGLE fipex FROM fmfxpo
              INTO l_fipex
              WHERE fipos = l_fipos.
        IF l_fipex IS INITIAL.
          l_fipex = l_fipos.
        ENDIF.

        CALL FUNCTION '/THKR/CHECK_FICA_UTK'
          EXPORTING
            activity           = ls_act
            fm_area            = i_fm_area
            fm_fincode_authgrp = ls_fincode_auth
            fm_fmfctr_authgrp  = ls_fmfctr_auth
            fm_fipex           = l_fipex
            fm_measure_authgrp = ls_measure_auth
            fm_farea_authgrp   = g_function_area_auth_grp
          IMPORTING
            ex_subrc           = l_subrc.
        IF l_subrc EQ 0.
          g_ok = 'X'.
        ELSE.
          g_ok = space.
        ENDIF.

        IF g_ok IS INITIAL AND l_counter GE g_max.
          "Sonderfall Berichte
          IF sy-tcode EQ 'START_REPORT'.
            SET PARAMETER ID 'Z_FICA_REPORT_AUTH' FIELD 'X'.
          ELSE.
            CASE l_subrc.
              WHEN 0.
              WHEN 4.
                c_f_message-msgid = '/THKR/RUB_MESSG'.
                c_f_message-msgty = 'E'.
                c_f_message-msgno = '23'.
              WHEN 6.
                c_f_message-msgid = '/THKR/RUB_MESSG'.
                c_f_message-msgty = 'E'.
                c_f_message-msgno = '22'.
              WHEN OTHERS.
                c_f_message-msgid = '/THKR/RUB_MESSG'.
                c_f_message-msgty = 'E'.
                c_f_message-msgno = '23'.
            ENDCASE.
          ENDIF.
        ENDIF.

      WHEN OTHERS.

        "Berechtigungsprüfung auf Berechtigungsgruppe der FIPOS
        CALL FUNCTION 'Z_CHECK_FICA_TRG'
          EXPORTING
            activity           = ls_act
            fm_area            = i_fm_area
            fm_fincode_authgrp = ls_fincode_auth
            fm_fmfctr_authgrp  = ls_fmfctr_auth
            fm_fipex_authgrp   = ls_fipex_auth
            fm_measure_authgrp = ls_measure_auth
            fm_farea_authgrp   = g_function_area_auth_grp
          IMPORTING
            ex_subrc           = l_subrc.
        IF l_subrc EQ 0.
          g_ok = 'X'.
        ELSE.
          g_ok = space.
        ENDIF.

        IF g_ok IS INITIAL AND l_counter GE g_max.
          "Sonderfall Berichte
          IF sy-tcode EQ 'START_REPORT'.
            SET PARAMETER ID 'Z_FICA_REPORT_AUTH' FIELD 'X'.
          ELSE.
            CASE l_subrc.
              WHEN 0.
              WHEN 4.
                c_f_message-msgid = '/THKR/RUB_MESSG'.
                c_f_message-msgty = 'E'.
                c_f_message-msgno = '21'.
              WHEN 6.
                c_f_message-msgid = '/THKR/RUB_MESSG'.
                c_f_message-msgty = 'E'.
                c_f_message-msgno = '22'.
              WHEN OTHERS.
                c_f_message-msgid = '/THKR/RUB_MESSG'.
                c_f_message-msgty = 'E'.
                c_f_message-msgno = '21'.
            ENDCASE.
          ENDIF.
        ENDIF.

    ENDCASE.

  ENDMETHOD.
ENDCLASS.
