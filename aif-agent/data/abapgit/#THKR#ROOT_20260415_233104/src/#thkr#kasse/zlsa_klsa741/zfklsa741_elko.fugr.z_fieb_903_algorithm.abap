FUNCTION z_fieb_903_algorithm .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_NOTE_TO_PAYEE) TYPE  STRING OPTIONAL
*"     REFERENCE(I_COUNTRY) TYPE  LAND1 OPTIONAL
*"  TABLES
*"      T_AVIP_IN STRUCTURE  AVIP OPTIONAL
*"      T_AVIP_OUT STRUCTURE  AVIP
*"      T_FILTER1 OPTIONAL
*"      T_FILTER2 OPTIONAL
*"----------------------------------------------------------------------

* This algorithm searches for numbers that
* are in T_FILTER1 (numeric document number Filter(BELNR)
* and checks then if for theses numbers cleared docuements exist
*"----------------------------------------------------------------------
  TYPES: BEGIN OF s_bkpf,
           bukrs TYPE bukrs,
           belnr TYPE bkpf-belnr,
           gjahr TYPE gjahr,
           blart TYPE bkpf-blart,
         END OF s_bkpf.

  TYPES: BEGIN OF ty_bvor,
           bvorg TYPE bvorg,
           bukrs TYPE bukrs,
           gjahr TYPE gjahr,
           belnr TYPE belnr_d,
         END OF ty_bvor.

  CONSTANTS: gc_off TYPE xfeld VALUE ' '.
  DATA l_xreversed TYPE  co_stokz.
  DATA: l_note_to_payee TYPE string,
        l_length        TYPE i,
        BEGIN OF belnr_tab OCCURS 10,
          belnr TYPE bkpf-belnr,
        END OF belnr_tab,
        l_belnr TYPE bkpf-belnr,
        l_xblnr TYPE bkpf-xblnr,
        r_gjahr TYPE RANGE OF gjahr WITH HEADER LINE,       "n1320997
        l_bukrs TYPE bukrs,                                 "n1320997
        r_bukrs TYPE RANGE OF bukrs WITH HEADER LINE,
        lt_bkpf TYPE STANDARD TABLE OF s_bkpf,
        l_t003  TYPE t003,
        l_bsad  TYPE bsad,
        l_bsak  TYPE bsak,
        l_bsas  TYPE bsas,                                  "n1320997
        lt_bsad TYPE STANDARD TABLE OF bsad,                "n1320997
        lt_bsak TYPE STANDARD TABLE OF bsak,                "n1320997
        lt_bsas TYPE STANDARD TABLE OF bsas,                "n1320997
        l_koart TYPE avip-koart,                            "n1390940
        l_loop  TYPE i.                                     "n1390940

  DATA: lv_augdt    TYPE augdt, "Repro-Roc: 08.02.2021
        lv_gjahr    TYPE gjahr,
        ls_avip_out TYPE avip. "Repro-Roc: 08.02.2021

  DATA: lt_kassz TYPE /thkr/tt_xblnr_ueb,
        lv_vwezw TYPE char30k.



  STATICS: s_gjahr      TYPE gjahr,                         "n1320997
           s_last_bukrs TYPE bukrs.

  FIELD-SYMBOLS: <bkpf>  TYPE s_bkpf,
                 <belnr> TYPE belnr.

  REFRESH t_avip_out.


*REPRO-ROC --> loop at r_bukrs geht damit nicht
*wegen exit wird hier nur der erste Bukrs aufgenommen
  LOOP AT t_avip_in WHERE bukrs <> space.
*the company code is passed by a line in t_avip_in
*if not, all company codes are searched
    r_bukrs-sign = 'I'.
    r_bukrs-option = 'EQ'.
    r_bukrs-low = t_avip_in-bukrs.
    APPEND r_bukrs.
*    l_koart = t_avip_in-koart.                              "n1390940
    EXIT.
  ENDLOOP.

  l_note_to_payee = i_note_to_payee.

  IF NOT l_note_to_payee IS INITIAL.
*reference information is free form, put it into good shape
*    CALL FUNCTION 'FIEB_EXTRACT_NUMBERS'
*      EXPORTING
*        i_note_to_payee = l_note_to_payee
*      TABLES
*        e_numbers       = belnr_tab.
    DATA(lr_elko) = NEW /thkr/cl_elko_appl( ).
    CLEAR: lt_kassz, lv_vwezw.
    lv_vwezw = i_note_to_payee.
    lr_elko->search_kassenz_ueb_belnr( EXPORTING iv_vwezw = lv_vwezw
                                       CHANGING  xt_kassz = lt_kassz ).

    LOOP AT lt_kassz ASSIGNING FIELD-SYMBOL(<ls_kassz>).
      APPEND    <ls_kassz>+4(10) TO belnr_tab.
      s_gjahr = <ls_kassz>+14(4).
    ENDLOOP.

    SORT belnr_tab.
    DELETE ADJACENT DUPLICATES FROM belnr_tab.
  ENDIF.

  LOOP AT r_bukrs.                                          "n1320997
    IF s_last_bukrs NE r_bukrs-low.
      IF s_gjahr IS NOT INITIAL.
        s_last_bukrs = r_bukrs-low.
        r_gjahr-sign = 'I'.
        r_gjahr-option = 'EQ'.
        r_gjahr-low = s_gjahr.
        APPEND r_gjahr.
      ENDIF.
*      CALL FUNCTION 'FI_PERIOD_DETERMINE'
*        EXPORTING
*          i_budat        = sy-datum
*          i_bukrs        = r_bukrs-low
*        IMPORTING
*          e_gjahr        = s_gjahr
*        EXCEPTIONS
*          fiscal_year    = 1
*          period         = 2
*          period_version = 3
*          posting_period = 4
*          special_period = 5
*          version        = 6
*          posting_date   = 7
*          OTHERS         = 8.
*      IF sy-subrc NE 0.
*        EXIT.
*      ELSE.
*        s_last_bukrs = r_bukrs-low.
*      ENDIF.
*    ENDIF.
*    IF NOT s_gjahr IS INITIAL.
*      r_gjahr-sign = 'I'.
*      r_gjahr-option = 'EQ'.
*      r_gjahr-low = s_gjahr.
*      APPEND r_gjahr.
*
*      r_gjahr-low = s_gjahr - 1.
*      APPEND r_gjahr.
    ENDIF.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM r_gjahr.
  IF lines( r_gjahr ) EQ 0. EXIT. ENDIF.

*--- Suche nach buchungskreisübergreifenden Belegnummern ---*
  DATA: lv_bvorg TYPE bkpf-bvorg.
* data: lt_bvor  type table of bvor.
  DATA: lt_bvor  TYPE STANDARD TABLE OF ty_bvor,
        ls_bvor  TYPE ty_bvor,
        lt_bvor2 TYPE STANDARD TABLE OF ty_bvor.
  DATA: BEGIN OF lt_belnr_tab OCCURS 10,
          belnr TYPE bkpf-belnr,
        END OF lt_belnr_tab.



  SELECT v~bvorg,
         v~bukrs,
         v~gjahr,
         v~belnr
   FROM bvor AS v
        INNER JOIN bkpf AS b ON b~bvorg = v~bvorg FOR ALL ENTRIES IN @belnr_tab
              WHERE b~bukrs IN @r_bukrs[]
               AND  b~belnr = @belnr_tab-belnr
               AND b~gjahr IN @r_gjahr[]
               AND  v~xarch = @gc_off
               INTO TABLE @lt_bvor.

*-----------------------------------------------------------*
  SORT lt_bvor BY gjahr DESCENDING.

*-----------------------------------------------------------*
  LOOP AT belnr_tab.
    CHECK belnr_tab IN t_filter1.

    CLEAR l_loop.                                           "n1390940
    DO 3 TIMES.
      l_loop = l_loop + 1.

*      IF ( l_loop = 1 AND l_koart = 'D' ) OR
*         ( l_loop = 2 AND l_koart = 'K').
      IF l_loop = 1 OR l_loop = 2.
        " Try debitor/customer
        CHECK lt_bvor IS NOT INITIAL.
        SELECT * FROM bsad INTO TABLE lt_bsad
          FOR ALL ENTRIES IN lt_bvor
*          WHERE bukrs IN r_bukrs
          WHERE bukrs = lt_bvor-bukrs
          AND   belnr = belnr_tab-belnr
          AND   gjahr IN r_gjahr.

        IF sy-subrc = 0.
          SORT lt_bsad DESCENDING BY gjahr.
          LOOP AT lt_bsad INTO l_bsad.
            t_avip_out-koart       = 'D'.
            t_avip_out-konto       = l_bsad-kunnr.
            t_avip_out-bukrs       = l_bsad-bukrs.
            t_avip_out-sfeld       = 'BELNR'.
            t_avip_out-swert       = l_bsad-belnr.
            t_avip_out-swert+10(4) = l_bsad-gjahr.
            APPEND t_avip_out.
            EXIT.
          ENDLOOP.
*          EXIT.   "item found: exit do
        ENDIF.

      ENDIF.

*      IF ( l_loop = 1 AND l_koart = 'K' ) OR
*         ( l_loop = 2 AND l_koart = 'D').
      IF l_loop = 1 OR l_loop = 2.
        CHECK lt_bsad IS NOT INITIAL.
        "Try Kreditor/vendor
        CHECK lt_bvor IS NOT INITIAL.
        SELECT * FROM bsak INTO TABLE lt_bsak
          FOR ALL ENTRIES IN lt_bvor
*          WHERE bukrs IN r_bukrs
          WHERE bukrs = lt_bvor-bukrs
          AND   belnr = belnr_tab-belnr
          AND   gjahr IN r_gjahr.

        IF sy-subrc = 0.
          SORT lt_bsak DESCENDING BY gjahr.
          LOOP AT lt_bsak INTO l_bsak.
            t_avip_out-koart       = 'K'.
            t_avip_out-konto       = l_bsak-lifnr.
            t_avip_out-bukrs       = l_bsak-bukrs.
            t_avip_out-sfeld       = 'BELNR'.
            t_avip_out-swert       = l_bsak-belnr.
            t_avip_out-swert+10(4) = l_bsak-gjahr.
            APPEND t_avip_out.
            EXIT.
          ENDLOOP.
*          EXIT.   "item found exit do
        ENDIF.
      ENDIF.

      IF l_loop = 3.
        CLEAR ls_avip_out.
        "Try Sachkonto/G/L
        CHECK lt_bvor IS NOT INITIAL.
        SELECT * FROM bsas INTO TABLE lt_bsas
          FOR ALL ENTRIES IN lt_bvor
*           WHERE bukrs IN r_bukrs
           WHERE bukrs = lt_bvor-bukrs
           AND   belnr = belnr_tab-belnr
           AND   gjahr IN r_gjahr.
        IF sy-subrc = 0.
          SORT lt_bsas DESCENDING BY gjahr augdt.
          LOOP AT lt_bsas INTO l_bsas.
* es könnte eine Überschneidung zum nächsten Satz geben
            ls_avip_out-koart       = 'S'.
            ls_avip_out-sfeld       = 'BELNR'.
            ls_avip_out-swert       = l_bsas-belnr.
            ls_avip_out-swert+10(4) = l_bsas-gjahr.
* es könnte eine Überschneidung zum nächsten Satz geben
*            noch nicht ergänzen
*            append ls_avip_out to t_avip_out.
            EXIT.
          ENDLOOP.
*          exit.   "item found exit do
        ENDIF.



* beim Sachkonto Fall - prüfen, ob der 2. Beleg aus BVOR- falls vorhanden einen Ausgleich
* hat ->
        LOOP AT lt_bvor INTO ls_bvor WHERE bvorg(10)  =  belnr_tab-belnr.
*                       AND belnr NE  belnr_tab-belnr.
          "Try Sachkonto/G/L
          SELECT * FROM bsas INTO TABLE lt_bsas
             WHERE bukrs = ls_bvor-bukrs
             AND   belnr = ls_bvor-belnr
             AND   gjahr = ls_bvor-gjahr.

          IF sy-subrc = 0.
            SORT lt_bsas DESCENDING BY gjahr.
            LOOP AT lt_bsas INTO l_bsas.
              t_avip_out-koart       = 'S'.
              t_avip_out-sfeld       = 'BELNR'.
              t_avip_out-swert       = ls_bvor-bvorg(10).
              t_avip_out-swert+10(4) = ls_bvor-gjahr.
*nur falls die sich unterscheiden
              IF ls_avip_out NE t_avip_out.
* jetzt noch schauen, ob es Überschneidungen zum Beleg gibt
                IF ls_avip_out-swert(10) = t_avip_out-swert(10).
                  IF ls_avip_out-swert+10(4) GE t_avip_out-swert+10(4).
                    APPEND ls_avip_out TO t_avip_out.
                  ELSE.
                    APPEND  t_avip_out.
                  ENDIF.
                ELSE.
                  IF ls_avip_out IS NOT INITIAL.
                    APPEND ls_avip_out TO t_avip_out.
                  ENDIF.
                  APPEND  t_avip_out.
                ENDIF.
              ELSE. "identisch
                APPEND  t_avip_out.
              ENDIF.
              EXIT.
            ENDLOOP.
*Frage - brauchen wir das Original auch noch???

* nur wenn dieser Eintrag einen Ausgleich hat --> aufnehmen
* GJahr ggf noch vereinfachen
            SELECT * FROM bsas INTO TABLE lt_bsas
                  WHERE bukrs = ls_bvor+10(4)
                  AND   belnr = ls_bvor(10)
                  AND   gjahr = ls_bvor-gjahr.

            IF sy-subrc = 0.
              SORT lt_bsas DESCENDING BY augdt.

              LOOP AT lt_bsas INTO l_bsas WHERE augbl IS NOT INITIAL.
                lv_augdt = l_bsas-augdt.
                CALL FUNCTION 'FI_PERIOD_DETERMINE'
                  EXPORTING
                    i_budat        = lv_augdt
                    i_bukrs        = l_bsas-bukrs
                  IMPORTING
                    e_gjahr        = lv_gjahr
                  EXCEPTIONS
                    fiscal_year    = 1
                    period         = 2
                    period_version = 3
                    posting_period = 4
                    special_period = 5
                    version        = 6
                    posting_date   = 7
                    OTHERS         = 8.
                IF sy-subrc NE 0.
                  lv_gjahr =  l_bsas-gjahr.
                ENDIF.
                t_avip_out-koart       = 'S'.
                t_avip_out-sfeld       = 'BELNR'.
                t_avip_out-bukrs       = l_bsas-bukrs.
                t_avip_out-swert       = l_bsas-augbl.
                t_avip_out-swert+10(4) = lv_gjahr.
                t_avip_out-swert+14(1) = 'A'.
                APPEND  t_avip_out.
                EXIT.
              ENDLOOP.
            ENDIF.
            EXIT. "item found, bvor -> exit
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDDO.    "do 3 times.
  ENDLOOP. "belnr

ENDFUNCTION.
