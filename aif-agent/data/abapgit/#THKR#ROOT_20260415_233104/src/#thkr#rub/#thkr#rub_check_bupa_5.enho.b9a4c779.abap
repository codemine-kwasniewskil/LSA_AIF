"Name: \PR:SAPLFI_APAR_SEPA_MANDATES\FO:AUTHORITY_CHECK_MANDATE_KUNNR\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/RUB_CHECK_BUPA_5.

CLEAR e_power.

DATA(lv_no_auth) = /thkr/cl_auth_check=>check_bupa_auth( iv_partner = i_kunnr
                                                      ).
IF lv_no_auth IS NOT INITIAL.
  MESSAGE e010(/thkr/bp) WITH i_kunnr.

  RETURN.

ENDIF.

ENDENHANCEMENT.
