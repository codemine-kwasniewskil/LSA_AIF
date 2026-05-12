"Name: \PR:SAPLMR1M\FO:PROT_ICON_SET\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/RUB_CHECK_FICA_TRG.
*Berechtigungsprüfung auf Z_FICA_TRG zu ergänzen

  "Daten beschaffen
  DATA: lv_fikrs TYPE fikrs,
        lv_subrc TYPE n,
        lv_fipex TYPE fm_fipex.

  READ TABLE ydrseg
    INDEX 1
    INTO DATA(ls_ydrseg).

  CALL FUNCTION 'FMFK_GET_FIKRS_FROM_BUKRS'
    EXPORTING
      i_bukrs            = ls_ydrseg-bukrs
    IMPORTING
      e_fikrs            = lv_fikrs
    EXCEPTIONS
      no_fikrs_for_bukrs = 1
      OTHERS             = 2.

  SELECT SINGLE augrp
    FROM fm01
    WHERE fikrs EQ @lv_fikrs
    INTO @DATA(lv_fincode_authgrp).

  SELECT SINGLE augrp
    FROM fmfctr
    WHERE fikrs   EQ @lv_fikrs
    AND   fictr   EQ @ls_ydrseg-fistl
    AND   datbis  GE @sy-datum
    INTO @DATA(lv_fmfctr_authgrp).

  SELECT SINGLE augrp
    FROM fmci
    WHERE fikrs EQ @lv_fikrs
    AND   gjahr EQ @ls_ydrseg-gjahr
    AND  fipos EQ @ls_ydrseg-fipos
    INTO @DATA(lv_fipex_authgrp).

  SELECT SINGLE authgrp
    FROM fmmeasure
    WHERE fmarea  EQ @lv_fikrs
    AND   measure EQ @ls_ydrseg-measure
    INTO @DATA(lv_measure_authgrp).

  SELECT SINGLE authgrp
    FROM tfkb
    WHERE fkber EQ @ls_ydrseg-fkber
    INTO @DATA(lv_farea_authgrp).

  DATA(lv_object_fica) = /thkr/cl_auth_check=>get_fica_object( ).
  CASE lv_object_fica.
    WHEN /THKR/CL_AUTH_CHECK=>GC_FICA_UTK.

      CLEAR lv_fipex.

      SELECT SINGLE fipex FROM fmfxpo
              INTO lv_fipex
              WHERE fipos = ls_ydrseg-fipos.
      IF lv_fipex IS INITIAL.
        lv_fipex = ls_ydrseg-fipos.
      ENDIF.
      CALL FUNCTION '/THKR/CHECK_FICA_UTK'
        EXPORTING
          activity           = '03'
          fm_area            = lv_fikrs
          fm_fincode_authgrp = lv_fincode_authgrp
          fm_fmfctr_authgrp  = lv_fmfctr_authgrp
          fm_fipex           = lv_fipex
          fm_measure_authgrp = lv_measure_authgrp
          fm_farea_authgrp   = lv_farea_authgrp
          iv_user            = sy-uname
        IMPORTING
          ex_subrc           = lv_subrc.

      IF lv_subrc NE 0.

        MESSAGE 'Keine Berechtigung zur Anzeige vorhanden'
          TYPE 'S'
          DISPLAY LIKE 'E'.

        LEAVE TO TRANSACTION sy-tcode.
      ENDIF.

    WHEN OTHERS.

      CALL FUNCTION 'Z_CHECK_FICA_TRG'
        EXPORTING
          activity           = '03'
          fm_area            = lv_fikrs
          fm_fincode_authgrp = lv_fincode_authgrp
          fm_fmfctr_authgrp  = lv_fmfctr_authgrp
          fm_fipex_authgrp   = lv_fipex_authgrp
          fm_measure_authgrp = lv_measure_authgrp
          fm_farea_authgrp   = lv_farea_authgrp
          iv_user            = sy-uname
        IMPORTING
          ex_subrc           = lv_subrc.

      IF lv_subrc NE 0.

        MESSAGE 'Keine Berechtigung zur Anzeige vorhanden'
          TYPE 'S'
          DISPLAY LIKE 'E'.

        LEAVE TO TRANSACTION sy-tcode.
      ENDIF.



  ENDCASE.

  IF ls_ydrseg-lifnr IS NOT INITIAL.

    DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
                              iv_partner = ls_ydrseg-lifnr
                              iv_type = 'K'  ).
    IF no_auth_l EQ abap_true.

      MESSAGE s010(/thkr/bp) WITH ls_ydrseg-lifnr DISPLAY LIKE 'E'.
      LEAVE TO TRANSACTION sy-tcode.

    ENDIF.

  ENDIF.

ENDENHANCEMENT.
