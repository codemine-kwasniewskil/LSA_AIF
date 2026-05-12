FUNCTION /thkr/klsa841_bte_00001703.
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_LAUFD) LIKE  F150V-LAUFD OPTIONAL
*"     REFERENCE(I_LAUFI) LIKE  F150V-LAUFI OPTIONAL
*"  TABLES
*"      T_SEL_CC
*"      T_SEL_CUST
*"      T_SEL_VEN
*"      T_LOG_CUST
*"      T_LOG_VEND
*"      T_SEL_FILTER
*"----------------------------------------------------------------------
  TYPES: BEGIN OF ts_konto,
           bukrs TYPE bukrs,
           hkont TYPE hkont,
         END   OF ts_konto,
         tt_konto TYPE TABLE OF ts_konto.

  TYPES: BEGIN OF ts_fldtab,
           fldna    LIKE f150v-fldna, "Feldname
           fldl1    LIKE f150v-fldl1, "Werteleiste Teil 1 - now 254 char!  "2219910
           fldl2    LIKE f150v-fldl2, "Werteleiste Teil 2 - now 254 char!  "2219910
           ignor    LIKE f150v-ignor, "Auswahl exclusiv ?
           uppct(1) TYPE c,           "Uppercase Translate ?
         END OF ts_fldtab,
         tt_fldtab TYPE TABLE OF ts_fldtab.



  DATA: lv_grdat   TYPE datum,
        lv_ausdt   TYPE datum,
        lv_lines   TYPE i,
        lv_lin     TYPE i,
        lv_dunn_it TYPE c,
        lv_anzahl  TYPE /thkr/man_anzahl,
        lv_text    TYPE string.

  DATA: ls_mhnk    TYPE mhnk,
        ls_iacctab TYPE iacctab,
        ls_mahns   TYPE mahns.

  DATA: lt_konto   TYPE tt_konto,
        lt_bsid    TYPE trty_bsid,
        lt_fldtab  TYPE tt_fldtab,
        lt_mhnk    TYPE TABLE OF mhnk,
        lt_mhnd    TYPE TABLE OF mhnd,
        lt_fimsgl  TYPE TABLE OF fimsg,
        lt_iacctab TYPE TABLE OF iacctab.

  RANGES:
    lt_bukrs        FOR ls_mhnk-bukrs,
    lt_cust         FOR ls_mhnk-kunnr,
    lt_vend         FOR ls_mhnk-lifnr,
    lt_log_kunnr    FOR ls_mhnk-kunnr,
    lt_log_lifnr    FOR ls_mhnk-lifnr.

  CLEAR: lv_grdat,
         lv_lines,
         lv_anzahl,
         lv_lin,
         lv_dunn_it,
         ls_iacctab,
         lt_bukrs,
         lt_cust,
         lt_vend,
         lt_bsid,
         lt_log_kunnr,
         lt_log_lifnr,
         lt_fldtab,
         lt_mhnk,
         lt_mhnd,
         lt_fimsgl,
         lt_iacctab.


  CALL FUNCTION 'F150_IMPORT_PARA'
    EXPORTING
      i_laufd        = i_laufd
      i_laufi        = i_laufi
    IMPORTING
      e_ausdt        = lv_ausdt
      e_grdat        = lv_grdat
    TABLES
      t_rng_bukrs    = lt_bukrs[]
      t_rng_cust     = lt_cust[]
      t_rng_vend     = lt_vend[]
      t_rng_cust_log = lt_log_kunnr[]
      t_rng_vend_log = lt_log_lifnr[]
      t_fldtab       = lt_fldtab[]
    EXCEPTIONS
      no_parameters  = 1
      OTHERS         = 2.

  IF sy-subrc EQ 0.
    SELECT  bukrs
            saknr  FROM  skb1                           "#EC CI_GENBUFF
                   INTO TABLE lt_konto
                   WHERE  bukrs  IN lt_bukrs
                   AND    mitkz  = 'D'.

    IF lt_konto IS NOT INITIAL.
      SELECT DISTINCT * FROM bsid_view INTO CORRESPONDING FIELDS OF TABLE @lt_bsid
                 FOR ALL ENTRIES IN @lt_konto
                 WHERE bukrs IN @lt_bukrs
                 AND   kunnr IN @lt_cust
                 AND   hkont EQ @lt_konto-hkont
                 AND   budat <= @lv_grdat.
      DELETE lt_bsid WHERE manst NE 0.
      LOOP AT lt_bsid ASSIGNING FIELD-SYMBOL(<ls_bsid>).
        READ TABLE lt_iacctab TRANSPORTING NO FIELDS
                   WITH KEY bukrs = <ls_bsid>-bukrs
                            kunnr = <ls_bsid>-kunnr.
        CHECK sy-subrc NE 0.
        CLEAR: ls_iacctab, lt_mhnk, lt_mhnd.
        ls_iacctab-bukrs   = <ls_bsid>-bukrs.
        ls_iacctab-kunnr   = <ls_bsid>-kunnr.
        CALL FUNCTION 'GENERATE_DUNNING_DATA'
          EXPORTING
            i_laufd               = i_laufd
            i_laufi               = i_laufi
            i_bukrs               = <ls_bsid>-bukrs
            i_grdat               = lv_grdat
            i_ausdt               = lv_ausdt
            i_trace               = abap_true
            i_mout                = space
            i_ofi                 = abap_true
          TABLES
            t_mhnk                = lt_mhnk[]
            t_mhnd                = lt_mhnd[]
          CHANGING
            c_kunnr               = ls_iacctab-kunnr
            c_lifnr               = ls_iacctab-lifnr
          EXCEPTIONS
            customer_wo_procedure = 1
            customer_not_found    = 2
            customizing_error     = 3
            parameter_error       = 4
            OTHERS                = 5.
        IF sy-subrc = 0.

