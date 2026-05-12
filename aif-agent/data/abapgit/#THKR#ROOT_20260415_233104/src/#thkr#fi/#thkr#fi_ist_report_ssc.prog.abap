*&---------------------------------------------------------------------*
*& Include          /THKR/FI_IST_REPORT_SSC
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      SELECTION SCREEN
*&---------------------------------------------------------------------*
  " CSV-File option
  SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-f01.
    PARAMETERS: p_save  TYPE flag AS CHECKBOX,
                p_local TYPE dxfields-location RADIOBUTTON GROUP file DEFAULT 'X' USER-COMMAND fls,
                p_appse TYPE dxfields-location RADIOBUTTON GROUP file,
                p_path  TYPE dxfields-longpath LOWER CASE.
  SELECTION-SCREEN END OF BLOCK bl1.

  " Additional options
  SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE TEXT-f02.
    PARAMETERS: p_pers   RADIOBUTTON GROUP mode DEFAULT 'X' USER-COMMAND tms,
                p_havw   RADIOBUTTON GROUP mode,
                p_vein   RADIOBUTTON GROUP mode,
                p_havwng RADIOBUTTON GROUP mode.
  SELECTION-SCREEN END OF BLOCK bl2.

  " Selection criterias
  SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE TEXT-f03.
    SELECT-OPTIONS: so_fonds FOR fmifiit-fonds MODIF ID nve,
                    so_fipex FOR fmifiit-fipex MODIF ID fpx.
    PARAMETERS: p_kapitl TYPE /thkr/fipos_kapitel MODIF ID kpt,
                p_titel  TYPE /thkr/fipos_titel   MODIF ID kpt.
    PARAMETERS: p_gjahr TYPE gjahr DEFAULT sy-datum(4),
                p_monat TYPE monat MODIF ID prs,
                p_anzah TYPE char1 AS CHECKBOX MODIF ID hng.
  SELECTION-SCREEN END OF BLOCK bl3.

*&---------------------------------------------------------------------*
*&      AT SELECTION-SCREEN OUTPUT
*&---------------------------------------------------------------------*
  AT SELECTION-SCREEN OUTPUT.
    LOOP AT SCREEN.
      " hide fields according to selected mode
      IF screen-group1 = 'KPT'.
        IF p_pers = abap_true
           OR p_havw = abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
      ENDIF.
      IF screen-group1 = 'PRS'.
        IF p_pers = abap_true.
          screen-active = 1.
        ELSE.
          screen-active = 0.
        ENDIF.
      ENDIF.
      IF screen-group1 = 'NVE'.
        IF p_vein = abap_true.
          screen-active = 0.
        ELSE.
          screen-active = 1.
        ENDIF.
      ENDIF.
      IF screen-group1 = 'HNG'.
        IF p_havwng = abap_false.
          screen-active = 0.
        ELSE.
          screen-active = 1.
        ENDIF.
      ENDIF.
      IF screen-group1 = 'FPX'.
        IF p_havwng = abap_false AND
           p_vein   = abap_false.
          screen-active = 0.
        ELSE.
          screen-active = 1.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
