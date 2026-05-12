*&---------------------------------------------------------------------*
*& Report /THKR/KASSE_OFFEN_EPLGHR
*&---------------------------------------------------------------------*
*& kLSA894
*&---------------------------------------------------------------------*
REPORT /thkr/kasse_offen_eplghr.

DATA: epls     TYPE bp_geber,
      lv_bldat TYPE bldat.
* Selektionsbild
SELECTION-SCREEN BEGIN OF BLOCK d1 WITH FRAME TITLE TEXT-001.
  PARAMETERS: p_fikrs TYPE fikrs DEFAULT '1000' OBLIGATORY
              ,p_hhj   TYPE gjahr DEFAULT sy-datum(4) OBLIGATORY.
  SELECT-OPTIONS: s_epls  FOR epls
                 ,s_bldat FOR lv_bldat.
SELECTION-SCREEN END OF BLOCK d1.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name CS 'P_FIKRS'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

INITIALIZATION.
  s_epls[] = VALUE #( ( sign   = if_fsbp_const_range=>sign_include
                        option = if_fsbp_const_range=>option_between
                        low    = '01'         " 2026-03-09 js EPL ist char2, daher '01' statt '1'
                        high   = '20' ) ).

START-OF-SELECTION.

* Fill and show ALV
  DATA(alv) = NEW /thkr/cl_opelphgr_alv_epl_ctr( gjahr = p_hhj epl = s_epls[] bldat = s_bldat[] ).
  alv->display_data( ).
