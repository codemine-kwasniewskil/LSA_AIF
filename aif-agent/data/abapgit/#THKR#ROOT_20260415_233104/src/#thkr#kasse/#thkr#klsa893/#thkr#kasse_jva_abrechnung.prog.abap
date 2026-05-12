*&---------------------------------------------------------------------*
*& Report /THKR/KASSE_GESAMT_HL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/kasse_jva_abrechnung.

* Selektionsbild
SELECTION-SCREEN BEGIN OF BLOCK d1 WITH FRAME TITLE TEXT-001.
PARAMETERS:  p_fikrs TYPE fikrs DEFAULT '1000' OBLIGATORY
            ,p_cap   TYPE /thkr/psm_fipos_kapitel DEFAULT '4231' "4231
            ,p_titel TYPE /thkr/psm_fipos_titel DEFAULT '11'  "11
            ,p_hhj   TYPE gjahr DEFAULT sy-datum(4) OBLIGATORY
            .
SELECTION-SCREEN end OF BLOCK d1.
AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name CS 'P_FIKRS'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

START-OF-SELECTION.

** Fill and show ALV
  DATA(alv) = NEW /thkr/cl_b_jvaabrech_alv_ctr( gjahr = p_hhj kapitel = p_cap titel = p_titel ).
  alv->display_data( ).
