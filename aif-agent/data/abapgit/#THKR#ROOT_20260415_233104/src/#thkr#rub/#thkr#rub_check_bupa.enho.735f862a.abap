"Name: \FU:CUSTOMER_READ\SE:END\EI
ENHANCEMENT 0 /THKR/RUB_CHECK_BUPA.
 DATA(no_auth_l) = /thkr/cl_auth_check=>check_bupa_auth(
                              iv_partner = i_kunnr
                              iv_type = 'D'  ).
 IF no_auth_l EQ abap_true.

   MESSAGE e010(/thkr/bp) WITH i_kunnr.

 ENDIF.
ENDENHANCEMENT.
