"Name: \FU:LFA1_SINGLE_READ\SE:END\EI
ENHANCEMENT 0 /THKR/RUB_CHECK_BUPA_3.

 DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
                              iv_partner = lfa1_lifnr
                              iv_type = 'K'  ).
 IF no_auth_l EQ abap_true.

   MESSAGE e010(/thkr/bp) RAISING no_auth WITH lfa1_lifnr.

 ENDIF.

ENDENHANCEMENT.
