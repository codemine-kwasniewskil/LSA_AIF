"Name: \PR:SAPLFI_APAR_SEPA_MANDATES\FO:DB_READ_KNA1\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/RUB_CHECK_BUPA_5.
DATA(lv_no_auth) = /thkr/cl_auth_check=>check_bupa_auth( iv_partner = i_kunnr
                                                      ).
IF lv_no_auth IS NOT INITIAL.

  clear es_kna1.
  RETURN.

ENDIF.
ENDENHANCEMENT.
