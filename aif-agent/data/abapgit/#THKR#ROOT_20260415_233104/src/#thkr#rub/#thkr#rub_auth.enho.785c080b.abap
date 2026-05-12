"Name: \PR:RKAEP000\TY:SS_LCL_HANDLER_MANA\ME:ADDED_FUNCTION\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/RUB_AUTH.
  IF E_SALV_FUNCTION = 'DELETE'.
    DATA: del_flag TYPE flag.
    DATA(lt_sels) = SS_GD-R_ALV->GET_SELECTIONS( )->GET_SELECTED_ROWS( ).
    LOOP AT lt_sels ASSIGNING FIELD-SYMBOL(<fs_sels>).
      READ TABLE SS_GD-T_SCR_MANAGE ASSIGNING FIELD-SYMBOL(<fs_manage>) INDEX <fs_sels>.
      CHECK <fs_manage>-user_spec is INITIAL.
      /thkr/cl_auth_variants=>rep_auth_check(
      EXPORTING
        iv_variant     = CONV #( <fs_manage>-scrname )
        iv_aktvt       = 'D'
      EXCEPTIONS
        not_authorized = 1            ).
      IF sy-subrc = 1.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        del_flag = abap_true.
        DELETE lt_sels.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF del_flag IS NOT INITIAL.
    SS_GD-R_ALV->GET_SELECTIONS( )->SET_SELECTED_ROWS( lt_sels ).
  ENDIF.
ENDENHANCEMENT.
