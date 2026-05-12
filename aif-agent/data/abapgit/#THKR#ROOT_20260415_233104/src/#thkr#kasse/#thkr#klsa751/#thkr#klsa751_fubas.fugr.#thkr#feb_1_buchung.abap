FUNCTION /thkr/feb_1_buchung.
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
  DATA: ls_ftpost  LIKE ftpost,
        ls_ftclear LIKE ftclear,
        lv_sum     TYPE wrbtr,
        lv_diff    TYPE wrbtr,
        lv_type    TYPE c,
        lv_dmbtr   TYPE dmbtr,
        lv_konto   TYPE t030h-hkont,
        lv_lsrea   TYPE t030h-lsrea,
        lv_lhrea   TYPE t030h-lhrea,
        lv_valut   TYPE ftpost-fval,
        lv_zuonr   TYPE ftpost-fval,
        lv_sgtxt   TYPE ftpost-fval,
        lv_tabix   TYPE sy-tabix,
        lv_bukrs   TYPE t001-bukrs,
        lv_hkont   TYPE ska1-saknr,
        lv_budat   TYPE bkpf-budat.

  READ TABLE t_ftpost INTO ls_ftpost WITH KEY stype = 'K' "#EC CI_STDSEQ
                                              count = '001'
                                              fnam  = 'BKPF-BUKRS'.
  IF sy-subrc = 0.
    lv_bukrs = ls_ftpost-fval.
    lv_tabix = sy-tabix.
  ENDIF.

  lv_sum = 0.
  LOOP AT t_ftclear INTO ls_ftclear WHERE selfd = 'BELNR'. "#EC CI_STDSEQ
    DATA: lv_gjahr TYPE gjahr,
          lv_curry TYPE gjahr,    " aktuelles Geschäftsjahr
          lv_prevy TYPE gjahr.    " vorhergehendes Geschäftsjahr
    lv_gjahr = ls_ftclear-selvon+10.
    IF NOT lv_gjahr IS INITIAL.
      SELECT SINGLE dmbtr, budat INTO (@lv_dmbtr, @lv_budat)
                                        FROM bsis_view WHERE bukrs = @ls_ftclear-agbuk "#EC WARNOK
                                         AND belnr = @ls_ftclear-selvon
                                         AND gjahr = @ls_ftclear-selvon+10.
    ELSE.
      CALL FUNCTION 'GET_CURRENT_YEAR'
        EXPORTING
          bukrs = ls_ftclear-agbuk
          date  = sy-datum
        IMPORTING
*         CURRM =
          curry = lv_curry
*         PREVM =
          prevy = lv_prevy.
      SELECT SINGLE dmbtr, budat INTO (@lv_dmbtr, @lv_budat)
                                        FROM bsis_view WHERE bukrs = @ls_ftclear-agbuk "#EC WARNOK
                                         AND belnr = @ls_ftclear-selvon
                                         AND gjahr = @lv_curry. " aktuelles Geschäftsjahr
      IF sy-subrc <> 0.
        SELECT SINGLE dmbtr,budat INTO (@lv_dmbtr, @lv_budat)
                                          FROM bsis_view WHERE bukrs = @ls_ftclear-agbuk "#EC WARNOK
                                           AND belnr = @ls_ftclear-selvon
                                           AND gjahr = @lv_prevy. " vorhergehendes Geschäftsjahr
      ENDIF.
    ENDIF.
    lv_sum = lv_sum + lv_dmbtr.
  ENDLOOP.
  lv_konto = ls_ftclear-agkon.

  SELECT SINGLE lsrea, lhrea INTO (@lv_lsrea, @lv_lhrea)
                             FROM t030h WHERE ktopl = 'VKP'
                                          AND hkont = @lv_konto
                                          AND waers = @space
                                          AND curtp = @space.
*--- Fehlerfall (kein gültiges Konto) überprüfen und Verarbeitung damit beenden
  IF sy-subrc = 0.
    IF lv_sum < i_febep-kwbtr.
      lv_diff = lv_sum - i_febep-kwbtr.
      lv_type = 'A'.                          " Aufwand
    ELSE.
      lv_diff = i_febep-kwbtr - lv_sum.
      lv_type = 'E'.                          " Ertrag
    ENDIF.

    READ TABLE t_ftpost INTO ls_ftpost WITH KEY stype = 'P' "#EC CI_STDSEQ
                                                count = '001'
                                                fnam  = 'BSEG-VALUT'.
    IF sy-subrc = 0.
      lv_valut = ls_ftpost-fval.
    ENDIF.

    READ TABLE t_ftpost INTO ls_ftpost WITH KEY stype = 'P' "#EC CI_STDSEQ
                                                count = '001'
                                                fnam  = 'BSEG-ZUONR'.
    IF sy-subrc = 0.
      lv_zuonr = ls_ftpost-fval.
    ENDIF.

    READ TABLE t_ftpost INTO ls_ftpost WITH KEY stype = 'P' "#EC CI_STDSEQ
                                                count = '001'
                                                fnam  = 'BSEG-SGTXT'.
    IF sy-subrc = 0.
      lv_sgtxt = ls_ftpost-fval.
    ENDIF.

    CLEAR ls_ftpost.
    IF lv_diff <> 0.                        " Kursdifferenz vorhanden ?
      ls_ftpost-stype = 'P'.
      ls_ftpost-count = '002'.
      ls_ftpost-fnam = 'BSEG-BSCHL'.
      IF lv_type = 'A'.                     " Aufwand / Ertrag
        ls_ftpost-fval = '40'.
      ELSE.
        ls_ftpost-fval = '50'.
      ENDIF.
      APPEND ls_ftpost TO t_ftpost.

      ls_ftpost-fnam = 'BSEG-HKONT'.
      IF lv_type = 'A'.                     " Aufwand / Ertrag
        ls_ftpost-fval = lv_lsrea.
      ELSE.
        ls_ftpost-fval = lv_lhrea.
      ENDIF.
      APPEND ls_ftpost TO t_ftpost.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_ftpost-fval
        IMPORTING
          output = lv_hkont.

      ls_ftpost-fnam = 'BSEG-WRBTR'.
      IF lv_diff < 0.
        lv_diff = lv_diff * -1.
      ENDIF.
      WRITE lv_diff TO ls_ftpost-fval LEFT-JUSTIFIED.
      APPEND ls_ftpost TO t_ftpost.

      ls_ftpost-fnam = 'BSEG-VALUT'.
      ls_ftpost-fval = lv_valut.
      APPEND ls_ftpost TO t_ftpost.

      ls_ftpost-fnam = 'BSEG-ZUONR'.
      ls_ftpost-fval = lv_zuonr.
      APPEND ls_ftpost TO t_ftpost.

      ls_ftpost-fnam = 'BSEG-SGTXT'.
      ls_ftpost-fval = lv_sgtxt.
      APPEND ls_ftpost TO t_ftpost.

      DATA(lr_elko) = NEW /thkr/cl_elko_appl( ).

      lr_elko->set_ftpost_from_kontier_k( EXPORTING iv_bukrs  = lv_bukrs
                                                    iv_hkont  = lv_hkont
                                                    iv_budat  = lv_budat
                                                    IV_tabix  = lv_tabix
                                          CHANGING  xt_ftpost = t_ftpost[] ).

    ENDIF.
  ENDIF.                                          " Kein gültiges Konto

ENDFUNCTION.
