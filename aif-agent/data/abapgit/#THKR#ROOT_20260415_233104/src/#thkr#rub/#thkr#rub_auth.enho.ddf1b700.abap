"Name: \PR:RKAEP000\TY:SS_LCL_HANDLER_MANA\ME:LINK_CLICK\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/RUB_AUTH.
Data: lv_mode type char1 value ''.
  READ TABLE SS_GD-T_SCR_MANAGE INDEX ROW INTO Data(lo_manage).
  CASE column.
    WHEN 'SCRDELE'.
      IF lo_manage-user_spec is INITIAL.
        lv_mode = 'D'.
      ENDIF.
    WHEN 'DEFAGLOB'.
      lv_mode = 'S'.
  ENDCASE.
  IF lv_mode IS NOT INITIAL.
     /thkr/cl_auth_variants=>rep_auth_check(
        EXPORTING
          iv_variant     = lo_manage-scrname
          iv_aktvt       = lv_mode
        EXCEPTIONS
          not_authorized = 1          " Keine Berechtigung
      ).
    IF sy-subrc = 1.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      RETURN.
    ENDIF.
  ENDIF.
ENDENHANCEMENT.
