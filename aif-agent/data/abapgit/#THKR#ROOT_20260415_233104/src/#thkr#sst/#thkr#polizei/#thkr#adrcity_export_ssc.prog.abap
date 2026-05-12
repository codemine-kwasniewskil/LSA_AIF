*&---------------------------------------------------------------------*
*& Include          /THKR/ADRCITY_EXPORT_SSC
*&---------------------------------------------------------------------*
  " CSV-File option
  SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-f01.
    PARAMETERS: p_user TYPE flag RADIOBUTTON GROUP aif DEFAULT 'X' USER-COMMAND aif,
                p_aif  TYPE flag RADIOBUTTON GROUP aif.
  SELECTION-SCREEN END OF BLOCK bl1.
  SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-f02.
    PARAMETERS: p_save TYPE flag AS CHECKBOX MODIF ID lcl.
    PARAMETERS: p_local TYPE dxfields-location RADIOBUTTON GROUP file DEFAULT 'X' USER-COMMAND fls MODIF ID lcl,
                p_appse TYPE dxfields-location RADIOBUTTON GROUP file MODIF ID lcl,
                p_path  TYPE dxfields-longpath LOWER CASE MODIF ID lcl.
  SELECTION-SCREEN END OF BLOCK bl2.
