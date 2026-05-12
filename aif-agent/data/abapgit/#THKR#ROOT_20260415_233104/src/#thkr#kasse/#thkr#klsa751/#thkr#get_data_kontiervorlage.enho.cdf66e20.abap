"Name: \TY:CL_FEB_BSPROC_ACC_ASS_STORAGE\ME:GET_DATA\SE:END\EI
ENHANCEMENT 0 /THKR/GET_DATA_KONTIERVORLAGE.
IF et_acc_assign_line IS INITIAL.
  DATA: lv_acctmp TYPE feb_acctmp.
  DATA(lr_elko) = NEW /thkr/cl_elko_appl( ).

  CHECK i_kukey IS NOT INITIAL AND i_esnum IS NOT INITIAL.
  lr_elko->get_kassenz_aus_gebkz( EXPORTING iv_kukey       = i_kukey
                                            iv_esnum       = i_esnum
                                  CHANGING  xv_acctmp      = lv_acctmp ).

*  lr_elko->set_kontiervorlage(    EXPORTING iv_kukey       = i_kukey
*                                            iv_esnum       = i_esnum
*                                            iv_acctmp      = lv_acctmp
*                                  CHANGING  xt_assign_line = et_acc_assign_line ).
ENDIF.
ENDENHANCEMENT.
