"Name: \FU:KNA1_SINGLE_READ\SE:END\EI
ENHANCEMENT 0 /THKR/RUB_CHECK_BUPA_2.

  DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
                              iv_partner = kna1_kunnr
                              iv_type = 'D'  ).
  IF no_auth_l EQ abap_true.

    MESSAGE e010(/thkr/bp) RAISING no_auth WITH kna1_kunnr.
  ENDIF.


ENDENHANCEMENT.
