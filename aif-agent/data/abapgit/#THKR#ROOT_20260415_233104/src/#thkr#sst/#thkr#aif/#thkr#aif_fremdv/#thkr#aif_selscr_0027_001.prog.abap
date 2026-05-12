*&---------------------------------------------------------------------*
*& Report /THKR/AIF_SELSCR_0027_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/aif_selscr_0027_001.

DATA: lv_lotkz TYPE /thkr/de_ao_id.
DATA: lv_belnr TYPE belnr_d.
DATA: lv_kass TYPE /thkr/bic_kassz.
DATA: lv_urkass TYPE /thkr/bic_urkass.

SELECTION-SCREEN BEGIN OF SCREEN  0001 AS SUBSCREEN.
  SELECT-OPTIONS: s_lotkz FOR lv_lotkz.
  SELECT-OPTIONS: s_belnr FOR lv_belnr.
  SELECT-OPTIONS: s_kass FOR lv_kass.
  SELECT-OPTIONS: s_urkass FOR lv_urkass.
  PARAMETERS: p_bpext TYPE bu_bpext.
SELECTION-SCREEN END OF SCREEN 0001.

AT SELECTION-SCREEN OUTPUT.

  /aif/cl_global_tools=>get_value_from_mem( ).
