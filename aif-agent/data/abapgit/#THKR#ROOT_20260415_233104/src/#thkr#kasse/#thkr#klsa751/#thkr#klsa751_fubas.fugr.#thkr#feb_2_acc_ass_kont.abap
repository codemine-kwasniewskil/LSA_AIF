FUNCTION /thkr/feb_2_acc_ass_kont .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_AUGLV)
*"     REFERENCE(I_FEBEP) LIKE  FEBEP STRUCTURE  FEBEP
*"     REFERENCE(I_FEBKO) LIKE  FEBKO STRUCTURE  FEBKO
*"  TABLES
*"      T_FEBCL STRUCTURE  FEBCL
*"      T_FEBRE STRUCTURE  FEBRE
*"      T_FTCLEAR STRUCTURE  FTCLEAR
*"      T_FTPOST STRUCTURE  FTPOST
*"      T_FTTAX STRUCTURE  FTTAX
*"----------------------------------------------------------------------

  DATA(lr_elko) = NEW /thkr/cl_elko_appl( ).
  DATA: lv_vwezw TYPE gho_temp_file_cont.


  CHECK i_febko-kukey IS NOT INITIAL AND i_febep-esnum IS NOT INITIAL.
  READ TABLE t_ftpost WITH KEY stype = 'P'               "#EC CI_STDSEQ
                               count = '002'
                               fnam  = 'BSEG-BSCHL'.
  IF sy-subrc NE 0.
    TRY.
        lr_elko->set_ftpost_aus_acctmp( EXPORTING iv_kukey  = i_febko-kukey
                                                  iv_esnum  = i_febep-esnum
                                        CHANGING  xt_ftpost = t_ftpost[] ).
      CATCH /thkr/cx_elko INTO DATA(err). " Fehlerkasse Init.

    ENDTRY.
  ENDIF.

  READ TABLE t_ftpost WITH KEY stype = 'P'               "#EC CI_STDSEQ
                               count = '002'
                               fnam  = 'BSEG-SGTXT'.
  IF sy-subrc NE 0.
    TRY.
        CLEAR: lv_vwezw.
        lv_vwezw = i_febep-sgtxt.
        IF lv_vwezw IS INITIAL.
          lr_elko->set_sgtxt_from_vwezw( EXPORTING is_febep = i_febep
                                         CHANGING  xv_sgtxt = lv_vwezw ).
        ENDIF.

        lr_elko->set_sgtxt_to_febep( EXPORTING iv_ftpost = abap_true
                                               iv_vwezw  = lv_vwezw
                                     CHANGING  xt_ftpost = t_ftpost[] ).
      CATCH /thkr/cx_elko INTO err. " Fehlerkasse Init.

    ENDTRY.
  ENDIF.
  TRY.
      lr_elko->set_ftpost_xblnr( EXPORTING iv_kukey  = i_febko-kukey
                                           iv_esnum  = i_febep-esnum
                                 CHANGING  xt_ftpost = t_ftpost[] ).
    CATCH /thkr/cx_elko INTO err. " Fehlerkasse Init.
  ENDTRY.


ENDFUNCTION.
