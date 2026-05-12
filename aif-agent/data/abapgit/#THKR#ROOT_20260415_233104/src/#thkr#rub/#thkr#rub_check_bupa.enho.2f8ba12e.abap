"Name: \FU:VENDOR_READ\SE:END\EI
ENHANCEMENT 0 /THKR/RUB_CHECK_BUPA.

 DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
                              iv_partner = i_lifnr
                              iv_type = 'K'  ).
 IF no_auth_l EQ abap_true.

   MESSAGE e010(/thkr/bp) WITH i_lifnr.

 ENDIF.

ENDENHANCEMENT.
