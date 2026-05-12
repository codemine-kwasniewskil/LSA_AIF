FUNCTION /thkr/fi_perform_00001640_e.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     VALUE(I_RFXPO) LIKE  RFXPO STRUCTURE  RFXPO
*"     VALUE(I_KNA1) LIKE  KNA1 STRUCTURE  KNA1
*"     VALUE(I_LFA1) LIKE  LFA1 STRUCTURE  LFA1
*"     VALUE(I_SKA1) LIKE  SKA1 STRUCTURE  SKA1
*"  EXPORTING
*"     VALUE(E_SUPPRESS_STANDARD) LIKE  BOOLE-BOOLE
*"  TABLES
*"      T_LINES STRUCTURE  EPTEXT
*"----------------------------------------------------------------------
************************************************************************

  CONSTANTS: lc_x TYPE char13 VALUE 'XXXXXXXXXXXXX'.
  DATA: ls_EPTEXT TYPE eptext,
        lv_name   TYPE name1_gp,
        lv_ort    TYPE ort01_gp.

**********************************************************************
* 07.04.2025 SCC_00000205 : Berechtigungsprüfung Geschäftspartner    *
**********************************************************************

  IF sy-tcode EQ 'FBL1N' OR
     sy-tcode EQ 'FBL5N'.

    IF i_ska1 IS NOT INITIAL AND
      ( i_kna1 IS INITIAL AND
        i_lfa1 IS INITIAL ).
      RETURN.
    ENDIF.

    CLEAR: ls_EPTEXT, t_lines, e_suppress_standard, lv_name.


**********************************************************************
*                Berechtigungsprüfung Lieferant                      *
**********************************************************************

    IF i_lfa1-lifnr IS NOT INITIAL.

      lv_name = i_lfa1-name1.
      lv_ort = i_lfa1-ort01.

      DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
                              iv_partner = i_lfa1-lifnr
                              iv_type = 'K' ).
      IF no_auth_l EQ abap_true.
        lv_name = lc_x.
        lv_ort = lc_x.
      ENDIF.


      ls_EPTEXT-text = |Lieferant         { i_lfa1-lifnr }|.
      APPEND ls_eptext TO t_lines.
      ls_EPTEXT-text = |Buchungskreis     { i_rfxpo-bukrs }|.
      APPEND ls_eptext TO t_lines.
      ls_EPTEXT-text = ||.
      APPEND ls_eptext TO t_lines.
      ls_EPTEXT-text = |Name              { lv_name }|.
      APPEND ls_eptext TO t_lines.
      ls_EPTEXT-text = |Ort               { lv_ort }|.
      APPEND ls_eptext TO t_lines.
      e_suppress_standard = 'X'.

    ENDIF.


**********************************************************************
*                Berechtigungsprüfung  Debitor                       *
**********************************************************************
    IF i_kna1-kunnr IS NOT INITIAL.

      lv_name = i_kna1-name1.
      lv_ort = i_kna1-ort01.


      DATA(no_auth_d) = /thkr/cl_auth_check=>check_bupa_auth(
                           iv_partner = i_kna1-kunnr
                           iv_type = 'D' ).
      IF no_auth_d EQ abap_true.
        lv_name = lc_x.
        lv_ort = lc_x.
      ENDIF.

      IF t_lines IS NOT INITIAL.
        ls_EPTEXT-text = ||.
        APPEND ls_eptext TO t_lines.
      ENDIF.

      ls_EPTEXT-text = |Debitor           { i_kna1-kunnr }|.
      APPEND ls_eptext TO t_lines.
      ls_EPTEXT-text = |Buchungskreis     { i_rfxpo-bukrs }|.
      APPEND ls_eptext TO t_lines.
      ls_EPTEXT-text = ||.
      APPEND ls_eptext TO t_lines.
      ls_EPTEXT-text = |Name              { lv_name }|.
      APPEND ls_eptext TO t_lines.
      ls_EPTEXT-text = |Ort               { lv_ort }|.
      APPEND ls_eptext TO t_lines.
      e_suppress_standard = 'X'.
    ENDIF.

  ENDIF.


ENDFUNCTION.
