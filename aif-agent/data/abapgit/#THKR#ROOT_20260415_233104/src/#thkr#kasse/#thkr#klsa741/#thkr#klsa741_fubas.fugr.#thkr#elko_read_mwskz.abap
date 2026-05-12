FUNCTION /THKR/ELKO_READ_MWSKZ.
*"--------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_KBLNR) TYPE  KBLNR
*"     REFERENCE(I_BLPOS) TYPE  KBLPOS
*"  EXPORTING
*"     REFERENCE(E_MWSKZ) TYPE  MWSKZ
*"  EXCEPTIONS
*"      NOT_FOUND
*"--------------------------------------------------------------------

 SELECT SINGLE zz_mwskz FROM kblp INTO e_mwskz
                        WHERE belnr = i_kblnr
                          AND blpos = i_blpos.

  IF sy-subrc <> 0.
    RAISE not_found.
  ENDIF.

ENDFUNCTION.
