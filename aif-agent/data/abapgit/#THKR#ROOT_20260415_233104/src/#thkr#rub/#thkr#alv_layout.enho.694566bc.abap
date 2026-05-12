"Name: \TY:CL_ALV_CUL_LAYOUT_SAVE_AS\ME:CHECK_INPUT_VARIANT\SE:END\EI
ENHANCEMENT 0 /THKR/ALV_LAYOUT.
IF r_okcode = abap_true.
  /thkr/cl_auth_variants=>alv_auth_check(
    EXPORTING
      iv_variant     = me->s_screen-variant
      iv_aktvt       = 'N'
      iv_default     = me->s_screen-defaultvar
    EXCEPTIONS
      not_authorized = 1          " Keine Berechtigung
  ).
  IF sy-subrc = 1.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    r_okcode = abap_false.
  ENDIF.
ENDIF.
/thkr/cl_auth_variants=>alv_auth = r_okcode.
ENDENHANCEMENT.
