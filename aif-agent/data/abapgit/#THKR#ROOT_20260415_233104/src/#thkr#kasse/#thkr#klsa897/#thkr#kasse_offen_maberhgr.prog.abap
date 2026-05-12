*&---------------------------------------------------------------------*
*& Report /THKR/KASSE_OFFEN_MABERHGR
*&---------------------------------------------------------------------*
*& kLSA897
*&---------------------------------------------------------------------*
REPORT /THKR/KASSE_OFFEN_MABERHGR.
  DATA: lv_bukrs TYPE bukrs,
        lv_bldat TYPE bldat.
* Selektionsbild
SELECTION-SCREEN BEGIN OF BLOCK d1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_fikrs TYPE fikrs DEFAULT '1000' OBLIGATORY
              ,p_hhj   TYPE gjahr DEFAULT sy-datum(4) OBLIGATORY.
  SELECT-OPTIONS: s_bukrs FOR lv_bukrs
                 ,s_bldat FOR lv_bldat.
SELECTION-SCREEN END OF BLOCK d1.

SELECTION-SCREEN BEGIN OF BLOCK d2 WITH FRAME TITLE TEXT-001.
  PARAMETERS:  p_no_nbf AS CHECKBOX TYPE abap_bool
              ,p_no_stg AS CHECKBOX TYPE abap_bool.
SELECTION-SCREEN END OF BLOCK d2.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name CS 'P_FIKRS'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

INITIALIZATION.
*  s_epls[] = VALUE #( ( sign   = if_fsbp_const_range=>sign_include
*                        option = if_fsbp_const_range=>option_between
*                        low    = '01'         " 2026-03-09 js EPL ist char2, daher '01' statt '1'
*                        high   = '20' ) ).

START-OF-SELECTION.

* Fill and show ALV
  DATA(alv) = NEW /thkr/cl_b_maberhgr_alv_ctr( gjahr = p_hhj bukrs = s_bukrs[] no_nebenforderung = p_no_nbf no_stundung = p_no_stg bldat = s_bldat[] ).
  alv->display_data( ).
