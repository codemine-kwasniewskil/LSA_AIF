*&---------------------------------------------------------------------*
*& Report /THKR/AIF_SELSCR_0027_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/AIF_SELSCR_0037_001.

DATA: lv_regnum(20)    TYPE c.
DATA: lv_idnum(10)       TYPE c.

SELECTION-SCREEN BEGIN OF SCREEN  0001 AS SUBSCREEN.
SELECT-OPTIONS: s_regnum FOR lv_regnum.
SELECT-OPTIONS: s_idnum FOR lv_idnum.
SELECTION-SCREEN END OF SCREEN 0001.

AT SELECTION-SCREEN OUTPUT.

  /aif/cl_global_tools=>get_value_from_mem( ).
