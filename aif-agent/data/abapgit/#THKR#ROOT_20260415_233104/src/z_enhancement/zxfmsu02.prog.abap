*&---------------------------------------------------------------------*
*& Include          ZXFMSU02
*&---------------------------------------------------------------------*
*"       TABLES
*"              T_FMFCTR STRUCTURE  FMFCTR
*"              T_FMFCTRT STRUCTURE  FMFCTRT
*"              T_FMHISV STRUCTURE  FMHISV

IF t_fmhisv[] IS NOT INITIAL.
  EXPORT t_fmhisv[] TO MEMORY ID 'ZFMHIST'.
ENDIF.
