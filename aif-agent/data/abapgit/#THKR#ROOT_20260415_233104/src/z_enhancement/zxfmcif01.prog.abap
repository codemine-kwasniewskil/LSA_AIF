*----------------------------------------------------------------------*
***INCLUDE ZXFMCIF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form set_input_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_input_fields .
  CHECK g_flg_display_only = abap_true.
  LOOP AT SCREEN.
    CASE screen-name.
      WHEN 'IFMCIDY-ZZ_FKZ'.
        screen-input = 0.
      WHEN 'IFMCIDY-ZZ_TG'.
        screen-input = 0.
      WHEN 'IFMCIDY-ZZ_NON_AVK'.
        screen-input = 0.
      WHEN 'IFMCIDY-ZZ_OZ1'.
        screen-input = 0.
      WHEN 'IFMCIDY-ZZ_OZ2'.
        screen-input = 0.
      WHEN 'IFMCIDY-ZZ_OZ3'.
        screen-input = 0.
      WHEN 'IFMCIDY-ZZ_OZ4'.
        screen-input = 0.
      WHEN 'IFMCIDY-ZZ_OZ5'.
        screen-input = 0.
      WHEN 'IFMCIDY-ZZ_UZ1'.
        screen-input = 0.
      WHEN 'IFMCIDY-ZZ_APL'.
        screen-input = 0.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_text_fields
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM set_text_fields .
  IF ifmcidy-zz_fkz IS INITIAL.
    CLEAR fkz_text.
  ELSEIF ifmcidy-zz_fkz <> fkz_old.
    SELECT SINGLE fkz_bez
      FROM /thkr/c_fkz
      INTO fkz_text
      WHERE fikrs = ifmcidy-fikrs AND
            gjahr = ifmcidy-gjahr AND
            fkz   = ifmcidy-zz_fkz.
    IF sy-subrc <> 0.
      CLEAR fkz_text.
    ENDIF.
  ENDIF.
  fkz_old = ifmcidy-zz_fkz.

  IF ifmcidy-zz_tg IS INITIAL.
    CLEAR tg_text.
  ELSEIF ifmcidy-zz_tg <> tg_old.
    SELECT SINGLE titelgrp_bez
      FROM /thkr/c_titelgrp
      INTO tg_text
      WHERE fikrs = ifmcidy-fikrs     AND
            gjahr = ifmcidy-gjahr     AND
            fkber = ifmcidy-fipex(4)  AND
            titelgrp   = ifmcidy-zz_tg.
    IF sy-subrc <> 0.
      CLEAR tg_text.
    ENDIF.
  ENDIF.
  tg_old = ifmcidy-zz_tg.

  IF ifmcidy-zz_oz1 IS INITIAL.
    ifmcidy-zz_oz1 = TEXT-ioz.
    ifmcidy-zz_oz2 = TEXT-ioz.
    ifmcidy-zz_oz3 = TEXT-ioz.
    ifmcidy-zz_oz4 = TEXT-ioz.
    ifmcidy-zz_oz5 = TEXT-ioz.
    ifmcidy-zz_uz1 = TEXT-ioz.
  ENDIF.
ENDFORM.
