*&---------------------------------------------------------------------*
*& Include          ZXFMYU35
*&---------------------------------------------------------------------*

DATA: "lt_KRIT_KON       TYPE TABLE OF ZFI_KRIT_KON,
  "lt_exce_user      TYPE TABLE OF ZFI_EXCE_USER,
  l_subrc           TYPE subrc,
  ls_auth_grp_fistl TYPE fm_authgrc,
  ls_auth_grp_hhp   TYPE fm_authgr_measure,
  ls_auth_grp_fond  TYPE fm_authgrf,
  ls_auth_grp_fipos TYPE fm_authgrp,
  ls_act            TYPE fm_authact,
  lv_fipex          TYPE fm_fipex.


CASE sy-tcode.
  WHEN 'F873'.
*   Anzeigen
    ls_act = '11'.
  WHEN 'F872'.
*   Ändern
    ls_act = '12'.
  WHEN 'F871'.
*   erstellen
    ls_act = '10'.
  WHEN 'START_REPORT'.
    SET PARAMETER ID 'FM_MEASURE' FIELD i_cobl-measure.
  WHEN OTHERS.
    RETURN.
ENDCASE.

SELECT SINGLE augrp FROM fmfctr INTO ls_auth_grp_fistl WHERE fikrs EQ i_cobl-fikrs AND fictr EQ i_cobl-fistl AND datbis GE sy-datum. "#EC CI_NOORDER

SELECT SINGLE augrp FROM fmci INTO ls_auth_grp_fipos WHERE fikrs EQ i_cobl-fikrs AND fipos EQ i_cobl-fipos AND gjahr EQ i_cobl-gjahr. "#EC CI_NOORDER

SELECT SINGLE augrp FROM fmfincode INTO ls_auth_grp_fond WHERE fincode EQ i_cobl-geber AND fikrs EQ i_cobl-fikrs.

SELECT SINGLE authgrp FROM fmmeasure INTO ls_auth_grp_hhp WHERE measure EQ i_cobl-measure AND fmarea EQ i_cobl-fikrs.
IF ls_auth_grp_hhp IS INITIAL.
*     message 'Keine Berechtigungsgruppe im Haushaltsprogramm gepflegt' TYPE 'E' .
ENDIF.

DATA(lv_object_fica) = /thkr/cl_auth_check=>get_fica_object( ).
CASE lv_object_fica.
  WHEN /THKR/CL_AUTH_CHECK=>GC_FICA_UTK.

    CLEAR lv_fipex.
    SELECT SINGLE fipex FROM fmfxpo
              INTO lv_fipex
              WHERE fipos = i_cobl-fipos.
    IF lv_fipex IS INITIAL.
      lv_fipex = i_cobl-fipos.
    ENDIF.
    CALL FUNCTION '/THKR/CHECK_FICA_UTK'
      EXPORTING
        activity           = ls_act
        fm_area            = i_cobl-fikrs
        fm_fincode_authgrp = ls_auth_grp_fond
        fm_fmfctr_authgrp  = ls_auth_grp_fistl
        fm_fipex           = lv_fipex
        fm_measure_authgrp = ls_auth_grp_hhp
*       FM_FAREA_AUTHGRP   =
      IMPORTING
        ex_subrc           = l_subrc.

    CASE l_subrc.
      WHEN 0.
      WHEN 4.
        MESSAGE ID '/THKR/RUB_MESSG' TYPE 'E' NUMBER '23'.
      WHEN 6.
        MESSAGE ID '/THKR/RUB_MESSG' TYPE 'E' NUMBER '22'.
      WHEN OTHERS.
        MESSAGE ID '/THKR/RUB_MESSG' TYPE 'E' NUMBER '23'.
    ENDCASE.


  WHEN OTHERS.

    CALL FUNCTION 'Z_CHECK_FICA_TRG'
      EXPORTING
        activity           = ls_act
        fm_area            = i_cobl-fikrs
        fm_fincode_authgrp = ls_auth_grp_fond
        fm_fmfctr_authgrp  = ls_auth_grp_fistl
        fm_fipex_authgrp   = ls_auth_grp_fipos
        fm_measure_authgrp = ls_auth_grp_hhp
*       FM_FAREA_AUTHGRP   =
      IMPORTING
        ex_subrc           = l_subrc.

    CASE l_subrc.
      WHEN 4.
        MESSAGE ID '/THKR/RUB_MESSG' TYPE 'E' NUMBER '21'.
      WHEN 6.
        MESSAGE ID '/THKR/RUB_MESSG' TYPE 'E' NUMBER '22'.
      WHEN OTHERS.
    ENDCASE.

ENDCASE.





IF i_cobl-lifnr IS NOT INITIAL.

  DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
                           iv_partner = i_cobl-lifnr
                           iv_type = 'K'  ).
  IF no_auth_l EQ abap_true.

    MESSAGE e010(/thkr/bp) WITH i_cobl-lifnr.

  ENDIF.

ELSEIF i_cobl-kunnr IS NOT INITIAL.

  no_auth_l = /thkr/cl_auth_check=>check_bupa_auth(
                               iv_partner = i_cobl-kunnr
                               iv_type = 'D'  ).
  IF no_auth_l EQ abap_true.

    MESSAGE e010(/thkr/bp) WITH i_cobl-kunnr.

  ENDIF.

ENDIF.
