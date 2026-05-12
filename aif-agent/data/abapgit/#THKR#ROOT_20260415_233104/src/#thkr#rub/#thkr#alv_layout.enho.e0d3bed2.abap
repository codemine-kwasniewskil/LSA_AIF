"Name: \TY:CL_ALV_CUL_LAYOUT_SAVE_AS\IN:IF_ALV_CUL_EDITOR_COMPONENT\ME:CHECK\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/ALV_LAYOUT.
  " Prüfe ob Variante exisitert
  r_layout_editor->get_layout_handler( )->get_variants( IMPORTING t_variants = DATA(lt_ui_variants) ).
  /thkr/cl_auth_variants=>alv_exists = COND #( WHEN line_exists( lt_ui_variants[ variant = me->s_screen-variant ] ) THEN abap_true ELSE abap_false ).

  " Wenn nicht unten geprüft wird, prüfe hier
  IF me->check_user_input = abap_false AND me->s_screen-user_specific = abap_false.
    /thkr/cl_auth_variants=>alv_auth_check(
      EXPORTING
        iv_variant     = me->s_screen-variant
        iv_aktvt       = SWITCH #( /thkr/cl_auth_variants=>alv_exists WHEN abap_true THEN 'C' ELSE 'N' )
        iv_default     = me->s_screen-defaultvar
      EXCEPTIONS
        not_authorized = 1          " Keine Berechtigung
    ).
    IF sy-subrc = 1.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      CLEAR /thkr/cl_auth_variants=>alv_auth.
    ELSEIF sy-subrc = 0.
      /thkr/cl_auth_variants=>alv_auth = abap_true.
    ENDIF.
  ENDIF.
ENDENHANCEMENT.
