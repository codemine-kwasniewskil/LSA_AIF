"Name: \TY:CL_FEB_BSPROC_ASSISTANCE\ME:PREPARE_BSPROC_WL\SE:END\EI
ENHANCEMENT 0 Z_FI_BSPROC_WORKLIST_FILL.
LOOP AT et_bsproc_wl REFERENCE INTO ld_bsproc_wl.
  READ TABLE lt_febep REFERENCE INTO ld_febep
     WITH TABLE KEY kukey = ld_bsproc_wl->kukey
                    esnum = ld_bsproc_wl->esnum.
  IF sy-subrc = 0.
    ld_bsproc_wl->fnam1 = ld_febep->zz_status.
    ld_bsproc_wl->fnam2 = ld_febep->zz_over.
    ld_bsproc_wl->fnam3 = ld_febep->zz_avviso.
    IF ld_febep->zz_iban IS NOT INITIAL.
      ld_bsproc_wl->siban = ld_febep->zz_iban.
    ELSE.
      CONCATENATE 'X-' ld_bsproc_wl->siban INTO ld_bsproc_wl->siban.
    ENDIF.

    IF ld_febep->zz_wdvdat IS NOT INITIAL.
      ld_bsproc_wl->jpdat = ld_febep->zz_wdvdat.
*        concatenate ld_febep->ZZ_WDVDAT(4) ld_febep->ZZ_WDVDAT+4(2)
*        ld_febep->ZZ_WDVDAT+6(2) into ld_bsproc_wl->fnam2 separated by '-'.
*       write ld_febep->ZZ_WDVDAT  to  ld_bsproc_wl->fnam2  DD/MM/YYYY.
    ENDIF.
  ENDIF.
ENDLOOP.

ENDENHANCEMENT.
