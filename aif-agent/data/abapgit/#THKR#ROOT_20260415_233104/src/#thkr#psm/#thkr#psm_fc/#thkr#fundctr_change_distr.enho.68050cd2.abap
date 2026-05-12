"Name: \PR:SAPMFMFS\FO:GRAPHIC_SAVE_PREPARE_HIERARCHY\SE:END\EI
ENHANCEMENT 0 /THKR/FUNDCTR_CHANGE_DISTR.
** Inject the change to Fund Center as well to keep the hierarchy in sync to fund distribution level!
LOOP AT c_t_fmmd_fmhisv ASSIGNING FIELD-SYMBOL(<fmhisv>).
  TRY.
      DATA(new_funddistr_lvl) = /thkr/cl_functr_fund_distr_lvl=>get_funddistr_by_hilevel( fistl = <fmhisv>-fistl hilevel = <fmhisv>-hilevel ).
      g_t_fmmd_fistl_all[ fikrs = <fmhisv>-fikrs fistl = <fmhisv>-fistl ]-tab_fmfctr[ 1 ]-zz_funddistr_lvl = new_funddistr_lvl.
      g_t_fmmd_fistl_all[ fikrs = <fmhisv>-fikrs fistl = <fmhisv>-fistl ]-flg_change = con_update.
    CATCH cx_sy_itab_line_not_found.
      "Nothing to do!
  ENDTRY.
ENDLOOP.
ENDENHANCEMENT.
