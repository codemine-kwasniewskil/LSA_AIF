*&---------------------------------------------------------------------*
*& Include          /THKR/FI_MS_STATS_CLEAR_SSC
*&---------------------------------------------------------------------*
" Selection criterias
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-f01.
  PARAMETERS: p_gjahr TYPE gjahr DEFAULT sy-datum(4) OBLIGATORY .
  SELECT-OPTIONS: so_belnr FOR kblk-belnr.
SELECTION-SCREEN END OF BLOCK bl1.
SELECTION-SCREEN BEGIN OF BLOCK b21 WITH FRAME TITLE TEXT-f02.
  PARAMETERS: p_test TYPE xflag AS CHECKBOX DEFAULT abap_true.
SELECTION-SCREEN END OF BLOCK b21.
