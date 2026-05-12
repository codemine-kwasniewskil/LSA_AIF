"Name: \PR:RFBUEB00\FO:GRID_DISPLAY\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/FI_GSBER_AUTH_CHECK_FB03.

*Berechtigungsprüfung KRITKON + Z_FICA_TRG

  CONSTANTS: lc_x TYPE string VALUE 'XXXXXXXXXXXXX'.
  DATA: ls_selopt    TYPE selopt,
        lt_bukrs     TYPE TABLE OF selopt,
        lt_belnr     TYPE TABLE OF selopt,
        lt_belnr_tmp TYPE TABLE OF selopt,
        lt_gjahr     TYPE TABLE OF selopt,
        lt_bkpf      TYPE TABLE OF bkpf,
        ls_tpbr_par  TYPE /thkr/c_tpbr_par.

  DATA: i_postab TYPE rfpos,
        e_postab TYPE rfpos.

  TYPES: BEGIN OF lty_acd,
           rbukrs TYPE acdoca-rbukrs,
           belnr  TYPE acdoca-belnr,
           gjahr  TYPE acdoca-gjahr,
           rbusa  TYPE acdoca-rbusa,
           rcntr  TYPE acdoca-rcntr,
           prctr  TYPE acdoca-prctr,
           fistl  TYPE acdoca-fistl,
           fipex  TYPE acdoca-fipex,
           blart  TYPE acdoca-blart,
           ukostl TYPE acdoca-ukostl,
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(5) Form GRID_DISPLAY, Anfang, Erweiterung /THKR/FI_GSBER_AUTH_CHECK_FB03, Typ LTY_ACD, Ende                                                          S
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(5) Form GRID_DISPLAY, Anfang, Erweiterung /THKR/FI_GSBER_AUTH_CHECK_FB03, Typ LTY_ACD, Ende                                                          S
         END OF lty_acd.

  DATA: lt_acdoca TYPE TABLE OF lty_acd,
        lt_ac_tmp TYPE TABLE OF lty_acd.

  TYPES : BEGIN OF ty_bseg,
            belnr TYPE bseg-belnr,
            fipos TYPE bseg-fipos,
            fistl TYPE bseg-fistl,
            kunnr TYPE bseg-kunnr,
            lifnr TYPE bseg-lifnr,

    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(6) Form GRID_DISPLAY, Anfang, Erweiterung /THKR/FI_GSBER_AUTH_CHECK_FB03, Typ TY_BSEG, Ende                                                          S
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""$"$\SE:(6) Form GRID_DISPLAY, Anfang, Erweiterung /THKR/FI_GSBER_AUTH_CHECK_FB03, Typ TY_BSEG, Ende                                                          S
          END OF ty_bseg.

  DATA: lv_fincode_auth TYPE fm_authgrf,
        lv_fmfctr_auth  TYPE fm_authgrc,
        lv_fipex_auth   TYPE fm_authgrp,
        lv_measure_auth TYPE fm_authgr_measure,
        lt_bseg         TYPE STANDARD TABLE OF ty_bseg,
        lv_ok           TYPE flag,
        lv_rc           TYPE n,
        lv_fipex        TYPE fm_fipex.


  LOOP AT gt_ybkpf_alv ASSIGNING FIELD-SYMBOL(<lf_ybkpf>).

    ls_selopt-sign   = 'I'.
    ls_selopt-option = 'EQ'.
    ls_selopt-low    = <lf_ybkpf>-bukrs.
    ls_selopt-high   = ''.

    APPEND ls_selopt TO lt_bukrs.
    CLEAR ls_selopt.

    ls_selopt-sign   = 'I'.
    ls_selopt-option = 'EQ'.
    ls_selopt-low    = <lf_ybkpf>-belnr.
    ls_selopt-high   = ''.

    APPEND ls_selopt TO lt_belnr.
    CLEAR ls_selopt.


    ls_selopt-sign   = 'I'.
    ls_selopt-option = 'EQ'.
    ls_selopt-low    = <lf_ybkpf>-gjahr.
    ls_selopt-high   = ''.

    APPEND ls_selopt TO lt_gjahr.
    CLEAR ls_selopt.

  ENDLOOP.

  SORT lt_bukrs ASCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_bukrs.

  SORT lt_belnr ASCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_belnr.

  SORT lt_gjahr ASCENDING.
  DELETE ADJACENT DUPLICATES FROM lt_gjahr.

  IF lt_bukrs IS INITIAL AND lt_belnr IS INITIAL
    AND lt_gjahr IS INITIAL.

    MESSAGE 'Lange Selektionszeiten möglich, wenn möglich, weitere Selektionskriterien pflegen'
      TYPE 'W'.
  ENDIF.

  IF lines( lt_belnr ) LT 2000.

    "FIPOS noch nicht in ACDOCA
    SELECT rbukrs belnr gjahr rbusa rcntr prctr fistl fipex blart ukostl
      FROM acdoca
      INTO TABLE lt_acdoca
      WHERE rbukrs  IN lt_bukrs
      AND   belnr   IN lt_belnr
      AND   gjahr   IN lt_gjahr.                        "#EC CI_SEL_DEL

  ELSE.

    LOOP AT lt_belnr ASSIGNING FIELD-SYMBOL(<ls_belnr>).

      IF lines( lt_belnr_tmp ) LT 2000.

        APPEND <ls_belnr> TO lt_belnr_tmp.
      ELSE.

        "FIPOS noch nicht in ACDOCA
        SELECT rbukrs belnr gjahr rbusa rcntr prctr fistl fipex blart ukostl
          FROM acdoca
          INTO TABLE lt_ac_tmp
          WHERE rbukrs  IN lt_bukrs
          AND   belnr   IN lt_belnr_tmp
          AND   gjahr   IN lt_gjahr.                    "#EC CI_SEL_DEL

        APPEND LINES OF lt_ac_tmp TO lt_acdoca.
        CLEAR: lt_ac_tmp, lt_belnr_tmp.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF lines( lt_acdoca ) GT 0.

    SORT lt_acdoca BY belnr.
    DELETE ADJACENT DUPLICATES FROM lt_acdoca.
  ENDIF.


  LOOP AT lt_acdoca ASSIGNING FIELD-SYMBOL(<lf_acdoca>).

    AUTHORITY-CHECK OBJECT 'F_BKPF_GSB'
      ID 'GSBER' FIELD <lf_acdoca>-rbusa
      ID 'ACTVT' FIELD '03'.

    IF sy-subrc NE 0.
      DELETE gt_ybkpf_alv
        WHERE bukrs EQ <lf_acdoca>-rbukrs
        AND   belnr EQ <lf_acdoca>-belnr
        AND   gjahr EQ <lf_acdoca>-gjahr.                "#EC CI_STDSEQ
      CONTINUE.
    ENDIF.

  ENDLOOP.