*         lock the account when mhnk entry is not empty
          DESCRIBE TABLE lt_mhnk LINES lv_lin.
          IF lv_lin <> 0.
            SORT lt_mhnk BY smaber.
            CLEAR: lv_dunn_it.
            LOOP AT lt_mhnk ASSIGNING FIELD-SYMBOL(<ls_mhnk>).
              SELECT * FROM mahns INTO ls_mahns
                UP TO 1 ROWS
                WHERE bukrs = <ls_mhnk>-bukrs
                  AND konko = <ls_mhnk>-kunnr
                  AND maber = <ls_mhnk>-smaber.
              ENDSELECT.
              IF sy-subrc EQ 0.
                lv_dunn_it = abap_false.
                APPEND ls_iacctab TO lt_iacctab.
                EXIT.
              ELSE.
                lv_dunn_it = abap_true.
                APPEND ls_iacctab TO lt_iacctab.
                EXIT.
              ENDIF.
            ENDLOOP.

          ENDIF.
          IF lv_dunn_it = space.
            DELETE lt_bsid WHERE kunnr = <ls_bsid>-kunnr.
            REFRESH lt_mhnk.
            REFRESH lt_mhnd.
          ENDIF.
        ENDIF.
      ENDLOOP.

      SORT lt_bsid BY kunnr.
      DELETE ADJACENT DUPLICATES FROM lt_bsid COMPARING kunnr.
      DESCRIBE TABLE lt_bsid LINES lv_lines.
    ENDIF.
    SELECT anzahl FROM /thkr/anz_mahndr INTO lv_anzahl.
*                  WHERE bukrs IN lt_bukrs.
      EXIT.  "Nur den 1. Eintrag
    ENDSELECT.
    IF sy-subrc EQ 0 AND lv_lines LE lv_anzahl.
      CONCATENATE 'Kein Mahnlauf, weil die Mindestdruckanzahl von' lv_anzahl 'unterschritten wurde' INTO lv_text SEPARATED BY space.
      MESSAGE lv_text TYPE 'E'.
    ENDIF.
  ENDIF.
ENDFUNCTION.
