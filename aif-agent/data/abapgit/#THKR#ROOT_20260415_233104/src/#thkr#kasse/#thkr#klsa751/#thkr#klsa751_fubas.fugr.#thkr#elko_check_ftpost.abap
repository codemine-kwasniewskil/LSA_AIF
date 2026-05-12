FUNCTION /THKR/ELKO_CHECK_FTPOST.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_AUGLV)
*"     REFERENCE(I_FEBEP) LIKE  FEBEP STRUCTURE  FEBEP
*"     REFERENCE(I_FEBKO) LIKE  FEBKO STRUCTURE  FEBKO
*"     REFERENCE(I_AREA) TYPE  T033F-EIGR2
*"  EXPORTING
*"     REFERENCE(E_RETURN) TYPE  SY-SUBRC
*"  TABLES
*"      T_FEBCL STRUCTURE  FEBCL
*"      T_FEBRE STRUCTURE  FEBRE
*"      T_FTCLEAR STRUCTURE  FTCLEAR
*"      T_FTPOST STRUCTURE  FTPOST
*"      T_FTTAX STRUCTURE  FTTAX
*"----------------------------------------------------------------------
*--- Datendefintionen für Zusatzkontierungen
  DATA: lv_count TYPE ftpost-count.               " Buchungszeile

  DATA: lv_ftpost    TYPE ftpost,
        lv_tabix     TYPE sy-tabix,
        lv_kblnr     TYPE kblnr,
        lv_kblpos    TYPE kblpos,
        lv_mwskz     TYPE mwskz.

  TYPES:
        ty_fnam  TYPE bdc_fnam.

  TYPES:
    BEGIN OF k_fields,                                 "Felder aus Tab. KBLK
      belnr    TYPE belnr_d,
      blart    TYPE blart,
      xblnr    TYPE xblnr,                                "Referenz
*      znsi_group type grpid_bkpf,                      "Feld für Vorverfahren
*      zz_maber TYPE maber ,                            "Mahnbereich
    END OF k_fields.

  DATA: lt_fnam    TYPE TABLE OF ty_fnam,
        ls_kfields TYPE k_fields,
        lt_kfields TYPE STANDARD TABLE OF k_fields,
        lv_lines   TYPE i,
        lv_index   TYPE sy-index.

  CONSTANTS:
    co_fnam1 TYPE ty_fnam VALUE 'BSEG-KBLNR',
    co_fnam2 TYPE ty_fnam VALUE 'BSEG-KBLPOS',
    co_fnam3 TYPE ty_fnam VALUE 'BSEG-MWSKZ'.

  lt_fnam = VALUE #( ( co_fnam1 ) ( co_fnam2 ) ( co_fnam3 ) ).


*--- Sonderbehandlung für OWI notwendig
**Todo
  DATA(lv_xblnr) = i_febep-xblnr.
****  IF lv_xblnr(4) = '1505'.
****    CONCATENATE i_febep-xblnr+0(6) '9999999999' INTO lv_xblnr.
****  ELSE.
****    IF lv_xblnr(3) = '505' .
****      CONCATENATE i_febep-xblnr+0(5) '9999999' INTO lv_xblnr.
****    ENDIF.
****  ENDIF.
  SELECT belnr, blart, xblnr FROM kblk
                WHERE xblnr = @lv_xblnr
                  AND blart = 'AN'
                  AND fexec IS INITIAL          " Meldung 2000000885
  INTO TABLE @lt_kfields.
  DESCRIBE TABLE lt_kfields LINES lv_lines.
  CHECK lv_lines = 1.
  READ TABLE lt_kfields INTO ls_kfields INDEX 1.        "#EC CI_NOORDER

  CALL FUNCTION 'Z_FI_ELKO_READ_MWSKZ'
    EXPORTING
      i_kblnr   = ls_kfields-belnr
      i_blpos   = '001'
    IMPORTING
      e_mwskz   = lv_mwskz
    EXCEPTIONS
      not_found = 1
      OTHERS    = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here

  ELSE.
    lv_tabix = 1.

    lv_ftpost-stype = 'K'.
    lv_ftpost-count = '001'.
    lv_ftpost-fnam = 'BKPF-XMWST'.     " Mehrwertsteuer rechnen
    lv_ftpost-fval = 'X'.
    INSERT lv_ftpost INTO t_ftpost INDEX lv_tabix.
  ENDIF.

*--- Anhängeen am Ende
  lv_count        = '002'.
  lv_ftpost-stype = 'P'.
  lv_ftpost-count = lv_count.

  lv_kblnr  = i_febep-fval1.
  lv_kblpos = '001'.

  LOOP AT lt_fnam ASSIGNING FIELD-SYMBOL(<fname>).
    lv_index = sy-tabix.
    READ TABLE t_ftpost ASSIGNING FIELD-SYMBOL(<po>) WITH KEY stype = 'P' count = lv_count "#EC CI_STDSEQ
                                                fnam  = <fname>.
    IF sy-subrc <> 0.
      lv_ftpost-fnam = <fname>.
      CASE lv_index.
        WHEN 1. lv_ftpost-fval = lv_kblnr.
        WHEN 2. lv_ftpost-fval = lv_kblpos.
        WHEN 3. lv_ftpost-fval = lv_mwskz.
        WHEN 4. "lv_ftpost-fval = ls_kfields-zz_maber.
      ENDCASE.
      IF lv_ftpost-fval IS NOT INITIAL.
        APPEND lv_ftpost TO t_ftpost.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFUNCTION.
