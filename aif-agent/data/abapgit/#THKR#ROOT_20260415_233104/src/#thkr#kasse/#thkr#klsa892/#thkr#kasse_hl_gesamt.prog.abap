*&---------------------------------------------------------------------*
*& Report /THKR/KASSE_GESAMT_HL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/kasse_hl_gesamt.

DATA: lv_titel   TYPE /thkr/psm_fipos_titel
      ,lv_kapitel      TYPE /thkr/psm_fipos_kapitel.
SELECTION-SCREEN BEGIN OF BLOCK d1 WITH FRAME TITLE TEXT-001.
* Selektionsbild
  PARAMETERS:   p_fikrs TYPE fikrs DEFAULT '1000' OBLIGATORY
               ,p_fcode TYPE bp_geber DEFAULT '95'.
  SELECT-OPTIONS:  s_cap   FOR lv_kapitel  DEFAULT '4000'
                  ,s_titel FOR lv_titel.

  SELECTION-SCREEN COMMENT /1(79) TEXT-002.
SELECTION-SCREEN END OF BLOCK d1.
SELECTION-SCREEN BEGIN OF BLOCK d2 WITH FRAME TITLE TEXT-001.
    PARAMETERS    p_neg AS CHECKBOX TYPE abap_bool.
SELECTION-SCREEN END OF BLOCK d2.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name CS 'P_FCODE'
    OR screen-name CS 'P_FIKRS'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.

** Fill and show ALV
  TRY.
      DATA(alv) = NEW /thkr/cl_b_hlgesamt_alv_ctr( fonds = p_fcode s_kapitel = s_cap[] s_titel = s_titel[] komplement = p_neg ).
      alv->display_data( ).
    CATCH cx_salv_error INTO DATA(err).
      MESSAGE err->get_text( ) TYPE 'E'.
  ENDTRY.
