*&---------------------------------------------------------------------*
*& Report /THKR/AIF_SELSCR_0027_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/AIF_SELSCR_0013_002.

DATA: lv_bpext    TYPE BU_BPEXT.

SELECTION-SCREEN BEGIN OF SCREEN  0001 AS SUBSCREEN.
SELECT-OPTIONS: s_bpext FOR lv_bpext.
SELECTION-SCREEN END OF SCREEN 0001.

AT SELECTION-SCREEN OUTPUT.

  /aif/cl_global_tools=>get_value_from_mem( ).
