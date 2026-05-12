*&---------------------------------------------------------------------*
*& Report /THKR/AIF_SELSCR_0036_002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /thkr/aif_selscr_0036_002.

DATA: lv_fkz TYPE /THKR/FKZ.

SELECTION-SCREEN BEGIN OF SCREEN  0001 AS SUBSCREEN.
  SELECT-OPTIONS: s_fkz FOR lv_fkz.
  PARAMETERS: p_gjahr TYPE gjahr.
SELECTION-SCREEN END OF SCREEN 0001.

AT SELECTION-SCREEN OUTPUT.

  /aif/cl_global_tools=>get_value_from_mem( ).
