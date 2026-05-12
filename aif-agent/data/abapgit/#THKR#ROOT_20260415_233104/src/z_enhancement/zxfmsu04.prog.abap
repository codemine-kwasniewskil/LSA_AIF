*&---------------------------------------------------------------------*
*& Include          ZXFMSU04
*&--------------------------------------------------------------------*

e_f_ifmci_fmfctr = CORRESPONDING #( ifmfctrdy ).

DATA(cache_zz_funddistr_lvl) = e_f_ifmci_fmfctr-zz_funddistr_lvl.

DATA histvs TYPE fmfunds_ctr_hivarnt_db_t.
*Export in EXIT_SAPSFMMD_008
IMPORT t_fmhisv = histvs FROM MEMORY ID 'ZFMHIST'.
FREE MEMORY ID 'ZFMHIST'.

TRY.
    " use the last line of the table (23,24....)
    DATA(histv) = histvs[ lines( histvs ) ].
    " Is the record correct?
    CHECK histv-fistl = ifmfctrdy-fictr.
    " case 1: root (MFH)
    " case 2: lowest level (TV)
    IF histv-fistl = histv-hiroot_st
    OR ( substring( val = histv-fistl off = strlen( histv-fistl ) - 2 len = 2 ) = '02'
         AND histv-parent_st IS NOT INITIAL ).
      e_f_ifmci_fmfctr-zz_funddistr_lvl = /thkr/cl_functr_fund_distr_lvl=>get_funddistr_level( fistl = histv-fistl fikrs = histv-fikrs hivar = histv-hivarnt ).
      " case 3: levels between root (MFH) and lowest (TV)
    ELSE.
      e_f_ifmci_fmfctr-zz_funddistr_lvl = /thkr/cl_functr_fund_distr_lvl=>get_funddistr_level( fistl = histv-parent_st fikrs = histv-fikrs hivar = histv-hivarnt adjust_level = 1 ).
    ENDIF.
  CATCH cx_sy_itab_line_not_found cx_sy_range_out_of_bounds.
    "" Nothing found and nothing to set:
ENDTRY.
