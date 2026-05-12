"Name: \PR:SAPLF0KA\FO:RESERVATION_READ\SE:END\EI
ENHANCEMENT 0 /THKR/PSM_PSOFN_SET.
* Aktenzeichen von Mittelbindung in Anordnung übernehmen
  TYPES:

    BEGIN OF lty_kblk,
      ktext TYPE kblk-ktext,
      blart TYPE kblk-blart,
    END OF lty_kblk.

  DATA: ls_psofn TYPE lty_kblk.
*
  IF ( NOT l_cobl-kblnr IS INITIAL
       AND c_pso02-psofn IS INITIAL ).   "20220408 _2000001905
* --- Select
    SELECT SINGLE ktext, blart
      FROM kblk
      INTO @ls_psofn
      WHERE belnr = @l_cobl-kblnr.
* --- Return
    IF ls_psofn-blart = 'AN'.
      c_pso02-psofn = ls_psofn-ktext.
    ENDIF.
*
  ENDIF.
ENDENHANCEMENT.
