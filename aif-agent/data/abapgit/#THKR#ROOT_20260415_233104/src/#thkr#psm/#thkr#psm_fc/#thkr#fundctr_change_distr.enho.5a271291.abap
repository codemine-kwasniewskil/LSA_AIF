"Name: \PR:SAPMFMFS\FO:SINGLE_COMMAND_SAVE\SE:BEGIN\EI
ENHANCEMENT 0 /THKR/FUNDCTR_CHANGE_DISTR.
TRY.

    ASSIGN u_f_fmmd_fistl_all-tab_fmfctr[ 1 ] TO FIELD-SYMBOL(<fmctr>).
    " Only run if nothing has been set yet!
    IF <fmctr> IS ASSIGNED AND
       <fmctr>-zz_funddistr_lvl IS INITIAL.
      " use the last line of the table (23,24....)
      DATA(histv) = u_f_fmmd_fistl_all-tab_fmhisv[ lines( u_f_fmmd_fistl_all-tab_fmhisv ) ].
      " case 1: levels root (MFH) or TV:
      IF histv-fistl = histv-hiroot_st
      OR ( substring( val = histv-fistl off = strlen( histv-fistl ) - 2 len = 2 ) = '02'
           AND histv-parent_st IS NOT INITIAL ).
        <fmctr>-zz_funddistr_lvl = /thkr/cl_functr_fund_distr_lvl=>get_funddistr_level( fistl = histv-fistl fikrs = histv-fikrs hivar = histv-hivarnt ).
        " case 3: levels between root (MFH) and lowest (TV)
      ELSE.
        <fmctr>-zz_funddistr_lvl = /thkr/cl_functr_fund_distr_lvl=>get_funddistr_level( fistl = histv-parent_st fikrs = histv-fikrs hivar = histv-hivarnt adjust_level = 1 ).
      ENDIF.
    ENDIF.

  CATCH cx_sy_itab_line_not_found cx_sy_range_out_of_bounds.
    "" Nothing found and nothing to set:
ENDTRY.
ENDENHANCEMENT.
