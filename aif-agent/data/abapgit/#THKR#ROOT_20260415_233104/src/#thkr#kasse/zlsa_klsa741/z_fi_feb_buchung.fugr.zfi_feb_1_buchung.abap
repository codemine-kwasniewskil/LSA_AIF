FUNCTION zfi_feb_1_buchung .
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
        lv_str     TYPE text20,
        lv_sum     TYPE wrbtr,
        lv_diff    TYPE wrbtr,
        lv_type    TYPE c,
        lv_wrbtr   TYPE wrbtr,
        lv_dmbtr   TYPE dmbtr,
        lv_waers   TYPE waers,
        lv_waers1  TYPE waers,
        lv_waers2  TYPE waers,
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
    lv_TABIX = sy-tabix.
  ENDIF.

  lv_sum = 0.
  LOOP AT t_ftclear INTO ls_ftclear WHERE selfd = 'BELNR'. "#EC CI_STDSEQ
    DATA: lv_gjahr TYPE gjahr,
          lv_curry TYPE gjahr,    " aktuelles Geschäftsjahr
          lv_prevy TYPE gjahr.    " vorhergehendes Geschäftsjahr
    lv_gjahr = ls_ftclear-selvon+10.
    IF NOT lv_gjahr IS INITIAL.
      SELECT SINGLE dmbtr, wrbtr, waers, budat INTO (@lv_dmbtr, @lv_wrbtr, @lv_waers, @lv_budat)
                                        FROM bsis WHERE bukrs = @ls_ftclear-agbuk "#EC WARNOK
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
      SELECT SINGLE dmbtr, wrbtr, waers, budat INTO (@lv_dmbtr, @lv_wrbtr, @lv_waers, @lv_budat)
                                        FROM bsis WHERE bukrs = @ls_ftclear-agbuk "#EC WARNOK
                                         AND belnr = @ls_ftclear-selvon
                                         AND gjahr = @lv_curry. " aktuelles Geschäftsjahr
      IF sy-subrc <> 0.
        SELECT SINGLE dmbtr, wrbtr, waers, budat INTO (@lv_dmbtr, @lv_wrbtr, @lv_waers, @lv_budat)
                                          FROM bsis WHERE bukrs = @ls_ftclear-agbuk "#EC WARNOK
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
      ls_FTPOST-stype = 'P'.
      ls_FTPOST-count = '002'.
      ls_FTPOST-fnam = 'BSEG-BSCHL'.
      IF lv_TYPE = 'A'.                     " Aufwand / Ertrag
        ls_FTPOST-fval = '40'.
      ELSE.
        ls_FTPOST-fval = '50'.
      ENDIF.
      APPEND ls_ftpost TO t_ftpost.

      ls_FTPOST-fnam = 'BSEG-HKONT'.
      IF lv_TYPE = 'A'.                     " Aufwand / Ertrag
        ls_FTPOST-fval = lv_lsrea.
      ELSE.
        ls_FTPOST-fval = lv_lhrea.
      ENDIF.
      APPEND ls_ftpost TO t_ftpost.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = ls_FTPOST-fval
        IMPORTING
          output = lv_hkont.

      ls_FTPOST-fnam = 'BSEG-WRBTR'.
      IF lv_diff < 0.
        lv_diff = lv_diff * -1.
      ENDIF.
      WRITE lv_diff TO ls_ftpost-fval LEFT-JUSTIFIED.
      APPEND ls_ftpost TO t_ftpost.

      ls_FTPOST-fnam = 'BSEG-VALUT'.
      ls_FTPOST-fval = lv_valut.
      APPEND ls_ftpost TO t_ftpost.

      ls_FTPOST-fnam = 'BSEG-ZUONR'.
      ls_FTPOST-fval = lv_zuonr.
      APPEND ls_ftpost TO t_ftpost.

      ls_FTPOST-fnam = 'BSEG-SGTXT'.
      ls_FTPOST-fval = lv_sgtxt.
      APPEND ls_ftpost TO t_ftpost.

      DATA: ls_kontierung TYPE zfi_kontierung_k.

      SELECT SINGLE gsber prctr fipex aufnr kostl fistl
             INTO CORRESPONDING FIELDS OF ls_kontierung
             FROM zfi_kontierung_k
             WHERE bukrs = lv_bukrs
               AND hkont = lv_hkont.

      DATA: o_desc TYPE REF TO cl_abap_structdescr.
      o_desc ?= cl_abap_structdescr=>describe_by_name( 'ZFI_KONTIERUNG_K' ).
      DATA(lt_ddic_fields) = o_desc->get_ddic_field_list( ).

      LOOP AT lt_ddic_fields INTO DATA(ls_ddic_field) WHERE fieldname <> 'MANDT' AND fieldname <> 'BUKRS' AND fieldname <> 'HKONT'. "#EC CI_STDSEQ
        ASSIGN COMPONENT ls_ddic_field-fieldname OF STRUCTURE ls_kontierung TO FIELD-SYMBOL(<v_value>).
        IF NOT <v_value> IS INITIAL.
          CONCATENATE 'COBL-' ls_ddic_field-fieldname INTO ls_ftpost-fnam.
          ls_ftpost-fval  = <v_value>.
          ls_ftpost-stype = 'P'.
          ls_ftpost-count = '002'.
          APPEND ls_ftpost TO t_ftpost.
        ENDIF.
      ENDLOOP.

      IF NOT lv_budat IS INITIAL.
        ls_FTPOST-stype = 'K'.
        ls_FTPOST-count = '001'.
        ls_FTPOST-fnam  = 'BKPF-WWERT'.
*       ls_FTPOST-FVAL  = lv_budat.
        WRITE lv_budat  TO ls_FTPOST-fval DD/MM/YYYY.
        INSERT ls_FTPOST INTO t_ftpost INDEX lv_TABIX.
      ENDIF.
    ENDIF.                                        " Kursdifferenz vorhanden ?
  ENDIF.                                          " Kein gültiges Konto

ENDFUNCTION.
