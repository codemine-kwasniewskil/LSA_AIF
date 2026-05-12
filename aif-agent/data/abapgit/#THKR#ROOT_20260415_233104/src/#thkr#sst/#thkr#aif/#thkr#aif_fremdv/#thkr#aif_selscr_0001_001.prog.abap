*&---------------------------------------------------------------------*
*& Report /THKR/AIF_SELSCR_0027_001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT /THKR/AIF_SELSCR_0001_001.

DATA: lv_hhj    TYPE /THKR/BIC_HHJ.
DATA: lv_gennr TYPE /THKR/BIC_GENNR.
DATA: lv_kassz  TYPE /THKR/BIC_KASSZ.
DATA: lv_urkass TYPE /THKR/BIC_URKASS.
DATA: lv_aktz   TYPE /THKR/BIC_AKTZ.

SELECTION-SCREEN BEGIN OF SCREEN  0001 AS SUBSCREEN.
SELECT-OPTIONS: s_hhj FOR lv_hhj.
SELECT-OPTIONS: s_gennr FOR lv_gennr.
SELECT-OPTIONS: s_kassz for lv_kassz.
SELECT-OPTIONS: s_urkass for lv_urkass.
SELECT-OPTIONS: s_aktz for lv_aktz.
SELECTION-SCREEN END OF SCREEN 0001.

AT SELECTION-SCREEN OUTPUT.

  /aif/cl_global_tools=>get_value_from_mem( ).
