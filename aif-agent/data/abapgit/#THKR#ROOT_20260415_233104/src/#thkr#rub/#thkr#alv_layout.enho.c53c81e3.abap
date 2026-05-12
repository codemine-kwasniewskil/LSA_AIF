"Name: \TY:CL_ALV_CUL_LAYOUT_SAVE_AS\ME:SHOW_SAVE_AS_POPUP\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/ALV_LAYOUT.
  IF /thkr/cl_auth_variants=>alv_auth = abap_false AND me->s_screen-user_specific = abap_false.
    c_okcode = abap_false.
    RETURN.
  ENDIF.
ENDENHANCEMENT.
