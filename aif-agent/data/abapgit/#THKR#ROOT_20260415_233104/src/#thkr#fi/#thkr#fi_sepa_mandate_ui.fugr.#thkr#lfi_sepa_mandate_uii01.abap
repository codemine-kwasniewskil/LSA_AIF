*----------------------------------------------------------------------*
***INCLUDE /THKR/LFI_SEPA_MANDATE_UII01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GET_CURSOR_SUB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE get_cursor_sub INPUT.
  CASE sy-dynnr.
    WHEN 206.
      gs_mandate-/thkr/gsber = sepa_mandate-/thkr/gsber.
      gs_mandate-/thkr/xblnr = sepa_mandate-/thkr/xblnr.
      " get cursor / translate to generic fieldname
      CLEAR: crs_field.
      GET CURSOR FIELD crs_field.
      CASE crs_field.
        WHEN 'SEPA_MANDATE-/THKR/GSBER'. crs_field = 'RFSEPA_WA-/THKR/GSBER'.
        WHEN 'SEPA_MANDATE-/THKR/XBLNR'. crs_field = 'RFSEPA_WA-/THKR/XBLNR'.
      ENDCASE.
      IF g_aktyp EQ '03'.
        IF crs_field EQ space.
          EXIT.
        ELSE.
          " send cursor position back to function group UI
          CALL FUNCTION 'SEPA_MANDATE_APPEND_SET_PAI'
            EXPORTING
              i_fieldname = crs_field.
          EXIT.
        ENDIF.
      ENDIF.

      " set FICA append
      gs_mandate-/thkr/gsber = sepa_mandate-/thkr/gsber.
      gs_mandate-/thkr/xblnr = sepa_mandate-/thkr/xblnr.
      " send APPEND data to function group UI
      CALL FUNCTION 'SEPA_MANDATE_APPEND_SET_PAI'
        EXPORTING
          i_mandate   = gs_mandate
          i_fieldname = crs_field.
  ENDCASE.
ENDMODULE.
