*&---------------------------------------------------------------------*
*& Report /THKR/AIF_SELSCR_0027_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/AIF_SELSCR_0001_002.

DATA: lv_kassz  TYPE /THKR/BIC_KASSZ.
DATA: lv_bukrs  TYPE bukrs.
DATA: lv_gjahr  TYPE gjahr.
DATA: lv_lotkz  TYPE lotkz.
Data: lv_belnr  TYPE belnr_d.

SELECTION-SCREEN BEGIN OF SCREEN  0001 AS SUBSCREEN.
SELECT-OPTIONS: s_bukrs for lv_bukrs.
SELECT-OPTIONS: s_gjahr for lv_gjahr.
SELECT-OPTIONS: s_lotkz for lv_lotkz.
SELECT-OPTIONS: s_belnr for lv_belnr.
SELECT-OPTIONS: s_kassz for lv_kassz.
SELECTION-SCREEN END OF SCREEN 0001.

AT SELECTION-SCREEN OUTPUT.

  /aif/cl_global_tools=>get_value_from_mem( ).