**********************************************************************
* 12.03.2025 08:59:19 REPRO-KOE : Z_FICA_TRG                         *
**********************************************************************
  CLEAR lv_ok.

  LOOP AT gt_ybkpf_alv ASSIGNING FIELD-SYMBOL(<fs_alv>).

    CLEAR: lt_bseg, lv_ok.
    SELECT DISTINCT belnr fipos fistl kunnr lifnr
     INTO TABLE lt_bseg
     FROM bseg
     WHERE belnr EQ <fs_alv>-belnr AND
           gjahr EQ <fs_alv>-gjahr AND
           bukrs EQ <fs_alv>-bukrs.

    "technische Positionen rausnehmen
*    DELETE lt_bseg WHERE fipos EQ '9999' OR
*                         fipos+0(4) EQ 'TECH'.

    CHECK lt_bseg IS NOT INITIAL.
    DATA(lv_object_fica) = /thkr/cl_auth_check=>get_fica_object( ).

    LOOP AT lt_bseg ASSIGNING FIELD-SYMBOL(<fs_bseg>)
      WHERE fipos <> '9999' AND fipos+0(4) <> 'TECH'.


*   Berechtigungsgruppen selektieren
      SELECT SINGLE augrp FROM fmfctr INTO lv_fmfctr_auth
          WHERE fictr EQ <fs_bseg>-fistl AND
                fikrs EQ <fs_alv>-fikrs  AND
                datbis GE sy-datum.
      SELECT SINGLE augrp FROM fmci INTO lv_fipex_auth
         WHERE fipex EQ <fs_bseg>-fipos AND
               fikrs EQ <fs_alv>-fikrs.

      CLEAR lv_rc.
      CASE lv_object_fica.
        WHEN /THKR/CL_AUTH_CHECK=>GC_FICA_UTK.
          CLEAR lv_fipex.
          SELECT SINGLE fipex FROM fmfxpo
              INTO lv_fipex
              WHERE fipos = <fs_bseg>-fipos.
          IF lv_fipex IS INITIAL.
            MOVE <fs_bseg>-fipos TO lv_fipex.
          ENDIF.
          CALL FUNCTION '/THKR/CHECK_FICA_UTK'
            EXPORTING
              activity          = '11'
              fm_area           = <fs_alv>-fikrs
              fm_fmfctr_authgrp = lv_fmfctr_auth    " Berechtigungsgruppe der Finanzstelle
              fm_fipex          = lv_fipex          "  Finanzposition
            IMPORTING
              ex_subrc          = lv_rc.

        WHEN OTHERS.
          CALL FUNCTION 'Z_CHECK_FICA_TRG'
            EXPORTING
              activity          = '11'
              fm_area           = <fs_alv>-fikrs
              fm_fmfctr_authgrp = lv_fmfctr_auth    " Berechtigungsgruppe der Finanzstelle
              fm_fipex_authgrp  = lv_fipex_auth     " Berechtigungsgruppe der Finanzposition
            IMPORTING
              ex_subrc          = lv_rc.
      ENDCASE.


      IF lv_rc EQ 0.
        lv_ok = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.

    " nicht berechtigt
    IF lv_ok EQ abap_false AND
       sy-subrc IS INITIAL.
      DELETE gt_ybkpf_alv.
    ENDIF.

    DATA(lv_object) = /thkr/cl_auth_check=>get_bupa_object( ).

    LOOP AT lt_bseg ASSIGNING <fs_bseg>.

      IF <fs_bseg>-lifnr IS NOT INITIAL.

        DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
                              iv_partner = <fs_bseg>-lifnr
                              iv_type = 'K'
                              iv_object = lv_object  ).
        IF no_auth_l EQ abap_true.

          DELETE gt_ybkpf_alv.
          EXIT.

        ENDIF.

      ELSEIF <fs_bseg>-kunnr IS NOT INITIAL.

        no_auth_l = /thkr/cl_auth_check=>check_bupa_auth(
                                     iv_partner = <fs_bseg>-kunnr
                                     iv_type = 'D'
                                     iv_object = lv_object ).
        IF no_auth_l EQ abap_true.

          DELETE gt_ybkpf_alv.
          EXIT.

        ENDIF.

      ENDIF.



    ENDLOOP.

  ENDLOOP.

ENDENHANCEMENT.
